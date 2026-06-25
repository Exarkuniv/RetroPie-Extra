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

rp_module_id="lr-boom3"
rp_module_desc="Doom 3 engine - dhewm3 port for libretro"
rp_module_help="ROM Extensions: .pk4\n\nCopy your Doom 3 roms to $romdir/ports/doom3/base\nCopy your Doom 3 - Ressurrection of Evil roms to $romdir/ports/doom3/d3xp"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/boom3/master/COPYING.txt"
rp_module_repo="git https://github.com/libretro/boom3.git master"
rp_module_section="exp"
rp_module_flags="!all 64bit !rpi5"

function depends_lr-boom3() {
    getDepends libjpeg-turbo8-dev libvorbis-dev libogg-dev libopenal-dev libsdl2-dev libcurl4-openssl-dev
}

function _get_targets_lr-boom3() {
    echo boom3 boom3_xp
}

function sources_lr-boom3() {
    gitPullOrClone
}
function build_lr-boom3() {
    cd "neo" || return 1
    mkdir -p "cores"
    local target
    for target in $(_get_targets_lr-boom3); do
        make clean
	if [[ "$target" == boom3_xp ]]; then
	    make D3XP=1 || return 1
	else
	    make || return 1
	fi
        cp "${target}_libretro.so" "cores"
        md_ret_require+=("$md_build/neo/cores/${target}_libretro.so")
    done
}

function install_lr-boom3() {
    md_ret_files=(
        'COPYING.txt'
    )
    local target
    for target in $(_get_targets_lr-boom3); do
        md_ret_files+=("neo/cores/${target}_libretro.so")
    done
}

function add_games_lr-boom3() {
    local cmd1="$md_inst/boom3_xp_libretro.so"
    local cmd2="$md_inst/boom3_libretro.so"
    declare -A games=(
        ['base']="Doom 3"
        ['d3xp']="Doom 3 - Resurrection of Evil"
    )
    local game
    local pk4
    for game in "${!games[@]}"; do
        pk4="$romdir/ports/doom3/$game/pak000.pk4"
        if [[ -f "$pk4" ]]; then
	    if [[ "$game" == d3xp ]]; then
                addPort "$md_id-xp" "doom3" "${games[$game]}" "$cmd1" "$pk4"
	    else
                addPort "$md_id" "doom3" "${games[$game]}" "$cmd2" "$pk4"
	    fi
        fi
    done
}

function configure_lr-boom3() {
    setConfigRoot "ports"

    mkRomDir "ports/doom3"
    mkRomDir "ports/doom3/base"
    mkRomDir "ports/doom3/d3xp"

    ensureSystemretroconfig "ports/doom3"

    [[ "$md_mode" == "install" ]] && add_games_lr-boom3

    chown $user:$user "ports/doom3"
}