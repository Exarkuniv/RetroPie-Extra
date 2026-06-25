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

rp_module_id="lr-thepowdertoy"
rp_module_desc="Sandbox physics game for libretro"
rp_module_help="Have you ever wanted to blow something up? Or maybe you always dreamt of operating an atomic power plant? Do you have a will to develop your own CPU? The Powder Toy lets you to do all of these, and even more!"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/ThePowderToy/master/LICENSE"
rp_module_repo="git https://github.com/libretro/ThePowderToy.git master"
rp_module_section="exp"
rp_module_flags=""

function depends_lr-thepowdertoy() {
    local depends=(build-essential cmake)
    getDepends "${depends[@]}"
}

function sources_lr-thepowdertoy() {
    gitPullOrClone
}

function build_lr-thepowdertoy() {
    mkdir -p build && cd build
    make clean
    cmake .. -DCMAKE_BUILD_TYPE=Release || return 1
    make || return 1
    md_ret_require="$md_build/build/src/thepowdertoy_libretro.so"
}

function install_lr-thepowdertoy() {
    md_ret_files=(
	'README.md'
	'build/src/thepowdertoy_libretro.so'
    )
}

function configure_lr-thepowdertoy() {
    setConfigRoot "ports"

    addPort "$md_id" "thepowdertoy" "The Powder Toy" "$md_inst/thepowdertoy_libretro.so"

    ensureSystemretroconfig "ports/thepowdertoy"
}