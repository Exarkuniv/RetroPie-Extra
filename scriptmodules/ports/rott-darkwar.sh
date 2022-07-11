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

rp_module_id="rott-darkwar"
rp_module_desc="rott-darkwar - Rise of the Triad - Dark War"
rp_module_licence="GPL2 https://raw.githubusercontent.com/zerojay/RoTT/master/COPYING"
rp_module_help="Please add your full version ROTT files to $romdir/ports/$md_id/ to play."
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_rott-darkwar() {
<<<<<<< xinit
    getDepends libsdl1.2-dev libsdl-mixer1.2-dev automake xorg
=======
    getDepends libsdl1.2-dev libsdl-mixer1.2-dev automake xorg 
>>>>>>> master
}

function sources_rott-darkwar() {
    gitPullOrClone "$md_build" https://github.com/zerojay/RoTT
}

function build_rott-darkwar() {
    sed -i 's/SUPERROTT   ?= 1/SUPERROTT   ?= 0/g' "$md_build/rott/Makefile"
    make clean
    make rott-darkwar
    make rott-darkwar
    make rott-darkwar
    md_ret_require=(
        "$md_build/rott-darkwar"
    )
}

function install_rott-darkwar() {
   md_ret_files=(
          'rott-darkwar'
    )
}

function configure_rott-darkwar() {
    mkRomDir "ports"
    mkRomDir "ports/$md_id"
    moveConfigDir "$home/.rott" "$md_conf_root/rott"

    addPort "$md_id" "rott-darkwar" "Rise Of The Triad - Dark War" " XINIT: pushd $romdir/ports/rott-darkwar; $md_inst/rott-darkwar; popd"
}
