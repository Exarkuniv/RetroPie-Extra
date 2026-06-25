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

rp_module_id="lr-minivmac"
rp_module_desc="Macintosh Plus Emulator - Mini vMac port for libretro"
rp_module_help="ROM Extensions: .dsk .zip\n\nCopy your Macintosh Plus games to $romdir/macintosh\n\nCopy the Macintosh bios file MacII.ROM into $biosdir"
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/libretro-minivmac/master/minivmac/COPYING.txt"
rp_module_repo="git https://github.com/libretro/libretro-minivmac.git master"
rp_module_section="exp"
rp_module_flags=""

function sources_lr-minivmac() {
    gitPullOrClone
}

function build_lr-minivmac() {
    make clean
    make || return 1
    md_ret_require="$md_build/minivmac_libretro.so"
}

function install_lr-minivmac() {
    md_ret_files=(
	'README'
	'minivmac/COPYING.txt'
        'minivmac_libretro.so'
    )
}

function configure_lr-minivmac() {
    mkRomDir "macintosh"
    ensureSystemretroconfig "macintosh"

    addEmulator 1 "$md_id" "macintosh" "$md_inst/minivmac_libretro.so"
    addSystem "macintosh"
}