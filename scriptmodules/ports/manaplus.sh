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

rp_module_id="manaplus"
rp_module_desc="manaplus - 2D MMORPG Client"
rp_module_licence="GPL2 https://gitlab.com/manaplus/manaplus/raw/master/COPYING"
rp_module_repo="git https://gitlab.com/manaplus/manaplus.git"
rp_module_section="exp"
rp_module_flags="!x86 !mali"

function depends_manaplus() {
    getDepends libsdl1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev libsdl-net1.2-dev libcurl4-gnutls-dev libxml2-dev automake libguichan-dev patch autoconf libtool libsdl-ttf2.0-dev libsdl-gfx1.2-dev gettext libgl1-mesa-dev libenet-dev libphysfs-dev libxml2-dev zlib1g-dev xorg autopoint
}

function sources_manaplus() {
    gitPullOrClone 
}

function build_manaplus() {
    autoreconf -i
    ./configure --prefix="$md_inst"
    make
}

function install_manaplus() {
    make install
}

function configure_manaplus() {
    mkRomDir "ports"
    mkRomDir "ports/manaplus"
    moveConfigDir "$home/.config/mana" "$md_conf_root/manaplus"

    addPort "$md_id" "manaplus" "manaplus - 2D MMORPG Client" "sudo xinit $md_inst/bin/manaplus" 
}