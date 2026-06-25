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

rp_module_id="shiromino"
rp_module_desc="shiromino - Tetris The Grand Master Clone"
rp_module_help="Requires a keyboard to exit or restart the game."
rp_module_licence="MIT https://raw.githubusercontent.com/FelicityVi/shiromino/master/LICENSE"
rp_module_repo="git https://github.com/FelicityVi/shiromino master"
rp_module_section="exp"
rp_module_flags="!mali"

function depends_shiromino() {
    getDepends cmake libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libvorbis-dev libsqlite3-dev
}

function sources_shiromino() {
    gitPullOrClone
}

function build_shiromino() {
    make || return 1
    md_ret_require="$md_build/bin/game"
}

function install_shiromino() {
    md_ret_files=(
          'bin/game'
          'game.cfg'
          'audio'
          'docs'
          'gfx'
    )
}

function configure_shiromino() {
    addPort "$md_id" "shiromino" "shiromino - Tetris The Grand Master Clone" "pushd $md_inst; ./shiromino; popd"
    moveConfigFile "$md_inst/scores.db" "$md_conf_root/shiromino/scores.db"
    moveConfigFile "$md_inst/game.cfg" "$md_conf_root/shiromino/game.cfg"
    mv "$md_inst/game" "$md_inst/shiromino" || return 1
}