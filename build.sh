#!/bin/zsh
emulate -LR zsh

# Check for latest version
LATEST_RELEASE=$(curl -s https://api.github.com/repos/aseprite/aseprite/releases/latest | grep -o '"tag_name": "[^"]*"' | cut -d'"' -f4)

if [ -z "$LATEST_RELEASE" ]; then
    LATEST_RELEASE="v1.3.7"
    echo "Failed to fetch latest version. Using default version: $LATEST_RELEASE"
else
    echo "Latest version of Aseprite is: $LATEST_RELEASE"
fi

# Export paths and URLs
export ROOT=$PWD
export DEPS=$ROOT/deps
export ASEPRITE=$DEPS/aseprite
export SKIA=$DEPS/skia
export ASEZIP="https://github.com/aseprite/aseprite/releases/download/$LATEST_RELEASE/Aseprite-$LATEST_RELEASE-Source.zip"
export SKIAZIP=https://github.com/aseprite/skia/releases/download/m102-861e4743af/Skia-macOS-Release-arm64.zip
export ARCH=arm64

# Dependencies check
deps_check() {
    command=$1
    message=$2
    not_found_message=$3

    if which -s $command; then
        echo $message
    else
        echo $not_found_message
        exit 1
    fi
}

deps_check "cmake" "CMake found." "CMake not found. Install CMake and try again."
deps_check "ninja" "Ninja found." "Ninja not found. Install Ninja and try again."

DUMMY=$( xcode-select -p 2>&1 )
if [ "$?" -eq 0 ]; then
    echo "Xcode found."
else
    echo "Xcode not found."
    exit 1
fi


# Deps download and checks
DUMMY=$(ls $DEPS 2>&1)

if [ "$?" -eq 0 ]; then
    echo "Deps directory found."
else
    echo "Deps directory not found. Creating one..."
    mkdir $DEPS

    if [ "$?" -eq 0 ]; then
        echo "Deps directory successfully created."
    else
        echo "Couldn't create Deps directory. Check permissions and try again."
        exit 1
    fi
fi

DUMMY=$(ls $ASEPRITE/ 2>&1)
if [ "$?" -eq 0 ]; then
    echo "Aseprite was found."
else
    echo "Aseprite not found. Downloading..."

    rm $TMPDIR/asesrc.zip
    curl $ASEZIP -L -o $TMPDIR/asesrc.zip
    mkdir $ASEPRITE
    tar -xf $TMPDIR/asesrc.zip -C $ASEPRITE

    if [ "$?" -eq 0 ]; then
        echo "Aseprite successfully downloaded and extracted."
    else
        echo "Aseprite failed to download and extract. Check internet connection and try again later."
        exit 1
    fi
fi

DUMMY=$(ls $SKIA/ 2>&1)
if [ "$?" -eq 0 ]; then
    echo "Skia found."
else
    echo "Skia not found. Downloading..."

    rm $TMPDIR/skia.zip
    curl $SKIAZIP -L -o $TMPDIR/skia.zip
    mkdir $SKIA
    tar -xf $TMPDIR/skia.zip -C $SKIA

    if [ "$?" -eq 0 ]; then
        echo "Skia successfully downloaded and extracted."
    else
        echo "Skia failed to download and extract. Check internet connection and try again later."
        exit 1
    fi
fi


# Begin compiling...
echo "Beginning compilation for Apple Silicon (tested on M1)..."
cd $ASEPRITE
mkdir build
cd build
cmake \
    -DCMAKE_BUILD_TYPE=RelWithDebInfo \
    -DCMAKE_OSX_ARCHITECTURES=arm64 \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=11.0 \
    -DCMAKE_OSX_SYSROOT=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk \
    -DLAF_BACKEND=skia \
    -DSKIA_DIR=$SKIA \
    -DSKIA_LIBRARY_DIR=$SKIA/out/Release-arm64 \
    -DSKIA_LIBRARY=$SKIA/out/Release-arm64/libskia.a \
    -DPNG_ARM_NEON:STRING=on \
    -G Ninja \
    ..

if [ "$?" -eq 0 ]; then
    ninja aseprite

    if [ "$?" -eq 0 ]; then
        echo "Build complete! Packaging into an app..."

        cd $ROOT && mkdir -p Aseprite.app/Contents
        cp -r ./Aseprite.app.template/. ./Aseprite.app/Contents/
        mkdir -p ./Aseprite.app/Contents/MacOS
        mkdir -p ./Aseprite.app/Contents/Resources
        cp $ASEPRITE/build/bin/aseprite ./Aseprite.app/Contents/MacOS/
        cp -r $ASEPRITE/build/bin/data ./Aseprite.app/Contents/Resources/
        sed -i "" "s/1.2.34.1/$LATEST_RELEASE/" ./Aseprite.app/Contents/Info.plist

        sudo xattr -r -d com.apple.quarantine ./Aseprite.app

        echo "Aseprite.app is ready. You can find it in the Aseprite directory."
        exit 0
    else
        echo "Failed to compile. Check Skia version and try again later..."
        exit 1
    fi

else
    echo "Configuring cmake failed. Check if all code is downloaded properly. Exiting..."
    exit 1
fi
