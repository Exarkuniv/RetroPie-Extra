#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="pcexhumed"
rp_module_desc="PCExhumed - Powerslave source port"
rp_module_licence="GPL3 https://github.com/OpenMW/osg/blob/3.4/LICENSE.txt"
rp_module_help="you need to put the 
STUFF.DAT
DEMO.VCR
BOOK.MOV
in the ports/PCExhumed folder

Recommended (but optional) - Add the games CD audio tracks as OGG files in the format exhumedXX.ogg or trackXX.ogg (where XX is the track number) 
to the same folder as pcexhumed.exe. The game includes tracks 02 to 19. These will provide the game with its music soundtrack 
and add storyline narration by the King Ramses NPC.
"
rp_module_section="exp"
rp_module_flags=""


function depends_pcexhumed() {
   getDepends cmake xorg xinit x11-xserver-utils xinit build-essential nasm libgl1-mesa-dev libglu1-mesa-dev libsdl1.2-dev libsdl-mixer1.2-dev libsdl2-dev libsdl2-mixer-dev flac libflac-dev libvorbis-dev libvpx-dev libgtk2.0-dev freepats
  
}

function sources_pcexhumed() {
	gitPullOrClone "$md_build" https://github.com/Exarkuniv/NBlood.git
}

function build_pcexhumed() {
    cd $md_build || return 1
    make exhumed USE_OPENGL=1 STARTUP_WINDOW=0 || return 1
	md_ret_require="$md_build"
}

function install_pcexhumed() {
    md_ret_files=(        
        'pcexhumed'
		'nblood.pk3'
		'pcexhumed.cfg'
    )
}
	
function configure_pcexhumed() {
	mkdir -p "$home/.config/pcexhumed"
	cp -v pcexhumed.cfg "$home/.config/pcexhumed"
	
	moveConfigDir "$home/.config/pcexhumed" "$md_conf_root/pcexhumed"
	mkRomDir "ports/pcexhumed"
	
	addPort "$md_id" "pcexhumed" "PCExhumed - Powerslave source port" "XINIT: $md_inst/pcexhumed  -j /home/pi/RetroPie/roms/ports/pcexhumed"	
}