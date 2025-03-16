// === Build Parameters ===
DEBUG_MEMORY :: (OS != .WASM);

// Editor
debugger_handle : *void;
EditorState :: struct
{
    app_window_rect: IntRect = .{0, 30, 800, 600}; @serialize
    console_window_rect: IntRect = .{50, 80, 800, 600}; @serialize
    debugger_window_rect: IntRect = .{50, 80, 800, 600}; @serialize

    resources_open: bool; @serialize
    imgui_demo_open: bool; @serialize

    animation_editor_open: bool; @serialize
}

editor_state : EditorState;
editor_settings_save_requested: = false;
DEFAULT_SERIALIZATION_PARAMS :: SerializationParams.{ filters = .[.{ .IN, type_info(EditorState), "serialize" }]};
EDITOR_SETTINGS_PATH :: "temp/editor_settings.json";

// Viewport
viewport: PixelPerfectViewport = .{
    min_render_width = 300,
    min_render_height = 200,
    min_pixel_ratio = 1,
    max_pixel_ratio = 3,
};

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

// Animation Editor
AnimationEditor :: struct
{
    player: AnimationPlayer;
    viewport: ViewportBase;
    is_dragging: = false;
}
animation_editor: AnimationEditor;

animation_editor_init :: (using editor: *AnimationEditor, animation: *Animation)
{
    animation_player_set_animation(*player, animation);
    viewport = .{};
}

animation_editor_update :: (using editor: *AnimationEditor, dt: float)
{
    dockspace_id: = ImGui.GetID("animation_dockspace");
    animation_editor_window_class: = ImGui.WindowClass.{ ClassId = dockspace_id };
    dockspace_size: = ImGui.GetContentRegionAvail();

    if ImGui.DockBuilderGetNode(dockspace_id) == null
    {
        ImGui.DockBuilderRemoveNode(dockspace_id); // Clear out existing layout
        ImGui.DockBuilderAddNode(dockspace_id, cast(ImGui.DockNodeFlags) ImGui.DockNodeFlagsPrivate_.DockNodeFlags_DockSpace); // Add empty node
        ImGui.DockBuilderSetNodeSize(dockspace_id, dockspace_size);

        dock_main_id: = dockspace_id; // This variable will track the document node, however we are not using it here as we aren't docking anything into it.
        dock_id_prop: = ImGui.DockBuilderSplitNode(dock_main_id, .ImGuiDir_Right, 0.20, null, *dock_main_id);
        dock_id_bottom: = ImGui.DockBuilderSplitNode(dock_main_id, .ImGuiDir_Down, 0.20, null, *dock_main_id);

        ImGui.DockBuilderDockWindow("Properties", dock_id_prop);
        ImGui.DockBuilderDockWindow("Timeline", dock_id_bottom);
        ImGui.DockBuilderDockWindow("Viewport", dock_main_id);
        ImGui.DockBuilderFinish(dockspace_id);
    }
    else
    {
        ImGui.DockSpace(dockspace_id, *dockspace_size, window_class = *animation_editor_window_class);
    }

    ImGui.SetNextWindowClass(*animation_editor_window_class);
    if ImGui.Begin("Properties", null)
    {
        ImGui.Text("props");
    }
    ImGui.End();

    ImGui.SetNextWindowClass(*animation_editor_window_class);
    if ImGui.Begin("Timeline", null)
    {
        if !player.is_playing
        {
            if ImGui.Button("Play")
            {
                animation_player_play(*player);
            }
        }
        else
        {
            if ImGui.Button("Stop")
            {
                animation_player_stop(*player);
            }
        }
        
        ImGui.Text("time");
    }
    ImGui.End();

    ImGui.SetNextWindowClass(*animation_editor_window_class);
    if ImGui.Begin("Viewport", null)
    {
        init_viewport: bool = viewport.render_target.id == 0;

        viewport_size: = ImGui.GetContentRegionAvail();
        viewport_screen_origin: = ImGui.GetCursorScreenPos();
        viewport_update(*viewport, viewport_size);
        ImGui.Image(viewport.render_target.texture.id, viewport_size);

        // Initialize
        if init_viewport
        {
            i, frame: = animation_player_current_frame(*player);
            sprite_size: = size(frame.sprite.bounds);

            editor.viewport.target = .{100,100};
            // viewport_align_points(*editor.viewport, viewport_size * 0.1, .{0, sprite_size.y}, viewport_size * 0.9, .{viewport_size.x, 0}, true);
        }
        else
        {
            viewport.size = viewport_size;
        }

        DRAG_BUTTON :: ImGui.MouseButton.Middle;
        drag_button_pressed: = ImGui.IsMouseClicked(DRAG_BUTTON);
        drag_button_down: = ImGui.IsMouseDown(DRAG_BUTTON);
        mouse_viewport_position: = ImGui.GetIO().MousePos - viewport_screen_origin;
        if ImGui.IsItemHovered()
        {
            ZOOM_STEP :: 0.5;
            wanted_zoom: = clamp(editor.viewport.zoom + xy(ZOOM_STEP * ImGui.GetIO().MouseWheel), 0.5, 10.0);
            viewport_set_zoom_focused(*editor.viewport, mouse_viewport_position, wanted_zoom);
            if drag_button_pressed { editor.is_dragging = true; }
        }

        if !drag_button_down
        {
            editor.is_dragging = false;
        }

        if editor.is_dragging
        {
            d: = ImGui.GetMouseDragDelta(DRAG_BUTTON, 0);
            ImGui.ResetMouseDragDelta(DRAG_BUTTON);
            viewport_pan(*editor.viewport, d);
        }
    }
    ImGui.End();

    animation_player_update(*player, dt);

    // Draw viewport
    viewport_begin_render(*editor.viewport);
    defer viewport_end_render(*editor.viewport);

    rl.ClearBackground(rl.LIGHTGRAY);

    // Draw Grid
    {
        GRID_STEP :: 100.0;
        viewport_min: = viewport_to_world_position(*editor.viewport, .{0, editor.viewport.size.y});
        viewport_max: = viewport_to_world_position(*editor.viewport, .{editor.viewport.size.x, 0});
        viewport_range: = viewport_max - viewport_min;
        viewport_start: = viewport_min - .{fmod_cycling(viewport_min.x, GRID_STEP), fmod_cycling(viewport_min.y, GRID_STEP)};
        cells_count_h: = floor_to_s32(viewport_range.x / GRID_STEP) + 1;
        cells_count_v: = floor_to_s32(viewport_range.y / GRID_STEP) + 1;

        // Vertical lines
        for i: 0.. cells_count_h
        {
            start: = viewport_start + .{xx i * GRID_STEP, 0};
            color: = ifx abs(start.x) < rl.EPSILON then rl.GREEN else rl.GRAY;
            rl.DrawLineV(start, .{start.x, viewport_max.y}, color);
        }

        // Horizontal lines
        for i: 0.. cells_count_v
        {
            start: = viewport_start + .{0, xx i * GRID_STEP};
            color: = ifx abs(start.y) < rl.EPSILON then rl.RED else rl.GRAY;
            rl.DrawLineV(start, .{viewport_max.x, start.y}, color);
        }
    }

    animation_player_draw(*player, .{});
}

