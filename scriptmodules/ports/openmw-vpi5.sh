#!/usr/bin/env bash

# OpenMW RetroPie Scriptmodule - Complete with Config File Handling
# Includes proper config setup and controller mappings

rp_module_id="openmw-vpi5"
rp_module_desc="OpenMW - Open-source Morrowind engine reimplementation"
rp_module_licence="GPL3 https://github.com/OpenMW/openmw/blob/stable/LICENSE"
rp_module_repo="git https://github.com/OpenMW/openmw.git stable"
rp_module_section="exp"
rp_module_flags="rpi5 !rpi4 !rpi3"

function depends_openmw) {
    local depends=(
        git cmake build-essential libopenal-dev libsdl2-dev
        libqt5opengl5-dev libunshield-dev libavcodec-dev libavformat-dev
        libavutil-dev libswscale-dev 
        libbullet-dev libmygui-dev libsqlite3-dev
        qtbase5-dev qttools5-dev libfftw3-dev libqt5svg5-dev
        liblz4-dev libyaml-cpp-dev
        libboost-filesystem-dev libboost-program-options-dev 
        libboost-system-dev libboost-thread-dev libboost-iostreams-dev
        luajit libluajit-5.1-dev matchbox-window-manager matchbox
    )

    if [[ "$(dpkg --print-architecture)" == "arm64" ]]; then
        depends+=(libopenscenegraph-dev)
    else
        depends+=(libopenscenegraph-3.4-dev)
    fi
    
    getDepends "${depends[@]}"
}

function sources_openmw() {
    gitPullOrClone "$md_build" https://github.com/OpenMW/openmw.git stable
}

function build_openmw() {
    local arch=$(dpkg --print-architecture)
    local osg_path=""
    local boost_path="/usr/lib/$arch"
    local lua_path="/usr/include/luajit-2.1"
    
    # First do a basic configuration test without optimizations
    mkdir -p build
    cd build || exit
    
    # Initial minimal configuration to test compiler
    cmake .. \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_BUILD_TYPE=Release \
        -DDESIRED_QT_VERSION=5
    
    # Only proceed if basic configuration worked
    if [ $? -eq 0 ]; then
        # Now reconfigure with full optimizations
        if [[ "$arch" == "arm64" ]]; then
            # Pi5 (64-bit) settings
            local march="armv8-a"
            local mtune="cortex-a76"
            local mfpu="neon-fp-armv8"
            local mfloat="hard"
            local make_jobs=4
            local extra_cflags="-O2 -mcpu=$mtune -fomit-frame-pointer -ffast-math"
            osg_path="/usr/lib/aarch64-linux-gnu"
        else
            # Pi4 (32-bit) settings
            local march="armv8-a"
            local mtune="cortex-a72"
            local mfpu="neon-fp-armv8"
            local mfloat="hard"
            local make_jobs=3
            local extra_cflags="-O2 -mcpu=$mtune -fomit-frame-pointer -ffast-math"
            osg_path="/usr/lib/arm-linux-gnueabihf"
        fi
        
        local extra_ldflags="-Wl,-O1 -Wl,--as-needed"

        cmake .. \
            -DLuaJit_INCLUDE_DIR="$lua_path" \
            -DLuaJit_LIBRARY="$osg_path/libluajit-5.1.so" \
            -Dyaml-cpp_DIR="$osg_path/cmake/yaml-cpp" \
            -DLZ4_INCLUDE_DIR="/usr/include" \
            -DLZ4_LIBRARY="$osg_path/liblz4.so" \
            -DOpenSceneGraph_DIR="$osg_path/cmake/OpenSceneGraph" \
            -DBOOST_ROOT="/usr" \
            -DBOOST_INCLUDEDIR="/usr/include" \
            -DBOOST_LIBRARYDIR="$boost_path" \
            -DBoost_USE_STATIC_LIBS=OFF \
            -DBoost_IOSTREAMS_LIBRARY="$boost_path/libboost_iostreams.so" \
            -DCMAKE_C_FLAGS="$extra_cflags" \
            -DCMAKE_CXX_FLAGS="$extra_cflags" \
            -DCMAKE_EXE_LINKER_FLAGS="$extra_ldflags"
            
        make -j$make_jobs
        md_ret_require="$md_build/build"
    else
        md_ret_errors+=("Failed to configure OpenMW - check compiler installation")
        return 1
    fi
}

function install_openmw() {
    cd build || exit
    make install
    
    # Create data directory
    mkdir -p "$md_inst/data"
}

function install_openmw() {
    cd build || exit
    make install
    
    # Create data directory
    mkdir -p "$md_inst/data"
}

function config_data_openmw() { 
    #look for the data files to see what config to install
	   # Copy the config file from build directory if it exists
    download "https://raw.githubusercontent.com/Exarkuniv/game-data/main/openmw/openmw.cfg" "$md_conf_root/openmw"    
    # Add required lines to the config file

    cat >> "$md_conf_root/openmw/openmw.cfg" << _EOF_

# RetroPie specific configuration
fallback-archive=Morrowind.bsa
fallback-archive=Tribunal.bsa
fallback-archive=Bloodmoon.bsa
data="/opt/retropie/ports/openmw/data"
content=Morrowind.esm
content=Tribunal.esm
content=Bloodmoon.esm
_EOF_

    chown $user:$user "$md_conf_root/openmw/openmw.cfg"

}

function configure_openmw() {
    local script="$md_inst/openmw-l.sh"
    local scripts="$md_inst/openmw-g.sh"
    local launcher=("$md_inst/bin/openmw-launcher")
    local game=("$md_inst/bin/openmw")

    mkRomDir "ports/$md_id"

    moveConfigDir "$md_inst/data" "$romdir/ports/openmw"
    moveConfigDir "$home/.config/openmw" "$md_conf_root/$md_id"

    # Download controller mappings
    download "https://raw.githubusercontent.com/gabomdq/SDL_GameControllerDB/master/gamecontrollerdb.txt" "$md_inst"
    
    # Create buffer script for menu
    cat > "$script" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
${launcher[*]}
_EOF_
    
   # Create buffer script for game
    cat > "$scripts" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
OPENMW_DECOMPRESS_TEXTURES=1 ${game[*]}
_EOF_
    

    chmod +x "$script"
    chmod +x "$scripts"

    # Add port using our launch script
    addPort "omwm" "omwm" "OpenMW - Setting menu" "XINIT: $script"
    addPort "openmw" "openmw" "OpenMW - Morrowind Engine" "XINIT: $scripts"

    # Set permissions
    chown -R $user:$user "$romdir/ports/$md_id"
    
    # Create docs
    cat > "$romdir/ports/$md_id/README.txt" << _EOF_
OpenMW Installation Guide:

1. Copy your Morrowind game files to:
   $romdir/ports/openmw
   Required files:
   - Morrowind.esm
   - Tribunal.esm (if owned)
   - Bloodmoon.esm (if owned)
   - Morrowind.bsa
   - Tribunal.bsa (if owned)
   - Bloodmoon.bsa (if owned)

2. If the OpenMW - Morrowind Engine crashes then you are missing a file. 
   To fix crashing
   - find the missing file
   - run OpenMW - Setting menu and it will configure the settings.cfg to see the files you have
_EOF_
    chown $user:$user "$romdir/ports/openmw/README.txt"

	[[ "$md_mode" == "install" ]] && config_data_openmw
}
