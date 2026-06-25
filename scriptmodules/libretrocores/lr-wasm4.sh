#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-wasm4"
rp_module_desc="WebAssembly (WASM-4)"
rp_module_help="ROM Extensions: .wasm .WASM"
rp_module_repo="git https://github.com/aduros/wasm4.git main"
rp_module_section="exp"

function sources_lr-wasm4() {
    gitPullOrClone
}

function build_lr-wasm4() {
    cd runtimes/native || return 1
    cmake -B build || return 1
    cmake --build build || return 1
}

function install_lr-wasm4() {
    md_ret_files=(
        'runtimes/native/build/wasm4_libretro.so'
    )
}

function configure_lr-wasm4() {
    mkRomDir "wasm4"

    mkUserDir "$md_conf_root/wasm4"

    addEmulator 1 "$md_id" "wasm4" "$md_inst/wasm4_libretro.so"
    addSystem "wasm4" "Wasm4" ".zip .ZIP .wasm .WASM"
}
