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

rp_module_id="vcmi"
rp_module_desc="Open-source engine for Heroes of Might and Magic III "
rp_module_help="Copy Data, Maps and Mp3 from Heroes III to roms/ports/vcmi"
rp_module_licence="GPL https://raw.githubusercontent.com/vcmi/vcmi/develop/license.txt"
rp_module_repo="git https://github.com/vcmi/vcmi.git develop"
rp_module_section="exp"
rp_module_flags="!mali !all rpi5" 

function depends_vcmi() {
    getDepends cmake g++ libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libsdl2-mixer-dev zlib1g-dev libavformat-dev libswscale-dev libboost-dev libboost-filesystem-dev libboost-system-dev libboost-thread-dev libboost-program-options-dev libboost-locale-dev qtbase5-dev libtbb-dev libluajit-5.1-dev
}

function sources_vcmi() {
    gitPullOrClone
}

function build_vcmi() {
    mkdir -p build
    cd build || return 1
    cmake .. -DENABLE_LAUNCHER=OFF -DENABLE_EDITOR=OFF -DENABLE_TEST=OFF -DM_DATA_DIR=/home/pi/RetroPie/roms/ports/vcmi    || return 1
    cmake --build . -- -j4 || return 1
    md_ret_require=()
}

function install_vcmi() {
	md_ret_files=(
        build/bin
        config
        Mods
    )
}

function configure_vcmi() {
    mkRomDir "/ports/$md_id/Saves"
    rm "$md_inst/bin/config"
    rm "$md_inst/bin/Mods"
    cp -r "$md_inst/config" "$md_inst/bin/config"
    cp -r "$md_inst/Mods" "$md_inst/bin/Mods"
    moveConfigDir "/home/pi/.local/share/$md_id/Saves" "$md_conf_root/$md_id/Saves"
    local script="$md_inst/$md_id.sh"

    cat > "$script" << _EOF_
#!/bin/bash
cd $md_inst/bin && ./vcmiclient
_EOF_

   chmod +x "$script"
   ln -sf "$romdir/ports/$md_id" "/home/pi/.local/share"
   addPort "$md_id" "vcmi" "Heroes of Might and Magic III" "$script"
}