shader_type canvas_item;

uniform float pixel_size : hint_range(1.0, 100.0) = 10.0;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
    vec2 uv = SCREEN_UV;
    // Use the uniform 'pixel_size' here
    uv.x = floor(uv.x * (1.0 / pixel_size * 100.0)) / (1.0 / pixel_size * 100.0);
    uv.y = floor(uv.y * (1.0 / pixel_size * 100.0)) / (1.0 / pixel_size * 100.0);
    
    // Use the sampler 'screen_texture' here
    COLOR = texture(screen_texture, uv);
}