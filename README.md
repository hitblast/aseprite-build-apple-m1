## ✨ Aseprite Build Script for Apple Silicon

This script will build Aseprite for Apple Silicon using the latest version of Aseprite and Skia's binary builds.
A minimum of **macOS 11 (Big Sur)** is required to run the script.

### Table of Contents


- [Requirements](#-requirements)
- [Test Device](#-test-device)
- [Build Instructions](#-build-instructions)

### ❔ Why?

Aseprite is a powerful tool for creating pixel art and animations, and as a hobby I've been doing pixel art for quite a while. However, building it on my MacBook was a challenging process. Thus, I've made this script which aims to simplify the build process by automating all of the steps, requiring little to no manual input.

### 🔨 Requirements

- [Xcode](https://developer.apple.com/xcode/)
- [CMake](https://cmake.org/)
- [Ninja](https://ninja-build.org/)
- [Git](https://git-scm.com/)

### 🔖 Test Device

The script has successfully built Aseprite on the following device:

- Name: MacBook Air (M1, 2020)
- Chip: Apple M1
- Memory: 8 GB
- Storage: 256 GB
- macOS Version: Sonoma (14.6)

### 🚀 Build Instructions

1. Clone the repository:

```bash
# Clone using git.
$ git clone https://github.com/hitblast/aseprite-build-apple-m1.git
```

2. Run the script:
(sudo is required for using xattr to remove quarantine attributes from the built binary)

```bash
# Change directory to the script.
$ cd aseprite-build-apple-m1

# Make the script executable.
$ chmod +x build.sh

# Run the script.
$ sudo ./build.sh
```
