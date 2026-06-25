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

rp_module_id="lr-easyrpg"
rp_module_desc="RPG Maker 2000/2003 engine - EasyRPG Player interpreter port for libretro."
rp_module_help="ROM Extension: .ldb\n\nYou need to unzip your RPG Maker games into subdirectories in $romdir/ports/easyrpg/games\n\nRTP file:\nExtract the RTP files from their respective .exe installers and then copy RTP 2000 files in $biosdir/rtp/2000 and RTP 2003 files in $biosdir/rtp/2003."
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/easyrpg-libretro/master/COPYING"
rp_module_repo="git https://github.com/libretro/easyrpg-libretro.git master"
rp_module_section="exp"
rp_module_flags=""

function depends_lr-easyrpg() {
    depends_easyrpg-player
}

function sources_lr-easyrpg() {
    gitPullOrClone 
}

function build_lr-easyrpg() {
    mkdir -p build
    cd build || return 1

    cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr -DPLAYER_TARGET_PLATFORM=libretro -DBUILD_SHARED_LIBS=ON || return 1
    cmake --build . || return 1
    md_ret_require="$md_build/build/easyrpg_libretro.so"
}

function install_lr-easyrpg() {
    md_ret_files=(
        'build/easyrpg_libretro.so'
    )
}

function remove_lr-easyrpg() {
    remove_easyrpg-player
}

function configure_lr-easyrpg() {
    setConfigRoot "ports"

    mkRomDir "ports/easyrpg/games"

    addPort "$md_id" "easyrpg" "EasyRPG Player" "$md_inst/easyrpg_libretro.so" "$romdir/ports/easyrpg/games/"

    ensureSystemretroconfig "ports/easyrpg"

    mkUserDir "$biosdir/rtp/2000"
    mkUserDir "$biosdir/rtp/2003"
}