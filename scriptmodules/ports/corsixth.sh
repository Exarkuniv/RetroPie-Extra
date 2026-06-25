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
rp_module_help="Mouse or mouse emulation through xboxdrv is required. You need to copy your Theme Hospital game data into $romdir/ports/$md_id/ and when starting up the game for the first time, select the directory. The colors and fonts could have bad colors here making it difficult."
rp_module_section="exp"
rp_module_flags="!x86 !mali"

function depends_corsixth() {
    local depends=(cmake liblua5.2-0 liblua5.2-dev libsdl2-dev libsdl2-mixer-dev timidity libfreetype6-dev lua-filesystem lua-lpeg libavcodec-dev libavformat-dev libavdevice-dev libavutil-dev libswscale-dev libpostproc-dev libavfilter-dev matchbox freepats)
    isPlatform "32bit" && depends+=(libavresample-dev)
   getDepends "${depends[@]}"
}

function sources_corsixth() {
    gitPullOrClone "$md_build" https://github.com/CorsixTH/CorsixTH.git 
}

function build_corsixth() {
    cmake . -DWITH_LIBAV=ON -DCMAKE_INSTALL_PREFIX:PATH="$md_inst" || return 1
    cd ./CorsixTH || return 1
    make || return 1
    md_return_require="$md_build/CorsixTH/CorsixTH"
    cd "$md_build" || return 1
}

function install_corsixth() {
    make install || return 1
}

function game_data_corsixth() {
    mkRomDir "ports"
    mkRomDir "ports/$md_id"
    if [[ ! -f "$romdir/ports/$md_id/HOSP.exe" ]]; then
        downloadAndExtract "https://archive.org/download/HOSP_zip/HOSP.zip" "$romdir/ports/$md_id"
    fi
}

function configure_corsixth() {
    mkRomDir "ports"
    mkRomDir "ports/$md_id"
    #mkdir "$home/.config/CorsixTH"
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
    [[ "$md_mode" == "install" ]] && game_data_corsixth
}