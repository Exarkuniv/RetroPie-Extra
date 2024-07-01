#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

# NOTE v1.4.0 may be the last version available to build on a rpi.  Newer versions have added a
# Microsoft DirectX dependency https://github.com/microsoft/DirectXShaderCompiler which only supports
# nvidia, amd, and intel GPUs (Not available for rpi)

rp_module_id="rbdoom3_bfg"
rp_module_desc="rbdoom3_bfg - Doom 3: BFG Edition"
rp_module_licence="GPL3 https://raw.githubusercontent.com/RobertBeckebans/RBDOOM-3-BFG/master/LICENSE.md"
rp_module_help="For the game data, from your windows install (Gog or Steam) locate the 'base' directory.  Copy ALL contents to $romdir/ports/doom3_bfg"
rp_module_section="exp"
rp_module_repo="git https://github.com/RobertBeckebans/RBDOOM-3-BFG.git v1.4.0"
rp_module_flags=""

function _arch_rbdoom3_bfg() {
    echo "$(uname -m | sed -e 's/i.86/x86/' | sed -e 's/^arm.*/arm/')"
}

function depends_rbdoom3_bfg() {
    local depends=(cmake libavcodec-dev libavformat-dev libavutil-dev libopenal-dev libsdl2-dev
                   libswscale-dev)
    isPlatform "rpi" && depends+=(libglew-dev libimgui-dev libjpeg-dev libpng-dev rapidjson-dev
                                  zlib1g-dev)

    getDepends "${depends[@]}"
}

function sources_rbdoom3_bfg() {
    gitPullOrClone
}

function build_rbdoom3_bfg() {
    if [[ -d $md_build/build ]]; then
        cd $md_build
        rm -rf build
    fi

    mkdir $md_build/build
    cd $md_build/build

    if isPlatform "rpi"; then
        # DCPU_TYPE is the only value to change: armhf for 32bit and aarch64 for 64bit  Is there a
        # variable that responds with those two values and only those values?  Might be a way to simplify this.
        # NOTE: I am guessing on DCPU_TYPE for 64bit
        if isPlatform "64bit"; then
            # This is a 64-bit rpi build
            # NOTE: This is from the rasbian rules file.  I have no idea what DEB_HOST_MULTIARCH
            # returns.  Since this isn't being cross-compiled, I hope it doesn't matter.
            #-DCMAKE_LIBRARY_PATH=$(DEB_HOST_MULTIARCH) \

            cmake -G "Unix Makefiles" \
	                -DSDL2=ON \
	                -DUSE_SYSTEM_ZLIB=ON \
                  -DUSE_SYSTEM_LIBPNG=ON \
	                -DUSE_SYSTEM_LIBJPEG=ON \
                  -DUSE_SYSTEM_LIBGLEW=ON \
	                -DUSE_SYSTEM_IMGUI=ON \
                  -DUSE_SYSTEM_RAPIDJSON=ON \
	                -DCPU_TYPE=aarch64 \
	                -DUSE_PRECOMPILED_HEADERS=OFF \
	                -DCPU_OPTIMIZATION="" \
                  -DUSE_INTRINSICS_SSE=OFF \
                  ../neo
        else
            # This is a 32-bit rpi build
            # NOTE: This is from the rasbian rules file.  I have no idea what DEB_HOST_MULTIARCH
            # returns.  Since this isn't being cross-compiled, I hope it doesn't matter.
            #-DCMAKE_LIBRARY_PATH=$(DEB_HOST_MULTIARCH) \

            cmake -G "Unix Makefiles" \
                  -DSDL2=ON \
                  -DUSE_SYSTEM_ZLIB=ON \
                  -DUSE_SYSTEM_LIBPNG=ON \
                  -DUSE_SYSTEM_LIBJPEG=ON \
                  -DUSE_SYSTEM_LIBGLEW=ON \
                  -DUSE_SYSTEM_IMGUI=ON \
                  -DUSE_SYSTEM_RAPIDJSON=ON \
                  -DCPU_TYPE=armhf \
                  -DUSE_PRECOMPILED_HEADERS=OFF \
                  -DCPU_OPTIMIZATION="" \
                  -DUSE_INTRINSICS_SSE=OFF \
                  ../neo
        fi
    else
        cmake -G "Eclipse CDT4 - Unix Makefiles" \
              -DCMAKE_BUILD_TYPE=RelWithDebInfo \
              -DSDL2=ON \
              ../neo
    fi

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
    addPort "$md_id" "doom3_bfg" "Doom 3 (BFG Edition)" "$md_inst/RBDoom3BFG"

    mkRomDir "ports/doom3_bfg"

    moveConfigDir "$md_inst/base" "$romdir/ports/doom3_bfg"

    if [[ "$md_mode" == "install" ]]; then
        mkdir /opt/retropie/ports/rbdoom3_bfg/base/
        mkdir "$home/.doom3/base"
    fi
}
