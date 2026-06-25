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

rp_module_id="prototype"
rp_module_desc="ProtoType - an R-Type remake by Ron Bunce"
rp_module_help="A keyboard is required to exit the game."
rp_module_licence="freeware https://web.archive.org/web/20160507085617/http://xout.blackened-interactive.com/ProtoType/Prototype.html"
rp_module_repo="git https://github.com/ptitSeb/prototype.git master 12d2de8"
rp_module_section="exp"
rp_module_flags="!all rpi4 rpi3"

function depends_prototype() {
    getDepends libsdl2-dev libsdl2-mixer-dev
}

function sources_prototype() {
    gitPullOrClone
}

function build_prototype() {
    local params=(SDL2=1)
    isPlatform "x86" && params+=(LINUX=1)
    ! isPlatform "x86" && params+=(ODROID=1)
    make "${params[@]}" || return 1
    md_ret_require="$md_build/prototype"
}

function install_prototype() {
    md_ret_files=(
        'prototype'
        'Data'
    )
}

function configure_prototype() {
    addPort "$md_id" "prototype" "ProtoType" "pushd $md_inst; $md_inst/prototype; popd"
    moveConfigDir "$home/.prototype" "$md_conf_root/prototype"
}