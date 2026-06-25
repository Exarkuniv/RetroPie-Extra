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
    mkdir build && cd build
    cmake ..
    make
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
    _download_doom_port_wads
}

function configure_eternity() {
    mkUserDir "$home/.config"
    moveConfigDir "$home/.config/eternity" "$md_conf_root/eternity"

    _add_doom_wad_ports "eternity" "Eternity" "$md_inst/eternity"
    _add_heretic_hexen_strife_ports "eternity" "Eternity" "$md_inst/eternity" "" "$md_inst/eternity"

    [[ "$md_mode" == "install" ]] && game_data_eternity
    [[ "$md_mode" == "remove" ]] && return

}
