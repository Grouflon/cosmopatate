#run build();

BUILD_NAME :: "cosmopatate";
BUILD_OUTPUT_DIRECTORY :: "bin";

build :: ()
{
    // No executable for this workspace.
    set_build_options_dc(.{do_output=false});

    // Read arguments
    args := get_build_options().compile_time_command_line;

    compile := array_find(args, "compile");
    run := array_find(args, "run");
    debug := array_find(args, "debug");
    wasm := array_find(args, "wasm");
    optimize := array_find(args, "optimize");

    // Set build type
    os_target: Operating_System_Tag = OS;
    if wasm { os_target = .WASM; }

    // Make bin directory
    make_directory_if_it_does_not_exist(BUILD_OUTPUT_DIRECTORY, recursive = true);

    // Kill previous process
    #if OS == .WINDOWS
    {
        exe_path: = tprint("%/%.exe", BUILD_OUTPUT_DIRECTORY, BUILD_NAME);
        kill_process_by_path(exe_path);
    }

    // Compile
    if compile
    {
        w := compiler_create_workspace(BUILD_NAME);
        
        // Build Options
        options := get_build_options();
        copy_commonly_propagated_fields(get_build_options(), *options);

        options.output_type = .EXECUTABLE;
        options.os_target = os_target;
        options.emit_debug_info = .DEFAULT;
        options.output_path = BUILD_OUTPUT_DIRECTORY;
        options.output_executable_name = BUILD_NAME;

        if options.os_target ==
        {
            case .WINDOWS;
            {
                options.use_natvis_compatible_types = true;
            }

            case .WASM;
            {
                options.backend                             = .LLVM; // WASM only works with the LLVM backend, obviously.
                options.cpu_target                          = .CUSTOM;
                options.backtrace_on_crash                  = .OFF; // Runtime_Support_Crash_Handler doesn’t support WASM (yet?)
                options.llvm_options.enable_split_modules   = false;
                options.llvm_options.function_sections      = true; // To get around "LLVM ERROR: section already has a defining function: .text"

                // This was compiled from https://github.com/wingo/walloc via "clang -Oz --target=wasm64 -nostdlib -c -o walloc.o walloc.c".
                // We should probably port this allocator to Jai instead…
                //  -rluba, 2023-11-15
                walloc_object_file_path := tprint("%/examples/wasm/walloc.o", compiler_get_base_path());
                print("%\n", walloc_object_file_path);
                options.output_executable_name = tprint("%0%0064", BUILD_NAME);

                STACK_SIZE :: 24 * 1024;
                options.additional_linker_arguments = .[
                    "--stack-first", "-z", tprint("stack-size=%", STACK_SIZE),
                    "--export-table",
                    "--export-all",
                    walloc_object_file_path,
                ];

                import_path : [..]string;
                array_add(*import_path, ..options.import_path);
                array_add(*import_path, ...[
                    tprint("%/examples/wasm/modules", compiler_get_base_path()),
                ]);
                options.import_path = import_path;

                options.llvm_options.target_system_features = "+bulk-memory"; // "This options is needed so that "memcpy" and "memset" are mapped to "memory.copy" and "memory.fill" instructions in WASM.

                // Replace the default allocator with Walloc (https://github.com/wingo/walloc).
                remap_import(w, "*", "Default_Allocator", "Walloc");
            }
        }

        set_optimization(*options, ifx optimize then .OPTIMIZED else .DEBUG);

        set_build_options(options, w);
        
        log("Compiling...");
        error_count: = 0;
        resource_types: [..]*Type_Info_Struct;
        generated_resource_types: = false;

        compiler_begin_intercept(w);
        add_build_file("src/main.jai", w);
        while true
        {
            message: = compiler_wait_for_message();
            if message.kind == {
                case .ERROR; error_count += 1;

                case .TYPECHECKED;
                {
                    mt := cast(*Message_Typechecked) message;
                    for st: mt.structs
                    {
                        struct_type_info: = st.expression.defined_type;

                        if is_subclass_of(struct_type_info, "Resource")
                        {
                            array_add(*resource_types, struct_type_info);
                        }
                    }
                }

                case .PHASE;
                {
                    mp := cast(*Message_Phase) message;

                    if mp.phase ==
                    {
                        case .TYPECHECKED_ALL_WE_CAN;
                        {
                            if !generated_resource_types
                            {
                                sb: String_Builder;
                                init_string_builder(*sb);
                                append(*sb, "resource_types: []*Type_Info_Struct = .[");
                                for struct_type_info, i: resource_types
                                {
                                    if i > 0 append(*sb, ",");
                                    append(*sb, tprint("type_info(%)", struct_type_info.name));
                                }
                                append(*sb, "];");

                                add_build_string(builder_to_string(*sb), w);
                                generated_resource_types = true;
                            }
                        }

                        case .POST_WRITE_EXECUTABLE;
                        {
                            // Post compilation steps
                            {
                                if os_target ==
                                {
                                    case .WASM;
                                    {
                                        // Convert wasm64 to wasm32
                                        wasm64_path: = tprint("./%1/%2%0064.wasm", BUILD_OUTPUT_DIRECTORY, BUILD_NAME);
                                        wasm32_path: = tprint("./%1/%2.wasm", BUILD_OUTPUT_DIRECTORY, BUILD_NAME);
                                        cmd := string.["./modules/yae/thirdparty/wasm64232.exe", "-o", wasm32_path, wasm64_path];
                                        log("%", cmd);
                                        run_command(..cmd, capture_and_return_output= true, print_captured_output= true);
                                        file_delete(wasm64_path);
                                    }

                                    case .WINDOWS;
                                    {
                                        copy_file_if_newer("./modules/raylib/windows/raylib.dll", tprint("%/raylib.dll", BUILD_OUTPUT_DIRECTORY));
                                    }
                                }
                            }
                        }
                    }
                }

                case .COMPLETE; break;
            }
        }
        compiler_end_intercept(w);
        if error_count != 0
        {
            log(tprint("Compilation failed with % error% :@", error_count, ifx error_count > 1 then "s" else ""));
            return;
        }
        log("Compilation completed without error :)");


        // Run
        if os_target == .WINDOWS
        {
            if debug
            {
                cmd: []string = .[
                    "remedybg", "-g", "-q",
                    tprint("%.rdbg", BUILD_NAME),
                ];
                result, output_string: = run_command(..cmd, capture_and_return_output= true);
                print("\n");
                log(output_string);
            }
            else if run
            {
                process: Process;
                args: []string = .["cmd", "/C", "start", get_absolute_path(exe_path)];
                result: = create_process(*process, ..args, kill_process_if_parent_exits= false);
            }
        }
    }
}

#import "Basic";
#import "File";
#import "File_Utilities";
#import "Compiler";
#import "Process";
#import "yae";
