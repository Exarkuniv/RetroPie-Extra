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

rp_module_id="lr-swanstation"
rp_module_desc="Playstation emulator - Duckstation fork for libretro"
rp_module_help="ROM Extensions: .exe .img .cue .bin .chd .psf .m3u .pbp\n\nCopy your PSX roms to $romdir/psx\n\nCopy the required BIOS file SCPH1001.BIN to $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/swanstation/main/LICENSE"
rp_module_repo="git https://github.com/libretro/swanstation.git main"
rp_module_section="exp"
rp_module_flags=" "

function sources_lr-swanstation() {
    gitPullOrClone
}


function depends_lr-swanstation() {
        local depends=(cmake libsdl2-dev libsnappy-dev pkg-config libevdev-dev libgbm-dev libdrm-dev)
    getDepends "${depends[@]}"
}

function build_lr-swanstation() {
local params=(-DCMAKE_BUILD_TYPE=Release)
    if isPlatform "x11"; then
        params+=(-DUSE_X11=ON)
    else
        params+=(-DUSE_X11=OFF)
    fi
    if isPlatform "kms"; then
        params+=(-DUSE_DRMKMS=ON)
    else
        params+=(-DUSE_DRMKMS=OFF)
    fi
    cmake "${params[@]}" . || return 1
    make clean
    make   || return 1
    md_ret_require="$md_build/swanstation_libretro.so"
}

function install_lr-swanstation() {
    md_ret_files=(
        'swanstation_libretro.so'
        'README.md'
    )
}

function configure_lr-swanstation() {
    mkRomDir "psx"
    defaultRAConfig "psx"

    if isPlatform "gles" && ! isPlatform "gles3"; then
        # Hardware renderer not supported on GLES2 devices
        setRetroArchCoreOption "swanstation_GPU_Renderer" "Software"
    fi

    # Pi 4 has occasional slowdown with hardware rendering
    # e.g. Gran Turismo 2 (Arcade) race start
    isPlatform "rpi4" && setRetroArchCoreOption "swanstation_GPU_Renderer" "Software"

    # Configure the memory card 1 saves through the libretro API
    setRetroArchCoreOption "swanstation_MemoryCards_Card1Type" "Libretro"


    addEmulator 1 "$md_id" "psx" "$md_inst/swanstation_libretro.so"

    addSystem "psx"

}
