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

rp_module_id="putty"
rp_module_desc="SSH and telnet client"
rp_module_licence="https://www.putty.org"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_putty() {
    getDepends xorg matchbox
}

function install_bin_putty() {
    aptInstall putty
}

function configure_putty() {
    mkRomDir "ports"
    mkdir -p "$md_inst"
    moveConfigDir "$home/.config/$md_id" "$md_conf_root/ports/$md_id"
    cat >"$md_inst/putty.sh" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
/usr/bin/putty
_EOF_
    chmod +x "$md_inst/putty.sh"

    addPort "$md_id" "putty" "Putty SSH and telnet client" "XINIT: $md_inst/putty.sh"
    mv "$md_conf_root/$md_id" "$md_conf_root/ports" || return 1
}