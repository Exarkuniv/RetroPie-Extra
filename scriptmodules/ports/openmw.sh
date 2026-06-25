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

rp_module_id="openmw"
rp_module_desc="openmw - Morrowind source port"
rp_module_licence="GPL3 https://github.com/OpenMW/osg/blob/3.4/LICENSE.txt"
rp_module_help="Copy\nMorrowind.esm\nBloodmoon.esm\nTribunal.esm\nFonts folder\nMusic folder\nSound folder\nin the morrowind Folder in above format.\nMAKE sure the video folder is not there, IT will crash. This takes 1HOUR 50MIN to build\n
This will only run MAIN game if you want the expansions have them in a morrowind folder before you install"
rp_module_section="exp"
rp_module_flags="noinstclean !all rpi4 rpi3"

function depends_openmw() {
   getDepends cmake build-essential libopenal-dev libopenscenegraph-3.4-dev libsdl2-dev libqt4-dev libboost-filesystem-dev libboost-thread-dev libboost-program-options-dev libboost-system-dev libboost-iostreams-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libswresample-dev libbullet-dev libmygui-dev libunshield-dev libqt4-opengl-dev libtinyxml-dev xorg matchbox
}

function _arch_openmw() {
    # exact parsing from Makefile
    echo "$(uname -m | sed -e 's/i.86/x86/' | sed -e 's/^arm.*/arm/')"
}


function sources_openmw() {
    local revision=openmw-0.46.0
    gitPullOrClone "$md_build" https://gitlab.com/OpenMW/openmw.git "" "$revision"
}

function build_openmw() {
    if [ ! -f "/usr/local/lib/libOpenThreads.so" ]; then
        gitPullOrClone "$md_build/openosg" https://github.com/OpenMW/osg.git
    cd "$md_build/openosg" || return 1
    cmake . -DBUILD_OSG_PLUGINS_BY_DEFAULT=0 -DBUILD_OSG_PLUGIN_OSG=1 -DBUILD_OSG_PLUGIN_DDS=1 -DBUILD_OSG_PLUGIN_TGA=1 -DBUILD_OSG_PLUGIN_BMP=1 -DBUILD_OSG_PLUGIN_JPEG=1 -DBUILD_OSG_PLUGIN_PNG=1 -DBUILD_OSG_PLUGIN_FREETYPE=1 -DBUILD_OSG_DEPRECATED_SERIALIZERS=0 -DOPENGL_PROFILE=GL2 -DOSG_GLES1_AVAILABLE=FALSE -DOSG_GLES2_AVAILABLE=FALSE -DOSG_GLES3_AVAILABLE=FALSE     || return 1
    make || return 1
    cd "$md_build/openosg" || return 1
    sudo make install
    rm -r "$md_build/openosg"
	
    fi

    mkdir -p $md_build/build
    cd $md_build/build || return 1
    cmake .. || return 1
    make clean
    make || return 1

    md_ret_require=(
        "$md_build/build/bsatool"
        "$md_build/build/esmtool"
        "$md_build/build/niftest"
        "$md_build/build/openmw"
        "$md_build/build/openmw-cs"
        "$md_build/build/openmw-cs.cfg"
        "$md_build/build/openmw.cfg"
        "$md_build/build/settings-default.cfg"
        )
}

function install_openmw() {
    md_ret_files=(
        "build/bsatool"
        "build/esmtool"
        "build/niftest"
        "build/openmw"
        "build/openmw-cs"
        "build/openmw-cs.cfg"
        "build/openmw.cfg"
        "build/resources"
        "build/settings-default.cfg"
        )
}

function config_data_openmw() { 
    #look for the data files to see what config to install
	
    #download config to for the data files for main and all exp
    if [[ -f "$romdir/ports/morrowind/Morrowind.bsa" && -f "$romdir/ports/morrowind/Tribunal.bsa" && -f "$romdir/ports/morrowind/Bloodmoon.bsa"  ]]; then
	download "https://raw.githubusercontent.com/Exarkuniv/game-data/main/openmw/1/openmw.cfg" "$md_conf_root/openmw"
	
	#download config to for the data files for main and tribunal exp
    elif [[ -f "$romdir/ports/morrowind/Morrowind.bsa" && -f "$romdir/ports/morrowind/Tribunal.bsa" ]]; then
	download "https://raw.githubusercontent.com/Exarkuniv/game-data/main/openmw/2/openmw.cfg" "$md_conf_root/openmw"
	
	#download config to for the data files for main and bloodmoon exp
    elif [[ -f "$romdir/ports/morrowind/Morrowind.bsa" && -f "$romdir/ports/morrowind/Bloodmoon.bsa" ]]; then
	download "https://raw.githubusercontent.com/Exarkuniv/game-data/main/openmw/3/openmw.cfg" "$md_conf_root/openmw"

    elif [[ -f "$romdir/ports/morrowind/Morrowind.bsa" ]]; then
    download "https://raw.githubusercontent.com/Exarkuniv/game-data/main/openmw/4/openmw.cfg" "$md_conf_root/openmw"
	fi
}

function configure_openmw() {
    local launcher=("$md_inst/openmw")
    local script="$md_inst/$md_id.sh"
    mkRomDir "ports/morrowind"
    moveConfigDir "$md_inst/data" "$romdir/ports/morrowind"
    moveConfigDir "$home/.config/openmw" "$md_conf_root/$md_id"

	#updated conntroller DB file
    download "https://raw.githubusercontent.com/gabomdq/SDL_GameControllerDB/master/gamecontrollerdb.txt" "$md_inst"

	#create buffer script for launch
	 cat > "$script" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
OPENMW_DECOMPRESS_TEXTURES=1 ${launcher[*]}
_EOF_

    chmod +x "$script"
    addPort "$md_id" "openmw" "The Elder Scrolls III - Morrowind" "XINIT:$script"
	
	[[ "$md_mode" == "install" ]] && config_data_openmw
}