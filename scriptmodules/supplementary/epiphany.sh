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

rp_module_id="epiphany"
rp_module_desc="epiphany lightweight web browser"
rp_module_licence="https://github.com/GNOME/epiphany"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_epiphany() {
    getDepends xorg matchbox
}

function install_bin_epiphany() {
    aptInstall epiphany-browser
}

function configure_epiphany() {
    mkRomDir "ports"
    mkdir -p "$md_inst"
    moveConfigDir "$home/.config/$md_id" "$md_conf_root/ports/$md_id"
    cat >"$md_inst/epiphany.sh" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
/usr/bin/epiphany-browser +set in_tty 0
_EOF_
    chmod +x "$md_inst/epiphany.sh"

    addPort "$md_id" "epiphany" "Epiphany Lightweight Web Browser" "XINIT: $md_inst/epiphany.sh"
    mv "$md_conf_root/$md_id" "$md_conf_root/ports" || return 1
}