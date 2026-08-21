#!/usr/bin/env bash

# This file is part of The RetroPie Project
# 
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
# 
# See the LICENSE.md file at the top-level directory of this distribution and 
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="corsixth"
rp_module_desc="CorsixTH - Theme Hospital Engine"
rp_module_licence="MIT https://raw.githubusercontent.com/CorsixTH/CorsixTH/master/LICENSE.txt"
rp_module_help="Mouse or mouse emulation through xboxdrv is required. You need to copy your Theme Hospital game data into $romdir/ports/corsixth/ and when starting up the game for the first time, select the directory. The colors and fonts could have bad colors here making it difficult."
rp_module_section="exp"
rp_module_flags="noinstclean !x86 !mali"

function depends_corsixth() {
    local depends=(cmake liblua5.3-0 liblua5.3-dev liblua5.3-0-dbg libsdl2-dev libsdl2-mixer-dev fluidsynth libfreetype6-dev lua-filesystem lua-lpeg doxygen ffmpeg libavcodec-dev libavformat-dev libavdevice-dev libavutil-dev libswscale-dev libpostproc-dev libavfilter-dev libswresample-dev librtmidi-dev matchbox)
    isPlatform "32bit" && depends+=(libavresample-dev)
   getDepends "${depends[@]}"
}

function sources_corsixth() {
    gitPullOrClone "$md_build" https://github.com/CorsixTH/CorsixTH.git 
}

function build_corsixth() {
    mkdir build
    cd build
    cmake -DCMAKE_INSTALL_PREFIX:PATH="$md_inst" -DCMAKE_BUILD_TYPE=Release -DCMAKE_CXX_FLAGS="-Ofast -DNDEBUG" -DWITH_MIDI_DEVICE=OFF ..
    make
    md_return_require="$md_build/build/CorsixTH"
	
}

function install_corsixth() {
    cd "$md_build/build/CorsixTH"
    make install
}

function game_data_corsixth() {
    if [[ ! -f "$romdir/ports/$md_id/HOSP.exe" ]]; then
        downloadAndExtract "https://archive.org/download/HOSP_zip/HOSP.zip" "$romdir/ports/$md_id"
    fi
	chown -R $__user:$__group "$romdir/ports/$md_id"
}

function configure_corsixth() {
    mkRomDir "ports"
    mkRomDir "ports/$md_id"
    moveConfigDir "$home/.config/CorsixTH" "$md_conf_root/$md_id"
    addPort "$md_id" "corsixth" "CorsixTH - Theme Hospital Engine" "$md_inst/bin/corsix.sh"

    cat >"$md_inst/bin/corsix.sh" << _EOF_
    
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager & /opt/retropie/ports/corsixth/bin/corsix-th
_EOF_

    cat >"$md_conf_root/$md_id/config.txt" << _EOF_

theme_hospital_install = [[$romdir/ports/$md_id]]

_EOF_

     chmod +x "$md_inst/bin/corsix.sh"
	 chown $__user:$__group "$md_conf_root/$md_id/config.txt"
    [[ "$md_mode" == "install" ]] && game_data_corsixth
}
