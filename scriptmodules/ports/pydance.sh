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

rp_module_id="pydance"
rp_module_desc="pydance - Open Source Dancing Game"
rp_module_licence="MIT https://raw.githubusercontent.com/asb/pydance/master/LICENSE"
rp_module_help="Be sure to add your songs to $configdir/ports/pydance/songs. For more information about adding songs from other games to pydance, please take a look at the pydance homepage: https://icculus.org/pyddr/"
rp_module_repo="git https://github.com/mbenkmann/pydance.git master"
rp_module_section="exp"
rp_module_flags="!mali !all rpi4 rpi3"

function depends_pydance() {
    getDepends python python-pygame libsdl-mixer1.2-dev libsdl-mixer1.2 libvorbis-dev libsmpeg-dev xorg
}

function sources_pydance() {
	gitPullOrClone
}

function build_pydance() {
    python setup.py
}

function install_pydance() {
    su -c 'make PREFIX="/opt/retropie/ports/pydance" install'
}

function configure_pydance() {
    local script="$md_inst/$md_id.sh"
    moveConfigDir "$home/.pydance" "$md_conf_root/$md_id"
    mkdir -p "$md_conf_root/$md_id/cdtitles"
    mkdir -p "$md_conf_root/$md_id/songs"
    mkdir -p "$md_conf_root/$md_id/themes"
    mkdir -p "$md_conf_root/$md_id/themes/dj"
    cd "$md_conf_root/$md_id/themes/dj" || return 1
    if [ ! -f "$md_conf_root/$md_id/themes/dj/mrt/its_good.ogg" ]; then
        wget https://icculus.org/pyddr/mrt.tar.gz || return 1
        tar zxvf ./mrt.tar.gz || return 1
        rm ./mrt.tar.gz
    fi
    cd "$md_conf_root/$md_id/songs" || return 1
    if [ ! -f "$md_conf_root/$md_id/songs/forkbomb.ogg" ]; then
        wget https://icculus.org/pyddr/forkbomb.ogg || return 1
    fi
    if [ ! -f "$md_conf_root/$md_id/songs/forkbomb.dance" ]; then
        wget https://icculus.org/pyddr/forkbomb.dance || return 1
    fi
    if [ ! -f "$md_conf_root/$md_id/songs/forkbomb-bg.jpg" ]; then
        wget https://icculus.org/pyddr/forkbomb-bg.jpg || return 1
    fi
    if [ ! -f "$md_conf_root/$md_id/songs/forkbomb-banner.png" ]; then
        wget https://icculus.org/pyddr/forkbomb-banner.png || return 1
    fi
    if [ ! -f "$md_conf_root/$md_id/songs/6jan.ogg" ]; then
        wget https://icculus.org/pyddr/6jan.ogg || return 1
    fi
    if [ ! -f "$md_conf_root/$md_id/songs/6jan.dance" ]; then
        wget https://icculus.org/pyddr/6jan.dance || return 1
    fi
    if [ ! -f "$md_conf_root/$md_id/songs/6jan-bg.jpg" ]; then
        wget https://icculus.org/pyddr/6jan-bg.jpg || return 1
    fi
    if [ ! -f "$md_conf_root/$md_id/songs/6jan-banner.png" ]; then
        wget https://icculus.org/pyddr/6jan-banner.png || return 1
    fi
    if [ ! -f "$md_conf_root/$md_id/songs/synrg.ogg" ]; then
        wget https://icculus.org/pyddr/synrg.ogg || return 1
    fi
    if [ ! -f "$md_conf_root/$md_id/songs/synrg.dance" ]; then
        wget https://icculus.org/pyddr/synrg.dance || return 1
    fi
    if [ ! -f "$md_conf_root/$md_id/songs/synrg-bg.png" ]; then
        wget https://icculus.org/pyddr/synrg-bg.png || return 1
    fi
    cd "$md_conf_root/$md_id/cdtitles" || return 1
    if [ ! -f "$md_conf_root/$md_id/cdtitles/pydance.png" ]; then
        wget https://icculus.org/pyddr/pydance-cdtitle.png || return 1
        mv pydance-cdtitle.png pydance.png || return 1
    fi
    chown -R $user:$user /opt/retropie/ports/pydance
	#create buffer script for launch
 cat > "$script" << _EOF_
#!/bin/bash
"/opt/retropie/ports/pydance/games/pydance"
_EOF_
    
	chmod +x "$script"
    addPort "$md_id" "pydance" "pydance - Open Source Dancing Game" "XINIT:$script"
}