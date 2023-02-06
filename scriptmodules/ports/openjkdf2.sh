#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="openjkdf2"
rp_module_desc="OpenJKDF2 is a function-by-function reimplementation of Dark Forces 2."
# I hate this really long line.  I couldn't get all the information to display otherwise.
#
rp_module_help="Data must be installed manually.\nData for Jedi Knight - Dark Forces 2 goes into $romdir/openjkdf2/openjkdf2.\nData for Jedi Knight - Mysteries of the Sith goes into $romdir/openjkdf2/openjkmots.\nFor both games the 'episode' 'player' 'resource' and 'Music' directories must be copied into their repsective folders."
rp_module_licence="OTHER https://github.com/shinyquagsire23/OpenJKDF2/blob/master/LICENSE.md"
rp_module_repo="git https://github.com/shinyquagsire23/OpenJKDF2.git v0.8.8"
rp_module_section="exp"

function depends_openjkdf2() {
    local depends=(
        git build-essential cmake make python3 python3-pip bison imagemagick libgtk-3-dev protobuf-compiler zsh
        clang libsdl2-dev libsdl2-mixer-dev libopenal-dev libglew-dev libssl-dev libprotobuf-dev
    )

    getDepends "${depends[@]}"

    # Note: This also needs to run: "pip3 install cogapp"
    pip3 install cogapp
}

function sources_openjkdf2() {
    gitPullOrClone
}

function build_openjkdf2() {
    export CC=clang
    export CXX=clang++

    chmod +x build_linux64.sh
    ./build_linux64.sh

    md_ret_require=build_linux64/openjkdf2
}

function install_openjkdf2() {
    md_ret_files=(
        build_linux64/openjkdf2
        build_linux64/libGameNetworkingSockets.so
        build_linux64/libprotobuf.so.3.21.4.0
    )
}

function game_data_openjkdf2() {
    chmod -R $user:$user "$romdir/ports/openjkdf2"
}

function add_games_openjkdf2() {
    # If neither game data is available, create both launcher (assuming person will add data later)
    if [[ ! -f "$romdir/openjkdf2/openjkdf2/Episode/JK1.GOB" ]] && [[ ! -f "$romdir/openjkdf2/openjkmots/Episode/JKM.GOO" ]]; then
        addPort "$md_id" "openjkdf2" "Star Wars - Jedi Knight - Dark Forces II" "$md_inst/openjkdf2 %ROM%" ""
        addPort "$md_id" "openjkdf2" "Star Wars - Jedi Knight - Mysteries of the Sith" "$md_inst/openjkdf2 %ROM%" "-motsCompat"
    fi
    # If Dark Forces 2 Data Available, create Dark Forces 2 launcher
    if [[ -f "$romdir/openjkdf2/openjkdf2/Episode/JK1.GOB" ]]; then
        addPort "$md_id" "openjkdf2" "Star Wars - Jedi Knight - Dark Forces II" "$md_inst/openjkdf2 %ROM%" ""
    fi
    # If Mysteries of the Sith data available, create MotS launcher
    if [[ -f "$romdir/openjkdf2/openjkmots/Episode/JKM.GOO" ]]; then
        addPort "$md_id" "openjkdf2" "Star Wars - Jedi Knight - Mysteries of the Sith" "$md_inst/openjkdf2 %ROM%" "-motsCompat"
    fi
}

function configure_openjkdf2() {
    mkRomDir "ports/openjkdf2"

    add_games_openjkdf2

    moveConfigDir "$home/.local/share/OpenJKDF2" "$romdir/ports/openjkdf2"

    [[ "$md_mode" == "install" ]] && game_data_openjkdf2
}
