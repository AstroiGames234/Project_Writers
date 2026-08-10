shader_type sky;

// PS1-ish limited colors
uniform vec3 top_color    : source_color = vec3(0.03, 0.04, 0.10); // deep blue
uniform vec3 mid_color    : source_color = vec3(0.01, 0.01, 0.04); // banded mid
uniform vec3 bottom_color : source_color = vec3(0.0,  0.0,  0.0);  // near-black

uniform vec3 star_color   : source_color = vec3(0.95, 0.95, 0.9);
uniform float star_density  : hint_range(0.98, 0.999) = 0.994; // closer to 1 = fewer stars
uniform float star_intensity : hint_range(0.0, 4.0)   = 1.8;

// Fake 8‑bit gradient banding
vec3 posterize(vec3 c, float steps) {
    return floor(c * steps) / steps;
}

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 34.45);
    return fract(p.x * p.y);
}

void sky() {
    vec3 dir = normalize(EYEDIR);

    float v = clamp(dir.y * 0.5 + 0.5, 0.0, 1.0);

    vec3 col;
    if (v > 0.66) {
        col = top_color;
    } else if (v > 0.33) {
        col = mid_color;
    } else {
        col = bottom_color;
    }

    if (dir.y > 0.0) {
        vec2 uv = dir.xz * 200.0;
        vec2 cell = floor(uv);
        float n = hash(cell);

        if (n > star_density) {
            float s = 0.5 + 0.5 * hash(cell + 13.37);
            col += star_color * star_intensity * s;
        }
    }

    col = posterize(col, 8.0);
    COLOR = col;
}