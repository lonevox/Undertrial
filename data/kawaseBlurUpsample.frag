#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec4 vertColor;
varying vec4 vertTexCoord;

uniform sampler2D texture;
uniform vec2 texOffset;

void main() {
    float offset = 2.0;

    vec4 sum = texture2D(texture, vertTexCoord.xy + vec2(-texOffset.s * 2.0, 0.0) * offset);

    sum += texture2D(texture, vertTexCoord.xy + vec2(-texOffset.s, texOffset.t) * offset) * 2.0;
    sum += texture2D(texture, vertTexCoord.xy + vec2(0.0, texOffset.t * 2.0) * offset);
    sum += texture2D(texture, vertTexCoord.xy + texOffset * offset) * 2.0;
    sum += texture2D(texture, vertTexCoord.xy + vec2(texOffset.s * 2.0, 0.0) * offset);
    sum += texture2D(texture, vertTexCoord.xy + vec2(texOffset.s, -texOffset.t) * offset) * 2.0;
    sum += texture2D(texture, vertTexCoord.xy + vec2(0.0, -texOffset.t * 2.0) * offset);
    sum += texture2D(texture, vertTexCoord.xy + vec2(-texOffset.s, -texOffset.t) * offset) * 2.0;

    gl_FragColor = sum / 10.0; // originally 12.0
}