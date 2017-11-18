#version 410
in vec2 texture_coords;

uniform sampler2D texture00;

out vec4 fragment_color;

void main ()
{
    vec4 texel_a = texture (texture00, texture_coords);
    fragment_color = texel_a;
}