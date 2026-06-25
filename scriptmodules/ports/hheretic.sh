#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="hheretic"
rp_module_desc="Heretic GL port"
rp_module_help="Please put your heretic.wad in the roms/ports/heretic folder" 
rp_module_licence="GNU https://sourceforge.net/p/hhexen/hhexen/ci/master/tree/LICENSE.md"
rp_module_repo="wget https://sourceforge.net/projects/hhexen/files/hheretic/0.2.3/hheretic-0.2.3-src.tgz"
rp_module_section="exp"
rp_module_flags="!mali"

function depends_hheretic() {
    getDepends libsndifsdl2-dev libsdl-mixer1.2-dev libgl1 libsdl-image1.2-dev xorg 
}

function sources_hheretic() {
    downloadAndExtract "$md_repo_url" "$md_build" "--strip-components=1"
}

function build_hheretic() {
    ./configure --enable-fullscreen --with-audio=sdlmixer --with-datapath=$romdir/ports/heretic
    make || return 1

    md_ret_require=(hheretic-gl)
}

function install_hheretic() {
    md_ret_files=(hheretic-gl)
}

function game_data_heretic() {
    if [[ ! -f "$romdir/ports/heretic/heretic.wad" ]]; then downloadAndExtract "https://github.com/Exarkuniv/game-data/raw/main/heretic.zip" "$romdir/ports/heretic" 
    chown -R $user:$user "$romdir/ports/heretic"
    fi
        [[ ! -d "$romdir/ports/heretic/music" ]] && downloadAndExtract "http://sycraft.org/content/audio/heretic/hereticsoundtrackhq.zip" "$romdir/ports/heretic/files" 
    unzip $romdir/ports/heretic/files/musichq.zip -d $romdir/ports/heretic/files || return 1
    mv "$romdir/ports/heretic/files/Data/jHeretic/Music"* "$romdir/ports/heretic/music" || return 1
    rm -r "$romdir/ports/heretic/files"
    chown -R $user:$user "$romdir/ports/heretic/music"

}

function configure_hheretic() {
    mkRomDir "ports/heretic"
    addPort "$md_id" "hheretic" "Heretic port" "XINIT: $md_inst/hheretic-gl -width 1920 -height 1080"
   [[ "$md_mode" == "install" ]] && game_data_heretic

}