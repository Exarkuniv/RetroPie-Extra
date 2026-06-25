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


rp_module_id="reminiscence"
rp_module_desc="REminiscence - Flashback Engine"
rp_module_licence="GPL3 https://raw.githubusercontent.com/Cheeseness/REminiscence/master/COPYING"
rp_module_help="Please copy your Flashback data files to $romdir/ports/reminiscence before running REminiscence."
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_reminiscence() {
    getDepends libsdl1.2-dev
}

function sources_reminiscence() {
    wget -O- -q https://cyxdown.free.fr/reminiscence/REminiscence-0.2.1.tar.bz2 | tar -xvj --strip-components=1
}

function build_reminiscence() {
    make
}

function install_reminiscence() {
    md_ret_files=('rs')
}

function configure_reminiscence() {
    mkRomDir "ports"
    mkRomDir "ports/$md_id"
    #fixme: Missing configuration dir.

    addPort "$md_id" "reminiscence" "REminiscence" "$md_inst/rs --datapath=$romdir/ports/$md_id --savepath=$md_conf_root/$md_id"
}