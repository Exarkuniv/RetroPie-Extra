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

rp_module_id="lr-cannonball"
rp_module_desc="An Enhanced OutRun engine for libretro"
rp_module_help="ROM Extensions: .game .88\n\nYou need to unzip your OutRun set B from latest MAME (outrun.zip) to $romdir/ports/cannonball. They should match the file names listed in the roms.txt file found in the roms folder. You will also need to rename the epr-10381a.132 file to epr-10381b.132 before it will work."
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/cannonball/master/docs/license.txt"
rp_module_repo="git https://github.com/libretro/cannonball.git master"
rp_module_section="exp"
rp_module_flags=""

function depends_lr-cannonball() {
    depends_cannonball
}

function sources_lr-cannonball() {
    gitPullOrClone
}

function build_lr-cannonball() {
    > CannonBall.game
    make clean
    make || return 1
    md_ret_require="$md_build/cannonball_libretro.so"
}

function install_lr-cannonball() {
    md_ret_files=(
	'CannonBall.game'
	'cannonball_libretro.so'
    )
}

function configure_lr-cannonball() {
    local script
    setConfigRoot "ports"

    mkRomDir "ports/cannonball"

    mv "$md_inst/CannonBall.game" "$romdir/ports/cannonball" || return 1

    addPort "$md_id" "cannonball" "Cannonball - OutRun Engine" "$md_inst/cannonball_libretro.so" "$romdir/ports/cannonball/CannonBall.game"

    ensureSystemretroconfig "ports/cannonball"
}