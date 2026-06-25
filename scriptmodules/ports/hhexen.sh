#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="hhexen"
rp_module_desc="Hexen GL port"
rp_module_help="Please put your heretic.wad in the roms/ports/hexen folder" 
rp_module_licence="GNU https://sourceforge.net/p/hhexen/hhexen/ci/master/tree/LICENSE.md"
rp_module_repo="wget https://sourceforge.net/projects/hhexen/files/hhexen/1.6.3/hhexen-1.6.3-src.tgz"
rp_module_section="exp"
rp_module_flags="!mali"

function depends_hhexen() {
    getDepends libsndifsdl2-dev libsdl-mixer1.2-dev libgl1 libsdl-image1.2-dev xorg 
}

function sources_hhexen() {
    downloadAndExtract "$md_repo_url" "$md_build" "--strip-components=1"
}

function build_hhexen() {
    ./configure --enable-fullscreen --with-audio=sdlmixer --with-datapath=/home/pi/RetroPie/roms/ports/hexen
    make || return 1

    md_ret_require=(hhexen-gl)
}

function install_hhexen() {
    md_ret_files=(hhexen-gl)
}

function game_data_hexen() {
    if [[ ! -f "$romdir/ports/hexen/hexen.wad" ]]; then downloadAndExtract "https://github.com/Exarkuniv/game-data/raw/main/hexen.zip" "$romdir/ports/hexen" 
    chown -R $user:$user "$romdir/ports/hexen"
    fi
    [[ ! -d "$romdir/ports/hexen/music" ]] && downloadAndExtract "http://sycraft.org/content/audio/hexen/sycraft-hexen-high.zip" "$romdir/ports/hexen/files" 
    mv "$romdir/ports/hexen/files/Data/jHexen/Music"* "$romdir/ports/hexen/music" || return 1
    rm -r "$romdir/ports/hexen/files"
    chown -R $user:$user "$romdir/ports/hexen/music"
    
}

function configure_hhexen() {
    mkRomDir "ports/hexen"
    addPort "$md_id" "hhexen" "Hexen port" "XINIT: $md_inst/hhexen-gl -width 1920 -height 1080"
     [[ -f "$romdir/ports/hexen/HEXDD.WAD" ]] && addPort "$md_id" "hhexen-dd" "Hexen -Deathkings of the Dark Citadel Port" "XINIT: $md_inst/hhexen-gl -file hexdd.wad -width 1920 -height 1080"

    [[ "$md_mode" == "install" ]] && game_data_hexen
}