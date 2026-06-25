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
rp_module_repo="git https://github.com/OpenDUNE/OpenDUNE.git master"
rp_module_section="exp"
rp_module_flags="noinstclean !all rpi4"


function depends_opendune() {
   getDepends libsdl2-image-dev libsdl2-dev  libsdl-image1.2-dev libsdl1.2-dev dos2unix zip timidity timidity-daemon xorg matchbox-window-manager x11-xserver-utils
}


function sources_opendune() {
    gitPullOrClone
}

function build_opendune() {
    ./configure --with-asound --without-oss --without-pulse --with-sdl2 --without-munt
    make || return 1

    md_ret_require=(
      )
}

function install_opendune() {
    md_ret_files=(bin/opendune
		bin/opendune.ini.sample
    )
}

function game_data_opendune() {

    if [[ ! -f "$romdir/ports/dune2/DUNE2.EXE" ]]; then
        downloadAndExtract "https://github.com/Exarkuniv/game-data/raw/main/dune-II.zip" "$romdir/ports/dune2/data"
    chown -R $user:$user "$romdir/ports/dune2/data"
    fi
    #changing the config to work with RetroPie
    sed -i -e "/;datadir=$usr$local$opendune/c\\datadir=$romdir/ports/dune2/data" -e "/;fullscreen=1/c\\fullscreen=1" -e "/;language=french/c\\language=english" -e "10d" -e "/save/a savedir=$md_conf_root/opendune" $home/.config/opendune/opendune.ini
}

function configure_opendune() {
    mkRomDir "ports/dune2"
    moveConfigDir "$home/.config/opendune" "$md_conf_root/opendune"
    cp $md_inst/opendune.ini.sample "$md_conf_root/opendune/opendune.ini"
    addPort "$md_id" "opendune" "OpenDune - Dune 2 port" "XINIT: $md_inst/opendune"

    [[ "$md_mode" == "install" ]] && game_data_opendune
}