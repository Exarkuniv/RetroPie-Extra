#!/usr/bin/env bash

# This file is part of RetroPie-Extra, a supplement to RetroPie.
# For more information, please visit:
#
# https://github.com/RetroPie/RetroPie-Setup
# https://github.com/Exarkuniv/RetroPie-Extra
#
# See the LICENSE file distributed with this source and at
# https://raw.githubusercontent.com/Exarkuniv/RetroPie-Extra/master/LICENSE
# last build that works 618c5bd 2-20-23

rp_module_id="openrct2"
rp_module_desc="OpenRCT2 - RollerCoaster Tycoon 2 port"
rp_module_licence="GNU https://github.com/OpenRCT2/OpenRCT2/blob/develop/licence.txt"
rp_module_help="Copy g1.dat, The 772 default RCT2 objects. /n/nEasy to identify by sorting on date, /n/nsince all 772 have a similar timestamp (usually from 2002 or 2003/n/n Required: If you use the OpenRCT2 title sequence, no scenarios are needed./n/n Six Flags Magic Mountain.SC6/n/n is needed for the RCT2 title sequence."
rp_module_repo="git https://github.com/OpenRCT2/OpenRCT2.git develop"
rp_module_section="exp"
rp_module_flags="noinstclean !all rpi5"


function depends_openrct2() {
    local depends=(xorg x11-xserver-utils libsdl2-dev libicu-dev gcc pkg-config libcurl4-openssl-dev libcrypto++-dev libfontconfig1-dev libfreetype6-dev libpng-dev libssl-dev libzip-dev build-essential make nlohmann-json3-dev libbenchmark-dev libvorbis-dev libflac-dev libzstd-dev)

    if isPlatform "64bit"; then
		depends+=(libduktape207)
		if [[ "$__os_debian_ver" -ge 13 ]]; then
			depends+=(libbenchmark1.9.1)
		else
			depends+=(libbenchmark1debian)
		fi
	fi
    isPlatform "32bit"&& depends+=(libduktape203 libbenchmark1)

	getDepends "${depends[@]}"
}


function sources_openrct2() {
    gitPullOrClone
}

function build_openrct2() {
    mkdir build && cd build
    cmake -DCMAKE_CXX_FLAGS="" ..
    make -j3
    DESTDIR=. make install
	mkdir "$md_build/build/usr/local/data/"
	mv "$md_build/build/usr/local/share/openrct2/"* "$md_build/build/usr/local/data/"
	mv "$md_build/build/usr/local/bin/"* "$md_build/build/usr/local/"

    md_ret_require=( 
	"$md_build/build/usr/local/openrct2"
    )
}

function game_data_openrct2() {
      if [[ ! -f "$home/.config/OpenRCT2/config.ini" ]]; then
        git clone "https://github.com/Exarkuniv/RCTconfig.git" "$home/.config/OpenRCT2"
		sed -i.bak "s|/home/pi|$home|g" "$home/.config/OpenRCT2/config.ini"
      fi
     chown -R "$__user":"$__group" "$home/.config/OpenRCT2"
     chmod +x "$home/.config/OpenRCT2/config.ini"
}

function install_openrct2() {
    md_ret_files=(
	'build/usr/local/openrct2'
	'build/usr/local/openrct2-cli'
	'build/usr/local/data'
    )
}

function configure_openrct2() {
	mv "$md_inst/bin/"* "$md_inst"
	rm "$md_inst/bin/"
	
	cat >"$md_inst/rct.sh" << _EOF_

#!/bin/bash
cd "/opt/retropie/ports/openrct2"
./openrct2 
_EOF_

    chmod +x "$md_inst/rct.sh"

    addPort "$md_id" "openrct2" "RollerCoaster Tycoon 2" "XINIT:$md_inst/rct.sh"
    mkRomDir "ports/openrct2"
    mkRomDir "ports/openrct1"

   [[ "$md_mode" == "install" ]] && game_data_openrct2
}
