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

rp_module_id="crack-attack"
rp_module_desc="Crack-Attack - Tetris Attack clone"
rp_module_licence="GPL2 http://cvs.savannah.nongnu.org/viewvc/*checkout*/crack-attack/crack-attack/COPYING?revision=1.2"
rp_module_help="Because this uses X, you may find that you are unable to control the game and the game appears in a small window in the top left. Use the Runcommand option to set the resolution to CEA-4 or similarly smaller sizes. This will allow you to control the game as the window will have focus and also fill up more of the screen."
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_crack-attack() {
    getDepends cmake xorg
}

function install_bin_crack-attack() {
    aptInstall crack-attack
}

function configure_crack-attack() {
    mkdir -p "ports"
    moveConfigDir "$home/.crack-attack" "$md_conf_root/crack-attack"
    addPort "$md_id" "crack-attack" "Crack-Attack - Tetris Attack clone" "XINIT: crack-attack"
}