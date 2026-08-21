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

rp_module_id="devilutionx"
rp_module_desc="devilutionx - Diablo Engine"
rp_module_licence="https://raw.githubusercontent.com/diasurgical/devilutionX/master/LICENSE"
rp_module_help="Copy your original diabdat.mpq file from Diablo to $romdir/ports/devilutionx."
rp_module_repo="git  https://github.com/diasurgical/devilutionX.git :_get_version_devilutionx"
rp_module_section="exp"
rp_module_flags="!x86 !mali"

function _get_version_devilutionx() {
    # default DevilutionX version
	local devilutionx_version=$(curl https://api.github.com/repos/diasurgical/devilutionX/releases/latest 2>&1 | grep -m 1 tag_name | cut -d\" -f4 | cut -dv -f2)

    # 32 bit
    isPlatform "32bit" && devilutionx_version="1.5.1"
    echo -ne $devilutionx_version
}

function depends_devilutionx() {
   getDepends cmake g++ libsdl2-dev libsodium-dev libpng-dev libbz2-dev libgtest-dev libgmock-dev libsdl2-image-dev libfmt-dev smpq

}

function sources_devilutionx() {
     gitPullOrClone 
}

function build_devilutionx() {
    cd tools
    ./build_and_install_smpq.sh
    cd ..

    cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF 
    cmake --build build
    md_ret_require="$md_build/build/devilutionx"
}

function install_devilutionx() {
    md_ret_files=(
        'build/devilutionx'
	'build/devilutionx.mpq'
	'README.md'
	'LICENSE.md'
    )
}

function game_data_diablo() {
    if [[ ! -f "$romdir/ports/devilutionx/diablo.exe" ]]; then
        downloadAndExtract "https://github.com/Exarkuniv/game-data/raw/main/diablo.zip" "$romdir/ports/devilutionx"
    mv "$romdir/ports/devilutionx/diablo"* "$romdir/ports/devilutionx/"
    chown -R $__user:$__group "$romdir/ports/devilutionx"
    fi
}

function configure_devilutionx() {
        addPort "$md_id" "devilutionx" "devilutionx - Diablo Engine" "$md_inst/devilutionx --data-dir $romdir/ports/devilutionx --save-dir $md_conf_root/devilutionx"
    mkRomDir "ports"
    mkRomDir "ports/devilutionx"
    cp -r "$md_inst/devilutionx.mpq" "$romdir/ports/$md_id"
	
    [[ "$md_mode" == "install" ]] && game_data_diablo
}
