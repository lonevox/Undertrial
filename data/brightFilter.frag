#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec4 vertTexCoord;

uniform sampler2D texture;

void mainImage( out vec4 fragColor, in vec2 fragCoord );

void main() {
    mainImage(gl_FragColor, vertTexCoord.xy);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 col = texture2D(texture, fragCoord);
    float brightness = (col.r * 0.2126) + (col.g * 0.7152) + (col.b * 0.0722);
    //fragColor = (col * brightness * 1.5) - 0.4;
    fragColor = col * brightness;
}