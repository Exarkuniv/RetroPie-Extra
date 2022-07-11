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

rp_module_id="opendune"
rp_module_desc="OpenDune - Dune 2 port using the OpenRA engine"
rp_module_help="Please put your data files in the roms/ports/opendune/data folder"
rp_module_licence="GNU https://github.com/OpenDUNE/OpenDUNE/blob/master/COPYING"
rp_module_repo="git https://github.com/OpenDUNE/OpenDUNE.git"
rp_module_section="exp"
rp_module_flags="noinstclean"


function depends_opendune() {
   getDepends libsdl2-image-dev libsdl2-dev  libsdl-image1.2-dev libsdl1.2-dev dos2unix zip timidity timidity-daemon xorg matchbox-window-manager x11-xserver-utils 
}


function sources_opendune() {
    gitPullOrClone
}

function build_opendune() {
    ./configure --with-asound --without-oss --without-pulse --with-sdl2 --without-munt
    make

    md_ret_require=(
      )
}

function install_opendune() {
    md_ret_files=(bin/opendune
		bin/opendune.ini.sample
    )
}

function game_data_opendune() {
    if [[ ! -f "$romdir/ports/opendune/DUNE2.EXE" ]]; then
        downloadAndExtract "https://github.com/Exarkuniv/game-data/raw/main/Dune-II-The-Building-of-a-Dynasty_DOS_EN.zip" "$romdir/ports/opendune"
    mv "$romdir/ports/opendune/dune-ii-the-building-of-a-dynasty/"* "$romdir/ports/opendune/"
    rmdir "$romdir/ports/opendune/dune-ii-the-building-of-a-dynasty/"
    chown -R $user:$user "$romdir/ports/opendune"
    fi

    cp $md_inst/opendune.ini.sample "/home/pi/.config/opendune/opendune.ini"
    sed -i "/.*;datadir=$usr$local$opendune.*/c\\datadir=/home/pi/RetroPie/roms/ports/opendune" /home/pi/.config/opendune/opendune.ini
    sed -i "/.*;fullscreen=1.*/c\\fullscreen=1" /home/pi/.config/opendune/opendune.ini
    sed -i "/.*;language=french.*/c\\language=english" /home/pi/.config/opendune/opendune.ini
}

function configure_opendune() {
    mkRomDir "ports/opendune"
    addPort "$md_id" "opendune" "OpenDune - Dune 2 port" "XINIT: $md_inst/opendune"

    [[ "$md_mode" == "install" ]] && game_data_opendune
}
