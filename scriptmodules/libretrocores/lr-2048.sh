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

rp_module_id="lr-2048"
rp_module_desc="2048 engine - 2048 port for libretro"
rp_module_licence="Unl https://raw.githubusercontent.com/libretro/libretro-2048/master/COPYING"
rp_module_repo="git https://github.com/libretro/libretro-2048.git master"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-2048() {
    gitPullOrClone
}

function build_lr-2048() {
    _build_libretro_core "2048"
}

function install_lr-2048() {
    md_ret_files=(
        '2048_libretro.so'
    )
}

function configure_lr-2048() {
    _configure_libretro_port "2048" "2048" "2048_libretro.so"
}