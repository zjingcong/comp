cmake_minimum_required(VERSION 3.6)
project(dpa8150glslComp)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES
        gl_utils.cpp
        gl_utils.h
        main.cpp
        maths_funcs.cpp
        maths_funcs.h
        stb_image.c
        stb_image.h)

add_executable(dpa8150glslComp ${SOURCE_FILES})