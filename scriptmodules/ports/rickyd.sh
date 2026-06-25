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

rp_module_id="rickyd"
rp_module_desc="rickyd - Port of Rick Dangerous"
rp_module_licence="GPL https://sourceforge.net/p/rickyd/code/ci/master/tree/COPYING"
rp_module_repo="git git://git.code.sf.net/p/rickyd/code master"
rp_module_section="exp"
rp_module_flags="!mali !kms !all rpi4 rpi3"

function depends_rickyd() {
    getDepends libsdl2-dev libsdl2-mixer-dev libsdl2-image-dev libsdl2-ttf-dev automake autoconf
}

function sources_rickyd() {
    gitPullOrClone
}

function build_rickyd() {
    ./bootstrap.sh
    make distclean
    mkdir -p build
    cd build || return 1
    .././configure --prefix=$md_inst
    make || return 1
    md_ret_require="$md_build/build/sources/ricky"
}

function install_rickyd() {
    cd "$md_build/build" || return 1
    make install || return 1
}

function configure_rickyd() {
    moveConfigFile "$home/.rickrc" "$md_conf_root/rickyd/rickrc"
    addPort "$md_id" "rickyd" "Rickyd - Rick Dangerous clone" "$md_inst/bin/ricky"
}