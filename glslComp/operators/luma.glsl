#version 410
in vec2 texture_coords;

uniform sampler2D texture00;
uniform sampler2D texture01;

out vec4 fragment_color;

float clamp(float invalue, float low, float high)
{
    if (invalue <= low)  { return low;}
    if (invalue >= high) { return high;}
    return invalue;
}

float contrast(float c, float low, float high)
{
    c = (1.0 / high - low) * c - (low / (high - low));
    return clamp(c, 0.0, 1.0);
}

vec4 premult(vec4 color)
{ return vec4(color.rgb * color.a, color.a);}

vec4 over(vec4 fg)
{
vec4 texel_b = texture (texture01, texture_coords);
vec4 premult_a = premult(fg);

return premult_a + (1.0 - fg.a) * texel_b;
}

void main ()
{
    vec4 texel_a = texture (texture00, texture_coords);
    // convert to monochrome image
    float graycolor = 0.21 * texel_a.r + 0.72 * texel_a.g + 0.07 * texel_a.b;
    // set blackpoint and whitepoint
    float blackpoint = 0.01;
    float whitepoint = 0.1;
    float matte = contrast(graycolor, blackpoint, whitepoint);

    vec4 matte_color = vec4(matte, matte, matte, matte);
    vec4 over_color = over(vec4(texel_a.rgb, matte));

    fragment_color = matte_color;
//    fragment_color = over_color;
}
