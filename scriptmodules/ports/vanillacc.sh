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
    getDepends cmake libsdl2-dev libopenal-dev
}

function sources_vanillacc() {
    gitPullOrClone
}

function build_vanillacc() {
    mkdir build
    cd build
    CXXFLAGS=-fpermissive cmake ..
    make
    md_ret_require=(
        "$md_build/build/vanillara"
        "$md_build/build/vanillatd"
    )
}

function install_vanillacc() {
    mkdir -p "$md_inst/redalert" "$md_inst/tiberiandawn"
    cp -vf "$md_build/build/vanillara" "$md_inst/redalert"
    cp -vf "$md_build/build/vanillatd" "$md_inst/tiberiandawn"
}

function game_data_vanillacc() {
    if [[ ! -f "$romdir/ports/tiberiandawn/CONQUER.MIX" && ! -f "$romdir/ports/tiberiandawn/DEMO.MIX" ]]; then
        downloadAndExtract "https://raw.githubusercontent.com/Exarkuniv/game-data/main/cctd.zip" "$romdir/ports/tiberiandawn"
        chown -R $user:$user "$romdir/ports/tiberiandawn"
    fi
    if [[ ! -f "$romdir/ports/redalert/REDALERT.MIX" ]]; then
        downloadAndExtract "https://raw.githubusercontent.com/Exarkuniv/game-data/main/ccra.zip" "$romdir/ports/redalert"
        chown -R $user:$user "$romdir/ports/redalert"
    fi
}

function configure_vanillacc() {
    local script="$md_inst/vanillacc.sh"

    addPort "$md_id" "vanillacc" "Command and Conquer - Red Alert" "$script %ROM%" "ra"
    addPort "$md_id" "vanillacc" "Command and Conquer - Tiberian Dawn" "$script %ROM%" "td"
    moveConfigDir "$home/.config/vanilla-conquer" "$md_conf_root/vanillacc"

    [[ "$md_mode" == "remove" ]] && return

    mkRomDir "ports/redalert"
    mkRomDir "ports/tiberiandawn"

    cat > "$script" << _EOF_
#!/bin/bash
mode="\$1"
shift

case "\$mode" in
    ra) launcher="$md_inst/redalert/vanillara" ;;
    td) launcher="$md_inst/tiberiandawn/vanillatd" ;;
esac

if [[ -n "\$launcher" ]]; then
    pushd "\$(dirname "\$launcher")"
    "\$launcher" "\$@"
    popd
fi
_EOF_
    chmod +x "$script"

    game_data_vanillacc

    ## Link game files to bin dir

    local ra_files=(
        allied
        soviet
        REDALERT.MIX
    )

    # RA demo
    ra_files+=(
        MAIN.MIX
    )

    local td_files=(
        gdi
        nod
        CONQUER.MIX
        DESERT.MIX
        TEMPERAT.MIX
        WINTER.MIX
        CCLOCAL.MIX
        TRANSIT.MIX
        SPEECH.MIX
        UPDATE.MIX
        UPDATEC.MIX
        DESEICNH.MIX
        TEMPICNH.MIX
        WINTICNH.MIX
    )

    # TD demo
    td_files+=(
        DEMO.MIX
        DEMOL.MIX
        DEMOM.MIX
        SOUNDS.MIX
    )

    local file
    for file in "${ra_files[@]}"; do
        ln -snf "$romdir/ports/redalert/$file" "$md_inst/redalert/$file"
    done

    for file in "${td_files[@]}"; do
        ln -snf "$romdir/ports/tiberiandawn/$file" "$md_inst/tiberiandawn/$file"
    done
}
