#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="xm8"
rp_module_desc="NEC PC-8801 emulator"
rp_module_help="ROM Extensions: .d88 .t77 .d88 .2d \n\nCopy your PC-8801 games to to $romdir/pc88\n\nCopy your P-8801 bios files N80.ROM, N88.ROM, N88_0.ROM, N88_1.ROM, N88_2.ROM, N88_3.ROM ,KANJI1.ROM, KANJI2.ROM, DISK.ROM, PC88.ROM to $biosdir/pc88"
rp_module_licence="https://raw.githubusercontent.com/bubio/xm8mac/bdfbcd1a40d55e9db4df7720b871bf916dac13f9/LICENSE"
rp_module_repo="git https://github.com/bubio/xm8mac.git main"
rp_module_section="exp"
rp_module_flags="sdl2"

function depends_xm8() {
    getDepends build-essential cmake libsdl2-dev
}

function sources_xm8() {
    gitPullOrClone
}

function build_xm8() {
    mkdir -p build
    cd build || return 1
    cmake .. || return 1
    make clean
    make || return 1
}

function install_xm8() {
    md_ret_files=(
        "/build/xm8"
        "LICENSE"
        "README.md"
        "CHANGELOG.md"
    )
}

function configure_xm8() {
    mkRomDir "pc88"
    moveConfigDir "$home/.local/share/retro_pc_pi/xm8" "$biosdir/xm8"

    addEmulator 0 "$md_id" "xm8" "$md_inst/xm8 %ROM%"
    addEmulator 1 "$md_id" "xm8_V1S_Mode" "$md_inst/xm8 --system V1S %ROM%"
    addSystem "pc88"

    [[ "$md_mode" == "remove" ]] && return
}
