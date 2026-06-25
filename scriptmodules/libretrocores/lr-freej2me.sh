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

rp_module_id="lr-freej2me"
rp_module_desc="Java ME emulator - FreeJ2ME port for libretro."
rp_module_help="ROM Extensions: .jar .zip .7z\n\nCopy your Java ME (J2ME) roms to $romdir/j2me\n\nThe BIOS files freej2me-sdl.jar, freej2me.jar and freej2me-lr.jar will automatically installed in $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/hex007/freej2me/master/LICENSE"
rp_module_repo="git https://github.com/hex007/freej2me.git master"
rp_module_section="exp"
rp_module_flags=""

function depends_lr-freej2me() {
    getDepends ant
    sudo update-alternatives --config java
}

function sources_lr-freej2me() {
    gitPullOrClone
}

function build_lr-freej2me() {
    ant
    cd "src/libretro" || return 1
    make clean
    make || return 1
    md_ret_require="$md_build/src/libretro/freej2me_libretro.so"
}

function install_lr-freej2me() {
    md_ret_files=(
        'build/freej2me.jar'
        'build/freej2me-lr.jar'
        'build/freej2me-sdl.jar'
        'src/libretro/retropie.txt'
        'src/libretro/freej2me_libretro.so'
    )
}

function configure_lr-freej2me() {
    mkRomDir "j2me"
    ensureSystemretroconfig "j2me"

    addEmulator 1 "$md_id" "j2me" "$md_inst/freej2me_libretro.so"
    addSystem "j2me" "J2ME" ".jar .JAR"

    cp -Rv "$md_inst/freej2me-lr.jar" "$md_inst/freej2me-sdl.jar" "$md_inst/freej2me.jar" "$biosdir"
    chown $user:$user -R "$biosdir/freej2me.jar" "$biosdir/freej2me-sdl.jar" "$biosdir/freej2me-lr.jar"
}