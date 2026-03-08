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

rp_module_id="dunedynasty"
rp_module_desc="Dune Dynasty - Dune 2 port"
rp_module_help="Please put your data files from Dune II v1.07 EU only in the roms/ports/dunedynasty/data folder.

Dune II has been classified as abandonware, the install script will take care of the data files. Please enjoy!"
rp_module_licence="GNU https://github.com/gameflorist/dunedynasty/LICENSE.txt"
rp_module_repo="git https://github.com/gameflorist/dunedynasty.git master"
rp_module_section="exp"
rp_module_flags="!all rpi4 rpi5"


function depends_dunedynasty() {
   getDepends build-essential cmake liballegro5-dev libenet-dev libmad0-dev libfluidsynth-dev fluidsynth libgl1 patchelf liballegro-acodec5-dev liballegro-audio5-dev liballegro-image5-dev
}


function sources_dunedynasty() {
    gitPullOrClone
}

function build_dunedynasty() {
    cmake -DCMAKE_BUILD_TYPE=Release .
    make
    mkdir dist/libs
    (ldd ./dist/dunedynasty | grep -E 'libfluidsynth' |awk '{if(substr($3,0,1)=="/") print $1,$3}' |sort) |cut -d\  -f2 |
    xargs -d '\n' -I{} cp --copy-contents {} ./dist/libs
    ls -1 ./dist/libs/ | while read file
    do
        patchelf --remove-needed $file ./dist/dunedynasty
        patchelf --add-needed $md_inst/libs/$file ./dist/dunedynasty
    done

    md_ret_require="$md_build/dist/dunedynasty"
}

function install_dunedynasty() {
    md_ret_files=(
        'dist/campaign'
        'dist/data'
        'dist/gfx'
        'dist/libs'
        'dist/licences'
        'dist/music'
        'dist/dunedynasty'
        'dist/dunedynasty.cfg-sample'
        'dist/LICENSE.txt'
        'dist/README.txt'
    )
}

function game_data_dunedynasty() {

    if [[ ! -f "$romdir/ports/dunedynasty/data/DUNE.PAK" ]]; then
        downloadAndExtract "https://github.com/er-tho/game-data/raw/main/dune-II-1.07eu.zip" "$romdir/ports/dunedynasty/data"
    chown -R $__user:$__group "$romdir/ports/dunedynasty"
    fi
}

function configure_dunedynasty() {
    mkRomDir "ports/dunedynasty/data"
    addPort "$md_id" "dunedynasty" "Dune Dynasty" "XINIT: $md_inst/dunedynasty"
	rm -r $md_inst/data
	ln -snf "$romdir/ports/dunedynasty/data" "$md_inst"

    [[ "$md_mode" == "install" ]] && game_data_dunedynasty
}
