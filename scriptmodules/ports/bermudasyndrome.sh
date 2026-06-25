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

rp_module_id="bermudasyndrome"
rp_module_desc="Bermuda Syndrome - Open Source Engine"
rp_module_help="Please copy your Bermuda Syndrome data files to $romdir/ports/bermudasyndrome before running the game."
rp_module_repo="file http://cyxdown.free.fr/bs/bs-0.1.7.tar.bz2"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_bermudasyndrome() {
    getDepends libsdl2-dev libsdl2-mixer-dev zlib1g-dev libvorbis-dev libvorbisfile3 libogg0
}

function sources_bermudasyndrome() {
    downloadAndExtract "$md_repo_url" "$md_build" "--strip-components=1"
}

function build_bermudasyndrome() {
    make || return 1
}

function install_bermudasyndrome() {
    md_ret_files=('bs')
}

function configure_bermudasyndrome() {
    mkRomDir "ports"
    mkRomDir "ports/$md_id"
# Might be missing config dir, FIX ME.

    addPort "$md_id" "bermudasyndrome" "Bermuda Syndrome - Open Source Engine" "$md_inst/bs --datapath=$romdir/ports/$md_id --savepath=$md_conf_root/$md_id"
}