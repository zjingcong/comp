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
    float u = texture_coords.x;
    float v = texture_coords.y;

    vec3 out_color = vec3(0.0, 0.0, 0.0);
    // box blur
//    mat3 kernel = (1.0 / 9.0) *
//                  mat3(
//                          1.0, 1.0, 1.0,
//                          1.0, 1.0, 1.0,
//                          1.0, 1.0, 1.0
//                  );

    // gaussian blur 3 × 3
    mat3 kernel = (1.0 / 16.0) *
                  mat3(
                          1.0, 2.0, 1.0,
                          2.0, 4.0, 2.0,
                          1.0, 2.0, 1.0
                  );
    for (int i = -1; i <= 1; ++i)
    {
        for (int j = -1; j < 1; ++j)
        {
            vec4 pixel_color = get_pixel_color(u + i * pixel_width, v + j * pixel_width);
            float weight = kernel[i + 1][j + 1];
            out_color += (pixel_color.rgb * weight);
        }
    }

	fragment_color = vec4(out_color, 1.0);
}
