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

rp_module_id="librecad"
rp_module_desc="librecad open-source 2d cad"
rp_module_licence="https://www.audacityteam.org"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_librecad() {
    getDepends xorg matchbox
}

function install_bin_librecad() {
    aptInstall librecad
}

function configure_librecad() {
    mkRomDir "ports"
    mkdir -p "$md_inst"
    moveConfigDir "$home/.config/$md_id" "$md_conf_root/ports/$md_id"
    cat >"$md_inst/librecad.sh" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
/usr/bin/librecad
_EOF_
    chmod +x "$md_inst/librecad.sh"

    addPort "$md_id" "librecad" "LibreCAD - Free Open Source 2D CAD" "XINIT: $md_inst/librecad.sh"
    mv "$md_conf_root/$md_id" "$md_conf_root/ports" || return 1
}