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

rp_module_id="bstone"
rp_module_desc="Blake Stone - BStone a source port of Blake Stone: Aliens of Gold and Blake Stone: Planet Strike"
rp_module_licence="GPL2 https://raw.githubusercontent.com/bibendovsky/bstone/develop/LICENSE"
rp_module_help="For Aliens of Gold registered version, replace the shareware files in $romdir/ports/bstone/aog/ to play. These files for the registered version are required: AUDIOHED.BS6, AUDIOT.BS6, EANIM.BS6, GANIM.BS6, IANIM.BS6, MAPHEAD.BS6, MAPTEMP.BS6, SANIM.BS6, VGADICT.BS6, VGAGRAPH.BS6, VGAHEAD.BS6, VSWAP.BS6."
rp_module_repo="git https://github.com/bibendovsky/bstone.git master 0f01190"
rp_module_section="exp"
rp_module_flags=""

function depends_bstone() {
    getDepends cmake libsdl2-dev libsdl2-net-dev libsdl2-mixer-dev libsdl2-image-dev timidity freepats
}

function sources_bstone() {
    gitPullOrClone
}

function build_bstone() {
    cd src || return 1
    cmake .. -DCMAKE_BUILD_TYPE=Release || return 1
    make || return 1
    md_ret_require="$md_src"
}

function install_bstone() {
    md_ret_files=(
       'src/src/bstone'
    )
}

function game_data_bstone() {
    if [[ ! -f "$romdir/ports/bstone/aog/BS_AOG.EXE" ]]; then
        downloadAndExtract "https://github.com/Exarkuniv/game-data/raw/main/bstone.zip" "$romdir/ports/bstone/aog/"
    mv "$romdir/ports/bstone/aog/bstone/"* "$romdir/ports/bstone/aog/" || return 1
    rmdir "$romdir/ports/bstone/aog/bstone/"

    fi
    chown -R $user:$user "$romdir/ports/bstone"
}

function configure_bstone() {
    addPort "$md_id" "bsaog" "Blake Stone - Aliens of Gold" "$md_inst/bstone --data_dir $romdir/ports/bstone/aog"	
	addPort "$md_id" "bsps" "Blake Stone - Planet Strike" "$md_inst/bstone --data_dir $romdir/ports/bstone/ps"

    #mkRomDir "ports/bstone"
    mkRomDir "ports/bstone/aog"
    mkRomDir "ports/bstone/ps"
    mkdir -p $home/.local/share/bibendovsky
    mkdir -p $home/.local/share/bibendovsky/bstone

    moveConfigDir "$home/.local/share/bibendovsky/bstone" "$md_conf_root/bibendovsky/bstone"

cat >"$md_conf_root/bibendovsky/bstone/bstone_config.txt" << _EOF_

vid_renderer "software"
vid_is_widescreen "1"
vid_is_windowed "0"

_EOF_

    [[ "$md_mode" == "install" ]] && game_data_bstone
}