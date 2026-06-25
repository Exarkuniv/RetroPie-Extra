#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-arduous_lcd"
rp_module_desc="ArduBoy emulator with LCD shader - arduous port for libretro"
rp_module_help="ROM Extensions: .hex .zip\n\nCopy your ArduBoy roms to $romdir/arduboy\n\nThis version uses the gb-pocket-shader from the master branch of the common-shader repository.\nThese shaders are cloned into :\n/opt/retropie/configs/all/retroarch/shaders-extra/.\nThe specific shader is added to load from :\n/opt/retropie/configs/arduboy/retroarch.cfg.\nBe aware that when installing another lr-arduous port the shader setting will probably be removed in :\n/opt/retropie/configs/arduboy/retroarch.cfg."
rp_module_licence="GPL2 https://raw.githubusercontent.com/libretro/arduous/master/license.txt"
rp_module_repo="git https://github.com/libretro/arduous main"
rp_module_section="exp"

function depends_lr-arduous_lcd() {
    local dir="$configdir/all/retroarch/shaders-extra"
    local branch=""
    branch="master"
    # remove if not git repository for fresh checkout
    [[ ! -d "$dir/.git" ]] && rm -rf "$dir"
    gitPullOrClone "$dir" https://github.com/RetroPie/common-shaders.git "$branch"
    chown -R $user:$user "$dir"
}

function sources_lr-arduous_lcd() {
    gitPullOrClone
}

function build_lr-arduous_lcd() {
    cd build || return 1
    cmake .. || return 1
    make clean
    make || return 1
    md_ret_require="$md_build/build/arduous_libretro.so"
}

function install_lr-arduous_lcd() {
    md_ret_files=(
        'build/arduous_libretro.so'
    )
}

function configure_lr-arduous_lcd() {
    mkRomDir "arduboy"

    ensureSystemretroconfig "arduboy"
    
    # add the per system default settings
    iniConfig " = " '"' "$configdir/arduboy/retroarch.cfg"
    iniSet "video_shader" "$configdir/all/retroarch/shaders-extra/handheld/gameboy/gb-pocket-shader.glslp"

    addEmulator 1 "$md_id" "arduboy" "$md_inst/arduous_libretro.so"

    addSystem "arduboy" "ArduBoy" ".hex .7z .zip"
}