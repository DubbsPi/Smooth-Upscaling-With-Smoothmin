const ivec2 inRes = ivec2(64, 64);
const float k = 0.25 / float(max(inRes.x, inRes.y));
const vec3 boxSize = vec3(1.0 / vec2(inRes) * 0.5, 0.5);


float smoothMin(in float a, in float b, in float k) {
    k *= 1.0 / (1.0 - sqrt(0.5));
    float h = max(k - abs(a - b), 0.0) / k;
    return min(a, b) - k * 0.5 * (1.0 + h - sqrt(1.0 - h * (h - 2.0)));
}

float sdBox(in vec3 p, in vec3 b) {
  vec3 q = abs(p) - b;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float badSceneSdf(in vec3 p) {
    float d = 1e6;
    for (int x = 0; x < inRes.x; x++) {
        for (int y = 0; y < inRes.y; y++) {
            if (texelFetch(iChannel0, ivec2(x, y), 0).r > 0.5) {
                vec3 pos = vec3(vec2(x, y) / vec2(inRes) - 0.5, 0.5);
                d = smoothMin(d, sdBox(pos - p, boxSize), k);
            }
        }
    }
    return d;
}

/* Ignore me I don't work yet
float betterSceneSdf(in vec3 p, in ivec2 fragPos) {
    float d = 1e6;
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            if (texelFetch(iChannel0, ivec2(x, y), 0).r > 0.5) {
                vec3 pos = vec3((vec2(x, y) + vec2(fragPos)) / vec2(inRes) - 0.5, 0.5);
                d = smoothMin(d, sdBox(pos - p, boxSize), k);
            }
        }
    }
    return d;
}
*/

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float texel = 1.0 / iResolution.y;
    vec2 uv = (fragCoord * 2.0 - iResolution.xy) * texel;
    ivec2 fragPos = ivec2(fragCoord);
    
    
    vec3 cameraPos = vec3(uv * 0.5, 0.0);
    
    float d = badSceneSdf(cameraPos);


    fragColor = vec4(vec3(d < 0.0? 1:0), 1.0);
}