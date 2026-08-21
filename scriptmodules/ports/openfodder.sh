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

rp_module_id="openfodder"
rp_module_desc="OpenFodder - Cannon Fodder Engine"
rp_module_licence="GPL3 https://raw.githubusercontent.com/OpenFodder/openfodder/master/gpl-3.0.txt"
rp_module_repo="git https://github.com/OpenFodder/openfodder.git"
rp_module_section="exp"
rp_module_flags="!x86 !mali"

function depends_openfodder() {
    getDepends \
        cmake ninja-build build-essential git pkg-config \
        libasound2-dev libpulse-dev libudev-dev \
        libx11-dev libxext-dev libxrandr-dev libxcursor-dev libxi-dev libxss-dev libxtst-dev \
        libwayland-dev libxkbcommon-dev libdrm-dev libgbm-dev \
        libegl1-mesa-dev libgl1-mesa-dev \
        libflac-dev libogg-dev libvorbis-dev libmpg123-dev libopusfile-dev libxmp-dev
}

function _build_sdl3_openfodder() {
    # Build SDL3 and SDL3_mixer - fully self-contained

    local sdl3_prefix="$md_inst/sdl3"
    mkdir -p "$sdl3_prefix"

    printMsgs "console" "Building SDL3 from source into $sdl3_prefix ..."
    if [[ ! -d "$md_build/SDL" ]]; then
        git clone --depth 1 --branch release-3.4.0 https://github.com/libsdl-org/SDL.git "$md_build/SDL"
    fi
    cmake -S "$md_build/SDL" -B "$md_build/SDL/build" \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$sdl3_prefix"
    cmake --build "$md_build/SDL/build"
    cmake --install "$md_build/SDL/build"

    printMsgs "console" "Building SDL3_mixer from source into $sdl3_prefix ..."
    if [[ ! -d "$md_build/SDL_mixer" ]]; then
        git clone --depth 1 https://github.com/libsdl-org/SDL_mixer.git "$md_build/SDL_mixer"
    fi
    cmake -S "$md_build/SDL_mixer" -B "$md_build/SDL_mixer/build" \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$sdl3_prefix" \
        -DCMAKE_PREFIX_PATH="$sdl3_prefix" \
        -DSDLMIXER_VENDORED=OFF \
        -DSDLMIXER_MOD_XMP=ON \
        -DSDLMIXER_MOD_XMP_LITE=OFF \
        -DSDLMIXER_MOD_XMP_SHARED=OFF
    cmake --build "$md_build/SDL_mixer/build"
    cmake --install "$md_build/SDL_mixer/build"
}

function sources_openfodder() {
    gitPullOrClone
}

function build_openfodder() {
    local sdl3_prefix="$md_inst/sdl3"

    _build_sdl3_openfodder

    cmake -S "$md_build/openfodder" -B "$md_build/openfodder/build" \
        -G Ninja \
        -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_PREFIX_PATH="$sdl3_prefix"
    cmake --build "$md_build/openfodder/build"

    # On Linux, CMake places the binary in the build dir (not Run/)
    md_ret_require="$md_build/openfodder/build/openfodder"
}

function install_openfodder() {
    # Copy the binary from the build dir, and game assets from the source tree
    cp "$md_build/openfodder/build/openfodder" "$md_inst/OpenFodder"
    chmod +x "$md_inst/OpenFodder"
    cp -r "$md_build/openfodder/Run/Campaigns" "$md_inst/"
    cp -r "$md_build/openfodder/Run/Data" "$md_inst/"
    mkdir -p "$md_inst/Saves"
}

function configure_openfodder() {

    mkRomDir "ports/$md_id"
    mkUserDir "$configdir/$md_id"

    ln -sf "$md_inst/Data" "$romdir/ports/$md_id/"
    moveConfigDir "$md_inst/Saves" "$configdir/$md_id"

    chown -R "$user:$user" "$romdir/ports/$md_id"

    # LD_LIBRARY_PATH points to the module-local SDL3 libs so the system is untouched
    addPort "$md_id" "openfodder" "OpenFodder - Cannon Fodder Engine" \
        "pushd $md_inst; LD_LIBRARY_PATH=$md_inst/sdl3/lib:\$LD_LIBRARY_PATH $md_inst/OpenFodder; popd"
}
