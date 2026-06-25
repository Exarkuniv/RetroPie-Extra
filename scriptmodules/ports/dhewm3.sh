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

rp_module_id="dhewm3"
rp_module_desc="dhewm3 - Doom 3 port"
rp_module_licence="GPL3 https://github.com/dhewm/dhewm3/blob/master/COPYING.txt"
rp_module_help="Please copybase/pak000.pk4\n\nbase/pak001.pk4\n\nbase/pak002.pk4\n\nbase/pak003.pk4\n\nbase/pak004.pk4\n\nbase/pak005.pk4\n\nbase/pak006.pk4\n\nbase/pak007.pk4\n\nbase/pak008.pk4\n\n
and if you have the expansion:\n\n
d3xp/pak000.pk4\n\n
d3xp/pak001.pk4\n\nInto the $romdir/doom3/base and $romdir/doom3/d3xp directories"
rp_module_repo="git https://github.com/dhewm/dhewm3.git master"
rp_module_section="exp"
rp_module_flags=""

function depends_dhewm3() {
    getDepends cmake libsdl2-dev libopenal-dev libogg-dev libvorbis-dev zlib1g-dev libcurl4-openssl-dev xorg
}

function sources_dhewm3() {
    gitPullOrClone
}

function build_dhewm3() {
    mkdir -p "$md_build/build"

    cd "$md_build/build" || return 1

    cmake "../neo" || return 1
    make clean
    make || return 1
    md_ret_require="$md_build/build"
}

function install_dhewm3() {
    md_ret_files=(
        "build/dhewm3"
        "build/d3xp.so"
        "build/base.so"
	"base"
    )
}

function game_data_dhewm3() {
    if [[ ! -f "$romdir/ports/doom3/base/pak000.pk4" ]]; then
        downloadAndExtract "https://github.com/techcoder20/RPIDoom3Installer/releases/download/v1.0.0/Doom3DemoGameFiles.zip" "$romdir/ports/doom3/base"
    mv "$romdir/ports/doom3/base/Doom3Demo/demo/"* "$romdir/ports/doom3/base" || return 1
    rm -r "$romdir/ports/doom3/base/Doom3Demo"
        chown -R pi:pi "$romdir/ports/doom3"
    fi
}

function configure_dhewm3() {
    if isPlatform "rpi"; then
        addPort "$md_id" "doom3" "Doom 3" "XINIT:$md_inst/dhewm3 +set in_tty 0"
    else
        addPort "$md_id" "doom3" "Doom 3" "$md_inst/dhewm3"
    fi

    mkRomDir "ports/doom3/base"
    mkRomDir "ports/doom3/d3xp"
    moveConfigDir "$md_inst/base" "$romdir/ports/doom3/base"
    moveConfigDir "$md_inst/d3xp" "$romdir/ports/doom3/d3xp"

 [[ "$md_mode" == "install" ]] && game_data_dhewm3
}