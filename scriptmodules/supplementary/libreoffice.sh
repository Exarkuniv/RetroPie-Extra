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

rp_module_id="libreoffice"
rp_module_desc="Open source office suite"
rp_module_licence="https://www.libreoffice.org"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_libreoffice() {
    getDepends xorg matchbox
}

function install_bin_libreoffice() {
    aptInstall libreoffice
}

function configure_libreoffice() {
    mkRomDir "ports"
    mkdir -p "$md_inst"
    moveConfigDir "$home/.config/$md_id" "$md_conf_root/ports/$md_id"
    cat >"$md_inst/libreoffice.sh" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
/usr/bin/libreoffice
_EOF_
    chmod +x "$md_inst/libreoffice.sh"

    addPort "$md_id" "libreoffice" "LibreOffice Open Source office suite" "XINIT: $md_inst/libreoffice.sh"
    mv "$md_conf_root/$md_id" "$md_conf_root/ports" || return 1
}