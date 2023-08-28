#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;

uniform vec2 texOffset;

varying vec4 vertColor;
varying vec4 vertTexCoord;

void main() {

	float strength = 0.1;

	float lod = (5.0 + 5.0 * strength) * step(vertTexCoord.s, 0.5);

	vec3 col = textureLod(texture, vertTexCoord.st, 4.0).xyz;

	gl_FragColor = vec4( col, 1.0 );
	
	//gl_FragColor = texture2D(texture, vertTexCoord.st) * vertColor;
}