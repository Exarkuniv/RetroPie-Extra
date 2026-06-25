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

rp_module_id="chocolate-doom"
rp_module_desc="Chocolate Doom - Enhanced port of the official DOOM source"
rp_module_licence="GPL2 https://raw.githubusercontent.com/chocolate-doom/chocolate-doom/sdl2-branch/COPYING"
rp_module_help="Please add your iWAD files to $romdir/ports/doom/ and reinstall chocolate-doom to create entries for each game to EmulationStation. Run 'chocolate-doom-setup' to configure your controls and options."
rp_module_repo="git https://github.com/chocolate-doom/chocolate-doom.git master 640de9f"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_chocolate-doom() {
    getDepends libsdl2-dev libsdl2-net-dev libsdl2-mixer-dev libsamplerate0-dev libpng-dev python3-pil automake autoconf
}

function sources_chocolate-doom() {
    gitPullOrClone
}

function build_chocolate-doom() {
    ./autogen.sh
    ./configure --prefix="$md_inst"
    make || return 1
    md_ret_require="$md_build/src/chocolate-doom"
    md_ret_require="$md_build/src/chocolate-hexen"
    md_ret_require="$md_build/src/chocolate-heretic"
    md_ret_require="$md_build/src/chocolate-strife"
}

function install_chocolate-doom() {
    md_ret_files=(
        'src/chocolate-doom'
        'src/chocolate-hexen'
        'src/chocolate-heretic'
        'src/chocolate-strife'
        'src/chocolate-doom-setup'
        'src/chocolate-hexen-setup'
        'src/chocolate-heretic-setup'
        'src/chocolate-strife-setup'
        'src/chocolate-setup'
        'src/chocolate-server'
    )
}

function game_data_chocolate-doom() {
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

function configure_chocolate-doom() {
    mkUserDir "$home/.config"
    moveConfigDir "$home/.chocolate-doom" "$md_conf_root/chocolate-doom"

    # Temporary until the official RetroPie WAD selector is complete.
    if [[ -f "$romdir/ports/doom/doom1.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/doom1.wad"
       addPort "$md_id" "chocolate-doom1" "Chocolate Doom Shareware" "$md_inst/chocolate-doom -iwad $romdir/ports/doom/doom1.wad"
    fi

    if [[ -f "$romdir/ports/doom/doom.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/doom.wad"
       addPort "$md_id" "chocolate-doom" "Chocolate Doom Registered" "$md_inst/chocolate-doom -iwad $romdir/ports/doom/doom.wad"
    fi

    if [[ -f "$romdir/ports/doom/freedoom1.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/freedoom1.wad"
       addPort "$md_id" "chocolate-freedoom1" "Chocolate Free Doom: Phase 1" "$md_inst/chocolate-doom -iwad $romdir/ports/doom/freedoom1.wad"
    fi

    if [[ -f "$romdir/ports/doom/freedoom2.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/freedoom2.wad"
       addPort "$md_id" "chocolate-freedoom2" "Chocolate Free Doom: Phase 2" "$md_inst/chocolate-doom -iwad $romdir/ports/doom/freedoom2.wad"
    fi

    if [[ -f "$romdir/ports/doom/doom2.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/doom2.wad"
       addPort "$md_id" "chocolate-doom2" "Chocolate Doom II: Hell on Earth" "$md_inst/chocolate-doom -iwad $romdir/ports/doom/doom2.wad"
    fi

    if [[ -f "$romdir/ports/doom/doomu.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/doomu.wad"
       addPort "$md_id" "chocolate-doomu" "Chocolate Ultimate Doom" "$md_inst/chocolate-doom -iwad $romdir/ports/doom/doomu.wad"
    fi

    if [[ -f "$romdir/ports/doom/tnt.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/tnt.wad"
       addPort "$md_id" "chocolate-doomtnt" "Chocolate Final Doom - TNT: Evilution" "$md_inst/chocolate-doom -iwad $romdir/ports/doom/tnt.wad"
    fi

    if [[ -f "$romdir/ports/doom/plutonia.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/plutonia.wad"
       addPort "$md_id" "chocolate-doomplutonia" "Chocolate Final Doom - The Plutonia Experiment" "$md_inst/chocolate-doom -iwad $romdir/ports/doom/plutonia.wad"
    fi

    if [[ -f "$romdir/ports/doom/heretic1.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/heretic1.wad"
       addPort "$md_id" "chocolate-heretic1" "Chocolate Heretic Shareware" "$md_inst/chocolate-heretic -iwad $romdir/ports/doom/heretic1.wad"
    fi

    if [[ -f "$romdir/ports/doom/heretic.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/heretic.wad"
       addPort "$md_id" "chocolate-heretic" "Chocolate Heretic Registered" "$md_inst/chocolate-heretic -iwad $romdir/ports/doom/heretic.wad"
    fi

    if [[ -f "$romdir/ports/doom/hexen.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/hexen.wad"
       addPort "$md_id" "chocolate-hexen" "Chocolate Hexen" "$md_inst/chocolate-hexen -iwad $romdir/ports/doom/hexen.wad"
    fi

    if [[ -f "$romdir/ports/doom/hexdd.wad" && -f "$romdir/ports/doom/hexen.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/hexdd.wad"
       addPort "$md_id" "chocolate-hexdd" "Chocolate Hexen: Deathkings of the Dark Citadel" "$md_inst/chocolate-hexen -iwad $romdir/ports/doom/hexen.wad -file $romdir/ports/doom/hexdd.wad"
    fi

    if [[ -f "$romdir/ports/doom/strife1.wad" ]]; then
       chown $user:$user "$romdir/ports/doom/strife1.wad"
       addPort "$md_id" "chocolate-strife1" "Chocolate Strife" "$md_inst/chocolate-strife -iwad $romdir/ports/doom/strife1.wad"
    fi

    [[ "$md_mode" == "install" ]] && game_data_chocolate-doom
    [[ "$md_mode" == "remove" ]] && return

}
