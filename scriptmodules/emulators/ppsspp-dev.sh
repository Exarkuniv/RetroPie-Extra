#!/usr/bin/env bash

# This file is part of RetroPie-Extra, a supplement to RetroPie.
# For more information, please visit:
#
# https://github.com/RetroPie/RetroPie-Setup
# https://github.com/Exarkuniv/RetroPie-Extra
#
# See the LICENSE file distributed with this source and at
# https://raw.githubusercontent.com/Exarkuniv/RetroPie-Extra/master/LICENSE
#

rp_module_id="ppsspp-dev"
rp_module_desc="PlayStation Portable emulator PPSSPP - latest development version"
rp_module_help="ROM Extensions: .iso .pbp .cso\n\nCopy your PlayStation Portable roms to $romdir/psp"
rp_module_licence="GPL2 https://raw.githubusercontent.com/hrydgard/ppsspp/master/LICENSE.TXT"
rp_module_repo="git https://github.com/hrydgard/ppsspp.git master"
rp_module_section="exp"
rp_module_flags="!rpi5"

function depends_ppsspp-dev() {
    local depends=(cmake libsdl2-dev libsnappy-dev libzip-dev zlib1g-dev)
    isPlatform "videocore" && depends+=(libraspberrypi-dev)
    isPlatform "mesa" && depends+=(libgles2-mesa-dev)
    isPlatform "vero4k" && depends+=(vero3-userland-dev-osmc)
    getDepends "${depends[@]}"
}

function sources_ppsspp-dev() {
    gitPullOrClone "$md_build/ppsspp"
    cd "ppsspp" || return 1

    # remove the lines that trigger the ffmpeg build script functions - we will just use the variables from it
    sed -i "/^build_ARMv6$/,$ d" ffmpeg/linux_arm.sh

    # remove -U__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 as we handle this ourselves if armv7 on Raspbian
    sed -i "/^  -U__GCC_HAVE_SYNC_COMPARE_AND_SWAP_2/d" cmake/Toolchains/raspberry.armv7.cmake
    # set ARCH_FLAGS to our own CXXFLAGS (which includes GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 if needed)
    sed -i "s/^set(ARCH_FLAGS.*/set(ARCH_FLAGS \"$CXXFLAGS\")/" cmake/Toolchains/raspberry.armv7.cmake

    # remove file(READ "/sys/firmware/devicetree/base/compatible" PPSSPP_PI_MODEL)
    # as it fails when building in a chroot
    sed -i "/^file(READ .*/d" cmake/Toolchains/raspberry.armv7.cmake

    # ensure Pi vendor libraries are available for linking of shared library
    sed -n -i "p; s/^set(CMAKE_EXE_LINKER_FLAGS/set(CMAKE_SHARED_LINKER_FLAGS/p" cmake/Toolchains/raspberry.armv?.cmake

    if hasPackage cmake 3.6 lt; then
        cd .. || return 1
        mkdir -p cmake
        downloadAndExtract "$__archive_url/cmake-3.6.2.tar.gz" "$md_build/cmake" --strip-components 1
    fi
}

function build_ffmpeg_ppsspp-dev() {
    cd "$1" || return 1
    local arch
    if isPlatform "arm"; then
        if isPlatform "armv6"; then
            arch="arm"
        else
            arch="armv7"
        fi
    elif isPlatform "x86"; then
        if isPlatform "x86_64"; then
            arch="x86_64";
        else
            arch="x86";
        fi
    elif isPlatform "aarch64"; then
        arch="aarch64"
    fi
    isPlatform "vero4k" && local extra_params='--arch=arm'

    local MODULES
    local VIDEO_DECODERS
    local AUDIO_DECODERS
    local VIDEO_ENCODERS
    local AUDIO_ENCODERS
    local DEMUXERS
    local MUXERS
    local PARSERS
    local GENERAL
    local OPTS # used by older lr-ppsspp fork
    # get the ffmpeg configure variables from the ppsspp ffmpeg distributed script
    source linux_arm.sh
    # linux_arm.sh has set -e which we need to switch off
    set +e
    ./configure $extra_params \
        --prefix="./linux/$arch" \
        --extra-cflags="-fasm -Wno-psabi -fno-short-enums -fno-strict-aliasing -finline-limit=300" \
        --disable-shared \
        --enable-static \
        --enable-zlib \
        --enable-pic \
        --disable-everything \
        ${MODULES} \
        ${VIDEO_DECODERS} \
        ${AUDIO_DECODERS} \
        ${VIDEO_ENCODERS} \
        ${AUDIO_ENCODERS} \
        ${DEMUXERS} \
        ${MUXERS} \
        ${PARSERS}
    make clean
    make install || return 1
}

