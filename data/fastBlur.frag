#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D texture;

uniform vec2 texOffset;

varying vec4 vertColor;
varying vec4 vertTexCoord;

const float blur = 0.3;
const float resolution = blur * 0.01 / 2.0;
const int n = 10;

void main()  {
    int totalWeight = 0;

    vec4 outColor = vec4(0.0);
    for(int i = -n; i <= n; ++i) {
        for(int j = -n; j <= n; ++j) {
            vec2 uv = vertTexCoord.st + vec2(float(i), float(j)) * resolution / float(n);
            outColor += texture2D(texture, uv);
            totalWeight += 1;
        }
    }
    
    gl_FragColor = outColor/ float(totalWeight);
}