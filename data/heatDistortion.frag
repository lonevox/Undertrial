#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;

uniform vec2 texOffset;

varying vec4 vertColor;
varying vec4 vertTexCoord;

uniform sampler2D distortTexture;
uniform int time;

const float size = 1.5;
const float strength = 0.002;
const float speed = 0.15;

void main() {
	vec2 distort;
	distort.x = texture2D(distortTexture, fract(vertTexCoord.st * size + vec2(0.0, float(time)/1000.0 * speed))).r * strength;
	distort.y = texture2D(distortTexture, fract(vertTexCoord.st * size * 3.4 + vec2(0.0, float(time)/1000.0 * speed * 1.6))).g * strength * 1.3;

	gl_FragColor = texture2D(texture, vertTexCoord.st + distort) * vertColor;
}