#version 460 core

in vec3 Normal;
in vec3 FragPos;
in vec2 TexCoord0;

out vec4 FragColor;

// Lights
struct DirLight
{
	vec3 dir;
	vec3 col;
};

struct PointLight
{
	vec3 pos;	
	vec3 col;

	float constant;
	float linear;
	float quadratic;
};

struct SpotLight
{
	vec3 pos;
	vec3 col;
	vec3 dir;

	float constant;
	float linear;
	float quadratic;

	float innerCone;
	float outerCone;
};

#define MAX_POINT_LIGHTS 4
#define MAX_SPOT_LIGHTS 4

uniform DirLight dirLight;
uniform PointLight pointLights[MAX_POINT_LIGHTS];
uniform SpotLight spotLights[MAX_SPOT_LIGHTS];

uniform vec3 ambientLight;

// Object
uniform vec3 tint;
uniform sampler2D tex0;

vec3 calc_dir_light(vec3 fragNormal)
{
	vec3 lightDir = normalize(-dirLight.dir);
	float intensity = max(dot(fragNormal, lightDir), 0.0);
	return (dirLight.col * intensity);
}

vec3 calc_point_light(PointLight light, vec3 fnormal, vec3 fpos)
{
	vec3 lightDir = normalize(light.pos - fpos);
	float intensity = max(dot(fnormal, lightDir), 0.0);
	
	// Attenuation
	float dst = length(light.pos - fpos);
	float atten = 1.0 / (light.constant + light.linear * dst + light.quadratic * (dst * dst));
	
	return max(light.col * intensity * atten, 0.0);  
}

vec3 calc_spot_light(SpotLight light, vec3 fnormal, vec3 fpos)
{
	vec3 lightDir = normalize(light.pos - fpos);
	float intensity = max(dot(fnormal, lightDir), 0.0);
	
	// Attenuation
	float dst = length(light.pos - fpos);
	float atten = 1.0 / (light.constant + light.linear * dst + light.quadratic * (dst * dst));
	
	// Spot falloff
	float theta = dot(light.dir, -lightDir);
	float epsilon = light.innerCone - light.outerCone;
	float falloff = clamp((theta - light.outerCone) / epsilon, 0.0, 1.0);

	return max(light.col * intensity * atten * falloff, 0.0);
}

vec3 posterize(vec3 col)
{
	float gamma = 0.3f;
	float numCols = 7f;

	col = pow(col, vec3(gamma, gamma, gamma));
	col *= numCols;
	col = floor(col);
	col /= numCols;
	col = pow(col, vec3(1.0 / gamma));

	return col;
}

void main()
{
	vec3 norm = normalize(Normal);
	
	// Get all light results
	vec3 dlightResult = calc_dir_light(norm);
	
	vec3 plightResult;
	for (int i = 0; i < MAX_POINT_LIGHTS; i++)
	{
		plightResult += calc_point_light(pointLights[i], norm, FragPos);
	}
	plightResult = clamp(plightResult, 0.0, 1.0);
	
  	vec3 slightResult;
	for (int i = 0; i < MAX_SPOT_LIGHTS; i++)
	{
		slightResult += calc_spot_light(spotLights[i], norm, FragPos);
	}
	
	


	// Depth stuff
	float depth = gl_FragCoord.z;
	float near = 0.1;
	float far  = 10;
	float ndc = depth * 2.0 - 1.0;
	float linearDepth = (2.0 * near * far) / (far + near - ndc * (far - near)) / far;
	vec3 fog = vec3(linearDepth);
	
	// vec3 final = diffuse * atten * tint + ambientLight;
	vec3 final = (dlightResult + plightResult + slightResult + ambientLight);
	final = clamp(final, 0.0, 1.0);
	
	FragColor = texture(tex0, TexCoord0) * vec4(final, 1.0);
	// FragColor = vec4(fog, 1.0);
}
