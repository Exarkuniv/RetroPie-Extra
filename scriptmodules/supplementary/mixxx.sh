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

rp_module_id="mixxx"
rp_module_desc="Mixxx DJ Mixing Software App"
rp_module_licence="www.mixxx.org"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_mixxx() {
    getDepends xorg matchbox
}

function install_bin_mixxx() {
    aptInstall mixxx
}

function configure_mixxx() {
    mkRomDir "ports"
    mkdir -p "$md_inst"
    moveConfigDir "$home/.mixxx" "$md_conf_root/ports/$md_id"
    cat >"$md_inst/mixxx.sh" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
/usr/bin/mixxx
_EOF_
    chmod +x "$md_inst/mixxx.sh"

    addPort "$md_id" "mixxx" "Mixxx - Free DJ Mixing Software App" "XINIT: $md_inst/mixxx.sh"
    mv "$md_conf_root/$md_id" "$md_conf_root/ports" || return 1
}