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

rp_module_id="lr-gearboy"
rp_module_desc="Game Boy (Color) emulator - Gearboy port for libretro."
rp_module_help="ROM Extensions: .gb .gbc .dmg .cgb .sgb .zip .7z\n\nCopy your GameBoy roms to $romdir/gb\nCopy your GameBoy Color roms to $romdir/gbc\n\nCopy the optional BIOS files\n\ndmg_boot.bin and\ncgb_boot.bin to\n\n$biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/Gearboy/master/LICENSE"
rp_module_repo="git https://github.com/DrHelius/GearBoy.git master"
rp_module_section="exp"
rp_module_flags=""


function depends_gearboy() {
    getDepends build-essential libsdl2-dev libglew-dev libgtk-3-dev

}

function sources_lr-gearboy() {
    gitPullOrClone
}

function build_lr-gearboy() {
    cd "platforms/libretro" || return 1
    make clean
    make || return 1
    md_ret_require="$md_build/platforms/libretro/gearboy_libretro.so"
}

function install_lr-gearboy() {
    md_ret_files=(
        'platforms/libretro/gearboy_libretro.so'
    )
}

function configure_lr-gearboy() {
    for x in gb gbc; do
        mkRomDir "$x"
        ensureSystemretroconfig "$x"

        addEmulator 1 "$md_id" "$x" "$md_inst/gearboy_libretro.so"
        addSystem "$x"
    done
}