
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

#include <math.h>
#include <time.h>
#include <cstring>
#include <iostream>

#include <GL/glew.h>       // Include GLEW (or new version of GL if on Windows).
#include <GLFW/glfw3.h>    // GLFW helper library.

#include "maths_funcs.h"   // Anton's maths functions.
#include "gl_utils.h"      // Anton's opengl functions and small utilities like logs

#include "stb_image.h"     // Sean Barrett's image loader with Anton's load_texture()

#define _USE_MATH_DEFINES
#define ONE_DEG_IN_RAD (2.0 * M_PI) / 360.0 // 0.017444444

#define VERTEX_SHADER_FILE   "vs.glsl"


bool load_texture (const char* file_name, GLuint* tex) {
	int x, y, n;
	int force_channels = 4;
	unsigned char* image_data = stbi_load (file_name, &x, &y, &n, force_channels);
	if (!image_data) {
		fprintf (stderr, "ERROR: could not load %s\n", file_name);
		return false;
	}

	glGenTextures (1, tex);
	glBindTexture (GL_TEXTURE_2D, *tex);
	glTexImage2D (
		GL_TEXTURE_2D,
		0,
		GL_RGBA,
		x,
		y,
		0,
		GL_RGBA,
		GL_UNSIGNED_BYTE,
		image_data);

	glGenerateMipmap (GL_TEXTURE_2D);
	glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri (GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR_MIPMAP_LINEAR);
	GLfloat max_aniso = 0.0f;
	glGetFloatv(GL_MAX_TEXTURE_MAX_ANISOTROPY_EXT, &max_aniso);
	glTexParameterf (GL_TEXTURE_2D, GL_TEXTURE_MAX_ANISOTROPY_EXT, max_aniso);
	return true;
}


const int cmd_parser(int argc, char* argv[], std::string& fgimg, std::string& bgimg, std::string& mimg)
{
    if (argc < 2)   {std::cout << "Please specify operator." << std::endl; exit(0);}
    // specify foreground image
    if (argc >= 3)  {fgimg = argv[2];   std::cout << "foreground image: " << fgimg << std::endl;}
    // specify background image
    if (argc >= 4)  {bgimg = argv[3];   std::cout << "background image: " << bgimg << std::endl;}
    // specify mask image
    if (argc >= 5)  {mimg = argv[4];   std::cout << "mask image: " << mimg << std::endl;}
    // specify operator
    /// manipulation methods
    if (strcmp (argv[1], "gamma") == 0) { std::cout << "gamma operator" << std::endl;  return 0;}
    if (strcmp (argv[1], "contrast") == 0)  { std::cout << "contrast operator" << std::endl;  return 1;}
    /// spatial filters
    if (strcmp (argv[1], "edge") == 0)  { std::cout << "edge detect" << std::endl;  return 2;}
    if (strcmp (argv[1], "blur") == 0)  { std::cout << "blur" << std::endl;  return 3;}
    if (strcmp (argv[1], "sharpen") == 0)  { std::cout << "sharpen" << std::endl;  return 4;}
    if (strcmp (argv[1], "median") == 0)  { std::cout << "median" << std::endl;  return 5;}
    /// basic image comp
    if (strcmp (argv[1], "mix") == 0)  { std::cout << "mix" << std::endl;  return 6;}
    if (strcmp (argv[1], "over") == 0)  { std::cout << "over" << std::endl;  return 7;}
    if (strcmp (argv[1], "keymix") == 0)  { std::cout << "key-mix" << std::endl;  return 8;}
    /// matte creation and manipulation
    if (strcmp (argv[1], "chroma") == 0)  { std::cout << "chroma key" << std::endl;  return 9;}
    if (strcmp (argv[1], "luma") == 0)  { std::cout << "luma key" << std::endl;  return 10;}
    if (strcmp (argv[1], "colordiff") == 0)  { std::cout << "color difference" << std::endl;  return 11;}
    else    {std::cout << "Please specify correct operator." << std::endl; exit(0);}
}


