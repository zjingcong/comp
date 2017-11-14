#version 410
in vec2 texture_coords;

uniform sampler2D texture00;

out vec4 fragment_color;

vec4 premult(vec4 color)
{ return vec4(color.rgb * color.a, color.a);}

void main () {
    vec4 texel_a = texture (texture00, texture_coords);
    // premult
    vec4 color = premult(texel_a);
    float r  = color.r;
    float g = color.g;
    float b = color.b;
    // first step
    if (g > b)  { g = b; }
    // second step
    /// generate matte
//    float matte = b - max(g, r);
    float matte = g - max(b, r);

	fragment_color = vec4(matte, matte, matte, 1.0);
}
