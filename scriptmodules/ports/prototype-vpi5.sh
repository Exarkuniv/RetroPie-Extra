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

rp_module_id="prototype-vpi5"
rp_module_desc="ProtoType - an R-Type remake by Ron Bunce"
rp_module_help="A keyboard is required to exit the game."
rp_module_licence="freeware https://web.archive.org/web/20160507085617/http://xout.blackened-interactive.com/ProtoType/Prototype.html"
rp_module_repo="git https://github.com/ptitSeb/prototype.git master"
rp_module_section="exp"
rp_module_flags="!all rpi5"

function depends_prototype() {
    getDepends libsdl1.2-dev libsdl-gfx1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev gcc-arm-linux-gnueabihf g++-arm-linux-gnueabihf libboost-all-dev zlib1g-dev
}

function sources_prototype() {
    gitPullOrClone
}

function build_prototype() {
    if isPlatform "64bit"; then
        sed -i 's/-mfpu=neon//g' Makefile
        sed -i 's/-mfloat-abi=softfp//g' Makefile
        sed -i 's/-mcpu=cortex-a8//g' Makefile
        sed -i 's/CFLAGS +=/CFLAGS += -march=armv8-a -mtune=cortex-a76/' Makefile
        sed -i 's/CXXFLAGS +=/CXXFLAGS += -march=armv8-a -mtune=cortex-a76/' Makefile
        sed -i 's/CC = gcc/CC = gcc/' Makefile
        sed -i 's/CXX = g++/CXX = g++/' Makefile

        make -j$(nproc)
    else

    local params=(SDL2=1)
    isPlatform "x86" && params+=(LINUX=1)
    ! isPlatform "x86" && params+=(ODROID=1)
    make "${params[@]}"
    md_ret_require="$md_build/prototype"

    fi
}

function install_prototype() {
    md_ret_files=(
        'prototype'
        'Data'
    )
}

function configure_prototype() {
    if isPlatform "64bit"; then
        addPort "$md_id" "prototype" "ProtoType" "XINIT: pushd $md_inst; $md_inst/prototype; popd"
	else

        addPort "$md_id" "prototype" "ProtoType" "pushd $md_inst; $md_inst/prototype; popd"
	fi
    moveConfigDir "$home/.prototype" "$md_conf_root/prototype"
}
