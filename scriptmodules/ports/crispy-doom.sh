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

rp_module_id="crispy-doom"
rp_module_desc="Crispy Doom - Enhanced port of the official DOOM source"
rp_module_licence="GPL2 https://raw.githubusercontent.com/fabiangreffrath/crispy-doom/master/COPYING"
rp_module_help="Please add your iWAD files to $romdir/ports/doom/ and reinstall crispy-doom to create entries for each game to EmulationStation. Run 'crispy-setup' to configure your controls and options."
rp_module_repo="git https://github.com/fabiangreffrath/crispy-doom.git master cb20512"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_crispy-doom() {
    getDepends libsdl2-dev libsdl2-mixer-dev libsdl2-net-dev python3-pil automake autoconf
}

function sources_crispy-doom() {
    gitPullOrClone
}

function build_crispy-doom() {
    ./autogen.sh
    ./configure --prefix="$md_inst"
    make || return 1
    md_ret_require="$md_build/src/crispy-doom"
}

function install_crispy-doom() {
    md_ret_files=(
        'src/crispy-doom'
        'src/crispy-doom-setup'
        'src/crispy-setup'
        'src/crispy-server'
    )
}

function game_data_doom() {
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

function configure_crispy-doom() {
    mkUserDir "$home/.config"
    moveConfigDir "$home/.crispy-doom" "$md_conf_root/crispy-doom"

    # Temporary until the official RetroPie WAD selector is complete.
    if [[ -f "$romdir/ports/doom/doom1.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/doom1.wad"
       addPort "$md_id" "crispy-doom1" "Crispy Doom Shareware" "$md_inst/crispy-doom -iwad $romdir/ports/doom/doom1.wad"
    fi

    if [[ -f "$romdir/ports/doom/doom.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/doom.wad"
       addPort "$md_id" "crispy-doom" "Crispy Doom Registered" "$md_inst/crispy-doom -iwad $romdir/ports/doom/doom.wad"
    fi

    if [[ -f "$romdir/ports/doom/freedoom1.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/freedoom1.wad"
       addPort "$md_id" "crispy-freedoom1" "Crispy Free Doom: Phase 1" "$md_inst/crispy-doom -iwad $romdir/ports/doom/freedoom1.wad"
    fi

    if [[ -f "$romdir/ports/doom/freedoom2.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/freedoom2.wad"
       addPort "$md_id" "crispy-freedoom2" "Crispy Free Doom: Phase 2" "$md_inst/crispy-doom -iwad $romdir/ports/doom/freedoom2.wad"
    fi

    if [[ -f "$romdir/ports/doom/doom2.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/doom2.wad"
       addPort "$md_id" "crispy-doom2" "Crispy Doom II: Hell on Earth" "$md_inst/crispy-doom -iwad $romdir/ports/doom/doom2.wad"
    fi

    if [[ -f "$romdir/ports/doom/doomu.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/doomu.wad"
       addPort "$md_id" "crispy-doomu" "Crispy Ultimate Doom" "$md_inst/crispy-doom -iwad $romdir/ports/doom/doomu.wad"
    fi

    if [[ -f "$romdir/ports/doom/tnt.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/tnt.wad"
       addPort "$md_id" "crispy-doomtnt" "Crispy Final Doom - TNT: Evilution" "$md_inst/crispy-doom -iwad $romdir/ports/doom/tnt.wad"
    fi

    if [[ -f "$romdir/ports/doom/plutonia.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/plutonia.wad"
       addPort "$md_id" "crispy-doomplutonia" "Crispy Final Doom - The Plutonia Experiment" "$md_inst/crispy-doom -iwad $romdir/ports/doom/plutonia.wad"
    fi

    [[ "$md_mode" == "install" ]] && game_data_doom
    [[ "$md_mode" == "remove" ]] && return

}
