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

rp_module_id="openloco"
rp_module_desc="OpenLoco - open-source re-implementation of Chris Sawyer's Locomotion, the spiritual successor to Transport Tycoon."
rp_module_help="Copy the Data, ObjData and Scenarios folders from your Chris Sawyer's Locomotion installation (or extract them with unshield) into your 'roms/ports/openloco/data' folder.

Set your resolution in the options menu after first launch of the game."
rp_module_licence="GNU https://raw.githubusercontent.com/OpenLoco/OpenLoco/refs/heads/master/LICENSE"
rp_module_repo="git https://github.com/OpenLoco/OpenLoco.git master"
rp_module_section="exp"
rp_module_flags="sdl2 !mali"


function depends_openloco() {
   getDepends libpng-dev libzip-dev libopenal-dev libyaml-cpp-dev libfmt-dev libsdl2-dev libtbb-dev matchbox
}


function sources_openloco() {
    gitPullOrClone
}

function build_openloco() {
    cmake --preset posix
    cmake --build --preset posix-release

    md_ret_require="$md_build/build/posix/Release/OpenLoco"
}

function install_openloco() {
    md_ret_files=(
        'build/posix/Release/OpenLoco'
		'build/posix/Release/data'
    )
}

function game_data_openloco() {
    cd "$md_inst/data"
	for file in $(ls -d *); do
		echo "Moving $md_inst/data/$file -> $romdir/ports/openloco/data/$file"
		if [[ -d "$md_inst/data/$file" ]]; then
			if [[ ! -d "$romdir/ports/openloco/data/$file" ]]; then
				mv "$md_inst/data/$file" "$romdir/ports/openloco/data/$file"
			else
				rm -rf "$romdir/ports/openloco/data/$file"
				mv "$md_inst/data/$file" "$romdir/ports/openloco/data/$file"
			fi
		else
			mv "$md_inst/data/$file" "$romdir/ports/openloco/data/$file"
		fi
	done

	rm -rf "$md_inst/data"
	ln -snf "$romdir/ports/openloco/data" "$md_inst/data"
	
	if [[ ! -f "$home/.config/OpenLoco/openloco.yml" ]]; then
	    [[ ! -d "$home/.config/OpenLoco" ]] && mkdir "$home/.config/OpenLoco"
		cd "$home/.config/OpenLoco"
        wget https://raw.githubusercontent.com/er-tho/game-data/main/openloco.yml
		sed -i.bak "s|/home/pi|$home|g" "$home/.config/OpenLoco/openloco.yml"
    fi
    chown -R $__user:$__group "$home/.config/OpenLoco"
}

function configure_openloco() {
    mkRomDir "ports/openloco/data"
	[[ "$md_mode" == "install" ]] && game_data_openloco
	chown -R $__user:$__group "$romdir/ports/openloco"
	
	cat >"$md_inst/loco.sh" << _EOF_

#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager & /opt/retropie/ports/openloco/OpenLoco 
_EOF_

 chmod +x "$md_inst/loco.sh"
	
    addPort "$md_id" "openloco" "OpenLoco - Chris Sawyer's Locomotion" "$md_inst/loco.sh"
}
