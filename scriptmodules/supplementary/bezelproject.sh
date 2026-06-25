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

rp_module_id="bezelproject"
rp_module_desc="Easily set up the Bezel Project"
rp_module_help="Follow the instructions on the dialogs to configure the Bezel Project"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function sources_bezelproject() {
    wget https://raw.githubusercontent.com/thebezelproject/BezelProject/master/bezelproject.sh || return 1
}

function install_bezelproject() {
    cp ./bezelproject.sh "$home/RetroPie/retropiemenu"
    chown -R $user:$user "$datadir/retropiemenu"
}

function remove_bezelproject() {
    rm -rfv "$datadir/retropiemenu/bezelproject.sh"
}

function gui_bezelproject() {
    bash "$md_inst/bezelproject.sh"
}