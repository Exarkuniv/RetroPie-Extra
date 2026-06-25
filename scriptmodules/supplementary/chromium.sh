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

rp_module_id="chromium"
rp_module_desc="chromium - Open Source Web Browser"
rp_module_licence="MIT https://raw.githubusercontent.com/chromium/chromium/trunk/LICENSE"
rp_module_section="exp"
rp_module_flags="!mali !x86 !rpi5"

function depends_chromium() {
    getDepends git omxplayer libgnome-keyring-common libgnome-keyring0 libnspr4 libnss3 xdg-utils matchbox xorg gconf-service libgconf-2-4
}

function install_bin_chromium() {
    aptInstall chromium-browser rpi-chromium-mods
}

function configure_chromium() {
    mkRomDir "ports"
    mkdir -p "$md_inst"
    moveConfigDir "$home/.config/$md_id" "$md_conf_root/ports/$md_id"

    cat >"$md_inst/chromium.sh" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
/usr/bin/chromium-browser "\$@"
_EOF_
    chmod +x "$md_inst/chromium.sh"

    addPort "$md_id" "chromium" "Chromium - Open Source Web Browser" "XINIT: $md_inst/chromium.sh %ROM%"
    mv "$md_conf_root/$md_id" "$md_conf_root/ports" || return 1
}
