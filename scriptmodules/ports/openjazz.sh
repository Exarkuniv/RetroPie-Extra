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

rp_module_id="openjazz"
rp_module_desc="OpenJazz - An enhanced Jazz Jackrabbit source port"
rp_module_licence="GPL2 https://raw.githubusercontent.com/AlisterT/openjazz/master/COPYING"
rp_module_help="For playing the registered version, replace the shareware files by adding your full version game files to $romdir/ports/openjazz/."
rp_module_repo="git https://github.com/AlisterT/openjazz.git master"
rp_module_section="exp"
rp_module_flags="!all rpi4 rpi3 rpi5"

function depends_openjazz() {
    getDepends libsdl1.2-dev libsdl-net1.2-dev libsdl-sound1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev timidity freepats libxmp-dev
}

function sources_openjazz() {
    gitPullOrClone
}

function build_openjazz() {
    cmake -B OJ -S . || return 1
    cmake --build OJ || return 1
    md_ret_require="$md_build/OJ/OpenJazz"
}

function install_openjazz() {
    md_ret_files=(
        'OJ/OpenJazz'
    )
}

function game_data_openjazz() {
    if [[ ! -f "$romdir/ports/jazz/JAZZ.EXE" ]]; then
        downloadAndExtract "https://image.dosgamesarchive.com/games/jazz.zip" "$romdir/ports/jazz"
        chown -R $user:$user "$romdir/ports/jazz"
    fi
}

function configure_openjazz() {
    mkRomDir "ports/jazz"
    moveConfigDir "$home/.openjazz" "$md_conf_root/jazz"
    addPort "$md_id" "jazz" "OpenJazz - An enhanced Jazz Jackrabbit source port" "pushd $md_conf_root/jazz; $md_inst/OpenJazz -f $romdir/ports/jazz; popd"

    [[ "$md_mode" == "install" ]] && game_data_openjazz
}