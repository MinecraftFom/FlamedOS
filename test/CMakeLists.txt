# Notification:
# This project is for environment tests
# If you see
# 1) Environment test 'C' finished
# 2) Environment test 'S' finished
# That means your environment is correctly configured
# But if one or both of these don't appear, or
# error occurs, then you have to read the error logs
# and reconfigure your environment

# ==========
# Header
cmake_minimum_required(VERSION 3.28.3)
project(FlameOS-Test ASM-ATT C)
# ==========

# ==========
# Language standards
set(CMAKE_C_STANDARD 11)
# ==========

# ==========
# Project registries
file(GLOB_RECURSE TEST_C_SOURCES "./test/src/*.c") # C sources
file(GLOB_RECURSE TEST_H_SOURCES "./test/includes/*.h") # Header sources
file(GLOB_RECURSE TEST_S_SOURCES "./test/src/*.S") # S (Assembly AT&T) sources

include_directories("./test/includes")
# ==========

# ==========
# Build, Compile & Release
add_executable(FlameOS-Test ${TEST_C_SOURCES} ${TEST_H_SOURCES} ${TEST_S_SOURCES})
# ==========