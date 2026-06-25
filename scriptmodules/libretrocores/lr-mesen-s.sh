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

rp_module_id="lr-mesen-s"
rp_module_desc="Super Nintendo emu - Mesen-S port for libretro"
rp_module_help="ROM Extension: .sfc .smc .fig .swc .zip .7z\n\nCopy your SNES roms to $romdir/snes"
rp_module_licence="GPL3 https://raw.githubusercontent.com/SourMesen/Mesen-S/master/LICENSE"
rp_module_repo="git https://github.com/SourMesen/Mesen-S.git master"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-mesen-s() {
    gitPullOrClone
}

function build_lr-mesen-s() {
    cd Libretro || return 1
    make clean
    make || return 1
    md_ret_require="$md_build/Libretro/mesen-s_libretro.so"
}

function install_lr-mesen-s() {
    md_ret_files=(
        'Libretro/mesen-s_libretro.so'
    )
}

function configure_lr-mesen-s() {
    mkRomDir "snes"
    ensureSystemretroconfig "snes"

    addEmulator 1 "$md_id" "snes" "$md_inst/mesen-s_libretro.so"
    addSystem "snes"
}