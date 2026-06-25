#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-bsnes-jg"
rp_module_desc="Super Nintendo Emulator - bsnes-jg is a cycle accurate emulator libretro"
rp_module_help="ROM Extensions: .bml .smc .sfc .zip\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="GPL3 https://github.com/libretro/bsnes-jg?tab=GPL-3.0-1-ov-file#readme"
rp_module_repo="git https://github.com/libretro/bsnes-jg libretro"
rp_module_section="exp"
rp_module_flags="!mali"

function depends_lr-bsnes-jg() {
    getDepends build-essential libgtk2.0-dev libpulse-dev mesa-common-dev libcairo2-dev libsdl2-dev libxv-dev libao-dev libopenal-dev libasound2-dev libudev-dev
}

function sources_lr-bsnes-jg() {
    gitPullOrClone
}

function build_lr-bsnes-jg() {
    local params=(target="libretro" build="release" binary="library" CXXFLAGS="$CXXFLAGS" platform="linux" local="false")
    cd libretro
    make clean
    make
    md_ret_require="$md_build/libretro/bsnes-jg_libretro.so"
}

function install_lr-bsnes-jg() {
    md_ret_files=(
        'libretro/bsnes-jg_libretro.so'
        'README'
    )
}

function configure_lr-bsnes-jg() {
    local system
    for system in satellaview sfc sfc-t snes snesh snesmsu1 snes-proto snes-unl sufami; do
    mkRomDir "$system"
    defaultRAConfig "$system"
    addEmulator 0 "$md_id" "$system" "$md_inst/bsnes-jg_libretro.so"
    addSystem "$system"
}
