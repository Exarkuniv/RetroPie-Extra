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

rp_module_id="eternity"
rp_module_desc="Eternity Doom - Enhanced port of the official DOOM source"
rp_module_licence="GPL3 https://github.com/team-eternity/eternity/blob/master/COPYING"
rp_module_help="Please add your iWAD files to $romdir/ports/doom/ and reinstall eternity to create entries for each game to EmulationStation. Run 'chocolate-doom-setup' to configure your controls and options."
rp_module_repo="git https://github.com/team-eternity/eternity.git master ab01fc5"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_eternity() {
    getDepends libsdl2-dev libsdl2-net-dev libsdl2-mixer-dev libsamplerate0-dev libpng-dev python3-pil automake autoconf
}

function sources_eternity() {
    gitPullOrClone
}

function build_eternity() {
    git submodule update --init
    mkdir -p build && cd build
    cmake .. || return 1
    make || return 1
    md_ret_require=
}

function install_eternity() {
    md_ret_files=(
        'build/eternity/eternity'
	'build/eternity/base'
	'build/eternity/user'
           )
}

function game_data_eternity() {
    mkRomDir "ports"
    mkRomDir "ports/doom"
    if [[ ! -f "$romdir/ports/doom/doom1.wad" ]]; then
        wget "$__archive_url/doom1.wad" -O "$romdir/ports/doom/doom1.wad" || return 1
    fi

    if [[ ! -f "$romdir/ports/doom/freedoom1.wad" ]]; then
        wget "https://github.com/freedoom/freedoom/releases/download/v0.12.1/freedoom-0.12.1.zip" || return 1
        unzip freedoom-0.12.1.zip || return 1
        mv freedoom-0.12.1/*.wad "$romdir/ports/doom" || return 1
        rm -rf freedoom-0.12.1
        rm freedoom-0.12.1.zip
    fi
}

function configure_eternity() {
    mkUserDir "$home/.config"
    moveConfigDir "$home/.config/eternity" "$md_conf_root/eternity"

    # Temporary until the official RetroPie WAD selector is complete.
    if [[ -f "$romdir/ports/doom/doom1.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/doom1.wad"
       addPort "$md_id" "eternity-doom1" "Eternity Doom Shareware" "$md_inst/eternity -iwad $romdir/ports/doom/doom1.wad"
    fi

    if [[ -f "$romdir/ports/doom/doom.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/doom.wad"
       addPort "$md_id" "eternity-doom" "Eternity Doom Registered" "$md_inst/eternity -iwad $romdir/ports/doom/doom.wad"
    fi

    if [[ -f "$romdir/ports/doom/freedoom1.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/freedoom1.wad"
       addPort "$md_id" "eternity-freedoom1" "Eternity Free Doom: Phase 1" "$md_inst/eternity -iwad $romdir/ports/doom/freedoom1.wad"
    fi

    if [[ -f "$romdir/ports/doom/freedoom2.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/freedoom2.wad"
       addPort "$md_id" "eternity-freedoom2" "Eternity Free Doom: Phase 2" "$md_inst/eternity -iwad $romdir/ports/doom/freedoom2.wad"
    fi

    if [[ -f "$romdir/ports/doom/doom2.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/doom2.wad"
       addPort "$md_id" "eternity-doom2" "Eternity Doom II: Hell on Earth" "$md_inst/eternity -iwad $romdir/ports/doom/doom2.wad"
    fi

    if [[ -f "$romdir/ports/doom/doomu.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/doomu.wad"
       addPort "$md_id" "eternity-doomu" "Eternity Ultimate Doom" "$md_inst/eternity -iwad $romdir/ports/doom/doomu.wad"
    fi

    if [[ -f "$romdir/ports/doom/tnt.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/tnt.wad"
       addPort "$md_id" "eternity-doomtnt" "Eternity Final Doom - TNT: Evilution" "$md_inst/eternity -iwad $romdir/ports/doom/tnt.wad"
    fi

    if [[ -f "$romdir/ports/doom/plutonia.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/plutonia.wad"
       addPort "$md_id" "eternity-doomplutonia" "Eternity Final Doom - The Plutonia Experiment" "$md_inst/eternity -iwad $romdir/ports/doom/plutonia.wad"
    fi

    if [[ -f "$romdir/ports/doom/heretic1.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/heretic1.wad"
       addPort "$md_id" "eternity-heretic1" "Eternity Heretic Shareware" "$md_inst/eternity -iwad $romdir/ports/doom/heretic1.wad"
    fi

    if [[ -f "$romdir/ports/doom/heretic.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/heretic.wad"
       addPort "$md_id" "eternity-heretic" "Eternity Heretic Registered" "$md_inst/eternity -iwad $romdir/ports/doom/heretic.wad"
    fi

    if [[ -f "$romdir/ports/doom/strife1.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/strife1.wad"
       addPort "$md_id" "eternity-strife1" "Eternity Strife" "$md_inst/eternity -iwad $romdir/ports/doom/strife1.wad"
    fi

    [[ "$md_mode" == "install" ]] && game_data_eternity
    [[ "$md_mode" == "remove" ]] && return

}
