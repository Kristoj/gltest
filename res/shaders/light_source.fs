#version 460 core

out vec4 FragColor;

uniform vec3 lightCol;

void main()
{
    FragColor = vec4(lightCol, 1.0);
}