// === Main ===
main :: ()
{
    debugger_handle = find_window_by_title_containing("RemedyBG");
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
        if read_json_file(EDITOR_SETTINGS_PATH, *editor_state, DEFAULT_SERIALIZATION_PARAMS)
        {
            set_window_rect(rl.GetWindowHandle(), editor_state.app_window_rect);
            set_window_rect(get_console_window_handle(), editor_state.console_window_rect);
            set_window_rect(debugger_handle, editor_state.debugger_window_rect);
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

        // Init animation editor
        animation_editor_init(*animation_editor, player.walk_animation);

        // Loop
        while !rl.WindowShouldClose()
        {
            reset_temporary_storage();
            dt: = rl.GetFrameTime();
            prev_editor_state: = editor_state;

            editor_state.app_window_rect = get_window_rect(rl.GetWindowHandle());
            editor_state.console_window_rect = get_window_rect(get_console_window_handle());
            editor_state.debugger_window_rect = get_window_rect(debugger_handle);

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
                        ImGui.MenuItem("Animation Editor", "", *editor_state.animation_editor_open);
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

                if editor_state.animation_editor_open
                {
                    if ImGui.Begin("Animation Editor", *editor_state.animation_editor_open)
                    {
                        animation_editor_update(*animation_editor, dt);
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
                make_directory_if_it_does_not_exist(get_directory(EDITOR_SETTINGS_PATH), true);
                write_json_file(EDITOR_SETTINGS_PATH, *editor_state, DEFAULT_SERIALIZATION_PARAMS);
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