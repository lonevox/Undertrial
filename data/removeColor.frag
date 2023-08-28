#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec4 vertTexCoord;
uniform sampler2D texture;

void main(void)
{
	vec4 col = texture2D(texture, vertTexCoord.st);

	if (0.299 * col.r + 0.587 * col.g + 0.114 * col.b < 0.1) {
		gl_FragColor = vec4(0,0,0,0);
	}

	gl_FragColor = col;
}