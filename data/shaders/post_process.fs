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
uniform float thickness;
uniform vec2 textureSize;
uniform vec2 renderSize;

void main()
{
    finalColor = texture(texture0, fragTexCoord);
    return;
    vec4 baseColor = texture(texture0, fragTexCoord);

    vec2 texelCoord = fragTexCoord * textureSize;
    texelCoord = mod(texelCoord, 1);
    vec2 pixelRatio = vec2(mod(texelCoord.x, 1), mod(texelCoord.y, 1)) - vec2(0.5, 0.5);

    float texelWidth = (renderSize / textureSize).x;
    vec4 leftColor = texture(texture0, fragTexCoord - vec2(1 / textureSize.x, 0));
    vec4 rightColor = texture(texture0, fragTexCoord + vec2(1 / textureSize.x, 0));

    float distance = 0;
    float thicknessFactor = 0;
    // if (pixelRatio.x <= 0 && length(leftColor.xyz - baseColor.xyz) < 0.01)
    if (pixelRatio.x <= 0 && leftColor.w > 0)
    {
        distance = abs(pixelRatio.y);
        thicknessFactor = mix(baseColor.w, leftColor.w, abs(pixelRatio.x));

    }
    // else if (pixelRatio.x > 0 && length(rightColor.xyz - baseColor.xyz) < 0.01)
    else if (pixelRatio.x > 0 && rightColor.w > 0)
    {
        distance = abs(pixelRatio.y);
        thicknessFactor = mix(baseColor.w, rightColor.w, abs(pixelRatio.x));
    }
    else
    {
        distance = length(pixelRatio);
        thicknessFactor = baseColor.w;
    }
    distance *= 2;

    float threshold = fwidth(fragTexCoord.x)*50;
    float mask = 1 - smoothstep(thickness * thicknessFactor - threshold , thickness * thicknessFactor + threshold, distance);

    finalColor = vec4(vec3(length(pixelRatio)), 1);
    finalColor = vec4(pixelRatio.x, pixelRatio.y, 0, 1);
    finalColor = baseColor;
    finalColor = vec4(baseColor.xyz * vec3(mask), 1);
    // finalColor = vec4(vec3(baseColor.w), 1);
    // finalColor = mix(vec4(mod(pixelCoord.x, 1), mod(pixelCoord.y, 1), 0, 1), baseColor, 0.5);
}