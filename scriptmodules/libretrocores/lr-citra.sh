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

rp_module_id="lr-citra"
rp_module_desc="3DS emulator - Citra port for libretro"
rp_module_help="OpenGL >= 3.3 is required.\n\nROM Extensions: .3ds .3dsx .elf .axf .cci .cxi .app\n\nCopy your Nintendo 3DS roms to $romdir/3ds"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/citra/master/license.txt"
rp_module_repo="git https://github.com/libretro/citra.git master"
rp_module_section="exp"
rp_module_flags="!all x86 !rpi5"

function depends_lr-citra() {
    getDepends cmake
}

function sources_lr-citra() {
    gitPullOrClone
}

function build_lr-citra() {
    mkdir -p build  && cd build
    cmake .. -DENABLE_LIBRETRO=1 -DLIBRETRO_STATIC=1 -DENABLE_SDL2=0 -DENABLE_QT=0 -DCMAKE_BUILD_TYPE="Release" -DENABLE_WEB_SERVICE=0 || return 1
    make || return 1
    md_ret_require="$md_build/build/citra_libretro.so"
}

function install_lr-citra() {
    md_ret_files=(
        'build/citra_libretro.so'
    )
}

function configure_lr-citra() {
    mkRomDir "3ds"
    ensureSystemretroconfig "3ds"

    addEmulator 1 "$md_id" "3ds" "$md_inst/citra_libretro.so"
    addSystem "3ds" "3ds" ".3ds .zip"
}