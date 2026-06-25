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

rp_module_id="lr-vemulator"
rp_module_desc="SEGA VMU emulator - VeMUlator port for libretro"
rp_module_help="ROM Extensions: .vms .dci .bin\n\nCopy your Sega VMU games to $romdir/vmu"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/vemulator-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/vemulator-libretro master"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-vemulator() {
    gitPullOrClone
}

function build_lr-vemulator() {
    make clean
    make || return 1
    md_ret_require="$md_build/vemulator_libretro.so"
}

function install_lr-vemulator() {
    md_ret_files=(
    	'COPYING'
        'vemulator_libretro.so'
    )
}

function configure_lr-vemulator() {
    mkRomDir "vmu"
    ensureSystemretroconfig "vmu"

    addEmulator 1 "$md_id" "vmu" "$md_inst/vemulator_libretro.so"
    addSystem "vmu" "Visual Memory Unit" ".dci .vms .bin .zip"
}