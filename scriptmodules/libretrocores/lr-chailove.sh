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

rp_module_id="lr-chailove"
rp_module_desc="2D Game Framework with ChaiScript roughly inspired by the LÖVE API to libretro"
rp_module_help="ROM Extension: .chai .chailove\n\nCopy your ChaiLove games to $romdir/love"
rp_module_licence="MIT https://raw.githubusercontent.com/libretro/libretro-chailove/master/COPYING"
rp_module_repo="git https://github.com/libretro/libretro-chailove.git master"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-chailove() {
    gitPullOrClone
}

function build_lr-chailove() {
    make clean
    make || return 1
    md_ret_require="$md_build/chailove_libretro.so"
}

function install_lr-chailove() {
    md_ret_files=(
        'chailove_libretro.so'
    )
}

function configure_lr-chailove() {
    mkRomDir "love"
    ensureSystemretroconfig "love"

    addEmulator 1 "$md_id" "love" "$md_inst/chailove_libretro.so"
    addSystem "love" ".chai .chailove"
}
