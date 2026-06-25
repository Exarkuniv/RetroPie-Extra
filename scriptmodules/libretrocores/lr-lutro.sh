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

rp_module_id="lr-lutro"
rp_module_desc="Lua engine - lua game framework (WIP) for libretro following the LÖVE API"
rp_module_help="ROM Extensions: .lutro .lua\n\nCopy your Lua Lutro games to $romdir/lutro"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/libretro-lutro/master/LICENSE"
rp_module_repo="git https://github.com/libretro/libretro-lutro.git master"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-lutro() {
    gitPullOrClone
}

function build_lr-lutro() {
    make clean
    make || return 1
    md_ret_require="$md_build/lutro_libretro.so"
}

function install_lr-lutro() {
    md_ret_files=(
	'lutro_libretro.so'
    )
}

function configure_lr-lutro() {
    mkRomDir "lutro"
    ensureSystemretroconfig "lutro"

    addEmulator 1 "$md_id" "lutro" "$md_inst/lutro_libretro.so"
    addSystem "lutro" "lutro" ".lutro .lua"
}