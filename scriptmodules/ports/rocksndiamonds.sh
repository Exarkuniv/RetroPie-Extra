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

rp_module_id="rocksndiamonds"
rp_module_desc="Rocks'n'Diamonds - Emerald Mine Clone"
rp_module_licence=" GNU https://git.artsoft.org/?p=rocksndiamonds.git;a=blob;f=COPYING;hb=HEAD"
rp_module_repo="git https://git.artsoft.org/rocksndiamonds.git"
rp_module_section="exp"
rp_module_flags="!mali"

function depends_rocksndiamonds() {
    getDepends libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-net-dev
}

function sources_rocksndiamonds() {
    git clone https://git.artsoft.org/rocksndiamonds.git || return 1
    cd rocksndiamonds || return 1
    git checkout master-next-patch-release
}

function build_rocksndiamonds() {
    cd rocksndiamonds || return 1
    make || return 1
    md_ret_require="rocksndiamonds"
}

function install_rocksndiamonds() {
    md_ret_files=(
        'rocksndiamonds/graphics'
        'rocksndiamonds/levels'
        'rocksndiamonds/music'
        'rocksndiamonds/sounds'
        'rocksndiamonds/COPYING'
        'rocksndiamonds/CREDITS'
        'rocksndiamonds/rocksndiamonds'
)
}

function configure_rocksndiamonds() {
    addPort "$md_id" "rocksndiamonds" "Rocks n' Diamonds" "$md_inst/rocksndiamonds"
    mkRomDir "ports/rocksndiamonds"
    moveConfigDir "$home/.rocksndiamonds" "$md_conf_root/rocksndiamonds"
}