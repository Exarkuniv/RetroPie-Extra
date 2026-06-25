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

rp_module_id="gearboy"
rp_module_desc="Gearboy - Gameboy & Gameboy Color Emulator"
rp_module_licence="GPL3 https://raw.githubusercontent.com/drhelius/Gearboy/master/LICENSE"
rp_module_section="exp"
rp_module_repo="git https://github.com/DrHelius/GearBoy.git master"
rp_module_flags="!x86"

function depends_gearboy() {
    getDepends build-essential libsdl2-dev libglew-dev libgtk-3-dev

}

function sources_gearboy() {
    gitPullOrClone
}

function build_gearboy() {
     cd "$md_build/platforms/linux" || return 1
    make clean
    make || return 1
    strip "gearboy"

        md_ret_require="$md_build/platforms/linux/gearboy"
}

function install_gearboy() {
        cp "$md_build/platforms/linux/gearboy" "$md_inst/gearboy"

}

function configure_gearboy() {
    mkRomDir "gbc"
    mkRomDir "gb"
    defaultRAConfig "gb"
    defaultRAConfig "gbc"
    addEmulator 1 "$md_id" "gb" "$md_inst/gearboy %ROM%"
    addEmulator 1 "$md_id" "gbc" "$md_inst/gearboy %ROM%"
    addSystem "gb"
    addSystem "gbc"
    moveConfigFile "$home/gearboy.cfg" "$md_conf_root/gearboy/gearboy.cfg"
}