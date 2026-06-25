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

rp_module_id="eternity-system"
rp_module_desc="Eternity Doom - Enhanced port of the official DOOM source"
rp_module_licence="GPL3 https://github.com/team-eternity/eternity/blob/master/COPYING"
rp_module_help="Please add your iWAD files to $romdir/ports/doom/ and reinstall eternity to create entries for each game to EmulationStation. Run 'chocolate-doom-setup' to configure your controls and options."
rp_module_repo="git https://github.com/team-eternity/eternity.git master ab01fc5"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_eternity-system() {
    getDepends libsdl2-dev libsdl2-net-dev libsdl2-mixer-dev libsamplerate0-dev libpng-dev python3-pil automake autoconf
}

function sources_eternity-system() {
    gitPullOrClone
}

function build_eternity-system() {
    git submodule update --init
    mkdir build && cd build
    cmake ..
    make
    md_ret_require=
}

function install_eternity-system() {
    md_ret_files=(
        'build/eternity/eternity'
	'build/eternity/base'
	'build/eternity/user'
           )
}

function game_data_doom() {
    _download_doom_system_wads
}

function configure_eternity-system() {
    mkUserDir "$home/.config"
    setConfigRoot ""
    addEmulator 1 "eternity" "doom" "$md_inst/eternity -iwad %ROM%"
    addSystem "doom" "DOOM" ".pk3 .wad"

    moveConfigDir "$home/.config/eternity" "$md_conf_root/eternity"

    [[ "$md_mode" == "install" ]] && game_data_doom
    [[ "$md_mode" == "remove" ]] && return
}
