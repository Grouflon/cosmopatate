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
    #as using _e: Entity;

    id: = 0;
    input: = 0.0;
    flip: = false;
    speed: = 15.0;
    animation_player: AnimationPlayer;

    hitboxes: [..]PoolID(Collider);
    hurtboxes: [..]PoolID(Collider);
    pushboxes: [..]PoolID(Collider);
}
// players: [2]PlayerState;
players: Pool(PlayerState);
player1: *PlayerState;
player2: *PlayerState;


cosmonaut_idle_animation: *Animation;
cosmonaut_walk_animation: *Animation;

main :: ()
{
    pool_init(*players, 8, false);
    defer pool_shutdown(*players);

    yae_init(YAE_COMPILE_TIME_INFO, 800, 600, "cosmopatate");
    defer yae_shutdown();

    // Load data
    cosomonaut_aseprite, success1: = resource_load(AsepriteFile, "./data/aseprite/cosmonaut.json");
    resource_save_to_disk(cosomonaut_aseprite, "./data/aseprite/cosmonaut.json.res");
    defer resource_unload(cosomonaut_aseprite);

    cosmonaut_idle_animation = get_animation(cosomonaut_aseprite, "idle");
    cosmonaut_walk_animation = get_animation(cosomonaut_aseprite, "walk");

    physics_set_layer_response(0, 0, .COLLIDE);

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

                for *player: players
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

BOX_COUNT :: 16;

player_init :: (using player: *PlayerState)
{
    for i: 0..BOX_COUNT-1
    {
        pushbox_id: = physics_add_collider(player, 0);
        hurtbox_id: = physics_add_collider(player, 1);
        hitbox_id: = physics_add_collider(player, 2);

        get(pushbox_id).enabled = false;
        get(hurtbox_id).enabled = false;
        get(hitbox_id).enabled = false;

        array_add(*pushboxes, pushbox_id);
        array_add(*hurtboxes, hurtbox_id);
        array_add(*hitboxes, hitbox_id);
    }
}

player_shutdown :: (using player: *PlayerState)
{
    for i: 0..BOX_COUNT-1
    {
        physics_remove_collider(pushboxes[i]);
        physics_remove_collider(hurtboxes[i]);
        physics_remove_collider(hitboxes[i]);
    }

    array_reset(*hitboxes);
    array_reset(*hurtboxes);
    array_reset(*pushboxes);
}

player_update_pre_animation :: (using player: *PlayerState, dt: float)
{
    // Input
    input = 0.0;
    if id == 0
    {
        if (rl.IsKeyDown(.KEY_RIGHT))
        {
            input += 1.0;
        }
        if (rl.IsKeyDown(.KEY_LEFT))
        {
            input -= 1.0;
        }
    }

    // Animation
    if input == 0.0
    {
        animation_player_play(*animation_player, cosmonaut_idle_animation);
    }
    else
    {
        animation_player_play(*animation_player, cosmonaut_walk_animation);
        if input > 0
        {
            flip = false;
        }
        else if input < 0
        {
            flip = true;
        }
    }
}

player_update_post_animation :: (using player: *PlayerState, dt: float)
{
    // Move
    position.x += input * speed * dt;

    for i: 0..BOX_COUNT-1
    {
        get(pushboxes[i]).enabled = false;
        get(hurtboxes[i]).enabled = false;
        get(hitboxes[i]).enabled = false;
    }

    pushbox_count, hurtbox_count, hitbox_count: = 0;
    box_events: = animation_player_get_current_box_events(*animation_player);
    for box: box_events
    {
        pool: *[..]PoolID(Collider);
        count: *int;
        if box.layer ==
        {
            case 0;
            {
                pool = *pushboxes;
                count = *pushbox_count;
            }
            case 1;
            {
                pool = *hurtboxes;
                count = *hurtbox_count;
            }
            case 2;
            {
                pool = *hitboxes;
                count = *hitbox_count;
            }
        }
        collider: = get((<<pool)[<<count]);
        collider.enabled = true;
        collider.rect = box.rect;
        collider.rect.x -= positive_mod(position.x, 1.0);
        collider.rect.y -= positive_mod(position.y, 1.0);
        <<count += 1;
    }
}

player_update_post_physics :: (using player: *PlayerState, dt: float)
{

}

player_draw :: (using player: *PlayerState)
{
    animation_player_draw(*animation_player, .{floor(position.x), floor(position.y)}, flip);
}

// === Imports ===
#scope_file

#import "Math";
rl :: #import "raylib";
ImGui :: #import,dir "../modules/yae/modules/ImGui";

// Yae mandatory imports
#import "Basic"()(MEMORY_DEBUGGER = YAE_DEBUG_MEMORY);
#import "yae";