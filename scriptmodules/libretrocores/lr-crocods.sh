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

rp_module_id="lr-crocods"
rp_module_desc="Amstrad CPC emu - CrocoDS port for libretro"
rp_module_help="ROM Extensions: .dsk .sna .kcr\n\nCopy your Amstrad CPC games to $romdir/amstradcpc"
rp_module_licence="MIT https://raw.githubusercontent.com/libretro/libretro-crocods/master/LICENSE"
rp_module_repo="git https://github.com/libretro/libretro-crocods.git master"
rp_module_section="exp x86=opt"
rp_module_flags=""

#function depends_lr-crocods() {
#    local depends
#    isPlatform "arm" && depends+=(gcc-arm-linux-gnueabihf)
#    getDepends "${depends[@]}"
#}

function sources_lr-crocods() {
    gitPullOrClone
}

function build_lr-crocods() {
    make clean
    make || return 1
    md_ret_require="$md_build/crocods_libretro.so"
}

function install_lr-crocods() {
    md_ret_files=(
        'crocods_libretro.so'
    )
}

function configure_lr-crocods() {
    mkRomDir "amstradcpc"
    ensureSystemretroconfig "amstradcpc"

    addEmulator 1 "$md_id" "amstradcpc" "$md_inst/crocods_libretro.so"
    addSystem "amstradcpc"
}