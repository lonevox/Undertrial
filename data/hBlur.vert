uniform mat4 transformMatrix;
uniform mat4 texMatrix;

attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord;

varying vec4 vertColor;
varying vec4 vertTexCoord;

varying vec2 blurTextureCoords[11];

uniform float targetWidth;

void main(){
	gl_Position = transformMatrix * position;
	vertColor = color;
	vertTexCoord = texMatrix * vec4(texCoord, 1.0, 1.0);

	//vec2 centerTexCoords = vec2(position) * 0.5 + 0.5;
	float pixelSize = 1.0 / targetWidth;

	for (int i=-5; i<=5; i++) {
		blurTextureCoords[i+5] = vertTexCoord + vec2(pixelSize * float(i), 0.0);
	}
}