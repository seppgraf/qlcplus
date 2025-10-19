# QLC+ aarch64 Cross-Compilation Devcontainer

This devcontainer provides a complete environment for cross-compiling QLC+ to aarch64 (ARM64) architecture, specifically targeting Raspberry Pi 4.

## Features

- **Cross-compilation toolchain**: Complete GCC toolchain for aarch64-linux-gnu
- **Build tools**: CMake, Ninja, ccache for efficient builds
- **QLC+ dependencies**: All required libraries for cross-compilation
- **VS Code integration**: Pre-configured with C/C++ and CMake extensions

## Quick Start

### Using GitHub Codespaces

1. Open this repository in GitHub Codespaces:
   - Click the "Code" button on the repository page
   - Select "Open with Codespaces"
   - Click "New codespace"

2. Wait for the container to build (this may take a few minutes on first launch)

3. Once ready, you can start cross-compiling:
   ```bash
   ./cross-compile-aarch64.sh
   ```

### Using VS Code with Dev Containers

1. Install the "Dev Containers" extension in VS Code
2. Open the repository folder
3. When prompted, click "Reopen in Container"
4. Wait for the container to build

## Cross-Compilation Process

### Prerequisites

Before you can build QLC+, you need Qt6 compiled for aarch64. You have several options:

#### Option 1: Use Pre-built Qt6 (Recommended)

Download pre-built Qt6 for aarch64 from:
- Qt's official installer (if available for your target)
- Third-party repositories (e.g., Boot2Qt)

Set the environment variable:
```bash
export QT6_AARCH64_PATH=/path/to/qt6-aarch64
```

#### Option 2: Cross-compile Qt6

This is time-consuming but provides the most control:

```bash
# Download Qt6 source
git clone https://github.com/qt/qt5.git qt6
cd qt6
git checkout v6.8.1  # or your desired version

# Configure for cross-compilation
./configure \
    -prefix /opt/qt6-aarch64 \
    -device linux-rasp-pi4-aarch64 \
    -device-option CROSS_COMPILE=aarch64-linux-gnu- \
    -release \
    -opensource \
    -confirm-license \
    -nomake examples \
    -nomake tests

# Build (this will take several hours)
cmake --build . --parallel
cmake --install .
```

#### Option 3: Use Raspberry Pi's sysroot

Extract the sysroot from a running Raspberry Pi 4 with Qt6 installed:

```bash
# On your Raspberry Pi 4, install Qt6
sudo apt-get install qt6-base-dev

# Create a tarball of the system
ssh pi@raspberry-pi.local "cd / && sudo tar czf /tmp/rpi-sysroot.tar.gz usr/lib/aarch64-linux-gnu usr/include"

# Download and extract
scp pi@raspberry-pi.local:/tmp/rpi-sysroot.tar.gz .
mkdir -p sysroot
tar xzf rpi-sysroot.tar.gz -C sysroot

# Update the toolchain file to point to this sysroot
export CMAKE_SYSROOT=$PWD/sysroot
```

### Building QLC+

Once Qt6 is available, build QLC+:

```bash
# For QLC+ v4 (default)
./cross-compile-aarch64.sh Release build-aarch64 v4

# For QLC+ v5 (QML UI)
./cross-compile-aarch64.sh Release build-aarch64 v5
```

The build script accepts three optional arguments:
1. Build type: `Release`, `Debug`, `RelWithDebInfo` (default: Release)
2. Build directory: custom build directory name (default: build-aarch64)
3. Qt version: `v4` or `v5` (default: v4)

### Manual CMake Configuration

For more control, you can configure CMake manually:

```bash
mkdir build-aarch64
cd build-aarch64

cmake .. \
    -DCMAKE_TOOLCHAIN_FILE=../.devcontainer/aarch64-toolchain.cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_PREFIX_PATH=/path/to/qt6-aarch64/lib/cmake \
    -G Ninja

ninja -j$(nproc)
```

## Deploying to Raspberry Pi 4

### Option 1: Direct Installation

Copy the build directory to your Raspberry Pi:

```bash
# From your development machine
rsync -av build-aarch64/ pi@raspberry-pi.local:~/qlcplus-build/

# On Raspberry Pi
cd ~/qlcplus-build
sudo ninja install
```

### Option 2: Create a Debian Package

```bash
cd build-aarch64
cpack -G DEB
scp *.deb pi@raspberry-pi.local:~
ssh pi@raspberry-pi.local "sudo dpkg -i qlcplus*.deb"
```

### Option 3: Create an AppImage

Follow the instructions in the main repository to create an AppImage for aarch64.

## Troubleshooting

### Qt6 not found

**Error**: CMake cannot find Qt6

**Solution**: Ensure `QT6_AARCH64_PATH` is set correctly:
```bash
export QT6_AARCH64_PATH=/path/to/qt6-aarch64
```

Or update `.devcontainer/aarch64-toolchain.cmake` with the correct Qt6 path.

### Library not found errors

**Error**: Cannot find library (e.g., libasound, libusb)

**Solution**: Install the aarch64 version of the library:
```bash
sudo dpkg --add-architecture arm64
sudo apt-get update
sudo apt-get install libpackagename-dev:arm64
```

### Compilation errors

**Error**: Compiler errors during build

**Solution**: Ensure you're using compatible versions:
- CMake 3.16+
- GCC 9+
- Qt 6.8+

Check the main QLC+ documentation for specific version requirements.

## Environment Variables

- `QT6_AARCH64_PATH`: Path to Qt6 installation for aarch64
- `CMAKE_SYSROOT`: Path to Raspberry Pi sysroot (optional)
- `CCACHE_DIR`: ccache directory (default: /workspace/.ccache)
- `CCACHE_MAXSIZE`: Maximum ccache size (default: 2G)

## Additional Resources

- [QLC+ Official Documentation](https://docs.qlcplus.org/)
- [QLC+ GitHub Wiki](https://github.com/mcallegari/qlcplus/wiki)
- [Raspberry Pi Cross-Compilation Guide](https://www.raspberrypi.com/documentation/computers/processors.html)
- [CMake Cross-Compiling](https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html)

## Testing in QEMU

You can test the compiled binaries using QEMU:

```bash
# Install QEMU user mode emulation
sudo apt-get install qemu-user-static

# Run the aarch64 binary
qemu-aarch64-static -L /usr/aarch64-linux-gnu build-aarch64/main/qlcplus
```

Note: This may not work for GUI applications without additional setup.

## Contributing

When making changes to the cross-compilation setup:

1. Test in a clean codespace
2. Document any new dependencies in the Dockerfile
3. Update this README with new instructions
4. Ensure compatibility with the main build system

## License

This devcontainer configuration is part of QLC+ and is licensed under the Apache 2.0 License.
