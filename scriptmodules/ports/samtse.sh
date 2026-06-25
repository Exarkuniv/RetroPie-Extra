#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="samtse"
rp_module_desc="SamTSE - Serious Sam Classic The Second Encounter"
rp_module_licence="GPL2 https://raw.githubusercontent.com/tx00100xt/SeriousSamClassic/main/LICENSE"
rp_module_help="NEED Serious Sam Classic version of this game\n Copy all *.gro files and Help folder from the game directory to SamTSE directory. At the current time the files are:
\nHelp (folder)\nSE1_00.gro\nSE1_00_Extra.gro\nSE1_00_ExtraTools.gro\nSE1_00_Levels.gro\nSE1_00_Logo.gro\nSE1_00_Music.gro\n1_04_patch.gro\n1_07_tools.gro"
rp_module_repo="git https://github.com/tx00100xt/SeriousSamClassic.git main"
rp_module_section="exp"
rp_module_flags="!all rpi5"

function depends_samtse() {
    getDepends libogg-dev libvorbis-dev xorg flex flexc++ bison libbison-dev
}

function sources_samtse() {
    gitPullOrClone

        if [[ "$md_id" == "samtse" ]]; then
        sed -i 's#1_0_InTheLastEpisode.wld#1_1_Palenque.wld#' "$md_build/SamTSE/Sources/SeriousSam/SeriousSam.cpp"
        #find . -wholename "Sources/SeriousSam/SeriousSam.cpp" -exec sed -i 's/1_1_Palenque.wld/1_0_InTheLastEpisode.wld/g' {} +
    fi

}

function build_samtse() {
    local params=()
    mkdir -p "$md_build/build"
    cd "$md_build/build" || return 1

    isPlatform "rpi4" && params+=(-DRPI4=TRUE)
    isPlatform "32bit" && params+=(-DUSE_I386_NASM_ASM=FALSE)

    cmake "${params[@]}" .. || return 1
    make -j4 || return 1

    if [[ "$md_id" == "samtfe" ]]; then
    md_ret_require="$md_build/build/SamTFE/Sources/SeriousSam"
    else
    md_ret_require="$md_build/build/SamTSE/Sources/SeriousSam"
fi

}

function install_samtse() {
    if [[ "$md_id" == "samtfe" ]]; then
       md_ret_files=('build/SamTFE/Sources/SeriousSam'
       'build/SamTFE/Sources/Debug'
       'SamTFE/SE1_10b.gro'
       'SamTFE/ModEXT.txt')
    else
        md_ret_files=('build/SamTSE/Sources/SeriousSam'
       'build/SamTSE/Sources/Debug'
       'SamTSE/SE1_10b.gro'
       'SamTSE/ModEXT.txt')
    fi
}

function configure_samtse() {
    local dirname="tse"
    local appname="samtse"
    local portname="samtse"
    local script="$md_inst/$portname.sh"
    if [[ "$md_id" == "samtfe" ]]; then
        dirname="tfe"
        appname="samtfe"
        portname="samtfe"

    fi

    mkdir -p "$md_inst/$dirname"
    sudo mv -v "/opt/retropie/ports/$portname/Debug" "/opt/retropie/ports/$portname/$dirname/Bin"
    sudo mv -v "/opt/retropie/ports/$portname/SeriousSam" "/opt/retropie/ports/$portname/$dirname/Bin"
    sudo mv -v "/opt/retropie/ports/$portname/SE1_10b.gro" "/opt/retropie/ports/$portname/$dirname"
    sudo mv -v "/opt/retropie/ports/$portname/ModEXT.txt" "/opt/retropie/ports/$portname/$dirname"

    mkRomDir "ports/$md_id"
       ln -sf "/opt/retropie/ports/$md_id/$dirname" "$romdir/ports/$md_id/"
    local script="$md_inst/$md_id.sh"
      cat > "$script" << _EOF_

#!/bin/bash
"$md_inst/$dirname/Bin/SeriousSam"
_EOF_
    chmod +x "$md_inst/$md_id.sh"
    chown -R pi:pi "/opt/retropie/ports/$md_id/$dirname"

    if [[ "$md_id" == "samtfe" ]]; then
    addPort "$md_id" "samtfe" "Serious Sam Classic The First Encounter" "XINIT: $script %ROM%"
    else
    addPort "$md_id" "$portname" "Serious Sam Classic The Second Encounter" "XINIT: $script %ROM%"
    fi
}