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

float get_median(float a[9])
{
    for (int i = 0; i < 9; i++)
    {
        float x = a[i];
        for (int j = 0; j < i; j++)
            if (a[j] > x)
            {
                float tmp = a[j];
                a[j] = x;
                x = tmp;
            }
        a[i] = x;
    }
    return a[5];
}

void main ()
{
    float pixel_width = 1.0 / 512;
    float u = texture_coords.x;
    float v = texture_coords.y;

    float r[9];
    float g[9];
    float b[9];
    int k = 0;
    for (int i = -1; i <= 1; ++i)
    {
        for (int j = -1; j <= 1; ++j, k++)
        {
            vec4 pixel_color = get_pixel_color(u + i * pixel_width, v + j * pixel_width);
            r[k] = pixel_color.r;
            g[k] = pixel_color.g;
            b[k] = pixel_color.b;
        }
    }
    float r_median = get_median(r);
    float g_median = get_median(g);
    float b_median = get_median(b);
	fragment_color = vec4(r_median, g_median, b_median, 1.0);
}
