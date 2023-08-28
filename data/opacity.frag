#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

#define PROCESSING_TEXTURE_SHADER
 
varying vec4 vertTexCoord;

uniform sampler2D texture;

uniform float brightness;
 
void main(void)
{

    vec4 col = texture2D(texture, vertTexCoord.st);
 
    //float a = 1.0 - col.r ; // make white transparent
    //col.rgb = 1.0 - col.rgb; // invert if wanted
 	
    gl_FragColor = vec4(col.rgb * brightness, col.a);
}