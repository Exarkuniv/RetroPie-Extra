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

rp_module_id="lr-melondsds"
rp_module_desc="NDS emu - MelonDS port for libretro with Mic Support & Rotation"
rp_module_help="ROM Extensions: .nds .zip .7z\n\nCopy your Nintendo DS roms to $romdir/nds\n\nCopy firmware.bin, bios7.bin and bios9.bin to $biosdir"
rp_module_licence="GPL3 https://raw.githubusercontent.com/libretro/melonDS/master/LICENSE"
rp_module_repo="git https://github.com/JesseTG/melonds-ds.git main"
rp_module_section="exp"
rp_module_flags="!all !rpi4 rpi5"

function sources_lr-melondsds() {
    gitPullOrClone
}

function build_lr-melondsds() {
    rm -fr build && mkdir build
    cd build || return 1
    cmake .. || return 1
    make || return 1
    md_ret_require="$md_build/build/src/libretro/melondsds_libretro.so"
}

function install_lr-melondsds() {
    md_ret_files=(
        'build/src/libretro/melondsds_libretro.so'
    )
}

function configure_lr-melondsds() {
    mkRomDir "nds"
    ensureSystemretroconfig "nds"

    local launch_prefix="XINIT-WM:"

    addEmulator 0 "$md_id" "nds" "$launch_prefix$emudir/retroarch/bin/retroarch -L $md_inst/melondsds_libretro.so --config $md_conf_root/nds/retroarch.cfg %ROM%"

    addSystem "nds"
}
