#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="rbdoom3_bfg"
rp_module_desc="rbdoom3_bfg - Doom 3: BFG Edition"
rp_module_licence="GPL3 https://raw.githubusercontent.com/RobertBeckebans/RBDOOM-3-BFG/master/LICENSE.md"
rp_module_help="For the game data, from your windows install (Gog or Steam) locate the 'base' directory.  Copy ALL contents to $romdir/ports/doom3_bfg"
rp_module_section="exp"
rp_module_repo="git https://github.com/RobertBeckebans/RBDOOM-3-BFG.git :_get_branch_rbdoom3_bfg"
rp_module_flags=""

function _get_branch_rbdoom3_bfg() {
    # NOTE v1.4.0 may be the last version available to build on a rpi.  Newer versions have added a
    # Microsoft DirectX dependency https://github.com/microsoft/DirectXShaderCompiler which only
    # supports nvidia, amd, and intel GPUs (Not available for rpi)
    local version="v1.4.0"

    if compareVersions "$__os_debian_ver" eq 10; then
        version="1.3.0"
        # elif compareVersions "$__os_debian_ver" gt 10; then
        #   if isPlatform "x86_64"; then
        #     local release_url
        #     release_url="https://api.github.com/repos/RobertBeckebans/RBDOOM-3-BFG/releases/latest"
        #     version=$(curl $release_url 2>&1 | grep -m 1 tag_name | cut -d\" -f4 | cut -dv -f2)
        #   fi
    fi

    echo -ne "$version"
}

function _arch_rbdoom3_bfg() {
    return "$(uname -m | sed -e 's/i.86/x86/' | sed -e 's/^arm.*/arm/')"
}

function depends_rbdoom3_bfg() {
    local depends=(cmake libavcodec-dev libavformat-dev libavutil-dev libsdl2-dev libopenal-dev)
    depends+=(libswscale-dev libglew-dev zlib1g-dev libpng-dev rapidjson-dev libjpeg-dev)

    if compareVersions "$__os_debian_ver" gt 10; then
        depends+=(libimgui-dev)
    fi

    if isPlatform "rpi"; then
        depnds+=(xorg)
    fi

    getDepends "${depends[@]}"
}

function sources_rbdoom3_bfg() {
    gitPullOrClone
}

function build_rbdoom3_bfg() {
    local params=()
    local rbdoom3_version

    rbdoom3_version=$(_get_branch_rbdoom3_bfg)

    if isPlatform "rpi"; then
        # DCPU_TYPE is the only value to change: armhf for 32bit and aarch64 for 64bit  Is there a
        # variable that responds with those two values and only those values?  Might be a way to
        # simplify this.
        # NOTE: I am guessing on DCPU_TYPE for 64bit
        params+=(-G 'Unix Makefiles' -DUSE_PRECOMPILED_HEADERS=OFF)
        params+=(-DCPU_OPTIMIZATION='' -DUSE_INTRINSICS_SSE=OFF)

        if isPlatform "64bit"; then
            params+=(-DCPU_TYPE=aarch64)
        else
            params+=(-DCPU_TYPE=armhf)
        fi
    else
        params+=(-G 'Eclipse CDT4 - Unix Makefiles' -DCMAKE_BUILD_TYPE=RelWithDebInfo)
    fi

    if [[ "$rbdoom3_version" != "v1.2.0" ]]; then
        if compareVersions "$__os_debian_ver" gt 10; then
            params+=(-DUSE_SYSTEM_IMGUI=ON)
        fi
    fi

    params+=(-DSDL2=ON -DUSE_SYSTEM_ZLIB=ON -DUSE_SYSTEM_LIBPNG=ON -DUSE_SYSTEM_RAPIDJSON=ON)
    params+=(-DUSE_SYSTEM_LIBGLEW=ON -DUSE_SYSTEM_LIBJPEG=ON)

    if [[ -d $md_build/build ]]; then
        cd $md_build
        rm -rf build
    fi

    mkdir $md_build/build
    cd $md_build/build

    cmake "${params[@]}" ../neo

    # Make clean is probably not necessary.  It can't hurt, might help.
    make clean
    make

    md_ret_require="$md_build/build/RBDoom3BFG"
}

function install_rbdoom3_bfg() {
    md_ret_files=(
        "build/RBDoom3BFG"
        "base/default.cfg"
        "base/extract_resources.cfg"
        "base/renderprogs"
    )
}

function configure_rbdoom3_bfg() {
    local launch_prefix=""
    if ! isPlatform "x86"; then
        launch_prefix="XINIT-WM:"
    fi

    addPort "$md_id" "doom3_bfg" "Doom 3 (BFG Edition)" "$launch_prefix$md_inst/RBDoom3BFG"

    mkRomDir "ports/doom3_bfg"

    moveConfigDir "$md_inst/base" "$romdir/ports/doom3_bfg"
    moveConfigDir "$home/.local/share/rbdoom3bfg" "$md_conf_root/rbdoom3bfg"

    if [[ "$md_mode" == "install" ]]; then
        mkdir /opt/retropie/ports/rbdoom3_bfg/base/
        mkdir -p "$home/.doom3/base"
    fi

}
