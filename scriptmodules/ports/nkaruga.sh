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

rp_module_id="nkaruga"
rp_module_desc="nKaruga - Ikaruga demake"
rp_module_licence="MIT https://github.com/gameblabla/nKaruga/blob/master/COPYING"
rp_module_repo="git https://github.com/gameblabla/nKaruga.git"
rp_module_section="exp"
rp_module_flags="!mali !kms"

function depends_nkaruga() {
    getDepends libsdl2-dev libsdl2-mixer-dev
}

function sources_nkaruga() {
    gitPullOrClone
}

function build_nkaruga() {
    make -f Makefile.linux
    md_ret_require="$md_build/nKaruga.elf"
}

function install_nkaruga() {
    md_ret_files=(
        'nKaruga.elf'
        'sfx'
    )

}

function configure_nkaruga() {
    addPort "$md_id" "nkaruga" "nKaruga - Ikaruga demake" "$md_inst/nKaruga.elf"
}
