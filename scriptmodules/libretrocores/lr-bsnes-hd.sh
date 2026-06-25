#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-bsnes-hd"
rp_module_desc="Super Nintendo Emulator - bsnes-HD port for libretro (BETA)"
rp_module_help="ROM Extensions: .bml .smc .sfc .zip\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="GPL3 https://raw.githubusercontent.com/DerKoun/bsnes-hd/master/LICENSE"
rp_module_repo="git https://github.com/DerKoun/bsnes-hd master"
rp_module_section="exp"
rp_module_flags="!mali"

function depends_lr-bsnes-hd() {
    getDepends build-essential libgtk2.0-dev libpulse-dev mesa-common-dev libcairo2-dev libsdl2-dev libxv-dev libao-dev libopenal-dev libasound2-dev libudev-dev
}

function sources_lr-bsnes-hd() {
    gitPullOrClone
}

function build_lr-bsnes-hd() {
    local params=(target="libretro" build="release" binary="library" CXXFLAGS="$CXXFLAGS" platform="linux" local="false")
    make -C bsnes clean "${params[@]}"
    make -C bsnes "${params[@]}"
    md_ret_require="$md_build/bsnes/out/bsnes_hd_beta_libretro.so"
}

function install_lr-bsnes-hd() {
    md_ret_files=(
        'bsnes/out/bsnes_hd_beta_libretro.so'
        'pack/GPLv3.txt'
        'LICENSE'
        'README.md'
    )
}

function configure_lr-bsnes-hd() {
    local system
    for system in satellaview sfc sfc-t snes snesh snesmsu1 snes-proto snes-unl sufami; do
    mkRomDir "$system"
    defaultRAConfig "$system"
    addEmulator 0 "$md_id" "$system" "$md_inst/bsnes_hd_beta_libretro.so"
    addSystem "$system"
}
