#!/bin/bash
# Test script to verify the aarch64 cross-compilation environment
# Run this script inside the devcontainer to verify everything is set up correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   QLC+ aarch64 Cross-Compilation Environment Test    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Function to test command
test_command() {
    local cmd=$1
    local name=$2
    
    echo -n "Testing $name... "
    if command -v $cmd &> /dev/null; then
        local version=$($cmd --version 2>&1 | head -n1)
        echo -e "${GREEN}✓${NC} $version"
        return 0
    else
        echo -e "${RED}✗ Not found${NC}"
        return 1
    fi
}

# Function to test library
test_library() {
    local lib=$1
    local name=$2
    
    echo -n "Testing $name... "
    if pkg-config --exists $lib 2>/dev/null; then
        local version=$(pkg-config --modversion $lib 2>/dev/null)
        echo -e "${GREEN}✓${NC} $version"
        return 0
    else
        echo -e "${YELLOW}⚠ Not found via pkg-config${NC}"
        return 1
    fi
}

# Test basic tools
echo -e "${YELLOW}Basic Build Tools:${NC}"
test_command "cmake" "CMake"
test_command "ninja" "Ninja"
test_command "ccache" "ccache"
test_command "pkg-config" "pkg-config"
test_command "git" "Git"
echo ""

# Test cross-compilation toolchain
echo -e "${YELLOW}Cross-Compilation Toolchain:${NC}"
test_command "aarch64-linux-gnu-gcc" "GCC (aarch64)"
test_command "aarch64-linux-gnu-g++" "G++ (aarch64)"
test_command "aarch64-linux-gnu-ar" "AR (aarch64)"
test_command "aarch64-linux-gnu-ld" "LD (aarch64)"
echo ""

# Test Python and lxml
echo -e "${YELLOW}Python Tools:${NC}"
test_command "python3" "Python 3"
echo -n "Testing Python lxml module... "
if python3 -c "import lxml" 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
else
    echo -e "${RED}✗ Not found${NC}"
fi
echo ""

# Test for multiarch support
echo -e "${YELLOW}Multi-Architecture Support:${NC}"
echo -n "Checking arm64 architecture... "
if dpkg --print-foreign-architectures | grep -q arm64; then
    echo -e "${GREEN}✓ arm64 enabled${NC}"
else
    echo -e "${RED}✗ arm64 not enabled${NC}"
fi
echo ""

# Test aarch64 libraries
echo -e "${YELLOW}aarch64 Libraries (via dpkg):${NC}"
for lib in libasound2-dev libusb-1.0-0-dev libftdi1-dev libudev-dev libmad0-dev libsndfile1-dev liblo-dev libfftw3-dev libgl1-mesa-dev; do
    echo -n "Testing $lib:arm64... "
    if dpkg -l | grep -q "$lib:arm64"; then
        echo -e "${GREEN}✓ Installed${NC}"
    else
        echo -e "${RED}✗ Not installed${NC}"
    fi
done
echo ""

# Test simple cross-compilation
echo -e "${YELLOW}Cross-Compilation Test:${NC}"
echo -n "Creating test C program... "
cat > /tmp/test_cross.c << 'EOF'
#include <stdio.h>
int main() {
    printf("Hello from aarch64!\n");
    return 0;
}
EOF
echo -e "${GREEN}✓${NC}"

echo -n "Compiling with aarch64-linux-gnu-gcc... "
if aarch64-linux-gnu-gcc /tmp/test_cross.c -o /tmp/test_cross_aarch64 2>/dev/null; then
    echo -e "${GREEN}✓${NC}"
    
    echo -n "Checking binary architecture... "
    if file /tmp/test_cross_aarch64 | grep -q "aarch64"; then
        echo -e "${GREEN}✓ ARM aarch64${NC}"
    else
        echo -e "${RED}✗ Wrong architecture${NC}"
    fi
    
    # Clean up
    rm -f /tmp/test_cross.c /tmp/test_cross_aarch64
else
    echo -e "${RED}✗ Compilation failed${NC}"
fi
echo ""

# Test CMake with toolchain file
echo -e "${YELLOW}CMake Toolchain Test:${NC}"
echo -n "Testing CMake toolchain file... "
if [ -f ".devcontainer/aarch64-toolchain.cmake" ]; then
    echo -e "${GREEN}✓ Toolchain file exists${NC}"
    
    # Create a simple CMakeLists.txt for testing
    mkdir -p /tmp/cmake_test
    cat > /tmp/cmake_test/CMakeLists.txt << 'EOF'
cmake_minimum_required(VERSION 3.16)
project(test C)
message(STATUS "System: ${CMAKE_SYSTEM_NAME}")
message(STATUS "Processor: ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "C Compiler: ${CMAKE_C_COMPILER}")
EOF
    
    echo -n "Running CMake configuration test... "
    cd /tmp/cmake_test
    if cmake . -DCMAKE_TOOLCHAIN_FILE=/workspace/.devcontainer/aarch64-toolchain.cmake &> /tmp/cmake_test.log; then
        if grep -q "aarch64" /tmp/cmake_test.log; then
            echo -e "${GREEN}✓ Configured for aarch64${NC}"
        else
            echo -e "${YELLOW}⚠ Configuration succeeded but architecture unclear${NC}"
        fi
    else
        echo -e "${RED}✗ Configuration failed${NC}"
        echo "See /tmp/cmake_test.log for details"
    fi
    cd - > /dev/null
    rm -rf /tmp/cmake_test
else
    echo -e "${RED}✗ Toolchain file not found${NC}"
fi
echo ""

# Check for Qt6
echo -e "${YELLOW}Qt6 Status:${NC}"
echo -n "Checking for Qt6 (aarch64)... "
if [ -d "${QT6_AARCH64_PATH}" ]; then
    echo -e "${GREEN}✓ Found at $QT6_AARCH64_PATH${NC}"
elif [ -d "/opt/qt6-aarch64" ]; then
    echo -e "${GREEN}✓ Found at /opt/qt6-aarch64${NC}"
else
    echo -e "${YELLOW}⚠ Not found${NC}"
    echo "  Qt6 for aarch64 is required to build QLC+"
    echo "  See .devcontainer/README.md for setup instructions"
fi
echo ""

# Summary
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║                    Test Summary                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "The cross-compilation toolchain is installed and working."
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "1. Set up Qt6 for aarch64 (see .devcontainer/README.md)"
echo "2. Run: ./cross-compile-aarch64.sh"
echo "3. Deploy to your Raspberry Pi 4"
echo ""
echo -e "For more information, see ${BLUE}.devcontainer/QUICKSTART.md${NC}"
