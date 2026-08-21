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

rp_module_id="barrage"
rp_module_desc="barrage - Shooting Range action game"
rp_module_licence="GPL2 https://sourceforge.net/p/lgames/code/HEAD/tree/trunk/barrage/COPYING"
rp_module_section="exp"
rp_module_flags="!mali"

function depends_barrage() {
   getDepends xorg xinit x11-xserver-utils
}

function install_bin_barrage() {
     aptInstall barrage
}

function configure_barrage() {

    addPort "$md_id" "barrage" "barrage - Shooting Range action game" "XINIT: /usr/games/barrage"
}
