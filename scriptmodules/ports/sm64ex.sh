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

rp_module_id="sm64ex"
rp_module_desc="sm64ex - Super Mario 64 PC Port (Pi 4 only)"
rp_module_help="To compile properly, this port requires a Super Mario 64 ROM in z64 format.\n\nPlace your Super Mario 64 ROM into $home with the name baserom.<VERSION>.z64\nwhere VERSION can be us, eu or jp depending on the ROM you are using.\n\nFor example, a US Super Mario 64 ROM should be placed at /home/pi/baserom.us.z64."
rp_module_repo="git https://github.com/sm64pc/sm64ex.git nightly"
rp_module_section="exp"
rp_module_flags="!mali !all rpi4 rpi3"

function depends_sm64ex() {
    getDepends git python3 libaudiofile-dev libglew-dev libglfw3-dev libusb-dev libsdl2-dev
}

function sources_sm64ex() {
    gitPullOrClone

    if [[ -f $home/baserom.us.z64 ]]
    then
	cp "$home/baserom.us.z64" "$md_build"
    elif [[ -f $home/baserom.eu.z64 ]]
    then
	cp "$home/baserom.eu.z64" "$md_build"
    elif [[ -f $home/baserom.jp.z64 ]]
    then
        cp "$home/baserom.jp.z64" "$md_build"
    else
	dialog --msgbox "Unable to find the required baserom.<VERSION>.z64 file to extract. Make sure to place it in $home." 0 0
        md_ret_errors+=("Failed: Couldn't find Super Mario 64 baserom to extract assets from.")
    fi
}

function build_sm64ex() {
    pitype=$(tr -d '\0' < /sys/firmware/devicetree/base/model)
    if [[ $pitype =~ "4" ]]
    then

	if [[ -f "$md_build/baserom.us.z64" ]]
	then
        	 make EXT_OPTIONS_MENU=1 CONTROLLER_API=SDL2 TARGET_RPI=1 VERSION=us || return 1
                 mv "$md_build/build/us_pc/sm64.us.f3dex2e.arm" "$md_build/build/sm64ex.arm" || return 1
    	elif [[ -f $home/baserom.eu.z64 ]]
    	then
        	 make EXT_OPTIONS_MENU=1 CONTROLLER_API=SDL2 TARGET_RPI=1 VERSION=eu || return 1
		 mv "$md_build/build/eu_pc/sm64.eu.f3dex2e.arm" "$md_build/build/sm64ex.arm" || return 1
    	elif [[ -f $home/baserom.jp.z64 ]]
    	then
        	 make EXT_OPTIONS_MENU=1 CONTROLLER_API=SDL2 TARGET_RPI=1 VERSION=jp || return 1
	         mv "$md_build/build/jp_pc/sm64.jp.f3dex2e.arm" "$md_build/build/sm64ex.arm" || return 1
    	else
        	dialog --msgbox "Can't find the baserom you are attempting to use so we cannot tell which version you are trying to compile." 0 0
        	md_ret_errors+=("Failed: Couldn't find baserom so unsure which version to compile.")
    	fi
    else
    	dialog --msgbox "This script is specifically for installing on the Raspberry Pi 4. You would be better off trying the Raspberry Pi helper script but it is unsupported by RetroPie: https://github.com/sm64pc/sm64ex/wiki/Helper-compiling-script-for-Raspberry-Pi" 0 0
        md_ret_errors+=("Failed: Installation script for $md_desc is specifically for Raspberry Pi 4.")
    fi
    md_ret_require="$md_build/build/sm64ex.arm"
}

function install_sm64ex() {
    md_ret_files=(
          'build/sm64ex.arm'
    )
}

function configure_sm64ex() {
    chown pi:pi "$md_inst"

    local dir
    for dir in .config .local/share; do
        moveConfigDir "$home/$dir/sm64pc" "$md_conf_root/sm64ex"
    done

    addPort "$md_id" "sm64ex" "sm64ex - Super Mario 64 PC Port (Pi 4)" "/opt/retropie/ports/sm64ex/sm64ex.arm"
}
