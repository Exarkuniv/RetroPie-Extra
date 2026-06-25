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
    make
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
    _download_doom_port_wads
}

function configure_chocolate-doom() {
    mkUserDir "$home/.config"
    moveConfigDir "$home/.chocolate-doom" "$md_conf_root/chocolate-doom"

    _add_doom_wad_ports "chocolate" "Chocolate" "$md_inst/chocolate-doom"
    _add_heretic_hexen_strife_ports "chocolate" "Chocolate" "$md_inst/chocolate-heretic" "$md_inst/chocolate-hexen" "$md_inst/chocolate-strife"

    [[ "$md_mode" == "install" ]] && game_data_chocolate-doom
    [[ "$md_mode" == "remove" ]] && return

}
