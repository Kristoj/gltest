#version 460 core


in vec3 Normal;
in vec2 TexCoord;
in vec3 FragPos;

out vec4 FragColor;  

// Ambient light
uniform vec3 ambientCol;

// Directional light
uniform vec3 dirlightDir;
uniform vec3 dirlightCol;

// Other light
uniform vec3 lightDir;
uniform vec3 lightPos;
uniform vec3 lightCol;
uniform float constant;
uniform float linear;
uniform float quadratic;

uniform sampler2D texture0;
  
void main()
{
    // Lighting
    // vec3 amb = ambientCol;
    // vec3 norm = normalize(Normal);
    // vec3 dir = normalize(lightPos - FragPos);
    // float directional = max(dot(norm, dirlightDir), 0.0);
    // vec3 diffuse = diff * dirlightCol;
    
    // vec3 finalLight = amb + diffuse;

    // Diffuse
    vec3 norm = normalize(Normal);
    vec3 lightDir = normalize(lightPos - FragPos);
    float diffIntensity = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = lightCol * diffIntensity;

    // Attentuation
    float dst = length(lightPos - FragPos);
    float atten = 1.0 / (constant + linear * dst + quadratic * (dst * dst));
    vec3 final = diffuse;
    FragColor = texture(texture0, TexCoord) * vec4(final, 1.0);
}
