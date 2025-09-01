resources: struct
{
    cosmonaut_aseprite: AsepriteFile = .{ path = "./data/aseprite/cosmonaut.json" };
    cosmonaut_texture: TextureFile = .{ path = "./data/aseprite/cosmonaut.png" };

    cosmonaut_idle: Animation = .{ path = "./data/animations/cosmonaut_idle.res" };
    cosmonaut_jump: Animation = .{ path = "./data/animations/cosmonaut_jump.res" };
    cosmonaut_walk: Animation = .{ path = "./data/animations/cosmonaut_walk.res" };
    cosmonaut_punch: Animation = .{ path = "./data/animations/cosmonaut_punch.res" };
    cosmonaut_hit: Animation = .{ path = "./data/animations/cosmonaut_hit.res" };
};



// Viewport
viewport: PixelPerfectViewport = .{
    min_render_width = 300,
    min_render_height = 200,
    min_pixel_ratio = 1,
    max_pixel_ratio = 3,
};

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

    yae_init(*YAE_COMPILE_TIME_INFO, 800, 600, "cosmopatate");
    defer yae_shutdown();

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

            viewport_update(*viewport);
        },
        // Draw
        ()
        {
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
            }

            rl.ClearBackground(rl.RED);

            viewport_draw(viewport);
            rl.DrawText("Congrats! You created your first window!", rl.GetScreenWidth() / 2 - 190, 200, 20, rl.LIGHTGRAY);
        }
    );
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
