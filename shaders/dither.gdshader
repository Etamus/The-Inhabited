shader_type canvas_item;
uniform vec4 color = vec4(0, 0, 0, 0.1);

uniform bool roll = true;
uniform float scanlines_width : hint_range(0.0, 0.5) = 0.25;
uniform float scanlines_opacity : hint_range(0.0, 1.0) = 0.4;
uniform float warp_amount :hint_range(0.0, 5.0) = 1.0;
uniform float vignette_opacity : hint_range(0.0, 1.0) = 0.5;
uniform float vignette_intensity = 0.4;
uniform bool overlay = false;
uniform vec2 resolution = vec2(640.0, 480.0);
uniform float noise_speed = 5.0;
uniform float roll_size : hint_range(0.0, 100.0) = 15.0;
uniform float roll_speed = 8.0;
uniform float roll_variation : hint_range(0.1, 5.0) = 1.8;
uniform float distort_intensity : hint_range(0.0, 0.2) = 0.05;


vec2 random(vec2 uv){
	uv = vec2( dot(uv, vec2(127.1,311.7) ),
		dot(uv, vec2(269.5,183.3) ) );
	return -1.0 + 2.0 * fract(sin(uv) * 43758.5453123);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix( mix( dot( random(uv_index + vec2(0.0,0.0) ), uv_fract - vec2(0.0,0.0) ),
                     dot( random(uv_index + vec2(1.0,0.0) ), uv_fract - vec2(1.0,0.0) ), blur.x),
                mix( dot( random(uv_index + vec2(0.0,1.0) ), uv_fract - vec2(0.0,1.0) ),
                     dot( random(uv_index + vec2(1.0,1.0) ), uv_fract - vec2(1.0,1.0) ), blur.x), blur.y) * 0.5 + 0.5;
}

vec2 warp(vec2 uv){
	vec2 delta = uv - 0.5;
	float delta2 = dot(delta.xy, delta.xy);
	float delta4 = delta2 * delta2;
	float delta_offset = delta4 * warp_amount;
	
	return uv + delta * delta_offset;
}

float vignette(vec2 uv){
	uv *= 1.0 - uv.xy;
	float vignette = uv.x * uv.y * 15.0;
	return pow(vignette, vignette_intensity * vignette_opacity);
}


void fragment() {
	vec2 uv = overlay ? warp(SCREEN_UV) : warp(UV);
	vec2 text_uv = uv;
	float time = roll ? TIME : 0.0;
	vec2 roll_uv = vec2(0.0);
	vec4 text;
	
	
	
	float scanlines = 0.5;
	scanlines = smoothstep(scanlines_width, scanlines_width + 0.5, abs(sin(uv.y * (resolution.y * 3.14159265))));
	text.rgb = mix(text.rgb, text.rgb * vec3(scanlines), scanlines_opacity);
	
	float roll_line = 0.0;
	roll_line = smoothstep(0.3, 0.9, sin(uv.y * roll_size - (time * roll_speed) ) );
	roll_line *= roll_line * smoothstep(0.3, 0.9, sin(uv.y * roll_size * roll_variation - (time * roll_speed * roll_variation) ) );
	roll_uv = vec2(( roll_line * distort_intensity * (1.-UV.x)), 0.0);
	
	
	float noise = smoothstep(0.4, 0.5, noise(uv * vec2(2.0, 200.0) + vec2(10.0, (TIME * (noise_speed))) ) );
	roll_line *= noise * scanlines * clamp(random((ceil(uv * resolution) / resolution) + vec2(TIME * 0.8, 0.0)).x + 0.8, 0.0, 1.0);
	
	
	text_uv = ceil(uv * resolution) / resolution;
	COLOR = text;
}