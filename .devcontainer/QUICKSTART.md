# Quick Start Guide: Cross-Compile QLC+ for Raspberry Pi 4

This guide will help you get started with cross-compiling QLC+ for Raspberry Pi 4 (aarch64) using GitHub Codespaces.

## Prerequisites

- A GitHub account
- Access to GitHub Codespaces (free tier available)
- A Raspberry Pi 4 running Raspberry Pi OS (64-bit)

## Step 1: Open in Codespaces

1. Navigate to the QLC+ repository on GitHub
2. Click the **Code** button (green button)
3. Select the **Codespaces** tab
4. Click **Create codespace on [branch-name]**

The codespace will automatically build the development environment. This takes about 5-10 minutes on the first launch.

### Verify Your Environment

Once the codespace is ready, verify the setup:

```bash
./.devcontainer/test-environment.sh
```

This will check that all required tools and libraries are installed correctly.

## Step 2: Understand the Limitations

⚠️ **Important Note about Qt6**: Cross-compiling QLC+ requires Qt6 libraries compiled for aarch64. The devcontainer provides the cross-compilation toolchain and all dependencies except Qt6.

You have three options to obtain Qt6 for aarch64:

### Option A: Use Raspberry Pi's Native Build (Recommended for Testing)

Instead of cross-compiling, you can build directly on the Raspberry Pi:

```bash
# On your Raspberry Pi 4
sudo apt-get update
sudo apt-get install -y qt6-base-dev qt6-multimedia-dev qt6-serialport-dev \
    libasound2-dev libusb-1.0-0-dev libftdi1-dev libudev-dev \
    libmad0-dev libsndfile1-dev liblo-dev libfftw3-dev cmake ninja-build

git clone https://github.com/mcallegari/qlcplus.git
cd qlcplus
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -G Ninja
ninja
sudo ninja install
```

### Option B: Set Up Qt6 Sysroot (For True Cross-Compilation)

1. **On your Raspberry Pi 4**, install Qt6 and development packages:
   ```bash
   sudo apt-get install -y qt6-base-dev qt6-multimedia-dev qt6-serialport-dev \
       qt6-3d-dev qt6-websockets-dev
   ```

2. **Create a sysroot tarball**:
   ```bash
   ssh pi@raspberrypi.local "sudo tar czf /tmp/rpi-sysroot.tar.gz \
       /usr/lib/aarch64-linux-gnu \
       /usr/include \
       /opt/qt6 \
       /lib/aarch64-linux-gnu"
   ```

3. **In your Codespace**, download and extract:
   ```bash
   scp pi@raspberrypi.local:/tmp/rpi-sysroot.tar.gz .
   mkdir -p /workspace/sysroot
   cd /workspace/sysroot
   tar xzf ../rpi-sysroot.tar.gz
   ```

4. **Update the toolchain file**:
   ```bash
   # Edit .devcontainer/aarch64-toolchain.cmake
   # Update CMAKE_FIND_ROOT_PATH to include /workspace/sysroot
   # Update Qt6_DIR to point to Qt6 in the sysroot
   ```

### Option C: Cross-Compile Qt6 (Advanced, Time-Consuming)

This option is documented in the full README but takes several hours.

## Step 3: Build QLC+ (If Qt6 is Available)

If you've set up Qt6 via Option B, you can cross-compile:

```bash
# In your Codespace terminal
export QT6_AARCH64_PATH=/workspace/sysroot/opt/qt6
./cross-compile-aarch64.sh Release build-aarch64 v4
```

## Step 4: Deploy to Raspberry Pi

### If you cross-compiled:

```bash
# Package the build
cd build-aarch64
tar czf qlcplus-aarch64.tar.gz *

# Copy to Raspberry Pi
scp qlcplus-aarch64.tar.gz pi@raspberrypi.local:~

# On Raspberry Pi, extract and install
ssh pi@raspberrypi.local
cd ~
tar xzf qlcplus-aarch64.tar.gz
sudo ninja install
```

### If you built natively on Raspberry Pi:

You're already done! Just run:
```bash
qlcplus
```

## Troubleshooting

### "Qt6 not found"

This is expected if you haven't set up Qt6 for cross-compilation. See Option A or B above.

### "Cannot find library"

Make sure all aarch64 libraries are installed in the devcontainer:
```bash
sudo apt-get install -y <library-name>:arm64
```

### "Permission denied" errors

Make sure scripts are executable:
```bash
chmod +x cross-compile-aarch64.sh
```

## Next Steps

- Read the full [.devcontainer/README.md](.devcontainer/README.md) for advanced options
- Check the [QLC+ documentation](https://docs.qlcplus.org/) for usage guides
- Visit the [QLC+ forum](https://www.qlcplus.org/forum/) for community support

## Quick Reference

### Useful Commands in Codespace

```bash
# Check cross-compiler version
aarch64-linux-gnu-gcc --version

# List installed aarch64 packages
dpkg -l | grep arm64

# Test build (without Qt6, will fail but shows toolchain works)
mkdir test-build && cd test-build
cmake .. -DCMAKE_TOOLCHAIN_FILE=../.devcontainer/aarch64-toolchain.cmake
```

### Raspberry Pi OS Commands

```bash
# Check architecture
uname -m  # Should show aarch64

# List installed Qt6 packages
dpkg -l | grep qt6

# Check Qt6 version
qmake6 --version
```

## Recommended Approach

For most users, we recommend **Option A** (native build on Raspberry Pi) because:
- ✅ Simpler setup
- ✅ No sysroot management
- ✅ Guaranteed compatibility
- ✅ Easier to debug

Use cross-compilation (Options B or C) if:
- You need automated builds
- You're building multiple times
- You have slow Raspberry Pi hardware
- You want CI/CD integration

## Support

If you encounter issues:
1. Check the [full README](.devcontainer/README.md)
2. Search existing [GitHub Issues](https://github.com/mcallegari/qlcplus/issues)
3. Ask on the [QLC+ Forum](https://www.qlcplus.org/forum/)
4. Create a new issue with the `cross-compilation` label
