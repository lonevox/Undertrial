#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

uniform sampler2D texture;
uniform vec2 iResolution;

void main()
{
    vec2 uv = vec2(gl_FragCoord.xy / (iResolution.xy / 2.0));
    vec2 halfpixel = 0.5 / (iResolution.xy / 2.0);
    float offset = 3.0;

    vec4 sum = texture2D(texture, uv) * 4.0;
    sum += texture2D(texture, uv - halfpixel.xy * offset);
    sum += texture2D(texture, uv + halfpixel.xy * offset);
    sum += texture2D(texture, uv + vec2(halfpixel.x, -halfpixel.y) * offset);
    sum += texture2D(texture, uv - vec2(halfpixel.x, -halfpixel.y) * offset);

    gl_FragColor = sum / 8.0;
}