function build_cmake_ppsspp-dev() {
    cd "$md_build/cmake" || return 1
    ./bootstrap
    make || return 1
}

function build_ppsspp-dev() {
    local ppsspp_binary="PPSSPPSDL"
    local cmake="cmake"
    if hasPackage cmake 3.6 lt; then
        build_cmake_ppsspp-dev
        cmake="$md_build/cmake/bin/cmake"
    fi

    # build ffmpeg
    build_ffmpeg_ppsspp-dev "$md_build/ppsspp/ffmpeg"

    # build ppsspp
    cd "$md_build/ppsspp" || return 1
    rm -rf CMakeCache.txt CMakeFiles
    local params=()
    if isPlatform "videocore"; then
        if isPlatform "armv6"; then
            params+=(-DCMAKE_TOOLCHAIN_FILE=cmake/Toolchains/raspberry.armv6.cmake -DFORCED_CPU=armv6 -DATOMIC_LIB=atomic)
        else
            params+=(-DCMAKE_TOOLCHAIN_FILE=cmake/Toolchains/raspberry.armv7.cmake)
        fi
    elif isPlatform "mesa"; then
        params+=(-DUSING_GLES2=ON -DUSING_EGL=OFF)
    elif isPlatform "mali"; then
        params+=(-DUSING_GLES2=ON -DUSING_FBDEV=ON)
        # remove -DGL_GLEXT_PROTOTYPES on odroid-xu/tinker to avoid errors due to header prototype differences
        params+=(-DCMAKE_C_FLAGS="${CFLAGS/-DGL_GLEXT_PROTOTYPES/}")
        params+=(-DCMAKE_CXX_FLAGS="${CXXFLAGS/-DGL_GLEXT_PROTOTYPES/}")
    elif isPlatform "tinker"; then
        params+=(-DCMAKE_TOOLCHAIN_FILE="$md_data/tinker.armv7.cmake")
    elif isPlatform "vero4k"; then
        params+=(-DCMAKE_TOOLCHAIN_FILE="cmake/Toolchains/vero4k.armv8.cmake")
    fi
    if isPlatform "arm" && ! isPlatform "x11"; then
        params+=(-DARM_NO_VULKAN=ON)
    fi
    if [[ "$md_id" == "lr-ppsspp-dev" ]]; then
        params+=(-DLIBRETRO=On)
        ppsspp_binary="lib/ppsspp_libretro.so"
    fi
    "$cmake" "${params[@]}" .
    make clean
    make || return 1

    md_ret_require="$md_build/ppsspp/$ppsspp_binary"
}

function install_ppsspp-dev() {
    md_ret_files=(
        'ppsspp/assets'
        'ppsspp/PPSSPPSDL'
    )
}

function configure_ppsspp-dev() {
    local extra_params=()
    if ! isPlatform "x11"; then
        extra_params+=(--fullscreen)
    fi

    mkRomDir "psp"
    if [[ "$md_mode" == "install" ]]; then
        moveConfigDir "$home/.config/ppsspp" "$md_conf_root/psp"
        mkUserDir "$md_conf_root/psp/PSP"
        ln -snf "$romdir/psp" "$md_conf_root/psp/PSP/GAME"
    fi

    addEmulator 0 "$md_id" "psp" "pushd $md_inst; $md_inst/PPSSPPSDL ${extra_params[*]} %ROM%; popd"
    addSystem "psp"

    # if we are removing the last remaining psp emu - remove the symlink
    if [[ "$md_mode" == "remove" ]]; then
        if [[ -h "$home/.config/ppsspp" && ! -f "$md_conf_root/psp/emulators.cfg" ]]; then
            rm -f "$home/.config/ppsspp"
        fi
    fi
}