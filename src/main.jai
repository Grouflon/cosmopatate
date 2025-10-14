resources: struct
{
    cosmonaut_aseprite: AsepriteFile = .{ path = "./data/aseprite/cosmonaut.json" };
    cosmonaut_texture: TextureFile = .{ path = "./data/aseprite/cosmonaut.png" };

    cosmonaut_idle: Animation = .{ path = "./data/animations/cosmonaut_idle.res" };
    cosmonaut_jump: Animation = .{ path = "./data/animations/cosmonaut_jump.res" };
    cosmonaut_walk: Animation = .{ path = "./data/animations/cosmonaut_walk.res" };
    cosmonaut_punch: Animation = .{ path = "./data/animations/cosmonaut_punch.res" };
    cosmonaut_kick: Animation = .{ path = "./data/animations/cosmonaut_kick.res" };
    cosmonaut_hit: Animation = .{ path = "./data/animations/cosmonaut_hit.res" };

    post_process_shader: Shader = .{ vs_path = "", fs_path = "./data/shaders/post_process.fs" };
};

game_settings: struct
{
}

// Viewport
viewport: Viewport;

// Player
// players: [2]Player;
players: Pool(Player);
player1: *Player;
player2: *Player;

main :: ()
{
    register_resources(*resources);
    
    pool_init(*players, 8, false);
    defer pool_shutdown(*players);

    register_settings_section("game", *game_settings);
    defer unregister_settings_section("game");

    // rl.SetConfigFlags(xx rl.ConfigFlags.FLAG_MSAA_4X_HINT);

    yae_init(*YAE_COMPILE_TIME_INFO, 800, 600, "cosmopatate");
    defer yae_shutdown();
    rl.SetWindowMinSize(300, 200);

    load_all_resources();
    defer unload_all_resources();

    physics_set_layer_response(0, 0, .COLLIDE);
    physics_set_layer_response(0, 2, .OVERLAP);

    _:, player1= pool_add(*players);
    // player1 = *players[0];
    player_init(player1);
    defer player_shutdown(player1);

    _:, player2= pool_add(*players);
    // player2 = *players[1];
    player_init(player2);
    defer player_shutdown(player2);
    player2.id = 1;
    player2.position.x = 25;
    player2.flip = true;

    yae_loop(
        // Update
        (dt: float) 
        {
            // pre animation
            for *player: players
            {
                player_update_pre_animation(player, dt);
            }

            // animation
            for *player: players
            {
                animation_player_update(*player.animation_player, dt);
            }


            // post animation
            for *player: players
            {
                player_update_post_animation(player, dt);
            }

            physics_update(dt);

            // post physics
            for *player: players
            {
                player_update_post_physics(player, dt);
            }
        },
        // Draw
        ()
        {
            MIN_PIXEL_RATIO :: 1;
            MAX_PIXEL_RATIO :: 32;
            MIN_RENDER_WIDTH :: 300;
            MIN_RENDER_HEIGHT :: 200;

            ImGui_EditValue("game_settings", *game_settings);

            window_width: = rl.GetRenderWidth();
            window_height: = rl.GetRenderHeight();

            pixel_ratio: = xx min(window_width / MIN_RENDER_WIDTH, window_height / MIN_RENDER_HEIGHT);
            pixel_ratio = clamp(pixel_ratio, MIN_PIXEL_RATIO, MAX_PIXEL_RATIO);

            game_size: Vector2 = .{ cast(float)window_width / cast(float)pixel_ratio, cast(float)window_height / cast(float)pixel_ratio };
            final_size: Vector2 = .{ game_size.x * pixel_ratio, game_size.y * pixel_ratio };

            viewport_update(*viewport, game_size);
            game_size = size(viewport);

            source_rect: = Rect.{ 0.0, 0.0, game_size.x, game_size.y };
            target_rect: = Rect.{ 0.0, 0.0, final_size.x, final_size.y };

            world_mouse_position: = viewport_screen_to_world_position(*viewport, target_rect, rl.GetMousePosition());

            {
                viewport_begin_render(viewport);
                defer viewport_end_render(viewport);

                rl.ClearBackground(rl.RAYWHITE);

                rl.DrawRectangle(-1000, -1000, 2000, 1000, rl.LIGHTGRAY);

                for < *player: players
                {
                    player_draw(player);
                }

                editor_draw();

                // draw_antialiased_circle(world_mouse_position, 3 + normalized_sin(yae.time) * 7, rl.RED);
            }

            rl.ClearBackground(rl.RED);

            {
                shader_begin_draw(*resources.post_process_shader);
                defer shader_end_draw(*resources.post_process_shader);

                // shader_set_uniform(*resources.post_process_shader, "thickness", game_settings.thickness);
                shader_set_uniform(*resources.post_process_shader, "textureSize", game_size);
                shader_set_uniform(*resources.post_process_shader, "renderSize", final_size);

                rl.DrawTexturePro(viewport.render_texture.texture, <<(cast(*rl.Rectangle)*source_rect), <<(cast(*rl.Rectangle)*target_rect), .{0.0, 0.0}, 0.0, rl.WHITE);
            }

            rl.DrawText("Congrats! You created your first window!", rl.GetScreenWidth() / 2 - 190, 200, 20, rl.LIGHTGRAY);
        }
    );

    // @NOTE(remi): Do we even need that? for some reason this is not flagged as a leak
    // free_string_hash_repository();
}

#load "player.jai";

rl :: #import "raylib";
ImGui :: #import,dir "../modules/yae/modules/ImGui";

// Yae mandatory imports
#import "Basic"()(MEMORY_DEBUGGER = YAE_DEBUG_MEMORY);
#import "yae";

// === Imports ===
#scope_file

#import "Math";
