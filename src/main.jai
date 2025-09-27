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

POST_PROCESS_FS :: #string DONE
#version 330

// Input vertex attributes (from vertex shader)
in vec2 fragTexCoord;
in vec4 fragColor;

// Input uniform values
uniform sampler2D texture0;
uniform vec4 colDiffuse;

// Output fragment color
out vec4 finalColor;

// User uniforms
uniform vec2 renderSize;

const int SAMPLE_COUNT = 3;

float offset[SAMPLE_COUNT] = float[](0.0, 1.3846153846, 3.2307692308);
float weight[SAMPLE_COUNT] = float[](0.2270270270, 0.3162162162, 0.0702702703);

void main()
{
    // Texel color fetching from texture sampler

    vec4 baseColor = texture(texture0, fragTexCoord);
    vec3 texelColor = baseColor.rgb*weight[0];

    for (int i = 1; i < SAMPLE_COUNT; i++)
    {
        texelColor += texture(texture0, fragTexCoord + vec2(offset[i], offset[i])/renderSize.x, 0.0).rgb*weight[i]*0.5;
        texelColor += texture(texture0, fragTexCoord + vec2(offset[i], -offset[i])/renderSize.x, 0.0).rgb*weight[i]*0.5;
        texelColor += texture(texture0, fragTexCoord + vec2(-offset[i], offset[i])/renderSize.x, 0.0).rgb*weight[i]*0.5;
        texelColor += texture(texture0, fragTexCoord + vec2(-offset[i], -offset[i])/renderSize.x, 0.0).rgb*weight[i]*0.5;
    }

    finalColor = baseColor;
    // finalColor = vec4(texelColor, 1.0);
}

DONE

post_process_shader: rl.Shader;
post_process_render_size_location: s32;

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

    yae_init(*YAE_COMPILE_TIME_INFO, 800, 600, "cosmopatate");
    defer yae_shutdown();

    rl.SetWindowMinSize(300, 200);

    load_all_resources();
    defer unload_all_resources();

    post_process_shader = rl.LoadShaderFromMemory(null, POST_PROCESS_FS);
    post_process_render_size_location = rl.GetShaderLocation(post_process_shader, "renderSize");
    defer rl.UnloadShader(post_process_shader);

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
            MAX_PIXEL_RATIO :: 3;
            MIN_RENDER_WIDTH :: 300;
            MIN_RENDER_HEIGHT :: 200;

            window_width: = rl.GetRenderWidth();
            window_height: = rl.GetRenderHeight();

            pixel_ratio: = xx min(window_width / MIN_RENDER_WIDTH, window_height / MIN_RENDER_HEIGHT);
            pixel_ratio = clamp(pixel_ratio, MIN_PIXEL_RATIO, MAX_PIXEL_RATIO);

            render_size: Vector2 = .{ cast(float)window_width / cast(float)pixel_ratio, cast(float)window_height / cast(float)pixel_ratio };
            draw_size: Vector2 = .{ render_size.x * pixel_ratio, render_size.y * pixel_ratio };

            source_rect: = Rect.{ 0.0, 0.0, render_size.x, render_size.y };
            target_rect: = Rect.{ 0.0, 0.0, draw_size.x, draw_size.y };

            viewport_update(*viewport, render_size);

            world_mouse_position: = viewport_screen_to_world_position(*viewport, target_rect, rl.GetMousePosition());

            {
                viewport_begin_render(*viewport);
                defer viewport_end_render(*viewport);

                rl.ClearBackground(rl.RAYWHITE);
                rl.DrawRectangle(-1000, -1000, 2000, 1000, rl.LIGHTGRAY);

                for < *player: players
                {
                    player_draw(player);
                }

                editor_draw();

                rl.DrawCircleV(world_mouse_position, 5, rl.RED);
            }

            rl.ClearBackground(rl.RED);

            rl.SetShaderValueV(post_process_shader, post_process_render_size_location, *draw_size, xx rl.ShaderUniformDataType.RL_SHADER_UNIFORM_VEC2, 1);
            rl.BeginShaderMode(post_process_shader);
            rl.DrawTexturePro(viewport.render_texture.texture, <<(cast(*rl.Rectangle)*source_rect), <<(cast(*rl.Rectangle)*target_rect), .{0.0, 0.0}, 0.0, rl.WHITE);
            rl.EndShaderMode();

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
