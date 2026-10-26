shader_type(ogl);

uniform sampler2D VIEWPORT_TEXTURE : hint_texture;
uniform float CRTFISHEYE_STRENGTH : hint_range(0.0, 1.0) = 0.3;
uniform float CRT_SCANLINE_INTENSITY : hint_range(0.0, 1.0) = 0.3;
uniform float CRT_VIGNETTE_INTENSITY : hint_range(0.0, 1.0) = 0.3;
uniform bool CRT_ENABLED = true;
uniform float CRT_NOISE = 0.0;

void vertex() {
    VERTEX = vec4(VERTEX.xy, 0.0, 1.0);
}

fragment() {
    vec2 uv = FRAGCOORD.xy / RESOLUTION.xy;
    
    if (!CRT_ENABLED) {
        ALBEDO = texture(VIEWPORT_TEXTURE, uv).rgb;
        return;
    }
    
    // Sample the viewport texture
    vec4 color = texture(VIEWPORT_TEXTURE, uv);
    
    // Fisheye/barrel distortion
    vec2 center = vec2(0.5);
    vec2 dist = uv - center;
    float d = length(dist);
    // Barrel distortion: push pixels outward from center
    vec2 distorted_uv = uv + dist * CRTFISHEYE_STRENGTH * d;
    
    // Re-sample at distorted coordinates
    color = texture(VIEWPORT_TEXTURE, distorted_uv);
    
    // Scanlines - subtle horizontal lines
    float scanline = abs(sin(uv.y * 80.0));
    color = mix(color, vec4(0.0, 0.0, 0.0, 1.0), scanline * CRT_SCANLINE_INTENSITY);
    
    // Vignette - darken corners gently
    float vignette = length(uv - 0.5) / 0.70710678;
    color = mix(color, vec4(0.0, 0.0, 0.0, 1.0), vignette * CRT_VIGNETTE_INTENSITY);
    
    // Optional CRT texture noise
    if CRT_NOISE > 0.0 {
        var noise = sin(TIME * 10.0 + uv.x * 100.0 + uv.y * 100.0) * 0.5 + 0.5;
        color = mix(color, vec4(noise, noise, noise, 1.0), CRT_NOISE);
    }
    
    ALBEDO = color.rgb;
    ALPHA = color.a;
}