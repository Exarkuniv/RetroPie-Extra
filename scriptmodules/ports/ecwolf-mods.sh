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

rp_module_id="ecwolf-mod"
rp_module_desc="ECWolf - ECWolf is an advanced source port for Wolfenstein 3D, Spear of Destiny, and Super 3D Noah's Ark based off of the Wolf4SDL code base. It also supports mods from .pk3 files."
rp_module_licence="GPL2 https://bitbucket.org/ecwolf/ecwolf/raw/5065aaefe055bff5a8bb8396f7f2ca5f2e2cab27/docs/license-gpl.txt"
rp_module_help="For registered versions, replace the shareware files by adding your full Wolf3d, Spear3D 1.4 version game files to $romdir/ports/wolf3d/."
rp_module_repo="git https://github.com/ECWolfEngine/ECWolf master"
rp_module_section="exp"
rp_module_flags=""

function depends_ecwolf-mod() {
    getDepends libsdl2-dev libsdl2-mixer-dev libsdl2-net-dev zlib1g-dev libsdl1.2-dev libsdl-mixer1.2-dev libsdl-net1.2-dev
}

function sources_ecwolf-mod() {
    gitPullOrClone
}

function build_ecwolf-mod() {
    mkdir -p build
    cd build || return 1
    cmake -DCMAKE_BUILD_TYPE=Release -DGPL=ON .. || return 1
    make || return 1
    md_ret_require="$md_build/build/ecwolf"
}

function install_ecwolf-mod() {
    md_ret_files=(
       'build/ecwolf'
       'build/ecwolf.pk3'
    )
}

function game_data_ecwolf-mod() {
    if [[ -z $(ls "$romdir/ports/wolf3d") ]]; then
        cd "$__tmpdir" || return 1
        downloadAndExtract "http://maniacsvault.net/ecwolf/files/shareware/wolf3d14.zip" "$romdir/ports/wolf3d/shareware"
        downloadAndExtract "http://maniacsvault.net/ecwolf/files/shareware/soddemo.zip" "$romdir/ports/wolf3d/shareware"
    fi
}

function _add_games_ecwolf-mod(){
    local ecw_bin="$1"
    local ext path game

    declare -A games=(
        ['wl1']="Wolfenstein 3D (demo)"
        ['wl6']="Wolfenstein 3D"
        ['sod']="Wolfenstein 3D - Spear of Destiny"
        ['sd1']="Wolfenstein 3D - Spear of Destiny"
        ['sdm']="Wolfenstein 3D - Spear of Destiny (demo)"
        ['n3d']="Wolfenstein 3D - Super Noah’s Ark 3D"
        ['sd2']="Wolfenstein 3D - SoD MP2 - Return to Danger"
        ['sd3']="Wolfenstein 3D - SoD MP3 - Ultimate Challenge"
    )

    pushd "$romdir/ports/wolf3d"
    for game in "${!games[@]}"; do
        ecw=$(find . -iname "*.$game" -print -quit)
        [[ -n "$ecw" ]] || continue
        ext="${ecw##*.}"
        path="${ecw%/*}"; path="${path#*/}"

        addPort "$md_id" "ecwolf" "${games[$game]}" "pushd $romdir/ports/wolf3d; bash %ROM%; popd" "$romdir/ports/wolf3d/${games[$game]}.ecwolf"
        _add_ecwolf_files_ecwolf-mod "$romdir/ports/wolf3d/${games[$game]}.ecwolf" "$path" "$ext" "$ecw_bin"
    done
    popd
}

function _add_ecwolf_files_ecwolf-mod() {
cat >"$1" <<_EOF_
cd "$2"
"$4" --data $3 --fullscreen --res 1920 1080
wait \$!
_EOF_
}

function add_games_ecwolf-mod() {
    _add_games_ecwolf-mod "$md_inst/ecwolf"
}

function configure_ecwolf-mod() {
    mkRomDir "ports/wolf3d"

    moveConfigDir "$home/.local/share/ecwolf" "$md_conf_root/ecwolf"
    moveConfigDir "$home/.config/ecwolf" "$md_conf_root/ecwolf"

    # Check if some wolfenstein files are present and upload shareware files
    [[ "$md_mode" == "install" ]] && game_data_ecwolf-mod
    [[ "$md_mode" == "install" ]] && add_games_ecwolf-mod

    chown -R $user:$user "$romdir/ports/wolf3d"
}