void set_fragment_shader(const int& id, std::string& fragment_shader_file)
{
    switch (id)
    {
        case 0:
            fragment_shader_file = "gamma.glsl";
            break;

        case 1:
            fragment_shader_file = "contrast.glsl";
            break;

        case 2:
            fragment_shader_file = "edge.glsl";
            break;

        case 3:
            fragment_shader_file = "blur.glsl";
            break;

        case 4:
            fragment_shader_file = "sharpen.glsl";
            break;

        case 5:
            fragment_shader_file = "median.glsl";
            break;

        case 6:
            fragment_shader_file = "mix.glsl";
            break;

        case 7:
            fragment_shader_file = "over.glsl";
            break;

        case 8:
            fragment_shader_file = "keymix.glsl";
            break;

        case 9:
            fragment_shader_file = "chroma.glsl";
            break;

        case 10:
            fragment_shader_file = "luma.glsl";
            break;

        default:
            break;
    }
    std::cout << "set fragment shader to file: " << fragment_shader_file << std::endl;
}


void update_gamma(const GLuint& shader_program, float& gamma)
{
    std::cout << "gamma: " << gamma << std::endl;
    GLint gamma_loc = glGetUniformLocation(shader_program, "gamma");
    if (gamma_loc != -1) { glUniform1f(gamma_loc, gamma); }
}


void update_contrast(const GLuint& shader_program, float& contrast)
{
    std::cout << "contrast: " << contrast << std::endl;
    GLint gamma_loc = glGetUniformLocation(shader_program, "contrast");
    if (gamma_loc != -1) { glUniform1f(gamma_loc, contrast); }
}

void update_mix(const GLuint& shader_program, float& mix)
{
    std::cout << "mix mix: " << mix << std::endl;
    GLint gamma_loc = glGetUniformLocation(shader_program, "mix");
    if (gamma_loc != -1) { glUniform1f(gamma_loc, mix); }
}


int main (int argc, char* argv[])
{
    std::string fgimg = "a.png";    // foreground image
    std::string bgimg = "b.png";    // background image
    std::string mimg = "m.png";    // mask image
    int id = cmd_parser(argc, argv, fgimg, bgimg, mimg);
    std::string fragment_shader_file;
    set_fragment_shader(id, fragment_shader_file);

/*--------------------------------START OPENGL--------------------------------*/

	assert (restart_gl_log ());
	assert (start_gl ());        // Start glfw window with GL context within.

/*------------------------------CREATE GEOMETRY-------------------------------*/

	int point_count = 6;

	GLfloat vp[]  = {-1, -1, -1, 1, 1, 1, -1, -1, 1, 1, 1, -1};
	GLfloat vt[]  = {0, 1, 0, 0, 1, 0, 0, 1, 1, 0, 1, 1};

	// VAO -- vertex attribute objects bundle the various things associated with vertices
	GLuint vao;
	glGenVertexArrays (1, &vao);   // generating and binding is common pattern in OpenGL
	glBindVertexArray (vao);       // basically setting up memory and associating it

	// VBO -- vertex buffer object to contain coordinates
	GLuint points_vbo;
	glGenBuffers(1, &points_vbo);
	glBindBuffer(GL_ARRAY_BUFFER, points_vbo);
	glBufferData(GL_ARRAY_BUFFER, 2 * point_count * sizeof (GLfloat), vp, GL_STATIC_DRAW);
	glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 0, NULL);
	glEnableVertexAttribArray (0);

    // VBO -- vt -- texture coordinates
	GLuint texcoords_vbo;
	glGenBuffers (1, &texcoords_vbo);
	glBindBuffer (GL_ARRAY_BUFFER, texcoords_vbo);
	glBufferData (GL_ARRAY_BUFFER, 2 * point_count * sizeof (GLfloat), vt, GL_STATIC_DRAW);
	glVertexAttribPointer (1, 2, GL_FLOAT, GL_FALSE, 0, NULL);
	glEnableVertexAttribArray (1);


	
