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

rp_module_id="hurrican"
rp_module_desc="Hurrican - Turrican clone - A freeware jump and shoot game made by Poke53280 (Eiswuxe)"
rp_module_help="After installation, select game from the Ports system.\n\nSelect gamepad controls in game preferences menu."
rp_module_repo="git https://github.com/HurricanGame/Hurrican.git master"
rp_module_licence="MIT https://raw.githubusercontent.com/HurricanGame/Hurrican/master/LICENSE"
rp_module_section="exp"
rp_module_flags="!all rpi4 rpi5"

function depends_hurrican() {
    getDepends libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libepoxy-dev cmake
}

function sources_hurrican() {
    gitPullOrClone
}

function build_hurrican() {
    cd "$md_build/Hurrican" || return 1
    mkdir -p build && cd build
    cmake -DCMAKE_BUILD_TYPE=Release .. || return 1
    make || return 1
    md_ret_require="$md_build/Hurrican/build/hurrican"
}

function install_hurrican() {
    md_ret_files=(
        'Hurrican/build/hurrican'
        'Hurrican/data'
        'Hurrican/lang'
        'Hurrican/splashscreen.bmp'
        'Editor/maps'
        'Editor/Gfx'
    )
}

function configure_hurrican() {
    addPort "$md_id" "hurrican" "Hurrican - Turrican clone" "pushd $md_conf_root/hurrican; $md_inst/hurrican --pathdata $md_inst --pathsave $md_conf_root/hurrican; popd"
    mkRomDir "ports"
    moveConfigDir "$home/.config/hurrican" "$md_conf_root/hurrican"
}