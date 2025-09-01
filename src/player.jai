
Player :: struct
{
    #as using _e: Entity;

    id: = 0;
    input: = 0.0;
    flip: = false;
    state: PlayerState = .NONE;

    animation_player: AnimationPlayer;

    hitboxes: [..]PoolID(Collider);
    hurtboxes: [..]PoolID(Collider);
    pushboxes: [..]PoolID(Collider);
}

PlayerState :: enum
{
    NONE;
    IDLE;
    WALK;
    PUNCH;
    HIT;
}

BOX_COUNT :: 16;

player_init :: (using player: *Player)
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

    player_set_state(player, .IDLE);
}

player_shutdown :: (using player: *Player)
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

player_update_pre_animation :: (using player: *Player, dt: float)
{
    // Input
    input = 0.0;
    punch: = false;
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

        punch = rl.IsKeyPressed(.KEY_SPACE);
    }

    if state ==
    {
        case .IDLE;
        {
            if punch
            {
                player_set_state(player, .PUNCH);
            }
            else if input != 0
            {
                player_set_state(player, .WALK);
            }
        }

        case .WALK;
        {
            if punch
            {
                player_set_state(player, .PUNCH);
            }
            else if input == 0
            {
                player_set_state(player, .IDLE);
            }
            else
            {
                flip = input < 0;
            }
        }

        case .PUNCH;
        {
            if animation_player.current_loop_count > 0
            {
                player_set_state(player, .IDLE);
            }
        }
    }
}

player_set_state :: (using player: *Player, new_state: PlayerState)
{
    if state == new_state return;

    if state ==
    {

    }

    state = new_state;

    if state ==
    {
        case .IDLE;
        {
            animation_player_play(*animation_player, *resources.cosmonaut_idle);
        }

        case .WALK;
        {
            flip = input < 0;
            animation_player_play(*animation_player, *resources.cosmonaut_walk);
        }

        case .PUNCH;
        {
            animation_player_play(*animation_player, *resources.cosmonaut_punch);
        }
    }
}

player_update_post_animation :: (using player: *Player, dt: float)
{
    // Move
    movement: = animation_player.current_movement * Vector2.{ifx flip then -1.0 else 1.0, 1.0};
    position += Vector3.{movement.x, movement.y, 0};

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
        if box.physics_layer ==
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

player_update_post_physics :: (using player: *Player, dt: float)
{

}

player_draw :: (using player: *Player)
{
    animation_player_draw(*animation_player, .{floor(position.x), floor(position.y)}, flip);
}