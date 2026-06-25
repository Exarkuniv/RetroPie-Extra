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

rp_module_id="abuse"
rp_module_desc="Abuse"
rp_module_licence="GPL https://raw.githubusercontent.com/Xenoveritas/abuse/master/COPYING"
rp_module_section="exp"
rp_module_flags=""

function depends_abuse() {
    local depends=(cmake)

	    isPlatform "64bit" && depends+=(libsdl2-dev libsdl2-mixer-dev)
        isPlatform "32bit" && depends+=(libsdl1.2-dev libsdl-mixer1.2-dev xorg)

	getDepends "${depends[@]}"
}

function sources_abuse() {
    if isPlatform "64bit"; then
        gitPullOrClone "$md_build" https://github.com/Exarkuniv/abuse-Rpi.git
    else
        downloadAndExtract "http://abuse.zoy.org/raw-attachment/wiki/download/abuse-0.8.tar.gz" "$md_build"
	fi
}

function build_abuse() {
if isPlatform "64bit"; then
        mkdir -p build
        cd build || return 1
        cmake -DCMAKE_INSTALL_PREFIX="$md_inst" .. || return 1
        make || return 1
		md_ret_require=()
    else
        cd abuse-0.8 || return 1
	    ./configure --enable-debug   
	    make || return 1
		md_ret_require=()
	fi
}

function install_abuse() {
    if isPlatform "64bit"; then
        cd build || return 1
        make install || return 1
    else
        cd abuse-0.8 || return 1
	    make install || return 1
	fi

    md_ret_files=(
    )
}

function configure_abuse() {
    if isPlatform "64bit"; then
        addPort "$md_id" "abuse" "Abuse" "$md_inst/bin/abuse -datadir /opt/retropie/ports/abuse/share/games/abuse"

    else
        addPort "$md_id" "abuse" "Abuse" "XINIT: /usr/local/bin/abuse -fullscreen"

	fi
}