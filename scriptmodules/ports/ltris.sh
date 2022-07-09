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

rp_module_id="ltris"
rp_module_desc="ltris - Open Source Tetris game"
rp_module_licence="GPL2 https://sourceforge.net/p/lgames/code/HEAD/tree/trunk/ltris/COPYING"
rp_module_section="exp"
rp_module_flags="!mali"

function depends_ltris() {
    getDepends xorg
}

function install_bin_ltris() {
     aptInstall ltris
}

function configure_ltris() {
    mkRomDir "ports"
    moveConfigFile "$home/.lgames/ltris.conf" "$md_conf_root/ltris/ltris.conf"
    addPort "$md_id" "ltris" "ltris - Open Source Tetris game" "XINIT: /usr/games/ltris"
}
