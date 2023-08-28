#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

varying vec4 vertColor;
varying vec4 vertTexCoord;

uniform sampler2D texture;
uniform vec2 iResolution;

void main()
{
    vec2 uv = vec2(gl_FragCoord.xy / (iResolution.xy * 2.0));
    vec2 halfpixel = 0.5 / (iResolution.xy * 2.0);
    float offset = 3.0;

    vec4 sum = texture2D(texture, uv +vec2(-halfpixel.x * 2.0, 0.0) * offset);
    
    sum += texture2D(texture, uv + vec2(-halfpixel.x, halfpixel.y) * offset) * 2.0;
    sum += texture2D(texture, uv + vec2(0.0, halfpixel.y * 2.0) * offset);
    sum += texture2D(texture, uv + vec2(halfpixel.x, halfpixel.y) * offset) * 2.0;
    sum += texture2D(texture, uv + vec2(halfpixel.x * 2.0, 0.0) * offset);
    sum += texture2D(texture, uv + vec2(halfpixel.x, -halfpixel.y) * offset) * 2.0;
    sum += texture2D(texture, uv + vec2(0.0, -halfpixel.y * 2.0) * offset);
    sum += texture2D(texture, uv + vec2(-halfpixel.x, -halfpixel.y) * offset) * 2.0;

    gl_FragColor = sum / 12.0;
}