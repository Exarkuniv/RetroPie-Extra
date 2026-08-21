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

rp_module_id="widelands"
rp_module_desc="Widelands, open source real-time strategy game"
rp_module_help="The compiling process is extremely long, hang tight!

The default config set a resolution of 800x600. After first launch, you can set your resolution in the game settings, but you may have to restart the game for it to take fully effect in fullscreen."
rp_module_licence="GNU https://raw.githubusercontent.com/widelands/widelands/refs/heads/master/COPYING"
rp_module_repo="git https://github.com/widelands/widelands.git master"
rp_module_section="exp"
rp_module_flags="sdl2"


function depends_widelands() {
   getDepends libasio-dev libglew-dev libpng-dev libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev python3 zlib1g-dev libminizip-dev
}

function sources_widelands() {
    gitPullOrClone
}

function build_widelands() {
    ./compile.sh -r -j 3

    md_ret_require="$md_build/widelands"
}

function install_widelands() {
	cp -a $md_build/* $md_inst
}

function configure_widelands() {
    addPort "$md_id" "widelands" "Widelands" "XINIT: $md_inst/widelands"
}
