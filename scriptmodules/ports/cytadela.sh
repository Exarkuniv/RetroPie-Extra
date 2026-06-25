#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="cytadela"
rp_module_desc="Cytadela project - a conversion of an Amiga first person shooter"
rp_module_licence="GNU http://cytadela.sourceforge.net/license.php"
rp_module_section="exp"
rp_module_flags="noinstclean"

function depends_cytadela() {
	 getDepends libvlccore9 libvlc-dev libsdl-mixer1.2-dev libsdl2-dev libglu1-mesa-dev libgl-dev libgl1-mesa-dev make libsdl1.2-dev libglbsp-dev xorg matchbox-window-manager x11-xserver-utils  vlc-plugin-base libvlc5 libsdl1.2debian libsdl-mixer1.2 libgl1 libgl1-mesa-glx

}

function sources_cytadela() {
	wget https://sourceforge.net/projects/cytadela/files/cytadela/1.1.0/cytadela-1.1.0.tar.bz2 || return 1
	tar -xf cytadela-1.1.0.tar.bz2 || return 1
}
function build_cytadela() {
	cd cytadela-1.1.0 || return 1
	./configure
 	make || return 1
	make install  || return 1

	md_ret_require=(
	)
}

function install_cytadela(){
	md_ret_files=(
	)
}

function configure_cytadela() {
   # moveConfigDir "$home/.cytadela" "$md_conf_root/$md_id"

    addPort "$md_id" "cytadela" " Cytadela clone" "XINIT:/usr/local/bin/cytadela"
}