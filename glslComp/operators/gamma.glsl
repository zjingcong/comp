#version 410
in vec2 texture_coords;

uniform sampler2D texture00;
uniform float gamma;

out vec4 fragment_color;   

void main ()
{
    vec4 texel_a = texture (texture00, texture_coords);

    float gamma_correction = 1.0 / gamma;
    float r = pow(texel_a.r, gamma_correction);
    float g = pow(texel_a.g, gamma_correction);
    float b = pow(texel_a.b, gamma_correction);
    vec4 out_color = vec4(r, g, b, texel_a.a);

	fragment_color = out_color;
}
