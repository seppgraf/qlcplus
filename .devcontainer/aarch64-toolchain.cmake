# CMake toolchain file for cross-compiling to aarch64 (ARM64) on Raspberry Pi 4
# This file should be used with: cmake -DCMAKE_TOOLCHAIN_FILE=.devcontainer/aarch64-toolchain.cmake

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

# Specify the cross compiler
set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

# Specify other cross-compilation tools
set(CMAKE_AR aarch64-linux-gnu-ar CACHE FILEPATH "Archiver")
set(CMAKE_LINKER aarch64-linux-gnu-ld CACHE FILEPATH "Linker")
set(CMAKE_NM aarch64-linux-gnu-nm CACHE FILEPATH "NM")
set(CMAKE_OBJCOPY aarch64-linux-gnu-objcopy CACHE FILEPATH "Objcopy")
set(CMAKE_OBJDUMP aarch64-linux-gnu-objdump CACHE FILEPATH "Objdump")
set(CMAKE_RANLIB aarch64-linux-gnu-ranlib CACHE FILEPATH "Ranlib")
set(CMAKE_STRIP aarch64-linux-gnu-strip CACHE FILEPATH "Strip")

# Where is the target environment located
set(CMAKE_FIND_ROOT_PATH /usr/aarch64-linux-gnu)

# Adjust the default behavior of the FIND_XXX() commands:
# search programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# Search headers and libraries in the target environment
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Set pkg-config for cross-compilation
set(ENV{PKG_CONFIG_PATH} "")
set(ENV{PKG_CONFIG_LIBDIR} "/usr/lib/aarch64-linux-gnu/pkgconfig:/usr/share/pkgconfig")
set(ENV{PKG_CONFIG_SYSROOT_DIR} "/")

# Qt6 configuration for cross-compilation
# Note: You will need to install Qt6 for aarch64 or build it from source
# Uncomment and adjust the path when Qt6 is available
# set(Qt6_DIR "/path/to/qt6/aarch64/lib/cmake/Qt6")
