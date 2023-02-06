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

rp_module_id="hexen2gl"
rp_module_desc="Hexen II - Hammer of Thyrion source port"
rp_module_licence="GPL2 https://raw.githubusercontent.com/svn2github/uhexen2/master/docs/COPYING"
rp_module_help="For registered version, please add your full version PAK files to $romdir/ports/hexen2/data1/ to play. These files for the registered version are required: pak0.pak, pak1.pak and strings.txt. The registered pak files must be patched to 1.11 for Hammer of Thyrion."
rp_module_repo="git https://github.com/jpernst/uhexen2-sdl2.git"
rp_module_section="exp"
rp_module_flags=""

function depends_hexen2gl() {
    getDepends cmake libsdl1.2-dev libsdl-net1.2-dev libsdl-sound1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev timidity freepats
}

function sources_hexen2gl() {
    gitPullOrClone
}

function build_hexen2gl() {
    cd "$md_build/engine/hexen2"
    ./build_all.sh
    md_ret_require="$md_build/engine/hexen2/glhexen2"
}

function install_hexen2gl() {
    md_ret_files=(
       'engine/hexen2/glhexen2'
    )
}

function game_data_hexen2gl() {
    if [[ ! -f "$romdir/ports/hexen2/data1/pak0.pak" ]]; then
        downloadAndExtract "https://netix.dl.sourceforge.net/project/uhexen2/Hexen2Demo-Nov.1997/hexen2demo_nov1997-linux-i586.tgz" "$romdir/ports/hexen2" --strip-components 1 "hexen2demo_nov1997/data1"
        chown -R $user:$user "$romdir/ports/hexen2/data1"
    fi
}

function configure_hexen2gl() {
    addPort "$md_id" "hexen2" "Hexen II" "$md_inst/glhexen2 -f -conwidth 800 "
    addPort "$md_id" "hexen2p" "Hexen II -Portals of Praevus" "$md_inst/glhexen2 -f -conwidth 800 -portals"

    mkRomDir "ports/hexen2"
    mkRomDir "ports/hexen2/portals"

    moveConfigDir "$home/.hexen2" "$md_conf_root/hexen2gl"

    [[ "$md_mode" == "install" ]] && game_data_hexen2gl
}