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

rp_module_id="shockolate"
rp_module_desc="Shockolate - Source port of System Shock"
rp_module_licence="GPL2 https://raw.githubusercontent.com/Interrupt/systemshock/master/LICENSE"
rp_module_help="Cody original cd-rom or SS:EE assets in a res/data folder in to the ports/shockolate/res."
rp_module_repo="git https://github.com/Interrupt/systemshock.git master"
rp_module_section="exp"
rp_module_flags="!all rpi4 rpi3"

function depends_shockolate() {
    getDepends cmake xorg libglu1-mesa-dev libgl1-mesa-dev libfluidsynth-dev libsdl2-dev libsdl2-mixer-dev  libfluidsynth-dev libfluidsynth1
}

function sources_shockolate() {
    gitPullOrClone
}

function build_shockolate() {
    ./build_deps.sh || return 1
    cmake ENABLE_SDL2=BUNDELED, ENABLE_SOUND=ON and ENABLE_FLUIDSYNTH=ON . || return 1
    make systemshock || return 1
}

function install_shockolate() {
    md_ret_files=(
       'systemshock'
    )
}


function configure_shockolate() {
    mkRomDir "ports/$md_id"
    ln -sf "$romdir/ports/$md_id/" "$md_inst/res"
    local script="$md_inst/$md_id.sh"
    mkUserDir "$home/.local/share/Interrupt/SystemShock"
    moveConfigDir "$home/.local/share/Interrupt/SystemShock" "$md_conf_root/systemshock"
    addPort "$md_id" "shockolate" "System Shock" "XINIT: $script %ROM%"

    #create buffer script for launch
    cat > "$script" << _EOF_
#!/bin/bash
pushd "$md_inst/res"
cd $md_inst && ./systemshock
_EOF_

    chmod +x "$script"
}