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

rp_module_id="lr-simcoupe"
rp_module_desc="SAM Coupe emulator - SimCoupe port for libretro"
rp_module_help="ROM Extensions: .dsk .mgt .sbt .sad\n\nCopy your Sam Coupe games to $romdir/samcoupe"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/libretro-simcoupe/master/SimCoupe/License.txt"
rp_module_repo="git https://github.com/libretro/libretro-simcoupe.git master"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-simcoupe() {
    gitPullOrClone
}

function build_lr-simcoupe() {
    make clean
    make || return 1
    mv "libretro-simcp.so" "simcp_libretro.so" || return 1
    md_ret_require="$md_build/simcp_libretro.so"
}

function install_lr-simcoupe() {
    md_ret_files=(
	'SimCoupe/SimCoupe.txt'
	'readme.txt'
	'simcp_libretro.so'
    )
}

function configure_lr-simcoupe() {
    mkRomDir "samcoupe"
    ensureSystemretroconfig "samcoupe"

    addEmulator 1 "$md_id" "samcoupe" "$md_inst/simcp_libretro.so"
    addSystem "samcoupe" "Samcoupe" ".dsk .mgt .sbt .sad .zip"
}