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

rp_module_id="freeciv"
rp_module_desc="freeciv - Open Source empire-building strategy game"
rp_module_help="To get FullScreen Press escape. -> Local Options -> Interface. Change the option Screen resolution\n\nchange to best fit your screen"
rp_module_licence="GPL3 https://raw.githubusercontent.com/Aleph-One-Marathon/alephone/master/COPYING"
rp_module_repo="file http://files.freeciv.org/stable/freeciv-2.6.6.tar.bz2"
rp_module_section="exp"
rp_module_flags="!mali"


function depends_freeciv() {
   getDepends cmake libsdl1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev libsdl-ttf2.0-dev libsdl-gfx1.2-dev
}

function sources_freeciv() {
    downloadAndExtract "$md_repo_url" "$md_build" --strip-components 1
}

function build_freeciv() {
    params=(--prefix="$md_inst" --enable-sdl-mixer=sdl --disable-fcmp --disable-gtktest --enable-client=sdl)
    ./configure "${params[@]}"
    make || return 1
}

function install_freeciv() {
    make install || return 1
}

function configure_freeciv() {
    mkRomDir "ports"
    moveConfigDir "$home/.freeciv" "$md_conf_root/freeciv"
    moveConfigFile "$home/.freeciv-client-rc-2.4" "$md_conf_root/freeciv"
    addPort "$md_id" "freeciv" "Freeciv" "$md_inst/bin/freeciv-sdl"
}