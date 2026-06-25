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

rp_module_id="breaker"
rp_module_desc="breaker - Arkanoid Clone"
rp_module_licence="GPL2 https://ayera.dl.sourceforge.net/project/breaker10/source/GNU-GPL-2.0.txt"
rp_module_repo="file http://oldschoolprg.x10.mx/downloads/_sf_breaker_215.tar.gz"
rp_module_help="Because this uses X, you may find that you are unable to control the game and the game appears in a small window in the top left. Use the Runcommand option to set the resolution to CEA-4 or similarly smaller sizes. This will allow you to control the game as the window will have focus and also fill up more of the screen."
rp_module_section="exp"
rp_module_flags="!x86 !mali"

function depends_breaker() {
    getDepends libsdl2-dev unzip xorg xinit x11-xserver-utils
}

function sources_breaker() {
    downloadAndExtract "$md_repo_url" "$md_build"
}

function build_breaker() {
  cd "$md_build/source" || return 1
 sed -i "s/-lSDL/-lSDL -lm/" "$md_build/source/Makefile"
  make || return 1
  md_ret_require="$md_build/source/breaker"
}

function install_breaker() {
    md_ret_files=(
	'source/breaker'
	'source/gfx'
	'source/sfx'
    )
}

function configure_breaker() {
    local script="$md_inst/$md_id.sh"
    mkRomDir "ports"
	#create buffer script for launch
	 cat > "$script" << _EOF_
#!/bin/bash
pushd "$md_inst"
"./breaker" \$*
popd
_EOF_
    
	chmod +x "$script"
    addPort "$md_id" "breaker" "breaker - Arkanoid Clone" "XINIT:$script"
}