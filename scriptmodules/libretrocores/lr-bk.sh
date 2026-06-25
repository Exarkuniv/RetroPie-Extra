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

rp_module_id="lr-bk"
rp_module_desc="Elektronika БК-0010/0011/Terak 8510a emulator - BK port for libretro"
rp_module_help="ROM Extension: .bin .zip .7z\n\nCopy your roms to $romdir/bk\n\nCopy the following BIOS files to $biosdir/bk:\nMONIT10.ROM (BK-0010/0010.01);\nFOCAL10.ROM (BK-0010);\nBASIC10.ROM (BK-0010.01);\nDISK_327.ROM (BK-0010.01/0011M + FDD);\nB11M_BOS.ROM, BAS11M_0.ROM, BAS11M_1.ROM and B11M_EXT.ROM (BK-0011M + FDD);\nTERAK.ROM (Terak 8510/a)."
rp_module_licence="NONCOM https://raw.githubusercontent.com/libretro/bk-emulator/master/COPYING"
rp_module_section="exp"
rp_module_repo="git https://github.com/libretro/bk-emulator.git master"
rp_module_flags=""

function sources_lr-bk() {
    gitPullOrClone
}

function build_lr-bk() {
    make -f Makefile.libretro clean || return 1
    make -f Makefile.libretro || return 1
    md_ret_require="$md_build/bk_libretro.so"
}

function install_lr-bk() {
    md_ret_files=(
	'bk_libretro.so'
	'COPYING'
    )
}

function configure_lr-bk() {
    mkRomDir "bk"
    ensureSystemretroconfig "bk"

    addEmulator 1 "$md_id" "bk" "$md_inst/bk_libretro.so"
    addSystem "bk" "BK" ".bin" ".zip" ".ZIP"

    mkdir -p "$biosdir/bk"
    chown $user:$user -R "$biosdir/bk"
}