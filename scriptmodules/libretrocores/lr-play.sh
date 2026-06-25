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

rp_module_id="lr-play"
rp_module_desc="PlayStation 2 emulator - Play port for libretro"
rp_module_help="ROM Extensions: .chd .iso .isz .cso .bin .elf\n\nCopy your PlayStation 2 roms to $romdir/ps2"
rp_module_licence="MIT https://raw.githubusercontent.com/libretro/Play-/master/License.txt"
rp_module_repo="git https://github.com/libretro/Play-.git master"
rp_module_section="exp"
rp_module_flags="!all 64bit !rpi5"

function depends_lr-play() {
    local depends=(cmake libalut-dev)
    getDepends "${depends[@]}"
}

function sources_lr-play() {
    gitPullOrClone
}

function build_lr-play() {
    mkdir -p build && cd build
    cmake .. -G"Unix Makefiles" -DBUILD_LIBRETRO_CORE=yes -DBUILD_PLAY=off -DBUILD_TESTS=no -DENABLE_AMAZON_S3=no -DCMAKE_BUILD_TYPE="Release" || return 1
    cmake --build . || return 1
    md_ret_require="$md_build/build/Source/ui_libretro/play_libretro.so"
}

function install_lr-play() {
    md_ret_files=(
	'build/Source/ui_libretro/play_libretro.so'
	'License.txt'
    )
}

function configure_lr-play() {
    mkRomDir "ps2"
    ensureSystemretroconfig "ps2"

    addEmulator 0 "$md_id" "ps2" "$md_inst/play_libretro.so"
    addSystem "ps2"
}