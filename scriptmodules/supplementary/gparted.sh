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

rp_module_id="gparted"
rp_module_desc="partition editing application"
rp_module_licence="https://gparted.org"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_gparted() {
    getDepends xorg matchbox
}

function install_bin_gparted() {
    aptInstall gparted
}

function configure_gparted() {
    mkRomDir "ports"
    mkdir -p "$md_inst"
    moveConfigDir "$home/.config/$md_id" "$md_conf_root/ports/$md_id"
    cat >"$md_inst/gparted.sh" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
sudo /usr/sbin/gpartedbin
_EOF_
    chmod +x "$md_inst/gparted.sh"

    addPort "$md_id" "gparted" "Gparted partition editing application" "XINIT: $md_inst/gparted.sh"
    mv "$md_conf_root/$md_id" "$md_conf_root/ports" || return 1
}