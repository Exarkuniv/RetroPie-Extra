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

rp_module_id="openlara"
rp_module_desc="OpenLara - Source port of Tomb Raider 1-5 (only 1 works)."
rp_module_licence="BSD 2-Clause https://github.com/XProger/OpenLara?tab=BSD-2-Clause-1-ov-file#readme"
rp_module_help="OpenLara requires the data from a full or demo version of Tomb Raider 1-5. For example, copy the full DATA and FMV folders from the PC CD-ROM. This script installs the PC demo."
rp_module_section="exp"
rp_module_flags="!all rpi5"

function depends_openlara() {
	local depends=(libsdl2-dev libsdl2-net-dev libsdl2-mixer-dev libsdl2-image-dev)

	if compareVersions "$__os_debian_ver" lt 10; then
        depends+=(libgles2-mesa-dev)
    fi
	
	getDepends "${depends[@]}"
}

function sources_openlara() {
    gitPullOrClone "$md_build" https://github.com/XProger/OpenLara.git
}

function build_openlara() {
    cd "$md_build/src/platform/sdl2"
    #./build.sh
    g++ -std=c++11 `sdl2-config --cflags` -O3 -fno-exceptions -fno-rtti -ffunction-sections -fdata-sections -Wl,--gc-sections -DNDEBUG -D__SDL2__ -D_SDL2_OPENGL main.cpp ../../libs/stb_vorbis/stb_vorbis.c ../../libs/minimp3/minimp3.cpp ../../libs/tinf/tinflate.c -I../../ -o OpenLara `sdl2-config --libs` -lGL -lm -lrt -lpthread -lasound -ludev
    md_ret_require="$md_build/src/platform/sdl2"
}

function install_openlara() {
    md_ret_files=(
        'src/platform/sdl2/OpenLara'
    )
}

function game_data_openlara() {
    mkdir "$home/.openlara"
    chown -R $user:$user "$md_conf_root/openlara"

    if [[ ! -f "$romdir/ports/tombraider/DATA/" ]]; then
        downloadAndExtract "https://github.com/Exarkuniv/game-data/raw/main/tomb.zip" "$romdir/ports/tombraider"
    #mv "$romdir/ports/tombraider/tomb/"* "$romdir/ports/tombraider"
    #rmdir "$romdir/ports/tombraider/tomb/"
    chown $__user:$__group -R "$romdir/ports/tombraider"
    fi
}

function configure_openlara() {
    addPort "openlara" "openlara" "Tomb Raider" "pushd $romdir/ports/tombraider; MESA_GL_VERSION_OVERRIDE=3.1 $md_inst/OpenLara; popd"

    mkRomDir "ports/tombraider"

    moveConfigDir "$home/.openlara" "$md_conf_root/openlara"

    [[ "$md_mode" == "install" ]] && game_data_openlara
}
function remove_openlara() {
 	rm /home/pi/.openlara
}