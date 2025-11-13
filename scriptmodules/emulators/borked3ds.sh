#!/usr/bin/env bash

# This file is part of RetroPie-Extra, a supplement to RetroPie.
# For more information, please visit:
#
# https://github.com/RetroPie/RetroPie-Setup
# https://github.com/Exarkuniv/RetroPie-Extra
# https://github.com/FollyMaddy/RetroPie-Share
#
# See the LICENSE file distributed with this source and at
# https://raw.githubusercontent.com/Exarkuniv/RetroPie-Extra/master/LICENSE
#

#Version 0.2
rp_module_id="borked3ds"
rp_module_desc="3DS Emulator borked3ds"
rp_module_help="ROM Extension: .3ds .3dsx .elf .axf .cci .cxi .app\n\nCopy your 3DS roms to $romdir/3ds"
rp_module_licence="GPL2 https://github.com/Borked3DS/Borked3DS/blob/master/license.txt"
rp_module_section="exp"
rp_module_flags="64bit"
 
function depends_borked3ds() {
    if compareVersions $__gcc_version lt 7; then
        md_ret_errors+=("Sorry, you need an OS with gcc 7.0 or newer to compile borked3ds")
        return 1
    fi
    
    #for aarch64 and x86_64 these dependancies are the same
    #seems to work without, depends that are removed (not tested yet on x86): libc++-dev ffmpeg libavdevice-dev
    local depends=(build-essential cmake clang clang-format libsdl2-dev libssl-dev qt6-l10n-tools qt6-tools-dev qt6-tools-dev-tools qt6-base-dev qt6-base-private-dev libxcb-cursor-dev libvulkan-dev qt6-multimedia-dev libqt6sql6 libasound2-dev xorg-dev libx11-dev libxext-dev libpipewire-0.3-dev libsndio-dev libgl-dev  libswscale-dev libavformat-dev libavcodec-dev libglut3.12 libglut-dev freeglut3-dev mesa-vulkan-drivers)
    #use libqt6core6t64 for Trixie or higher
    
    if compareVersions $__gcc_version lt 14; then
		depends+=(libqt6core6)
	else
		depends+=(libqt6core6t64)
	fi
    #cpu based: additional libraries
    #packages not in bookworm for x86_64 : libfdk-aac-dev
	#robin-map-dev is in the source and found when using https://github.com/rtiangha/Borked3DS.git
	if isPlatform "aarch64"; then
		depends+=(libfdk-aac-dev robin-map-dev) 
	fi
	getDepends "${depends[@]}"
}

function sources_borked3ds() {
#backup of all forks, replace in if function when needed
#gitPullOrClone "$md_build" https://github.com/rtiangha/Borked3DS.git vk-regression 
#gitPullOrClone "$md_build" https://github.com/borked3ds/Borked3DS.git
#gitPullOrClone "$md_build" https://github.com/rtiangha/Borked3DS.git vulkan-validation
#gitPullOrClone "$md_build" https://github.com/rtiangha/Borked3DS.git mobile-gpus
#gitPullOrClone "$md_build" https://github.com/rtiangha/Borked3DS.git gpu-revert
#gitPullOrClone "$md_build" https://github.com/rtiangha/Borked3DS.git opengles-dev
#gitPullOrClone "$md_build" https://github.com/rtiangha/Borked3DS.git opengles-dev
#gitPullOrClone "$md_build" https://github.com/rtiangha/Borked3DS.git vk-revert
#gitPullOrClone "$md_build" https://github.com/rtiangha/Borked3DS.git
#gitPullOrClone "$md_build" https://github.com/rtiangha/Borked3DS.git vk-revert-mem-alloc
#gitPullOrClone "$md_build" https://github.com/rtiangha/Borked3DS.git vk-revert-0
#gitPullOrClone "$md_build" https://github.com/rtiangha/Borked3DS.git vk-revert-1
#gitPullOrClone "$md_build" https://github.com/rtiangha/Borked3DS.git vk-revert-2
#gitPullOrClone "$md_build" https://github.com/rtiangha/Borked3DS.git vk-revert-3
#gitPullOrClone "$md_build" https://github.com/Borked3DS/Borked3DS.git
#gitPullOrClone "$md_build" https://github.com/rtiangha/Borked3DS.git opengles-dev-v2
#gitPullOrClone "$md_build" https://github.com/rtiangha/Borked3DS.git fix-gcc12
#gitPullOrClone "$md_build" https://github.com/gvx64/Borked3DS-rpi.git

	if isPlatform "aarch64"; then
		gitPullOrClone "$md_build" https://github.com/gvx64/Borked3DS-rpi.git
	else
		gitPullOrClone "$md_build" https://github.com/rtiangha/Borked3DS.git
	fi
	
	#do this after cloning Borked3ds, otherwise the $md_build will already exist and cloning will fail
	#Borked3DS requires a cmake 3.5 as minimum, we will use the 4.0.2 binary when using Bookworm or lower
	#find the files on "https://cmake.org/files/v4.0/" (cmake-4.0.2.tar.gz is source only)
	if compareVersions $__gcc_version lt 14; then
		if isPlatform "aarch64"; then
			downloadAndExtract https://cmake.org/files/v4.0/cmake-4.0.2-linux-aarch64.tar.gz "$md_build"
		else
			downloadAndExtract https://cmake.org/files/v4.0/cmake-4.0.2-linux-x86_64.tar.gz "$md_build"
		fi
		mv cmake-4.0.2* cmake-4.0.2
	fi
}
 
