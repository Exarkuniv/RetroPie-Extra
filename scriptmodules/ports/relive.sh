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

rp_module_id="relive"
rp_module_desc="R.E.L.I.V.E - Oddworld: Abe's Oddysee and Oddworld: Abe's Exoddus"
rp_module_licence="GNU https://github.com/lethal-guitar/RigelEngine/blob/master/LICENSE.md"
rp_module_repo="git https://github.com/AliveTeam/alive_reversing.git"
rp_module_section="exp"
rp_module_flags="noinstclean"


function depends_relive() {
   
	getDepends cmake libboost-all-dev libsdl2-dev libsdl2-mixer-dev libopengl-dev libglx-dev libopengl0 libclang-7-dev  libclang-common-7-dev clang clang-7 zenity xorg x11-xserver-utils libxrandr-dev libxrandr2 lxrandr
}

function sources_relive() {
    gitPullOrClone
}

function build_relive() {
    
	cd alive_reversing
	mkdir build
    cd build
	
	export CC=/usr/bin/clang
	export CXX=/usr/bin/clang++
    cmake -S .. -B .
	make
	#make -j$(nproc) > output.txt 2> errors.txt
    
	    md_ret_require=(
      )
}

function install_relive() {
    
	md_ret_files=(alive_reversing/build/Source/relive/relive
        	alive_reversing/assets/relive-ao
	alive_reversing/assets/relive-ae
        )
}

function configure_relive() {

		mkRomDir "ports/exoddus"
		mkRomDir "ports/oddysee"
	
	cp -r /opt/retropie/ports/relive/relive /home/pi/RetroPie/roms/ports/oddysee
	cp -r /opt/retropie/ports/relive/relive /home/pi/RetroPie/roms/ports/exoddus

	addPort "$md_id" "reliveae" "Oddworld: Abe's Exoddus" "XINIT: $md_inst/ae.sh"

	addPort "$md_id" "reliveao" "Oddworld: Abe's Oddysee" "XINIT: $md_inst/ao.sh"

cat >"$md_inst/ao.sh" << _EOF_

#!/bin/bash
cd "/home/pi/RetroPie/roms/ports/oddysee"
./relive

_EOF_
	 chmod +x "$md_inst/ao.sh"

cat >"$md_inst/ae.sh" << _EOF_

#!/bin/bash
cd "/home/pi/RetroPie/roms/ports/exoddus"
./relive

_EOF_
	 chmod +x "$md_inst/ae.sh"

	chown -R pi:pi "/home/pi/RetroPie/roms/ports/exoddus/relive"
	chown -R pi:pi "/home/pi/RetroPie/roms/ports/oddysee/relive"


	#ln -s "/home/pi/RetroPie/roms/ports/relive" "/opt/retropie/ports/relive"  
  
}
