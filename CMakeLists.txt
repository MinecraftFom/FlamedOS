## Notice: to compile i686 environment, you have to:
## 1) run 'download_i686.sh'. If you have it installed, you can skip this step
## 2) run 'compile_i686.sh'. If you have it in ./cross/bin, you can skip this step
## Now, you are ready to go!
## Without further ado, lets start!
#
## ==========
## Header
#cmake_minimum_required(VERSION 3.28.3)
#project(FlameOS ASM-ATT C)
## ==========
#
## ==========
## Includes & Sub projects
## Only uncomment this when testing environment
## include(./test/CMakeLists.txt)
## ==========
#
## ==========
## Language standards
#set(FLAMEOS_NAME flame_os)
#set(FLAMEOS_OUTPUT_BIN ${FLAMEOS_NAME}.bin)
#set(FLAMEOS_OUTPUT_ELF ${FLAMEOS_NAME}.elf)
#
#set(CMAKE_CROSSCOMPILING 1)
#set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC)
#
#set(CMAKE_SYSTEM_NAME FlameOS) # Configure system name
#set(CMAKE_SYSTEM_PROCESSOR i686) # i686 environment
#
#set(CMAKE_C_STANDARD 11)
#
## i686 gcc cross-compiler spec
#set(CMAKE_ASM_COMPILER ${CMAKE_SOURCE_DIR}/cross/bin/i686-elf-gcc)
#set(CMAKE_C_COMPILER   ${CMAKE_SOURCE_DIR}/cross/bin/i686-elf-gcc)
#set(CMAKE_CXX_COMPILER ${CMAKE_SOURCE_DIR}/cross/bin/i686-elf-g++)
#set(CMAKE_OBJCOPY      ${CMAKE_SOURCE_DIR}/cross/bin/i686-elf-objcopy)
#set(CMAKE_OBJDUMP      ${CMAKE_SOURCE_DIR}/cross/bin/i686-elf-objdump)
#
#set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ffreestanding -fno-builtin -fno-stack-protector -fno-pic -fno-pie -nostdlib -nostdinc") # no std libs
## ==========
#
## ==========
## Project registries
#file(GLOB_RECURSE C_SOURCES "./src/*.c") # C sources
#file(GLOB_RECURSE H_SOURCES "./includes/*.h") # Header sources
#file(GLOB_RECURSE L_SOURCES "./src/*.ld") # Linker sources
#file(GLOB_RECURSE S_SOURCES "./src/*.S") # S (Assembly AT&T) sources
#
#include_directories("./includes")
## ==========
#
## ==========
## Build, Compile & Release
#add_executable(${FLAMEOS_OUTPUT_ELF} ${C_SOURCES} ${H_SOURCES} ${S_SOURCES})
#target_link_options(${FLAMEOS_OUTPUT_ELF} PRIVATE
#        -T${CMAKE_CURRENT_SOURCE_DIR}/src/linker.ld
#        -nostdlib -static -no-pie
#        -Wl,--build-id=none
#        -Wl,-z,max-page-size=0x1000
#)
#add_custom_target(run
#        COMMAND qemu-system-i386 -kernel $<TARGET_FILE:${FLAMEOS_OUTPUT_ELF}> -serial stdio
#        DEPENDS ${FLAMEOS_OUTPUT_ELF}
#        USES_TERMINAL
#        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
#        VERBATIM)
## ==========

cmake_minimum_required(VERSION 3.28.3)
project(FlameOS ASM-ATT C)

# ==========
# Variables
set(FLAMEOS_NAME flame_os)
set(FLAMEOS_OUTPUT_BIN ${FLAMEOS_NAME}.bin)
set(FLAMEOS_OUTPUT_ELF ${FLAMEOS_NAME}.elf)
set(FLAMEOS_OUTPUT_IMG ${FLAMEOS_NAME}.img)
set(FLAMEOS_BOOTSECTOR_BIN bootsector.bin)
set(FLAMEOS_BOOTSECTOR_ELF bootsector.elf)
set(FLAMEOS_BOOTSECTOR_OBJ bootsector.o)

set(CMAKE_CROSSCOMPILING 1)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR i686)
set(CMAKE_C_STANDARD 11)

