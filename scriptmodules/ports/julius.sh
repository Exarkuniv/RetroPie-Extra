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

rp_module_id="julius"
rp_module_desc="Julius - Caesar III source port"
rp_module_licence="GPL3 https://raw.githubusercontent.com/bvschaik/julius/master/LICENSE.txt"
rp_module_help="Julius requires the original assets (graphics, sounds, etc) from Caesar 3 to run. Add all data files from your Caesar 3 installation folder to $romdir/ports/caesar3"
rp_module_repo="git https://github.com/bvschaik/julius.git master"
rp_module_section="exp"
rp_module_flags=""

function depends_julius() {
    getDepends cmake libsdl2-dev libsdl2-net-dev libsdl2-mixer-dev libsdl2-image-dev
}

function sources_julius() {
    gitPullOrClone
}

function build_julius() {
    cd "$md_build" || return 1
    cmake . || return 1
    make || return 1
    md_ret_require="$md_build"
}

function install_julius() {
    md_ret_files=(
       'julius'
    )
}

function game_data_julius() {
    chown -R $user:$user "$romdir/ports/caesar3"
}

function configure_julius() {
    addPort "$md_id" "julius" "Caesar III" "$md_inst/julius $romdir/ports/caesar3"

    mkRomDir "ports/caesar3"

    mkUserDir "$home/."
    moveConfigDir "$home/.local/share/bvschaik/julius" "$md_conf_root/julius"

    [[ "$md_mode" == "install" ]] && game_data_julius
}