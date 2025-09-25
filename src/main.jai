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
min_pixel_ratio: s32 = 1;
max_pixel_ratio: s32 = 3;
min_render_width: s32 = 300;
min_render_height: s32 = 200;
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

    rl.SetWindowMinSize(min_render_width * min_pixel_ratio, min_render_height * min_pixel_ratio);

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
            window_width: = rl.GetRenderWidth();
            window_height: = rl.GetRenderHeight();

            pixel_ratio: = xx min(window_width / min_render_width, window_height / min_render_height);
            pixel_ratio = clamp(pixel_ratio, min_pixel_ratio, max_pixel_ratio);

            render_width: = cast(float)window_width / cast(float)pixel_ratio;
            render_height: = cast(float)window_height / cast(float)pixel_ratio;
            viewport_update(*viewport, .{ render_width, render_height });

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
            }

            rl.ClearBackground(rl.RED);

            draw_size: Vector2 = .{ render_width * pixel_ratio, render_height * pixel_ratio };
            source_rect: = rl.Rectangle.{ 0.0, 0.0, render_width, render_height };
            target_rect: = rl.Rectangle.{ 0.0, 0.0, draw_size.x, draw_size.y };

            rl.SetShaderValueV(post_process_shader, post_process_render_size_location, *draw_size, xx rl.ShaderUniformDataType.RL_SHADER_UNIFORM_VEC2, 1);
            rl.BeginShaderMode(post_process_shader);
            rl.DrawTexturePro(viewport.render_texture.texture, source_rect, target_rect, .{0.0, 0.0}, 0.0, rl.WHITE);
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
