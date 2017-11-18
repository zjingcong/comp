#version 410
in vec2 texture_coords;

uniform sampler2D texture00;
uniform sampler2D texture01;

out vec4 fragment_color;

vec4 premult(vec4 color)
{ return vec4(color.rgb * color.a, color.a);}

void main ()
{
    vec4 texel_a = texture (texture00, texture_coords);
    vec4 texel_b = texture (texture01, texture_coords);
    vec4 premult_a = premult(texel_a);

	fragment_color = premult_a + (1 - texel_a.a) * texel_b;
}
