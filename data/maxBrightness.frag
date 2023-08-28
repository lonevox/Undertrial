#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec4 vertTexCoord;
uniform sampler2D texture;

void main(void)
{
	vec4 col = texture2D(texture, vertTexCoord.st);
	float maxBrightness = 0.5;
	gl_FragColor = vec4(min(col.r, maxBrightness * 0.2125), min(col.g, maxBrightness), min(col.b, maxBrightness), col.a);
}