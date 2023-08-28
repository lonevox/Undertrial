#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

varying vec4 vertTexCoord;
uniform sampler2D texture;

//uniform lowp float shadows;
//uniform lowp float highlights;

const vec3 luminanceWeighting = vec3(0.2125, 0.7154, 0.0721);

void main()
{
    float shadows = 1.0;
    float highlights = 0.0;

    vec4 source = texture2D(texture, vertTexCoord.st);
    float luminance = dot(source.rgb, luminanceWeighting);

    float shadow = clamp((pow(luminance, 1.0/(shadows+1.0)) + (-0.76)*pow(luminance, 2.0/(shadows+1.0))) - luminance, 0.0, 1.0);
    float highlight = clamp((1.0 - (pow(1.0-luminance, 1.0/(2.0-highlights)) + (-0.8)*pow(1.0-luminance, 2.0/(2.0-highlights)))) - luminance, -1.0, 0.0);
    vec3 result = vec3(0.0, 0.0, 0.0) + ((luminance + shadow + highlight) - 0.0) * ((source.rgb - vec3(0.0, 0.0, 0.0))/(luminance - 0.0));

    gl_FragColor = vec4(result.rgb, source.a);
}