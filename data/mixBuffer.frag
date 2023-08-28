#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER

varying vec4 vertTexCoord;

uniform sampler2D texture;
uniform sampler2D bufferTexture;

void main()
{
    vec4 col = texture2D(texture, vertTexCoord.st);
    vec4 bufferCol = texture2D(bufferTexture, vertTexCoord.st);
    
    gl_FragColor = col * brightness;
}