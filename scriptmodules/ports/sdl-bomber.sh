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

rp_module_id="sdl-bomber"
rp_module_desc="sdl-bomber - Atomic Bomberman Clone"
rp_module_licence="GPL2 https://raw.githubusercontent.com/HerbFargus/SDL-Bomber/master/COPYING"
rp_module_repo="git https://github.com/HerbFargus/SDL-Bomber.git master"
rp_module_section="exp"
rp_module_flags="!mali"

function depends_sdl-bomber() {
    getDepends libsdl1.2-dev
}

function sources_sdl-bomber() {
    gitPullOrClone
}

function build_sdl-bomber() {
  make || return 1
  md_ret_require="$md_build"
}

function install_sdl-bomber() {
    md_ret_files=(
	'data'
	'bomber'
	'matcher'
    )
}

function configure_sdl-bomber() {
    local script="$md_inst/$md_id.sh"
    setConfigRoot "ports"
#create buffer script for launch
 cat > "$script" << _EOF_
#!/bin/bash
pushd "$md_inst"
"./bomber" \$*
popd
_EOF_
    
	chmod +x "$script"
    addPort "$md_id" "sdl-bomber" "SDL-Bomber" "XINIT: pushd $md_inst; ./bomber; popd"
}