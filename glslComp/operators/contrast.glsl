#version 410
in vec2 texture_coords;

uniform sampler2D texture00;
uniform float contrast;

out vec4 fragment_color;


float sigmoid(float in_value, float contrast)
{
//    float out_value = in_value + in_value * contrast * (1.0 / (1.0 + exp(-in_value)));    // ref: Hassan1&2, Naglaa, and Norio Akamatsu. "A new approach for contrast enhancement using sigmoid function." (2004).
    float out_value = 1.0 / (1.0 + exp(-(contrast * 10.0) * (in_value - 0.5)));
    return out_value;
}

float linear(float in_value, float contrast)
{
    float out_value = contrast * (in_value - 0.5) + 0.5;
    return out_value;
}

void main () {
    vec4 texel_a = texture (texture00, texture_coords);

    // sigmoid
//    float r = sigmoid(texel_a.r, contrast);
//    float g = sigmoid(texel_a.g, contrast);
//    float b = sigmoid(texel_a.b, contrast);

    // linear
    float r = linear(texel_a.r, contrast);
    float g = linear(texel_a.g, contrast);
    float b = linear(texel_a.b, contrast);

    vec4 out_color = vec4(r, g, b, texel_a.a);

	fragment_color = out_color; 
}
