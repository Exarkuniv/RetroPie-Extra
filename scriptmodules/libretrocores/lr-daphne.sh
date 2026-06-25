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

rp_module_id="lr-daphne"
rp_module_desc="lr-daphne - Daphne port for libretro - laserdisk games"
rp_module_help="ROM Extension: .zip\n\nCopy your Daphne roms to $romdir/daphne. See readme file for directory structure."
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/daphne/master/docs/mame.txt"
rp_module_repo="git https://github.com/libretro/daphne.git master"
rp_module_section="exp"
rp_module_flags=" !rpi5"

function sources_lr-daphne() {
    gitPullOrClone
}

function build_lr-daphne() {
    rpSwap on 750
    make clean
    local params=()
    isPlatform "arm" && params+=("ARM=1")
    make ARCH="$CFLAGS" "${params[@]}" || return 1
    rpSwap off
    md_ret_require="$md_build/daphne_libretro.so"
}

function install_lr-daphne() {
    md_ret_files=(
        'daphne_libretro.so'
        'README.md'
    )
}

function configure_lr-daphne() {
    mkRomDir "daphne"

    addEmulator 0 "$md_id" "daphne" "$md_inst/daphne_libretro.so"
    addSystem "daphne" "Daphne" ".zip"
}