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
    make
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
    _download_doom_port_wads
}

function configure_crispy-doom() {
    mkUserDir "$home/.config"
    moveConfigDir "$home/.crispy-doom" "$md_conf_root/crispy-doom"

    _add_doom_wad_ports "crispy" "Crispy" "$md_inst/crispy-doom"

    [[ "$md_mode" == "install" ]] && game_data_doom
    [[ "$md_mode" == "remove" ]] && return

}
