#version 410
in vec2 texture_coords;

uniform sampler2D texture00;
uniform sampler2D texture01;

out vec4 fragment_color;

# define maximum(x, y, z) ((x) > (y)? ((x) > (z)? (x) : (z)) : ((y) > (z)? (y) : (z)))
# define minimum(x, y, z) ((x) < (y)? ((x) < (z)? (x) : (z)) : ((y) < (z)? (y) : (z)))

// convert rgb to hsv
// output HSV colors: h, s and v on scale 0-1
vec3 RGBtoHSV(vec3 rgb)
{
    float red = rgb.r;
    float green = rgb.g;
    float blue = rgb.b;

    float max, min, delta;
    float h, s, v;

    max = maximum(red, green, blue);
    min = minimum(red, green, blue);

    v = max;    // value is maximum of r, g, b
    if(max == 0)    // saturation and hue 0 if value is 0
    {
        s = 0;
        h = 0;
    }
    else
    {
        s = (max - min) / max;  // saturation is color purity on scale 0 - 1
        delta = max - min;
        if(delta == 0)  // hue doesn't matter if saturation is 0
            h = 0;
        else    // otherwise, determine hue on scale 0 - 360
        {
            if(red == max)
                h = (green - blue) / delta;
            else if(green == max)
                h = 2.0 + (blue - red) / delta;
            else /* (green == max) */
                h = 4.0 + (red - green) / delta;

            h = h * 60.0;   // change hue to degrees
            if(h < 0)
                h = h + 360.0;  // negative hue rotated to equivalent positive around color wheel
        }
    }
    h = h / 360.0;
    return vec3(h, s, v);
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
    // set thresholds
    float th_hl_1 = 120.0 / 360.0;
    float th_hl_2 = 160.0 / 360.0;
    float th_s_1 = 0.4;
    float th_s_2 = 1.0;
    float th_v_1 = 0.3;
    float th_v_2 = 1.0;
    float th_hh_1 = 105.0 / 360.0;
    float th_hh_2 = 180.0 / 360.0;
    // get color
    vec4 texel_a = texture (texture00, texture_coords);
    // convert color
    vec3 hsv = RGBtoHSV(texel_a.rgb);
    float h = hsv.x;
    float s = hsv.y;
    float v = hsv.z;
	// create matte
    float matte = 1.0;
    if (h < th_hl_2 && h > th_hl_1 && s > th_s_1 && s < th_s_2 && v > th_v_1 && v < th_v_2) {matte = 0.0;}
    // set alpha value (matte value) between 0 to 1
    if (h <= th_hh_2 && h >= th_hl_2)   {matte = (th_hh_2 - h) / (th_hh_2 - th_hl_2);}
    if (h >= th_hh_1 && h <= th_hl_1)   {matte = (h - th_hh_1) / (th_hl_1 - th_hh_1);}

    vec4 matte_color = vec4(matte, matte, matte, matte);
    vec4 over_color = over(vec4(texel_a.rgb, matte));

//    fragment_color = matte_color;
    fragment_color = over_color;
}
