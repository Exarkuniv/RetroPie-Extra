#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-vircon32"
rp_module_desc="Vircon32 game console - port of vircon32 for libretro"
rp_module_help="ROM Extensions: .v32 .zip\n\nCopy your roms to $romdir/vircon32\n\nCopy the bios to $biosdir"
rp_module_licence="3-Clause BSD https://raw.githubusercontent.com/vircon32/vircon32-libretro/main/LICENSE.md"
rp_module_repo="git https://github.com/vircon32/vircon32-libretro.git main"
rp_module_section="exp"
rp_module_flags="!all rpi3 rpi4 rpi5 x86"

function sources_lr-vircon32() {
    gitPullOrClone
    local cmake_ver
    cmake_ver=$(cmake --version | head -n 1 | cut -f 3 -d ' ')
    if dpkg --compare-versions "${cmake_ver}" lt 3.17 ; then
        # for OS with cmake less than 3.17 (missing: foreach(<loop_var>... IN ZIP_LISTS <lists>))
        applyPatch "$md_data/cmake_pre3.17.patch"
    fi
}

function build_lr-vircon32() {
    local defines=()
    isPlatform "gles" && defines+=("-DENABLE_OPENGLES2=1")
    cmake "${defines[@]}" . || return 1
    make -j$(nproc) || return 1
    md_ret_require="$md_build/vircon32_libretro.so"
}

function install_lr-vircon32() {
    md_ret_files=(
        'vircon32_libretro.so'
        'README.md'
        'LICENSE.md'
    )
}

function configure_lr-vircon32() {
    mkRomDir "vircon32"

    addEmulator 1 "$md_id" "vircon32" "$md_inst/vircon32_libretro.so"
    addSystem "vircon32" "Vircon32 game console" ".v32 .zip .V32 .ZIP"

    [[ "$md_mode" == "remove" ]] && return
}
