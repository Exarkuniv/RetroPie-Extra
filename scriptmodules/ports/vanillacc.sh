#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="vanillacc"
rp_module_desc="Vanilla-Command and Conquer"
rp_module_licence="GNU https://github.com/TheAssemblyArmada/Vanilla-Conquer/blob/vanilla/License.txt"
rp_module_help="you will need to vist my github.com/Exarkuniv/Vanilla-Conquer=RPI for more info NOTE\n\ CCLOCAL.MIX needs to stay in tiberian dawn or the game will not run
\nconquer.mix 	GDI or NOD disc: CONQUER.MIX\ndesert.mix 	GDI or NOD disc: DESERT.MIX\ntemperat.mix 	GDI or NOD disc: TEMPERAT.MIX\nwinter.mix 	GDI or NOD disc: WINTER.MIX\nsounds.mix 	GDI or NOD disc: SOUNDS.MIX\ncclocal.mix 	GDI or NOD disc, within: INSTALL/SETUP.Z\ntransit.mix 	GDI or NOD disc, within: INSTALL/SETUP.Z\nspeech.mix 	GDI or NOD disc, within: INSTALL/SETUP.Z\nupdate.mix 	GDI or NOD disc, within: INSTALL/SETUP.Z\nupdatec.mix 	GDI or NOD disc, within: INSTALL/SETUP.Z\ndeseicnh.mix 	GDI or NOD disc, within: INSTALL/SETUP.Z\ntempicnh.mix 	GDI or NOD disc, within: INSTALL/SETUP.Z\nwinticnh.mix 	GDI or NOD disc, within: INSTALL/SETUP.Z\ngdi/general.mix 	GDI disc: GENERAL.MIX\ngdi/movies.mix 	GDI disc: MOVIES.MIX\ngdi/scores.mix 	GDI disc: SCORES.MIX\nnod/general.mix 	NOD disc: GENERAL.MIX\nnod/movies.mix 	NOD disc: MOVIES.MIX\nnod/scores.mix 	NOD disc: SCORES.MIX"
rp_module_repo="wget https://github.com/TheAssemblyArmada/Vanilla-Conquer/archive/refs/tags/latest.tar.gz"
rp_module_section="exp"
rp_module_flags="noinstclean"


function depends_vanillacc() {
   getDepends cmake g++ cmake libsdl2-dev libopenal-dev
}

function sources_vanillacc() {
   downloadAndExtract "$md_repo_url" "$md_build" "--strip-components=1"
}

function build_vanillacc() {
    mkdir -p build
    cd build || return 1
    CXXFLAGS=-fpermissive cmake .. 

    make -j4  || return 1
    cd .. || return 1
    md_ret_require=(
	'build/vanillara'
	'build/vanillatd'
	)
}

function install_vanillacc() {
    md_ret_files=(
	'build/vanillara'
	'build/vanillatd'
         )
}

function game_data_vanillacc() {
    if [[ ! -f "$romdir/ports/tiberian dawn/CONQUER.MIX" ]]; then
        downloadAndExtract "https://github.com/Exarkuniv/game-data/raw/main/cctd.zip" "$romdir/ports/tiberian dawn"
    fi
	if [[ ! -f "$romdir/ports/red alert/REDALER.MIX" ]]; then
        downloadAndExtract "https://github.com/Exarkuniv/game-data/raw/main/ccra.zip" "$romdir/ports/red alert"
    fi
}

function configure_vanillacc() {
    mkRomDir "ports/red alert"
    mkRomDir "ports/tiberian dawn"
    ln -sf  "$romdir/ports/red alert" "$md_inst/"
    ln -sf  "$romdir/ports/tiberian dawn" "$md_inst/"

cat >"$md_inst/vanillatd.sh" << _EOF_
#!/bin/bash
pushd "$romdir/ports/tiberian dawn"
"$md_inst/vanillatd" \$*
popd
_EOF_

cat >"$md_inst/vanillara.sh" << _EOF_
#!/bin/bash
pushd "$romdir/ports/red alert"
"$md_inst/vanillara" \$*
popd
_EOF_

    chmod +x "$md_inst/vanillatd.sh"
    chmod +x "$md_inst/vanillara.sh"
    addPort "$md_id" "vanillatd" "Vanilla-Command and Conquer" "$md_inst/vanillatd.sh"
    addPort "$md_id" "vanillara" "Vanilla-Red Alert" "$md_inst/vanillara.sh"

	 [[ "$md_mode" == "install" ]] && game_data_vanillacc
}