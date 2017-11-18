#version 410
in vec2 texture_coords;

uniform sampler2D texture00;
uniform sampler2D texture01;

out vec4 fragment_color;

# define maximum(x, y) ((x > y) ? x: y)

vec4 premult(vec4 color)
{ return vec4(color.rgb * color.a, color.a);}

vec4 over(vec4 fg)
{
    vec4 texel_b = texture (texture01, texture_coords);
    vec4 premult_a = premult(fg);

    return premult_a + (1.0 - fg.a) * texel_b;
}

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

void main ()
{
    vec4 texel_a = texture (texture00, texture_coords);
    vec4 texel_b = texture (texture01, texture_coords);

    float r = texel_a.r;
    float g = texel_a.g;
    float b = texel_a.b;
    // split suppression
    float new_b = b;
    if (b > g)  new_b = g;
    // create inverted matte
    float matte = b - maximum(g, r);
    // multiply inverted matte with background image
    matte = contrast(matte, 0.0, 0.5);  // contrast adjust for matte
    vec4 tmp = matte * texel_b;
    // add together
    vec3 out_color = vec3(r, g, new_b) + tmp.rgb;

    fragment_color = vec4(out_color, 1.0);
}
