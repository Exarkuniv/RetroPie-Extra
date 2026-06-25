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

source "$(dirname "${BASH_SOURCE[0]}")/../helpers.sh"

rp_module_id="lr-potator"
rp_module_desc="Watara Supervision emulator based on Normmatt version - Potator port for libretro"
rp_module_help="ROM Extensions: .sv .zip .7z\n\nCopy your Watara Supervision roms to $romdir/svision"
rp_module_licence="Unl https://raw.githubusercontent.com/libretro/potator/master/LICENSE"
rp_module_section="exp"
rp_module_repo="git https://github.com/libretro/potator.git master"
rp_module_flags=""

function sources_lr-potator() {
    gitPullOrClone
}

function build_lr-potator() {
    cd "platform/libretro"
    make clean
    make
    md_ret_require="$md_build/platform/libretro/potator_libretro.so"
}

function install_lr-potator() {
    md_ret_files=(
	'LICENSE'
	'platform/libretro/potator_libretro.so'
    )
}

function configure_lr-potator() {
    _configure_libretro_system "potator" "potator_libretro.so" 1 "Watara Supervision" ".sv .SV"
}