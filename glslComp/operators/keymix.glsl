#version 410
in vec2 texture_coords;

uniform sampler2D texture00;
uniform sampler2D texture01;
uniform sampler2D texture02;

uniform float mix;

out vec4 fragment_color;

void main ()
{
    vec4 texel_a = texture (texture00, texture_coords);
    vec4 texel_b = texture (texture01, texture_coords);
    vec4 texel_c = texture (texture02, texture_coords);

    float mask = texel_c.a; // use alpha channel as mask

	fragment_color = mask * texel_a + (1 - mask) * texel_b;
}
