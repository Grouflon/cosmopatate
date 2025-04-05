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
player: PlayerState;

main :: ()
{
    yae_init(YAE_COMPILE_TIME_INFO, 800, 600, "cosmopatate");
    defer yae_shutdown();

    // Load data
    cosomonaut_aseprite, success1: = resource_load(AsepriteFile, "./data/aseprite/cosmonaut.json");
    resource_save_to_disk(cosomonaut_aseprite, "./data/aseprite/cosmonaut.json.res");
    defer resource_unload(cosomonaut_aseprite);

    player.idle_animation = get_animation(cosomonaut_aseprite, "idle");
    player.walk_animation = get_animation(cosomonaut_aseprite, "walk");

    yae_loop(
        // Update
        (dt: float) 
        {
            player_update(*player, dt);
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
                player_draw(*player);
            }

            rl.ClearBackground(rl.RED);

            viewport_draw(viewport);
            rl.DrawText("Congrats! You created your first window!", rl.GetScreenWidth() / 2 - 190, 200, 20, rl.LIGHTGRAY);
        }
    );
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

// === Imports ===
#scope_file

#import "Math";
rl :: #import "raylib";
ImGui :: #import,dir "../modules/yae/modules/ImGui";

// Yae mandatory imports
#import "Basic"()(MEMORY_DEBUGGER = YAE_DEBUG_MEMORY);
#import "yae";