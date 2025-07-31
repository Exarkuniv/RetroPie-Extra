#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="dosbox-x"
rp_module_desc="Testing of a new DOSbox system"
rp_module_help="ROM Extensions: .bat .com .exe .sh .conf\n\nCopy your DOS games to ports/dosbox"
rp_module_licence="GNU https://raw.githubusercontent.com/joncampbell123/dosbox-x/master/COPYING"
rp_module_repo="git https://github.com/joncampbell123/dosbox-x.git master"
rp_module_section="exp"
rp_module_flags=""

function depends_dosbox-x() {
    local depends=(
        automake whiptail kdialog libncurses-dev nasm libsdl-net1.2-dev
        libpcap-dev libfluidsynth-dev ffmpeg libavformat-dev 
        libswscale-dev libavcodec-dev xorg matchbox)
    isPlatform "64bit" && depends+=(libavdevice59)
    isPlatform "32bit" && depends+=(libavdevice58)
    getDepends "${depends[@]}"

}

function sources_dosbox-x() {
    gitPullOrClone
}

function build_dosbox-x() {
    ./build-debug --prefix="$md_inst"
}

function install_dosbox-x() {
    make install
}

function configure_dosbox-x() {
    mkRomDir "ports/dosbox"
    local script="$md_inst/$md_id.sh"


    cat > "$script" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
$md_inst/bin/dosbox-x
_EOF_

    chmod +x "$script"
    addPort "$md_id" "dosboxx" "DOSbox-X" "XINIT:$script"
}