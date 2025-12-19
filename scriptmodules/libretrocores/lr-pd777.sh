#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-pd777"
rp_module_desc="Epoch Cassette Vision emulator - PD777 port for libretro"
rp_module_help="ROM Extensions: .bin777\n\nCopy your PD777 roms to $romdir/cassettevision"
rp_module_licence="MIT https://raw.githubusercontent.com/mittonk/PD777/refs/heads/main/LICENSE"
rp_module_repo="git https://github.com/mittonk/PD777.git main"
rp_module_section="exp"

function sources_lr-pd777() {
    gitPullOrClone
}

function build_lr-pd777() {
    cd source/libretro
    make clean
    make
    md_ret_require="$md_build/source/libretro/pd777_libretro.so"
}

function install_lr-pd777() {
    md_ret_files=(
        'README.md'
        'source/libretro/pd777_libretro.so'
        'LICENSE'
    )
}

function configure_lr-pd777() {
    mkRomDir "cassettevision"
    defaultRAConfig "cassettevision"
    addEmulator 0 "$md_id" "cassettevision" "$md_inst/pd777_libretro.so"
    addSystem "cassettevision" "Cassette Vision" ".bin777"
}
