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

rp_module_id="lr-yabasanshiro"
rp_module_desc="Saturn & ST-V emulator - Yabasanshiro port for libretro"
rp_module_help="ROM Extensions: .iso .cue .zip .ccd .mds\n\nCopy your Sega Saturn & ST-V roms to $romdir/saturn\n\nCopy the required BIOS file saturn_bios.bin / stvbios.zip to $biosdir/yabasanshiro"
rp_module_licence="GPL2 https://raw.githubusercontent.com/ALLRiPPED/yabause/yabasanshiro/LICENSE"
rp_module_repo="git https://github.com/ALLRiPPED/yabause.git yabasanshiro 73c67668"
rp_module_section="exp"
rp_module_flags="!all rpi4 rpi5"

function sources_lr-yabasanshiro() {
    gitPullOrClone
    isPlatform "rpi4" && applyPatch "$md_data/01_shader_hack_rpi4.diff"
}

function build_lr-yabasanshiro() {
    local params=()
    ! isPlatform "x86" && params+=(HAVE_SSE=0)
    if isPlatform "arm"; then
        params+=(USE_ARM_DRC=1 DYNAREC_DEVMIYAX=1 ARCH_IS_LINUX=1)
        isPlatform "neon" && params+=(HAVE_NEON=1)
    elif isPlatform "aarch64"; then
        params+=(USE_AARCH64_DRC=1 DYNAREC_DEVMIYAX=0)
    fi
    isPlatform "gles" && params+=(FORCE_GLES=1)

    cd yabause/src/libretro || return 1
    make clean
    make "${params[@]}" || return 1
    md_ret_require="$md_build/yabause/src/libretro/yabasanshiro_libretro.so"
}

function install_lr-yabasanshiro() {
    md_ret_files=(
        'yabause/src/libretro/yabasanshiro_libretro.so'
        'LICENSE'
        'README.md'
    )
}

function configure_lr-yabasanshiro() {
    mkRomDir "saturn"
    ensureSystemretroconfig "saturn"

    addEmulator 1 "$md_id" "saturn" "$md_inst/yabasanshiro_libretro.so"
    addSystem "saturn"
}