#!/bin/sh

if [ -z "$ANDROID_NDK" -o -z "$ANDROID_ABI" ]; then
    echo "Please set the ANDROID_NDK environment variable with its path.\n"
    echo "ANDROID_ABI should match your ABI: armeabi-v7a, armeabi or ..."
    exit 1
fi

# Must use android-9 here. Any replacement functions needed are in the vlc-android/jni
# folder.
ANDROID_API=android-9

VLC_SOURCEDIR=..

CFLAGS="-g -O2 -fstrict-aliasing -funsafe-math-optimizations"
if [ -n "$HAVE_ARM" ]; then
    CFLAGS="${CFLAGS} -mlong-calls"
fi

LDFLAGS="-Wl,-Bdynamic,-dynamic-linker=/system/bin/linker -Wl,--no-undefined"

if [ -n "$HAVE_ARM" ]; then
    if [ ${ANDROID_ABI} = "armeabi-v7a" ]; then
        EXTRA_PARAMS=" --enable-neon"
        LDFLAGS="$LDFLAGS -Wl,--fix-cortex-a8"
    fi
fi

CPPFLAGS="-I${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++${CXXSTL}/include -I${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++${CXXSTL}/libs/${ANDROID_ABI}/include"
LDFLAGS="$LDFLAGS -L${ANDROID_NDK}/sources/cxx-stl/gnu-libstdc++${CXXSTL}/libs/${ANDROID_ABI}"

SYSROOT=$ANDROID_NDK/platforms/$ANDROID_API/arch-$PLATFORM_SHORT_ARCH
ANDROID_BIN=`echo $ANDROID_NDK/toolchains/${PATH_HOST}-${GCCVER}/prebuilt/\`uname|tr A-Z a-z\`-*/bin/`
CROSS_COMPILE=${ANDROID_BIN}/${TARGET_TUPLE}-

CPPFLAGS="$CPPFLAGS" \
CFLAGS="$CFLAGS ${VLC_EXTRA_CFLAGS}" \
CXXFLAGS="$CFLAGS" \
LDFLAGS="$LDFLAGS" \
CC="${CROSS_COMPILE}gcc --sysroot=${SYSROOT}" \
CXX="${CROSS_COMPILE}g++ --sysroot=${SYSROOT}" \
NM="${CROSS_COMPILE}nm" \
STRIP="${CROSS_COMPILE}strip" \
RANLIB="${CROSS_COMPILE}ranlib" \
AR="${CROSS_COMPILE}ar" \
MODULE_LITE=1 \
sh $VLC_SOURCEDIR/configure --host=arm-linux-androideabi --build=x86_64-unknown-linux $EXTRA_PARAMS \
                --disable-live555 --disable-realrtsp \
                --enable-avformat \
                --enable-swscale \
                --enable-avcodec \
                --disable-opus \
                --enable-opensles \
                --enable-android-surface \
                --enable-debug \
                --disable-mkv \
                --disable-taglib \
                --enable-dvbpsi \
                --disable-freetype \
                --disable-vlc --disable-shared \
                --disable-update-check \
                --disable-vlm \
                --disable-dbus \
                --disable-lua \
                --disable-vcd \
                --disable-v4l2 \
                --disable-gnomevfs \
                --disable-dvdread \
                --disable-dvdnav \
                --disable-bluray \
                --disable-linsys \
                --disable-decklink \
                --disable-libva \
                --disable-dv1394 \
                --disable-mod \
                --disable-sid \
                --disable-gme \
                --disable-tremor \
                --disable-mad \
                --disable-dca \
                --disable-sdl-image \
                --disable-zvbi \
                --disable-fluidsynth \
                --disable-jack \
                --disable-pulse \
                --disable-alsa \
                --disable-samplerate \
                --disable-sdl \
                --disable-xcb \
                --disable-atmo \
                --disable-qt \
                --disable-skins2 \
                --disable-mtp \
                --disable-notify \
                --disable-libass \
                --disable-svg \
                --disable-udev \
                --disable-libxml2 \
                --disable-caca \
                --disable-glx \
                --disable-egl \
                --disable-goom \
                --disable-projectm \
                --disable-sout \
                --disable-vorbis \
                --enable-faad \
                --disable-x264 \
                --disable-postproc \
                --disable-a52 \
                --disable-libmpeg2 \
                --disable-schroedinger --disable-dirac \
                $*
