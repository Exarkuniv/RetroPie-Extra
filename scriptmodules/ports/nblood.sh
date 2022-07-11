#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="nblood"
rp_module_desc="Nblood - Blood source port"
rp_module_licence="GPL3 https://github.com/OpenMW/osg/blob/3.4/LICENSE.txt"
rp_module_help="you need to put the \n\BLOOD.INI, \n\BLOOD.RFF, \n\BLOOD000.DEM, ..., BLOOD003.DEM (optional), \n\GUI.RFF, \n\SOUNDS.RFF, \n\SURFACE.DAT, \n\TILES000.ART, ..., TILES017.ART, \n\VOXEL.DAT in $romdir/ports/Nblood

Cryptic Passage
CP01.MAP, ..., CP09.MAP,\n\CPART07.AR_,\n\CPART15.AR_,\n\CPBB01.MAP, ..., CPBB04.MAP,\n\CPSL.MAP,\n\CRYPTIC.INI\n\CRYPTIC.SMK \n\CRYPTIC.WAV"
rp_module_repo="git https://github.com/Exarkuniv/NBlood.git"
rp_module_section="exp"
rp_module_flags=""


function depends_nblood() {
   getDepends cmake xorg xinit x11-xserver-utils build-essential nasm libgl1-mesa-dev libglu1-mesa-dev libsdl1.2-dev libsdl-mixer1.2-dev libsdl2-dev libsdl2-mixer-dev flac libflac-dev libvorbis-dev libvpx-dev libgtk2.0-dev freepats
  
}

function sources_nblood() {
	gitPullOrClone 
}

function build_nblood() {
    cd $md_build
   make blood USE_OPENGL=0 STARTUP_WINDOW=0
	md_ret_require="$md_build"
}

function install_nblood() {
    md_ret_files=(        
        'nblood'
		'nblood.pk3'
		'nblood.cfg'
    )
}

function game_data_nblood() {
    if [[ ! -f "$romdir/ports/nblood/BLOOD.EXE" ]]; then
        downloadAndExtract "https://archive.org/download/Blood_64/BLOOD.zip" "$romdir/ports/nblood/"
    chown -R $user:$user "$romdir/ports/nblood"
    fi
}
	
function configure_nblood() {
	mkdir "$home/.config/nblood"
	
	cp -v nblood.cfg "$home/.config/nblood"
	chown -R pi:pi "$home/.config/nblood"
	
	mkRomDir "ports/nblood"
	#mkRomDir "ports/nblood/CP"
	
	addPort "$md_id" "nblood" "Nblood - Blood source port" "XINIT: $md_inst/nblood  -j=/home/pi/RetroPie/roms/ports/nblood"	
	#addPort "$md_id" "nbloodcp" "Nblood - Cryptic Passage " "XINIT: $md_inst/nblood -ini CRYPTIC.INI -j=/home/pi/RetroPie/roms/ports/nblood/CP"

	[[ "$md_mode" == "install" ]] && game_data_nblood
}