# Compiler
set(CMAKE_ASM_COMPILER ${CMAKE_SOURCE_DIR}/cross/bin/i686-elf-gcc)
set(CMAKE_C_COMPILER   ${CMAKE_SOURCE_DIR}/cross/bin/i686-elf-gcc)
set(CMAKE_CXX_COMPILER ${CMAKE_SOURCE_DIR}/cross/bin/i686-elf-g++)
set(CMAKE_OBJCOPY      ${CMAKE_SOURCE_DIR}/cross/bin/i686-elf-objcopy)
set(CMAKE_OBJDUMP      ${CMAKE_SOURCE_DIR}/cross/bin/i686-elf-objdump)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -ffreestanding -fno-builtin -fno-stack-protector -fno-pic -fno-pie -nostdinc")
# ==========

# ==========
# Project registries
file(GLOB_RECURSE C_SOURCES "./src/*.c")
file(GLOB_RECURSE H_SOURCES "./includes/*.h")
file(GLOB_RECURSE S_SOURCES "./src/*.s")

# Bootsector must NOT be part of the kernel; remove it from the glob
set(BOOTSECTOR_SRC "${CMAKE_CURRENT_SOURCE_DIR}/src/boot/boot.s")
set(BOOTSECTOR_LD  "${CMAKE_CURRENT_SOURCE_DIR}/src/linker.ld")
list(REMOVE_ITEM S_SOURCES "${BOOTSECTOR_SRC}")

include_directories("./includes")
# ==========

# ==========
# Bootsector: assemble → link at 0x7C00 → 512-byte raw binary
add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_BOOTSECTOR_ELF}
        COMMAND ${CMAKE_ASM_COMPILER} -c ${BOOTSECTOR_SRC}
        -o ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_BOOTSECTOR_OBJ}
        COMMAND ${CMAKE_C_COMPILER}
        -T ${BOOTSECTOR_LD}
        -nostdlib -static -no-pie -Wl,--build-id=none
        -o ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_BOOTSECTOR_ELF}
        ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_BOOTSECTOR_OBJ}
        DEPENDS ${BOOTSECTOR_SRC} ${BOOTSECTOR_LD}
        VERBATIM)

add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_BOOTSECTOR_BIN}
        COMMAND ${CMAKE_OBJCOPY} -O binary -j .text
        ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_BOOTSECTOR_ELF}
        ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_BOOTSECTOR_BIN}
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_BOOTSECTOR_ELF}
        COMMENT "objcopy: bootsector.elf -> bootsector.bin (512 bytes)"
        VERBATIM)
# ==========

# ==========
# Kernel: compile → link at 0x10000 → pad to 8 KiB
add_executable(${FLAMEOS_OUTPUT_ELF} ${C_SOURCES} ${S_SOURCES})

target_link_options(${FLAMEOS_OUTPUT_ELF} PRIVATE
        -T${CMAKE_CURRENT_SOURCE_DIR}/src/linker.ld
        -nostdlib -static -no-pie
        -Wl,--build-id=none)

add_custom_command(TARGET ${FLAMEOS_OUTPUT_ELF} POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O binary
        $<TARGET_FILE:${FLAMEOS_OUTPUT_ELF}>
        ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_OUTPUT_BIN}
        COMMAND sh -c "truncate -s 8192 '${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_OUTPUT_BIN}'"
        BYPRODUCTS ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_OUTPUT_BIN}
        COMMENT "objcopy: kernel.elf -> boot.bin (padded to 8 KiB = 16 sectors)"
        VERBATIM)
# ==========

# ==========
# Disk image: [512-byte bootsector][8 KiB kernel] = 8704 bytes
add_custom_command(
        OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_OUTPUT_IMG}
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_BOOTSECTOR_BIN}
        ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_OUTPUT_IMG}
        COMMAND sh -c "cat '${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_OUTPUT_BIN}' >> '${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_OUTPUT_IMG}'"
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_BOOTSECTOR_BIN}
        ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_OUTPUT_BIN}
        COMMENT "Building ${FLAMEOS_OUTPUT_IMG} (bootsector + kernel)"
        VERBATIM)

add_custom_target(image ALL DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_OUTPUT_IMG})
# ==========

# ==========
# QEMU run
add_custom_target(run
        COMMAND qemu-system-i386 -fda ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_OUTPUT_IMG} -serial stdio
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_OUTPUT_IMG}
        USES_TERMINAL
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        VERBATIM)

add_custom_target(debug
        COMMAND qemu-system-i386 -fda ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_OUTPUT_IMG} -S -s
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${FLAMEOS_OUTPUT_IMG}
        USES_TERMINAL
        WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
        VERBATIM)
# ==========