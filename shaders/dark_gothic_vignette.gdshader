shader_type canvas_item;

// Don't Starve / Darkest Dungeon aesthetic post-processing shader
// Provides ink-etched vignetting, parchment color grading, and subtle animated grain.

uniform float vignette_intensity : hint_range(0.0, 3.0) = 1.4;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.75;
uniform vec4 vignette_color : source_color = vec4(0.02, 0.01, 0.03, 1.0);
uniform float grain_amount : hint_range(0.0, 0.2) = 0.04;
uniform float desaturation : hint_range(0.0, 1.0) = 0.25;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

void fragment() {
    vec4 base_color = texture(TEXTURE, UV);
    
    // 1. Calculate distance from center for gothic vignette
    vec2 center_dist = UV - vec2(0.5);
    float dist = length(center_dist * vec2(1.0, 0.85));
    float vignette = smoothstep(0.2, 0.85, dist * vignette_intensity);
    
    // 2. Add subtle sketch grain
    float grain = (random(UV + vec2(TIME * 0.05, 0.0)) - 0.5) * grain_amount;
    
    // 3. Gothic color grading (desaturate with dried-blood tint)
    float gray = dot(base_color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 graded = mix(base_color.rgb, vec3(gray), desaturation);
    graded += vec3(grain);
    
    // 4. Blend vignette
    vec3 final_color = mix(graded, vignette_color.rgb, vignette * vignette_opacity);
    
    COLOR = vec4(final_color, base_color.a);
}
