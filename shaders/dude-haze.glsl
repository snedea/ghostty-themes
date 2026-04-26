// The Dude shader for Ghostty
// Mellow sepia haze with slow drift, warm bloom, drifting smoke wisps.
// No harsh scanlines. The Dude does not abide harsh scanlines.

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = fragCoord.xy / iResolution.xy;

    // Slow stoned wobble -- the screen drifts like the room is gently spinning
    vec2 wuv = uv;
    wuv.x += sin(iTime * 0.40) * 0.0009 + sin(iTime * 0.73 + 1.3) * 0.0005;
    wuv.y += sin(iTime * 0.31 + 2.1) * 0.0007;

    // Soft hazy blur -- generous radius, like looking through smoke
    vec3 col = vec3(0.0);
    col += texture(iChannel0, wuv).rgb * 0.36;
    col += texture(iChannel0, wuv + vec2( 0.0014,  0.0)).rgb * 0.16;
    col += texture(iChannel0, wuv + vec2(-0.0014,  0.0)).rgb * 0.16;
    col += texture(iChannel0, wuv + vec2( 0.0,     0.0017)).rgb * 0.16;
    col += texture(iChannel0, wuv + vec2( 0.0,    -0.0017)).rgb * 0.16;

    // Sepia / warm tint -- bias whites toward cream, blacks toward warm brown
    float lum = dot(col, vec3(0.299, 0.587, 0.114));
    vec3 sepia = vec3(lum) * vec3(1.05, 0.92, 0.72);
    col = mix(col, sepia, 0.28);

    // Warm phosphor bloom -- glows amber, not green
    vec3 bloom = vec3(0.0);
    bloom += texture(iChannel0, wuv + vec2( 0.0030, 0.0)).rgb;
    bloom += texture(iChannel0, wuv + vec2(-0.0030, 0.0)).rgb;
    bloom += texture(iChannel0, wuv + vec2( 0.0,    0.0030)).rgb;
    bloom += texture(iChannel0, wuv + vec2( 0.0,   -0.0030)).rgb;
    bloom *= 0.25;
    col += bloom * 0.32 * vec3(1.00, 0.85, 0.55);

    // Smoke wisps drifting upward -- value noise advected over time
    float smokeY = wuv.y + iTime * 0.045;
    float smoke  = noise(vec2(wuv.x *  4.0, smokeY * 2.5));
    smoke       *= noise(vec2(wuv.x *  8.5 + 13.0, smokeY * 5.0 - 7.0));
    smoke       *= smoothstep(1.0, 0.25, wuv.y);   // denser near the bottom
    smoke       *= 0.10;
    col += vec3(0.42, 0.34, 0.24) * smoke;

    // Warm 70s film vignette
    vec2 vu = uv - 0.5;
    float vig = 1.0 - dot(vu, vu) * 0.90;
    col *= clamp(vig, 0.0, 1.0);

    // Whisper of scanlines -- almost imperceptible, just texture
    float scan = sin(uv.y * iResolution.y * 1.4) * 0.5 + 0.5;
    col *= mix(0.96, 1.0, scan);

    // Soft film grain
    float n = hash(fragCoord.xy + iTime);
    col += (n - 0.5) * 0.025;

    // Slow candle-like flicker -- not a CRT, more like a swaying lampshade
    col *= 0.97 + 0.03 * sin(iTime * 1.3);

    fragColor = vec4(col, 1.0);
}
