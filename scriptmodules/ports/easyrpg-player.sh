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

rp_module_id="easyrpg-player"
rp_module_desc="RPG Maker 2000/2003 - EasyRPG Player Interpreter"
rp_module_help="ROM Extension: .ldb\n\nYou need to unzip your RPG Maker games into subdirectories in $romdir/ports/easyrpg/games\n\nRTP file:\nExtract the RTP files from their respective .exe installers and then copy RTP 2000 files in $biosdir/rtp/2000 and RTP 2003 files in $biosdir/rtp/2003."
rp_module_licence="GPL3 https://raw.githubusercontent.com/EasyRPG/Player/master/COPYING"
rp_module_repo="git https://github.com/EasyRPG/Player.git master"
rp_module_section="exp"
rp_module_flags="!mali"

function depends_easyrpg-player() {
    local depends=(
        cmake autoconf automake libtool doxygen libsdl2-dev libsdl2-mixer-dev
        libpng-dev libfreetype6-dev libboost-dev libpixman-1-dev libmpg123-dev
        libwildmidi-dev libvorbis-dev libopusfile-dev libsndfile1-dev libxmp-dev
        libspeexdsp-dev libharfbuzz-dev libfmt-dev zlib1g-dev
        expat libexpat1-dev libexpat-ocaml-dev libinih-dev
        libfluidsynth-dev fluidsynth)
    isPlatform "32bit" && depends+=(libraspberrypi-dev libraspberrypi-bin)
    getDepends "${depends[@]}"
}

function sources_easyrpg-player() {
    gitPullOrClone
}

function build_easyrpg-player() {
    mkdir -p build
    cd build || return 1

    sed -i 's#APPEND_STRING PROPERTY#APPEND PROPERTY#' "$md_build/builds/cmake/Modules/FindSDL2.cmake"
    sed -i 's#INTERFACE_LINK_LIBRARIES "${SDL2PC_STATIC_LIBRARIES}")#INTERFACE_INCLUDE_DIRECTORIES "${SDL2PC_STATIC_LIBRARY_DIRS}")#' "$md_build/builds/cmake/Modules/FindSDL2.cmake"
    cmake .. -DCMAKE_BUILD_TYPE=Release -DPLAYER_BUILD_LIBLCF=ON || return 1
    cmake --build . || return 1

    md_ret_require="$md_build/build/easyrpg-player"
}

function install_easyrpg-player() {
    md_ret_files=(
        'build/easyrpg-player'
    )
}

function remove_easyrpg-player() {
    for x in liblcf; do
        rm -rf "/usr/include/$x"
        rm -rf "/usr/lib/$x"*
        rm -rf "/usr/lib/cmake/$x"
        rm -rf "/usr/lib/pkgconfig/$x"*
        rm -rf "/usr/share/mime/packages/$x"*
    done
}

function configure_easyrpg-player() {
    setConfigRoot "ports"

    mkRomDir "ports/easyrpg/games/"
    mkUserDir "$biosdir/rtp/2000"
    mkUserDir "$biosdir/rtp/2003"

    addPort "$md_id" "easyrpg" "EasyRPG Player" "cd $romdir/ports/easyrpg/games/; RPG2K_RTP_PATH=$biosdir/rtp/2000/ RPG2K3_RTP_PATH=$biosdir/rtp/2003 $md_inst/easyrpg-player"

}