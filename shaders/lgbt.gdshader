shader_type spatial;
render_mode cull_disabled;

uniform int flag_type : hint_enum("Pride", "Trans", "Asexual", "Progress") = 0;
uniform float wind_strength = 1.0;
uniform float wind_speed = 1.0;
uniform float wind_angle = 0.2;
uniform float wind_phase = 0.0;
/**
 * Pin the vertices on the left edge of the flag. Assumes you're using a default 2 x 2 plane.
*/
uniform bool pin = true;

void vertex() {
	float strength = wind_strength * 0.15;
	if (pin) strength *= smoothstep(-1.0, 0.0, VERTEX.x);
	
	float a = PI * 2.0;
	float b = wind_speed * -PI * 2.0 * TIME + wind_phase;
	float t = VERTEX.x * cos(wind_angle) + VERTEX.z * sin(wind_angle);
	float f_t = strength * sin(a * t + b);
	float df_dt = strength * a * cos(a * t + b);
	VERTEX.y += f_t;
	NORMAL.x = -df_dt;
	NORMAL.z = -df_dt;
}

#define black vec3(0.0)
#define white vec3(1.0)
#define pride_red vec3(0.846873, 0.015996, 0.0185)
#define pride_orange vec3(0.947306, 0.304987, 0.015208)
#define pride_yellow vec3(0.879622, 0.822785, 0.010329)
#define pride_green vec3(0.003676, 0.327778, 0.066625)
#define pride_blue vec3(0.040915, 0.088655, 0.376262)
#define pride_purple vec3(0.291770, 0.021219, 0.270497)
#define trans_blue vec3(0.104616, 0.6172061, 0.955973)
#define trans_pink vec3(0.91309, 0.391572, 0.479320)
#define ace_gray vec3(0.361306)
#define ace_purple vec3(0.212230, 0.000303, 0.212230)
#define progress_brown vec3(0.138431, 0.036889, 0.00091)

vec3 color_pride(vec2 uv) {
	if (uv.y < 1.0/6.0) 
		return pride_red;
	else if (uv.y < 2.0/6.0) 
		return pride_orange;
	else if (uv.y < 3.0/6.0) 
		return pride_yellow;
	else if (uv.y < 4.0/6.0) 
		return pride_green;
	else if (uv.y < 5.0/6.0) 
		return pride_blue;
	else 
		return pride_purple;
}

vec3 color_trans(vec2 uv) {
	if (uv.y < 1.0/5.0 || uv.y > 4.0/5.0) 
		return trans_blue;
	else if (uv.y < 2.0/5.0 || uv.y > 3.0/5.0) 
		return trans_pink;
	else 
		return white;
}

vec3 color_asexual(vec2 uv) {
	if (uv.y < 1.0/4.0) 
		return black;
	else if (uv.y < 2.0/4.0) 
		return ace_gray;
	else if (uv.y < 3.0/4.0) 
		return white;
	else 
		return ace_purple;
}

vec3 color_progress(vec2 uv) {
	vec3 color = vec3(0.0);
	
	if (uv.y < 1.0/6.0) 
		color = pride_red;
	else if (uv.y < 2.0/6.0) 
		color = pride_orange;
	else if (uv.y < 3.0/6.0) 
		color = pride_yellow;
	else if (uv.y < 4.0/6.0) 
		color = pride_green;
	else if (uv.y < 5.0/6.0) 
		color = pride_blue;
	else 
		color = pride_purple;
	
	if (uv.y > -0.25 + 2.0 * uv.x && uv.y < 1.25 - 2.0 * uv.x) 
		color = black;
	if (uv.y > -0.125 + 2.0 * uv.x && uv.y < 1.125 - 2.0 * uv.x) 
		color = progress_brown;
	if (uv.y > 0.0 + 2.0 * uv.x && uv.y < 1.0 - 2.0 * uv.x) 
		color = trans_blue;
	if (uv.y > 0.125 + 2.0 * uv.x && uv.y < 0.875 - 2.0 * uv.x) 
		color = trans_pink;
	if (uv.y > 0.25 + 2.0 * uv.x && uv.y < 0.75 - 2.0 * uv.x) 
		color = white;
	
	return color;
}

void fragment() {
	vec3 color = vec3(0.0);
	switch(flag_type) {
		case 0:
			color = color_pride(UV);
			break;
		case 1:
			color = color_trans(UV);
			break;
		case 2:
			color = color_asexual(UV);
			break;
		case 3:
			color = color_progress(UV);
			break;
	}
	ALBEDO = color;
}