// === Build Parameters ===
DEBUG_MEMORY :: (OS != .WASM);

EditorState :: struct
{
    app_window_rect: IntRect = .{0, 30, 800, 600};
    console_window_rect: IntRect = .{50, 80, 800, 600};

    resources_open: bool;
    imgui_demo_open: bool;
}
editor_state : EditorState;
editor_settings_save_requested: = false;
EDITOR_SETTINGS_PATH :: "temp/editor_settings.json";

// Player
PlayerState :: struct
{
    x: = 0.0;
    flip: = false;
    speed: = 15.0;
    animation_player: AnimationPlayer;

    idle_animation: *Animation;
    walk_animation: *Animation;
}

viewport: PixelPerfectViewport = .{
    min_render_width = 300,
    min_render_height = 200,
    min_pixel_ratio = 1,
    max_pixel_ratio = 3,
};

player_update :: (using player: *PlayerState, dt: float)
{
    // Input
    direction: = 0.0;
    if (rl.IsKeyDown(.KEY_RIGHT))
    {
        direction += 1.0;
    }
    if (rl.IsKeyDown(.KEY_LEFT))
    {
        direction -= 1.0;
    }

    // Move
    x += direction * speed * dt;
    if direction > 0
    {
        flip = false;
    }
    else if direction < 0
    {
        flip = true;
    }

    // Animation
    if direction == 0
    {
        animation_player_play(*animation_player, idle_animation);
    }
    else
    {
        animation_player_play(*animation_player, walk_animation);
    }
    animation_player_update(*animation_player, dt);
}

player_draw :: (using player: *PlayerState)
{
    animation_player_draw(*animation_player, .{floor(x), 0}, flip);
}

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
        window_flags |= .FLAG_WINDOW_RESIZABLE;
        rl.InitWindow(800, 600, "cosmopatate");
        rl.SetWindowState(xx window_flags);
        rl.SetTargetFPS(60);
        rl.SetExitKey(.KEY_NULL);
        defer rl.CloseWindow();

        // Set windows positions
        if read_json_file(EDITOR_SETTINGS_PATH, *editor_state)
        {
            set_window_rect(rl.GetWindowHandle(), editor_state.app_window_rect);
            set_window_rect(get_console_window_handle(), editor_state.console_window_rect);
        }
        

        // Init shit
        raylib_imgui_init();
        defer raylib_imgui_shutdown();

        resource_manager_init(resource_types, "data");
        defer resource_manager_shutdown();

        // Load data
        cosomonaut_aseprite, success1: = resource_load(AsepriteFile, "./data/aseprite/cosmonaut.json");
        resource_save_to_disk(cosomonaut_aseprite, "./data/aseprite/cosmonaut.json.res");
        defer resource_unload(cosomonaut_aseprite);

        player: PlayerState;
        player.idle_animation = get_animation(cosomonaut_aseprite, "idle");
        player.walk_animation = get_animation(cosomonaut_aseprite, "walk");

        // Loop
        while !rl.WindowShouldClose()
        {
            reset_temporary_storage();
            dt: = rl.GetFrameTime();
            prev_editor_state: = editor_state;

            editor_state.app_window_rect = get_window_rect(rl.GetWindowHandle());
            editor_state.console_window_rect = get_window_rect(get_console_window_handle());

            // Update
            {
                resource_manager_update();

                raylib_imgui_new_frame(dt);

                player_update(*player, dt);
                viewport_update(*viewport);

                if (editor_state.imgui_demo_open)
                {
                    ImGui.ShowDemoWindow(*editor_state.imgui_demo_open);
                }

                if ImGui.BeginMainMenuBar()
                {
                    if ImGui.BeginMenu("Windows")
                    {
                        ImGui.MenuItem("Resources", "", *editor_state.resources_open);
                        ImGui.MenuItem("ImGui Demo", "", *editor_state.imgui_demo_open);

                        ImGui.EndMenu();
                    }
                }
                ImGui.EndMainMenuBar();

                prev_resources_open: = editor_state.resources_open;
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
                {
                    viewport_begin_render(viewport);
                    defer viewport_end_render(viewport);

                    rl.ClearBackground(rl.RAYWHITE);
                    rl.DrawRectangle(-1000, -1000, 2000, 1000, rl.LIGHTGRAY);
                    player_draw(*player);
                }

                rl.BeginDrawing();
                defer rl.EndDrawing();

                rl.ClearBackground(rl.RED);

                viewport_draw(viewport);
                rl.DrawText("Congrats! You created your first window!", rl.GetScreenWidth() / 2 - 190, 200, 20, rl.LIGHTGRAY);

                raylib_imgui_render();
                rl.DrawFPS(rl.GetScreenWidth() - 90, 10);
            }

            editor_settings_save_requested = memcmp(*prev_editor_state, *editor_state, size_of(EditorState)) != 0;
            if editor_settings_save_requested
            {
                editor_settings_save_requested = false;

                editor_state.app_window_rect = get_window_rect(rl.GetWindowHandle());
                editor_state.console_window_rect = get_window_rect(get_console_window_handle());

                make_directory_if_it_does_not_exist(get_directory(EDITOR_SETTINGS_PATH), true);
                write_json_file(EDITOR_SETTINGS_PATH, *editor_state);
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
#import "File";

#import "Math";
#import "yae";
rl :: #import "raylib";
ImGui :: #import,dir "../modules/yae/modules/ImGui";