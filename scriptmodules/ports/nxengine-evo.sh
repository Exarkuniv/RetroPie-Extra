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

rp_module_id="nxengine-evo"
rp_module_desc="Cave Story engine clone - NXEngine-Evo"
rp_module_help="Keyboard required for initial setup, gamepad controls can be configured in game options menu.\n\nSet runcommand video mode to match in-game resolution - recommended 640x480."
rp_module_licence="GPL3 http://nxengine.sourceforge.net/LICENSE"
rp_module_repo="git https://github.com/nxengine/nxengine-evo.git master"
rp_module_section="exp"
rp_module_flags="!armv6 !mali"

function depends_nxengine-evo() {
    getDepends libpng-dev libjpeg-dev cmake libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev
}

function sources_nxengine-evo() {
    gitPullOrClone
}

function build_nxengine-evo() {
    mkdir -p build
    cd build || return 1
    CFLAGS='-DDATADIR="\"'"$romdir"'/ports/CaveStory/'"$md_id"'/data/\""' CXXFLAGS='-DDATADIR="\"'"$romdir"'/ports/CaveStory/'"$md_id"'/data/\""' cmake -DCMAKE_BUILD_TYPE=Release -DPORTABLE=On ..
    make || return 1
    md_ret_require=(
        "$md_build/build/nxengine-evo"
        "$md_build/build/nxextract"
    )
}

function install_nxengine-evo() {
    md_ret_files=(
        'build/nxengine-evo'
        'build/nxextract'
        'data'
    )
}

function gamedata_nxengine-evo() {
    if [[ ! -f "$romdir/ports/CaveStory/$md_id/Doukutsu.exe" ]]; then
        downloadAndExtract "https://cavestory.org/downloads/cavestoryen.zip" "$romdir/ports/CaveStory/$md_id"
        mv "$romdir/ports/CaveStory/$md_id/CaveStory/"* "$romdir/ports/CaveStory/$md_id" || return 1
        rmdir "$romdir/ports/CaveStory/$md_id/CaveStory"
    fi
    [[ ! -d "$romdir/ports/CaveStory/$md_id/data/lang" ]] && downloadAndExtract "https://github.com/nxengine/translations/releases/download/v1.14/all.zip" "$romdir/ports/CaveStory/$md_id"
    [[ ! -d "$romdir/ports/CaveStory/$md_id/data/mods" ]] && downloadAndExtract "https://github.com/nxengine/nxengine-evo/releases/download/v2.6.5/boss_rush.zip" "$romdir/ports/CaveStory/$md_id"
    cp -r "$md_inst/data" "$romdir/ports/CaveStory/$md_id"
    pushd "$romdir/ports/CaveStory/$md_id"; "$md_inst/nxextract"; popd
    chown -R $user:$user "$romdir/ports/CaveStory/$md_id"
}

function configure_nxengine-evo() {
    [[ "$md_mode" == "install" ]] && gamedata_nxengine-evo
    addPort "$md_id" "cavestory" "Cave Story" "$md_inst/nxengine-evo"
    mkRomDir "ports/CaveStory"
    moveConfigDir "$home/.local/share/nxengine" "$md_conf_root/cavestory/$md_id"
}