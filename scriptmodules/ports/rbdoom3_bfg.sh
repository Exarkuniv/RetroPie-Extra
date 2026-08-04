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

rp_module_id="rbdoom3_bfg"
rp_module_desc="rbdoom3_bfg - Doom 3: BFG Edition"
rp_module_licence="GPL3 https://raw.githubusercontent.com/RobertBeckebans/RBDOOM-3-BFG/master/LICENSE.md"
rp_module_help="For the game data, from your windows install (Gog or Steam) locate the 'base' directory.  Copy ALL contents to $romdir/ports/doom3_bfg"
rp_module_section="exp"
rp_module_repo="git https://github.com/RobertBeckebans/RBDOOM-3-BFG.git :_get_branch_rbdoom3_bfg"
rp_module_flags="!32bit"

function _get_branch_rbdoom3_bfg() {
    echo -ne "v1.4.0"
}

function depends_rbdoom3_bfg() {
    local depends=(cmake libavcodec-dev libavformat-dev libavutil-dev libsdl2-dev libopenal-dev libswscale-dev libglew-dev zlib1g-dev libpng-dev rapidjson-dev libjpeg-dev libimgui-dev)

    if isPlatform "rpi"; then
        depends+=(xorg)
    fi

    getDepends "${depends[@]}"
}

function sources_rbdoom3_bfg() {
    gitPullOrClone
}

function build_rbdoom3_bfg() {
    local params=()

    params+=(-G 'Unix Makefiles' -DCMAKE_BUILD_TYPE=RelWithDebInfo)

    if isPlatform "rpi"; then
        params+=(-DUSE_PRECOMPILED_HEADERS=OFF -DCPU_OPTIMIZATION='' -DUSE_INTRINSICS_SSE=OFF)
        params+=(-DCPU_TYPE=aarch64)
    fi

    params+=(-DUSE_SYSTEM_IMGUI=ON)
    params+=(-DSDL2=ON -DUSE_SYSTEM_ZLIB=ON -DUSE_SYSTEM_LIBPNG=ON -DUSE_SYSTEM_RAPIDJSON=ON)
    params+=(-DUSE_SYSTEM_LIBGLEW=ON -DUSE_SYSTEM_LIBJPEG=ON)

    if [[ -d "$md_build/build" ]]; then
        rm -rf "$md_build/build"
    fi

    mkdir -p "$md_build/build"
    cd "$md_build/build" || return 1

    cmake "${params[@]}" ../neo
    make clean
    make

    md_ret_require="$md_build/build/RBDoom3BFG"
}

function install_rbdoom3_bfg() {
    md_ret_files=(
        "build/RBDoom3BFG"
        "base/default.cfg"
        "base/extract_resources.cfg"
        "base/renderprogs"
    )
}

function configure_rbdoom3_bfg() {
    local launch_prefix=""
    if ! isPlatform "x86"; then
        launch_prefix="XINIT-WM:"
    fi

    addPort "$md_id" "doom3_bfg" "Doom 3 (BFG Edition)" "$launch_prefix$md_inst/RBDoom3BFG"

    mkRomDir "ports/doom3_bfg"

    moveConfigDir "$md_inst/base" "$romdir/ports/doom3_bfg"
    moveConfigDir "$home/.local/share/rbdoom3bfg" "$md_conf_root/rbdoom3bfg"

    if [[ "$md_mode" == "install" ]]; then
        mkdir -p "$md_inst/base"
        mkUserDir "$home/.doom3/base"
    fi
}
