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

rp_module_id="pokerth"
rp_module_desc="pokerth is an open source online poker"
rp_module_licence="https://github.com/GNOME/epiphany"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_pokerth() {
    getDepends xorg matchbox
}

function install_bin_pokerth() {
    aptInstall pokerth
}

function configure_pokerth() {
    mkRomDir "ports"
    mkdir -p "$md_inst"
    moveConfigDir "$home/.config" "$md_conf_root/$md_id"
    cat >"$md_inst/pokerth.sh" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
/usr/games/pokerth
_EOF_
    chmod +x "$md_inst/pokerth.sh"
    
     addPort "$md_id" "pokerth" "PokerTH is an Open Source Online Poker" "XINIT: $md_inst/pokerth.sh"
}
