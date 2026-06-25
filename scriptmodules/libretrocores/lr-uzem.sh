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

rp_module_id="lr-uzem"
rp_module_desc="Uzebox engine - Uzem port for libretro"
rp_module_help="ROM Extensions: .uze\n\nCopy your ROM files to $romdir/uzebox"
rp_module_licence="GPL3 https://raw.githubusercontent.com/Uzebox/uzebox/master/gpl-3.0.txt"
rp_module_repo="git https://github.com/libretro/libretro-uzem.git master"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-uzem() {
    gitPullOrClone
}

function build_lr-uzem() {
    _build_libretro_core "uzem"
}

function install_lr-uzem() {
    md_ret_files=(
        'uzem_libretro.so'
    )
}

function configure_lr-uzem() {
    _configure_libretro_system "uzebox" "uzem_libretro.so" 1 "Uzem" ".uze .zip"
}