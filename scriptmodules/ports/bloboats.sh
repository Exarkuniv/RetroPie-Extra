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

rp_module_id="bloboats"
rp_module_desc="Bloboats"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_bloboats() {
    getDepends cmake xorg
}

function sources_bloboats() {
    if [ ! -f "/opt/retropie/supplementary/glshim/libGL.so.1" ]; then
        gitPullOrClone "$md_build/glshim" https://github.com/ptitseb/glshim.git
    fi
}

function build_bloboats() {
    if [ ! -f "/opt/retropie/supplementary/glshim/libGL.so.1" ]; then
       cd "$md_build/glshim" || return 1
       cmake . -DBCMHOST=1 || return 1
       make GL || return 1
    fi
}

function install_bin_bloboats() {
    aptInstall bloboats
    if [ ! -f "/opt/retropie/supplementary/glshim/libGL.so.1" ]; then
       mkdir -p /opt/retropie/supplementary/glshim/
       cp "$md_build/glshim/lib/libGL.so.1" /opt/retropie/supplementary/glshim/
    fi
}

function configure_bloboats() {
    mkdir -p "ports"
    moveConfigDir "$home/.bloboats" "$md_conf_root/bloboats"
    addPort "$md_id" "bloboats" "Bloboats" "XINIT: /usr/games/bloboats"
}