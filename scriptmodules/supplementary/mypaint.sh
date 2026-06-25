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

rp_module_id="mypaint"
rp_module_desc="mypaint easy-to-use painting program"
rp_module_licence="mypaint.org"
rp_module_section="exp"
rp_module_flags="!mali !x86 !rpi5"

function depends_mypaint() {
    getDepends xorg matchbox
}

function install_bin_mypaint() {
    aptInstall mypaint
}

function configure_mypaint() {
    mkRomDir "ports"
    mkdir -p "$md_inst"
    moveConfigDir "$home/.config/$md_id" "$md_conf_root/ports/$md_id"
    cat >"$md_inst/mypaint.sh" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
/usr/bin/mypaint +set in_tty 0
_EOF_
    chmod +x "$md_inst/mypaint.sh"

    addPort "$md_id" "mypaint" "MyPaint easy-to-use painting program" "XINIT: $md_inst/mypaint.sh"
    mv "$md_conf_root/$md_id" "$md_conf_root/ports"  || return 1
}