/*-------------------------------CREATE SHADERS-------------------------------*/

    // The vertex shader program generally acts to transform vertices.
    // The fragment shader is where we'll do the actual "shading."

	GLuint shader_program = create_program_from_files (
		VERTEX_SHADER_FILE, fragment_shader_file.c_str()
	);

	glUseProgram (shader_program);


/*-------------------------------SETUP TEXTURES-------------------------------*/
	// load textures
	GLuint tex00;
	int tex00location = glGetUniformLocation (shader_program, "texture00");
	glUniform1i (tex00location, 0);
	glActiveTexture (GL_TEXTURE0);
	assert (load_texture (fgimg.c_str(), &tex00));

	GLuint tex01;
	int tex01location = glGetUniformLocation (shader_program, "texture01");
	glUniform1i (tex01location, 1);
	glActiveTexture (GL_TEXTURE1);
	assert (load_texture (bgimg.c_str(), &tex01));

    GLuint tex02;
    int tex02location = glGetUniformLocation (shader_program, "texture02");
    glUniform1i (tex02location, 2);
    glActiveTexture (GL_TEXTURE2);
    assert (load_texture (mimg.c_str(), &tex02));


/*-------------------------------CHANGE PARMS-------------------------------*/

    float gamma_value = 1.0;
    float contrast = 1.0;
    float mix_mix = 0.5;
    if (id == 0)    {update_gamma(shader_program, gamma_value);}
    if (id == 1)    {update_contrast(shader_program, contrast);}
    if (id == 6)    {update_mix(shader_program, mix_mix);}

/*---------------------------SET RENDERING DEFAULTS---------------------------*/

	// Setup basic GL display attributes.	
	glEnable (GL_DEPTH_TEST);   // enable depth-testing
    glEnable(GL_BLEND);
	glDepthFunc (GL_LESS);      // depth-testing interprets a smaller value as "closer"
	glEnable (GL_CULL_FACE);    // cull face
	glCullFace (GL_BACK);       // cull back face
	glFrontFace (GL_CW);       // set counter-clock-wise vertex order to mean the front
	glClearColor (0.1, 0.1, 0.1, 1.0);   // non-black background to help spot mistakes
	glViewport (0, 0, g_gl_width, g_gl_height); // make sure correct aspect ratio

/*-------------------------------RENDERING LOOP-------------------------------*/
	
	while (!glfwWindowShouldClose (g_window)) {
		// clear graphics context
		glClear (GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

		// setup shader use	
		glUseProgram (shader_program);
        glDrawArrays (GL_TRIANGLES, 0, point_count);

		// update other events like input handling 
		glfwPollEvents ();
        // exit
        if (GLFW_PRESS == glfwGetKey (g_window, GLFW_KEY_ESCAPE)) {
            glfwSetWindowShouldClose (g_window, 1);
        }
        // gamma value
        if (GLFW_PRESS == glfwGetKey (g_window, GLFW_KEY_UP )) {
            if (id == 0)
            {
                gamma_value *= 1.05;
                update_gamma(shader_program, gamma_value);
            }
            if (id == 1)
            {
                contrast += 0.05;
                update_contrast(shader_program, contrast);
            }
            if (id == 6)
            {
                mix_mix *= 1.05;
                update_mix(shader_program, mix_mix);
            }
        }
        if (GLFW_PRESS == glfwGetKey (g_window, GLFW_KEY_DOWN )) {
            if (id == 0)
            {
                gamma_value /= 1.05;
                update_gamma(shader_program, gamma_value);
            }
            if (id == 1)
            {
                contrast -= 0.05;
                update_contrast(shader_program, contrast);
            }
            if (id == 6)
            {
                mix_mix /= 1.05;
                update_mix(shader_program, mix_mix);
            }
        }
		// put the stuff we've been drawing onto the display
		glfwSwapBuffers (g_window);
	}
	
	// close GL context and any other GLFW resources
	glfwTerminate();

	return 0;
}
