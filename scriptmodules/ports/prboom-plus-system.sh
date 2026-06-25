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

rp_module_id="prboom-plus-system"
rp_module_desc="Doom/Doom II engine - Enhanced PRBoom Port"
rp_module_licence="https://github.com/coelckers/prboom-plus"
rp_module_repo="git https://github.com/coelckers/prboom-plus.git master"
rp_module_section="exp"

function depends_prboom-plus-system() {
    getDepends libsdl2-dev libsdl2-net-dev libsdl2-image-dev libpcre3-dev libsdl2-mixer-dev libfluidsynth-dev libportmidi-dev libmad0-dev libdumb1-dev libvorbis-dev
}

function sources_prboom-plus-system() {
    gitPullOrClone
}

function build_prboom-plus-system() {
    cd prboom2 || return 1
#    ./bootstrap
#    ./configure
    cmake . || return 1
    make || return 1
    md_ret_require="$md_build/prboom2/prboom-plus"
}

function install_prboom-plus-system() {
    md_ret_files=(
        'prboom2/prboom-plus'
        'prboom2/prboom-plus.wad'
    )
}

function game_data_prboom-plus() {
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
function configure_prboom-plus-system() {
    mkUserDir "$home/.config"
    setConfigRoot ""

    mv $md_inst/prboom-plus.wad "$home/.prboom-plus/prboom-plus.wad" || return 1

    addEmulator 1 "prboom-plus" "doom" "$md_inst/prboom-plus -iwad %ROM%"
    addSystem "doom" "DOOM" ".pk3 .wad"
	
    moveConfigDir "$home/.prboom-plus" "$md_conf_root/prboom-plus"

    [[ "$md_mode" == "install" ]] && game_data_prboom-plus
    [[ "$md_mode" == "remove" ]] && return
}