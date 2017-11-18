#version 410
in vec2 texture_coords;

uniform sampler2D texture00;

out vec4 fragment_color;

vec4 get_pixel_color(float u, float v)
{
    // boundary condition
    if (u <= 0.0)    {u = -(u - int(u));}
    if (u >= 1.0)    {u = 1.0 - (u - int(u));}
    if (v <= 0.0)    {v = -(v - int(v));}
    if (v >= 1.0)    {v = 1.0 - (v - int(v));}
    // return pixel color
    vec4 pixel_color = texture (texture00, vec2(u, v));
    return pixel_color;
}

void main ()
{
    float pixel_width = 1.0 / 512;
    float u = texture_coords.s;
    float v = texture_coords.t;

    mat3 kernel = mat3(
            -1.0, -1.0, -1.0,
            -1.0, 8.0, -1.0,
            -1.0, -1.0, -1.0
    );

    // for all channels
    vec4 out_color = vec4(0.0, 0.0, 0.0, 0.0);
    for (int i = -1; i <= 1; ++i)
    {
        for (int j = -1; j <= 1; ++j)
        {
            vec4 pixel_color = get_pixel_color(u + i * pixel_width, v + j * pixel_width);
            float weight = kernel[i + 1][j + 1];
            out_color += (pixel_color * weight);
        }
    }

    // edge detection for grayscale
//    vec3 out_color = vec3(0.0, 0.0, 0.0);
//    for (int i = -1; i <= 1; ++i)
//    {
//        for (int j = -1; j <= 1; ++j)
//        {
//            vec4 pixel_color = get_pixel_color(u + i * pixel_width, v + j * pixel_width);
//            float graycolor = 0.21 * pixel_color.r + 0.72 * pixel_color.g + 0.07 * pixel_color.b;
//            float weight = kernel[i + 1][j + 1];
//            out_color += (vec3(graycolor, graycolor, graycolor) * weight);
//        }
//    }

	fragment_color = vec4(out_color.rgb, 1.0);
}
