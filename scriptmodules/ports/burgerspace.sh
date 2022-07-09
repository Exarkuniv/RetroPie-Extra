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

rp_module_id="burgerspace"
rp_module_desc="BurgerSpace - BurgerTime clone"
rp_module_help="Because this uses X, you may find that you are unable to control the game and the game appears in a small window in the top left. Use the Runcommand option to set the resolution to CEA-4 or similarly smaller sizes. This will allow you to control the game as the window will have focus and also fill up more of the screen."
rp_module_licence="GPL2 https://www.gnu.org/licenses/gpl-2.0.txt"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_burgerspace() {
    getDepends xorg
}

function install_bin_burgerspace() {
    aptInstall burgerspace
}

function configure_burgerspace() {
    mkRomDir "ports"

    moveConfigDir "$home/.burgerspace" "$md_conf_root/$md_id"
    addPort "$md_id" "burgerspace" "BurgerSpace - BurgerTime clone" "XINIT: /usr/games/burgerspace"
}
