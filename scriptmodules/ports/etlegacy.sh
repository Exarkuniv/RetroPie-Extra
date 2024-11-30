#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="etlegacy"
rp_module_desc="etlegacy - ET: Legacy - A Fully compatable Wolfenstein: Enemy Territory Client and Server"
rp_module_licence="GPL3 https://raw.githubusercontent.com/etlegacy/etlegacy/master/COPYING.txt"
rp_module_help="Fix Me!"
rp_module_section="exp"
rp_module_repo="git https://github.com/etlegacy/etlegacy.git master :_get_branch_etlegacy"
rp_module_flags="!64bit"

function _get_branch_etlegacy() {
    # Tested tag was 2.82.1 commit 0a24c70
    # manual:
    # 'curl https://api.github.com/repos/etlegacy/etlegacy/tags | grep -m 1 sha | cut -d\" -f4 | cut -dv -f2'

    download https://api.github.com/repos/etlegacy/etlegacy/tags - | grep -m 1 sha | cut -d\" -f4 | cut -dv -f2
}

function _arch_etlegacy() {
    # exact parsing from Makefile
    echo "$(uname -m | sed -e 's/i.86/x86/' | sed -e 's/^arm.*/arm/')"
}

function depends_etlegacy() {
    getDepends cmake #libsdl1-dev libopenal-dev libc6-dev-i386 libx11-dev:i386 libgl1-mesa-dev:i386
}

function sources_etlegacy() {
    gitPullOrClone
}

function build_etlegacy() {
    local params=(-DCMAKE_BUILD_TYPE=Release)

    if isPlatform "64bit"; then
        params+=(-DCROSS_COMPILE32=1)
        git submodule init
        git submodule update
    fi

    if isPlatform "rpi"; then
        params+=(-DARM=1)
    fi

    mkdir "$md_build/build"
    cd "$md_build/build"

    if isPlatform "64bit"; then
        # The added CC= and CXX= is to ensure that 64 bit libraries are not used during
        # compilation of the 32 bit version
        CC="gcc -m32" CXX="g++ -m32" cmake "${params[@]}" ..
    else
        cmake "${params[@]}" ..
    fi
    make clean
    make

    md_ret_require="$md_build/build/etl.$(_arch_etlegacy)"
}

function install_etlegacy() {
    md_ret_files=(
        "build/etl.$(_arch_etlegacy)"
        "build/etlded.$(_arch_etlegacy)"
        "build/librenderer_opengl1_$(_arch_etlegacy).so"
        "build/legacy/cgame.mp.$(_arch_etlegacy).so"
        "build/legacy/ui.mp.$(_arch_etlegacy).so"
        "build/legacy/qagame.mp.$(_arch_etlegacy).so"
    )
}

function game_data_etlegacy() {
    downloadAndExtract "https://cdn.splashdamage.com/downloads/games/wet/et260b.x86_full.zip" "$md_build"
    cd $md_build
    ./et260b.x86_keygen_V03.run --noexec --target tmp
    cd $md_build/tmp/etmain

    cp *.pk3 $romdir/ports/etlegacy
}

function configure_etlegacy() {
    addPort "$md_id" "etlegacy" "Wolfenstein - Enemy Territory" "$md_inst/etl.$(_arch_etlegacy)"

    mkRomDir "ports/etlegacy"

    moveConfigDir "$md_inst/etmain" "$romdir/ports/etlegacy"
    [[ "$md_mode" == "install" ]] && game_data_etlegacy

    mkdir $md_inst/legacy
    mv $md_inst/cgame.mp.$(_arch_etlegacy).so $md_inst/legacy/
    mv $md_inst/ui.mp.$(_arch_etlegacy).so $md_inst/legacy/
    mv $md_inst/qagame.mp.$(_arch_etlegacy).so $md_inst/legacy/
}
