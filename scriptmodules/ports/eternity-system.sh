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
    mkdir -p build && cd build
    cmake .. || return 1
    make || return 1
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
    mkRomDir "doom"
    if [[ ! -f "$romdir/doom/doom1.wad" ]]; then
        wget "$__archive_url/doom1.wad" -O "$romdir/doom/doom1.wad" || return 1
    fi

    if [[ ! -f "$romdir/doom/freedoom1.wad" ]]; then
        wget "https://github.com/freedoom/freedoom/releases/download/v0.12.1/freedoom-0.12.1.zip" || return 1
        unzip freedoom-0.12.1.zip || return 1
        mv freedoom-0.12.1/*.wad "$romdir/doom" || return 1
        rm -rf freedoom-0.12.1
        rm freedoom-0.12.1.zip
    fi
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
