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

rp_module_id="meritous"
rp_module_desc="Meritous - port of an action-adventure dungeon crawl game"
rp_module_licence="GPL3 https://github.com/TurBoss/meritous/blob/master/gpl.txt"
rp_module_repo="git https://github.com/TurBoss/meritous.git"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_meritous() {
    getDepends libsdl1.2-dev libsdl-image1.2-dev libsdl-mixer1.2-dev xorg xinit
}

function sources_meritous() {
    gitPullOrClone 
}

function build_meritous() {
    make
    md_ret_require="$md_build/meritous"
}

function install_meritous() {
    md_ret_files=(
       'dat'
       'meritous'
    )
}

function configure_meritous() {
    chown pi:pi "$md_inst"
    mkRomDir "ports"

    addPort "$md_id" "meritous" "Meritous 1.2" "XINIT: pushd $md_inst; $md_inst/meritous; popd"
}
