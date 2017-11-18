#version 410
in vec2 texture_coords;

uniform sampler2D texture00;
uniform sampler2D texture01;

uniform float mix;

out vec4 fragment_color;

void main ()
{
    vec4 texel_a = texture (texture00, texture_coords);
    vec4 texel_b = texture (texture01, texture_coords);

	fragment_color = mix * texel_a + (1 - mix) * texel_b;
}
