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

rp_module_id="vlc"
rp_module_desc="VLC media player"
rp_module_licence="https://www.videolan.org"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_vlc() {
    getDepends xorg matchbox
}

function install_bin_vlc() {
    aptInstall vlc
}

function configure_vlc() {
    mkRomDir "ports"
    mkRomDir "ports\vlc"
    mkdir -p "$md_inst"
    moveConfigDir "$home/.config/$md_id" "$md_conf_root/ports/$md_id"
    cat >"$md_inst/vlc.sh" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
/usr/bin/vlc
_EOF_
    chmod +x "$md_inst/vlc.sh"

    addPort "$md_id" "vlc" "VLC media player" "XINIT: $md_inst/vlc.sh"
    mv "$md_conf_root/$md_id" "$md_conf_root/ports" || return 1
}