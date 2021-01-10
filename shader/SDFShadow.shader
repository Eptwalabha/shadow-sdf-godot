shader_type spatial;
render_mode unshaded;

uniform vec3 light = vec3(10., 2., 10.);

uniform vec4 shadow_color : hint_color = vec4(vec3(.5), 1.);
uniform float shadow_feather : hint_range(2., 128.) = 16.;
uniform float shadow_intensity : hint_range(0, 1.) = .2;
uniform vec4 sky_color : hint_color = vec4(.3, .3, .8, 1);
uniform bool enable = true;
uniform bool shadow_enable = true;
uniform bool feather_enable = true;
uniform bool normal_enable = true;
uniform bool ao_enable = true;

uniform float AO_DIST : hint_range(0.01, .3) = .1;

varying vec3 rO;
varying vec3 v;

const float MAX_DIST = 30.;
const float SURF_DIST = 1e-2;
const int MAX_STEP = 70;

float sdBox(vec3 p, vec3 box) {
	vec3 q = abs(p) - box;
	return length(max(q, 0.)) + min(max(q.x, max(q.y, q.z)), 0.);
}

float sdShell(vec3 p, vec3 box, float r) {
	return abs(sdBox(p, box + r/2.)) - r/2.;
}

float map(vec3 p) {
	float d = p.y;
	d = min(d, sdShell(p - vec3(0., 3., 0.), vec3(4., 3., 4.), .2));
	d = max(-sdBox(p - vec3(0., 3., 0.), vec3(3., 1.5, 9.)), d);
	d = max(-sdBox(p - vec3(0., 3., 0.), vec3(5., .5, 5.)), d);
	d = max(-sdBox(p - vec3(0., 6., 0.), vec3(1.5, .5, 1.5)), d);
	d = max(-sdBox(p - vec3(4., 1.5, 0.), vec3(.5, 1.5, 1.)), d);
	return d;
}

vec3 getNormal(vec3 p) {
	vec2 e = vec2(1e-3, 0.);
	return normalize(map(p) - vec3(
			map(p - e.xyy),
			map(p - e.yxy),
			map(p - e.yyx)
		));
}

vec2 getDist(vec3 ro, vec3 rd) {
	float dist = 0.;
	float r;
	float c = 1.;
	
	for (int i = 0; i < MAX_STEP && dist < MAX_DIST; ++i) {
		r = map(ro + rd * dist);
		if (r <= SURF_DIST) {
			return vec2(dist + r, 0.);
		}
		c = min(c, shadow_feather * r / dist);
		dist += r;
	}
	return vec2(dist, c);
}

float getDiffuse(vec3 p, vec3 normal, vec3 light_dir) {
	if (step(map(p), 0.1) < 1.) return 1.;
	float d = dot(normal, light_dir) * .5 + .5;
	return d;
}

vec3 getBackground(vec3 p) {
	return mix(vec3(.6), sky_color.rgb, smoothstep(-.1, .3, p.y));
}

float getAO(vec3 p, vec3 normal) {
	return map(p + normal * AO_DIST) / AO_DIST;
}

vec3 getShadowDir(vec3 p, vec3 normal, vec3 l) {
	vec3 q = p + normal * SURF_DIST * 1.1;
	return vec3(
			getDist(q, l),
			getAO(q, normal)
		);
}

vec4 getLinearDepth(sampler2D text, vec2 screen_uv, mat4 inv_proj, mat4 camera) {
	float depth = texture(text, screen_uv).x;
	vec3 ndc = vec3(screen_uv, depth) * 2.0 - 1.0;
	vec4 view = inv_proj * vec4(ndc, 1.0);
	view.xyz /= view.w;
	vec4 world = camera * inv_proj * vec4(ndc, 1.0);
	vec3 world_position = world.xyz / world.w;
	return vec4(world_position, -view.z);
}

void vertex() {
	rO = CAMERA_MATRIX[3].xyz;
	v = VERTEX;
	POSITION = vec4(VERTEX, 1.);
}

void fragment() {
	if (!enable) {
		discard;
	}
	vec4 depth_infos = getLinearDepth(
			DEPTH_TEXTURE,
			SCREEN_UV,
			INV_PROJECTION_MATRIX,
			CAMERA_MATRIX
		);
	
	vec3 p = depth_infos.xyz;
	vec3 c;
	vec3 light_normal = normalize(light);
	
	if (depth_infos.w > 40.) {
		vec3 rd = normalize(p - rO);
		vec3 bg = getBackground(rd);
		vec3 sun = vec3(.8, .8, .5);
		float sd = smoothstep(.99, .999, dot(rd, light_normal));
		c = mix(bg, sun, sd);
//		c = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	} else {
		vec3 normal = getNormal(p);
		float diff = getDiffuse(p, normal, light_normal);
		vec3 shadow = getShadowDir(p, normal, light_normal);
		vec3 mat = vec3(1.);
		if (normal_enable) {
			mat *= diff;
		}
		float sh = step(MAX_DIST, shadow.x); // in shadow or not
		if (feather_enable) {
			sh -= sh * (1. - shadow.y); // shadow's feather
		}
		if (ao_enable) {
			sh *= (shadow.z * .25) + .75; // ao
		}
		sh = (1. - sh) * shadow_intensity; // shadow mask
		if (!shadow_enable) {
			sh = 0.;
		}
		c = mix(mat, shadow_color.rgb, sh);
	}
	ALBEDO = c;
}