function build_borked3ds() {
	local extra_build_options
 	isPlatform "aarch64" && extra_build_options="-DDYNARMIC_USE_BUNDLED_EXTERNALS=OFF"
	mkdir build
	cd build
	#Borked3DS requires a cmake 3.5 as minimum, we will use the 4.0.2 binary when using Bookworm or lower
	if compareVersions $__gcc_version lt 14; then
		$md_build/cmake-4.0.2/bin/cmake .. -DCMAKE_BUILD_TYPE=Release $extra_build_options
		$md_build/cmake-4.0.2/bin/cmake --build . -- -j"$(nproc)"
	else
		cmake .. -DCMAKE_BUILD_TYPE=Release $extra_build_options
		cmake --build . -- -j"$(nproc)"
	fi
	md_ret_require="$md_build/build/bin"
}
 
function install_borked3ds() {
	md_ret_files=(
	'build/bin/Release/borked3ds'
	#'build/bin/Release/borked3ds-cli'
	#'build/bin/Release/borked3ds-room'
	#'build/bin/Release/tests'
	)
}
 
function configure_borked3ds() {
    mkRomDir "3ds"
    ensureSystemretroconfig "3ds"
    local launch_prefix
    local launch_extension
    isPlatform "kms" && launch_prefix="XINIT-WMC:"
    #isPlatform "aarch64" && launch_extension="env MESA_EXTENSION_OVERRIDE=GL_OES_texture_buffer;"
	addEmulator 0 "$md_id-ui" "3ds" "$launch_extension$launch_prefix$md_inst/borked3ds"
	addEmulator 1 "$md_id-roms" "3ds" "$launch_extension$launch_prefix$md_inst/borked3ds %ROM%"
	#addEmulator 1 "$md_id-room" "3ds" "$launch_extension$launch_prefix$md_inst/borked3ds-room"
	#addEmulator 2 "$md_id-cli" "3ds" "$launch_extension$launch_prefix$md_inst/borked3ds-cli"
	#addEmulator 3 "$md_id-tests" "3ds" "$launch_extension$launch_prefix$md_inst/tests"
	addSystem "3ds" "3ds" ".3ds .3dsx .elf .axf .cci .cxi .app" 
}

function gui_borked3ds() {
    #special charachters ■□▪▫▬▲►▼◄◊○◌●☺☻←↑→↓↔↕⇔
    local csv=()
    csv=(
`□menu_item□□to_do□□□□□help_to_do□`
'□Add/Remove GL_OES_texture_buffer (Mesa Extension Overide)□□patch_es_systems_cfg_borked3ds□□□□□printMsgs dialog "@gvx64:\nI added support for GL_OES_texture_buffer in Borked3ds-rpi. This is a GLES 3.2 extension that the Pi does not completely support, but the code in Borked3ds-rpi does not depend on the problematic portions of this extension and so we can tap into this GLES 3.2 functionality on the Pi by using an environment variable override. to launch within Retropie with GL_OES_texture_buffer support enabled, edit the contents of /etc/emulationstation/es_systems.cfg so that the 3DS entry appears as follows. This will theoretically give better performance than the fall-back code path that uses 2D texture LUTs and it should be more accelerated in games that have fog/lighting effects (that said, I am not noticing much of an improvement on my Pi4, maybe because it is GPU is too weak for it to matter)."□'
# next are a few examples
#'□Enable Gles□□iniConfig "=" "" "/home/$user/.config/borked3ds-emu/qt-config.ini";iniSet "use_gles" "true"□□□□□printMsgs dialog "NO HELP"□'
#'□Disable Gles□□iniConfig "=" "" "/home/$user/.config/borked3ds-emu/qt-config.ini";iniSet "use_gles" "false"□□□□□printMsgs dialog "NO HELP"□'
#'□Overwrite qt-config.ini from pastebin (@DTEAM)□□curl https://pastebin.com/raw/KXEmXpjQ > "/home/$user/.config/borked3ds-emu/qt-config.ini"□□□□□printMsgs dialog "NO HELP"□'
	)
    build_menu_borked3ds
}

function build_menu_borked3ds() {
    local options=()
    local default
    local i
    local run
    IFS="□"
    for i in ${!csv[@]}; do set ${csv[$i]}; options+=("$i" "$2");done
    while true; do
        local cmd=(dialog --colors --no-collapse --help-button --menu "Choose an option" 22 76 16)
        local choice=$("${cmd[@]}" "${options[@]}" 2>&1 >/dev/tty)
        default="$choice"
        IFS="□"
        if [[ -n "$choice" ]]; then
            joy2keyStop
            joy2keyStart 0x00 0x00 kich1 kdch1 0x20 0x71
            clear
			if [[ $choice == HELP* ]];then
			run="$(set ${csv[${choice/* /}]};echo $9)"
			else
			run="$(set ${csv[$choice]};echo $4)"
			fi
            joy2keyStop
            joy2keyStart
            unset IFS
	    eval $run
	    joy2keyStart
        else
            break
        fi
    done
    unset IFS
}

function patch_es_systems_cfg_borked3ds() {
local patch_option
local patch_msgs
if [[ $(cat /etc/emulationstation/es_systems.cfg) == *"buffer;"* ]];then
patch_msgs=Remove
patch_option=-R
else
patch_msgs=Add
patch_option=
fi
printMsgs dialog "$patch_msgs :\n'env MESA_EXTENSION_OVERRIDE=GL_OES_texture_buffer'\nin /etc/emulationstation/es_systems.cfg\n\nJust use this option again to reverse !"
patch $patch_option /etc/emulationstation/es_systems.cfg << _EOF_
@@ -1 +1 @@
-    <command>/opt/retropie/supplementary/runcommand/runcommand.sh 0 _SYS_ 3ds %ROM%</command>
+    <command>env MESA_EXTENSION_OVERRIDE=GL_OES_texture_buffer;/opt/retropie/supplementary/runcommand/runcommand.sh 0 _SYS_ 3ds %ROM%</command>
_EOF_
}
