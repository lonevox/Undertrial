#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec4 vertColor;
varying vec4 vertTexCoord;

uniform sampler2D texture;
uniform vec2 texOffset;

void main() {
    float offset = 3.0;

    vec4 sum = texture2D(texture, vertTexCoord.xy) * 4.0;
    sum += texture2D(texture, vertTexCoord.xy + vec2(texOffset.s * offset, 0.0));
    sum += texture2D(texture, vertTexCoord.xy + vec2(-texOffset.s * offset, 0.0));
    sum += texture2D(texture, vertTexCoord.xy + vec2(0.0, texOffset.t * offset));
    sum += texture2D(texture, vertTexCoord.xy + vec2(0.0, -texOffset.t * offset));

    gl_FragColor = sum / 8.0;
}