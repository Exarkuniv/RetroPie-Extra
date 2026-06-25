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

rp_module_id="firefox-esr"
rp_module_desc="FireFox-ESR - Formally known as IceWeasel, the Rebranded Firefox Web Browser"
rp_module_licence="MPL2 https://www.mozilla.org/media/MPL/2.0/index.815ca599c9df.txt"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_firefox-esr() {
    getDepends xorg matchbox
}

function install_bin_firefox-esr() {
    aptInstall firefox-esr
}

function configure_firefox-esr() {
    mkRomDir "ports"
    mkdir -p "$md_inst"
    moveConfigDir "$home/.mozilla" "$md_conf_root/ports/$md_id"
    cat >"$md_inst/firefox-esr.sh" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
/usr/bin/firefox-esr
_EOF_
    chmod +x "$md_inst/firefox-esr.sh"

    addPort "$md_id" "firefox-esr" "FireFox-ESR - Firefox Web Browser" "XINIT: $md_inst/firefox-esr.sh"
    mv "$md_conf_root/$md_id" "$md_conf_root/ports" || return 1
}