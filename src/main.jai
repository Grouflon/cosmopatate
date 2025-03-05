// === Build Parameters ===
DEBUG_MEMORY :: (OS != .WASM);

EditorState :: struct
{
    resources_open: bool;
}
editor_state : EditorState;

// === Main ===
main :: ()
{
    exe_directory: = path_strip_filename(get_path_of_running_executable());
    root_directory: = tprint("%/..", exe_directory);
    set_working_directory(root_directory);
    context.logger = yae_logger;
    log("working directory: %", get_working_directory());

    // Run application
    {
        // Init Window
        window_flags: rl.ConfigFlags;
        // window_flags |= .FLAG_WINDOW_RESIZABLE;
        rl.InitWindow(800, 600, "cosmopatate");
        rl.SetWindowState(xx window_flags);
        rl.SetTargetFPS(60);
        rl.SetExitKey(.KEY_NULL);
        defer rl.CloseWindow();

        // Init shit
        raylib_imgui_init();
        defer raylib_imgui_shutdown();

        resource_manager_init(resource_types, "data");
        defer resource_manager_shutdown();

        // Load data
        cosomonaut_aseprite, success: = resource_load(AsepriteFile, "./data/aseprite/cosmonaut.json");
        defer resource_unload(cosomonaut_aseprite);
        resource_save_to_disk(cosomonaut_aseprite, "./data/aseprite/cosmonaut.json.res");

        // Loop
        while !rl.WindowShouldClose()
        {
            reset_temporary_storage();

            dt: = rl.GetFrameTime();
            raylib_imgui_new_frame(dt);

            // Update
            {
                ImGui.ShowDemoWindow();

                if ImGui.BeginMainMenuBar()
                {
                    if ImGui.BeginMenu("Windows")
                    {
                        ImGui.MenuItem("Resources", "", *editor_state.resources_open);

                        ImGui.EndMenu();
                    }
                }
                ImGui.EndMainMenuBar();

                if editor_state.resources_open
                {
                    if ImGui.Begin("Resources", *editor_state.resources_open)
                    {
                        for resource : resource_manager().resources
                        {
                            ImGui.Text(resource.name);
                        }
                    }
                    ImGui.End();
                }

            }


            // Draw
            {
                rl.BeginDrawing();
                defer rl.EndDrawing();

                rl.ClearBackground(rl.RAYWHITE);
                rl.DrawText("Congrats! You created your first window!", 190, 200, 20, rl.LIGHTGRAY);
                raylib_imgui_render();
                rl.DrawFPS(rl.GetScreenWidth() - 90, 10);
            }
        }
    }

    // Memory leak check
    #if DEBUG_MEMORY
    {
        report: = make_leak_report();
        if report.sorted_summaries.count
        {
            log_error("\n=========\nMemory Leak!!\n=========");
            log_leak_report(report);
            assert(false);
        }
    }
}

// === Imports ===
#scope_file
#import "Basic"()(MEMORY_DEBUGGER = DEBUG_MEMORY);
#import "String";
#import "System";

#import "Math";
#import "yae";
rl :: #import "raylib";
ImGui :: #import "ImGui";