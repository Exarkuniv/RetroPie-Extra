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

rp_module_id="hcl"
rp_module_desc="Hydra Castle Labyrinth - a Metroidvania game created by E. Hashimoto (a.k.a. Buster)"
rp_module_help="Linux port by ptitSeb, based on the 3DS port by 4chan/anon\n\nMake sure to set the language to English from the options menu before playing. If you are experiencing slowdowns in game, make sure the xBRZ shader is turned off in the options menu."
rp_module_licence="GPL2 https://github.com/ptitSeb/hydracastlelabyrinth/blob/master/LICENSE"
rp_module_repo="git https://github.com/ptitSeb/hydracastlelabyrinth.git master c5e6afc"
rp_module_section="exp"
rp_module_flags="!all rpi4 rpi5"

function depends_hcl() {
    getDepends libsdl2-dev libsdl2-mixer-dev cmake
}

function sources_hcl() {
    gitPullOrClone
}

function build_hcl() {
    mkdir -p build && cd build
    cmake -DUSE_SDL2=ON .. || return 1
    make || return 1
    md_ret_require="$md_build/build/hcl"
}

function install_hcl() {
    md_ret_files=(
        'build/hcl'
        'data'
    )
}

function configure_hcl() {
    addPort "$md_id" "hcl" "Hydra Castle Labyrinth" "pushd $md_inst; $md_inst/hcl -d; popd"
    moveConfigDir "$home/.hydracastlelabyrinth" "$md_conf_root/hcl"
}