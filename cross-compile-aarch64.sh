#!/bin/bash
# Script to cross-compile QLC+ for aarch64 (Raspberry Pi 4)
# This script is designed to be run inside the devcontainer

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}QLC+ aarch64 Cross-Compilation Script${NC}"
echo "========================================"

# Check if we're in the right directory
if [ ! -f "CMakeLists.txt" ]; then
    echo -e "${RED}Error: CMakeLists.txt not found. Please run this script from the QLC+ root directory.${NC}"
    exit 1
fi

# Parse command line arguments
BUILD_TYPE="${1:-Release}"
BUILD_DIR="${2:-build-aarch64}"
QT_VERSION="${3:-v4}"

echo -e "${YELLOW}Configuration:${NC}"
echo "  Build Type: $BUILD_TYPE"
echo "  Build Directory: $BUILD_DIR"
echo "  Qt Version: $QT_VERSION"
echo ""

# Check for required tools
echo -e "${YELLOW}Checking for required tools...${NC}"
for tool in aarch64-linux-gnu-gcc aarch64-linux-gnu-g++ cmake ninja; do
    if ! command -v $tool &> /dev/null; then
        echo -e "${RED}Error: $tool not found. Please ensure the cross-compilation toolchain is installed.${NC}"
        exit 1
    fi
    echo "  ✓ $tool found"
done

# Note about Qt6
echo ""
echo -e "${YELLOW}Note: Qt6 for aarch64 cross-compilation${NC}"
echo "  Qt6 needs to be either:"
echo "  1. Cross-compiled for aarch64, or"
echo "  2. Installed via a package manager that provides aarch64 Qt6 libraries"
echo ""
echo "  If Qt6 is not available, you can:"
echo "  - Use the Raspberry Pi's native Qt6 packages (requires sysroot)"
echo "  - Cross-compile Qt6 yourself (time-consuming but most flexible)"
echo "  - Use Buildroot or similar embedded build systems"
echo ""

# Check for Qt6 (this is a placeholder - actual path will vary)
QT6_AARCH64_PATH="${QT6_AARCH64_PATH:-/opt/qt6-aarch64}"
if [ -d "$QT6_AARCH64_PATH" ]; then
    echo -e "${GREEN}Qt6 for aarch64 found at: $QT6_AARCH64_PATH${NC}"
    CMAKE_PREFIX_PATH_ARG="-DCMAKE_PREFIX_PATH=$QT6_AARCH64_PATH/lib/cmake"
else
    echo -e "${RED}Warning: Qt6 for aarch64 not found at $QT6_AARCH64_PATH${NC}"
    echo "  Set QT6_AARCH64_PATH environment variable to the Qt6 installation path"
    echo "  Continuing without Qt6 prefix path..."
    CMAKE_PREFIX_PATH_ARG=""
fi

# Create build directory
echo ""
echo -e "${YELLOW}Creating build directory: $BUILD_DIR${NC}"
mkdir -p "$BUILD_DIR"

# Configure CMake
echo ""
echo -e "${YELLOW}Configuring CMake for aarch64...${NC}"
cd "$BUILD_DIR"

QMLUI_FLAG=""
if [ "$QT_VERSION" = "v5" ]; then
    QMLUI_FLAG="-Dqmlui=ON"
fi

cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=../.devcontainer/aarch64-toolchain.cmake \
    -DCMAKE_BUILD_TYPE=$BUILD_TYPE \
    $CMAKE_PREFIX_PATH_ARG \
    $QMLUI_FLAG \
    -G Ninja

# Build
echo ""
echo -e "${YELLOW}Building QLC+ for aarch64...${NC}"
ninja -j$(nproc)

echo ""
echo -e "${GREEN}Build completed successfully!${NC}"
echo "Build artifacts are in: $BUILD_DIR"
echo ""
echo "To deploy to Raspberry Pi 4:"
echo "  1. Copy the build directory to your Raspberry Pi"
echo "  2. Run 'sudo ninja install' on the Raspberry Pi"
echo "  3. Or create a package using 'cpack' (if configured)"
