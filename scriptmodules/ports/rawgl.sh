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

rp_module_id="rawgl"
rp_module_desc="rawgl - Another World Engine"
rp_module_help="Please copy your Another World data files to $romdir/ports/$md_id before running the game."
rp_module_section="exp"
rp_module_repo="git https://github.com/cyxx/rawgl.git"
rp_module_flags="!mali !x86"

function depends_rawgl() {
    getDepends g++ libsdl2-dev libsdl2-mixer-dev
}

function sources_rawgl() {
    gitPullOrClone
}

function build_rawgl() {
    make clean
    make
    md_ret_require="$md_build/rawgl"
}

function install_rawgl() {
    md_ret_files=('rawgl')
}

function configure_rawgl() {
    mkRomDir "ports"
    mkRomDir "ports/$md_id"

    addPort "$md_id" "rawgl" "rawgl - Another World Engine" "$md_inst/rawgl --datapath=$romdir/ports/$md_id --language=us --render=original --fullscreen-ar"
}
