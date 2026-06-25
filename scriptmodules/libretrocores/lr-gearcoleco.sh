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

rp_module_id="lr-gearcoleco"
rp_module_desc="ColecoVision emulator - GearColeco port for libretro."
rp_module_help="ROM Extensions: .col .cv .bin .rom .zip .7z\n\nCopy your ColecoVision roms to $romdir/coleco\n\nCopy the required BIOS files colecovision.rom md5 2c66f5911e5b42b8ebe113403548eee7 to $biosdir"
rp_module_licence="GPL3 https://git.libretro.com/libretro/gearcoleco/blob/main/LICENSE"
rp_module_repo="git https://github.com/drhelius/Gearcoleco.git main"
rp_module_section="exp"
rp_module_flags=""

function depends_gearboy() {
    getDepends build-essential libsdl2-dev libglew-dev libgtk-3-dev

}

function sources_lr-gearcoleco() {
    gitPullOrClone
}

function build_lr-gearcoleco() {
    cd "platforms/libretro" || return 1
    make clean
    make || return 1
    md_ret_require="$md_build/platforms/libretro/gearcoleco_libretro.so"
}

function install_lr-gearcoleco() {
    md_ret_files=(
        'platforms/libretro/gearcoleco_libretro.so'
    )
}

function configure_lr-gearcoleco() {
    local system
    for system in coleco colecoh coleco-proto coleco-sgm coleco-unl; do
    mkRomDir "$system"
    defaultRAConfig "$system"
    addEmulator 0 "$md_id" "$system" "$md_inst/gearcoleco_libretro.so"
    addSystem "$system"
}
