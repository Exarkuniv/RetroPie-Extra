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

rp_module_id="2s2h"
rp_module_desc="2s2h - 2ship2harkinian is an advanced source port for The Legend of Zelda - Majora's Mask"
rp_module_help="Save your valid USA .z64 copy of Majora's Mask to $romdir/n64"
rp_module_repo="git https://github.com/HarbourMasters/2ship2harkinian.git 1.0.1"
rp_module_section="exp"
rp_module_flags="all"

function depends_2s2h() {
    getDepends gcc g++ git cmake ninja-build lsb-release libsdl2-dev libpng-dev libsdl2-net-dev libzip-dev zipcmp zipmerge ziptool nlohmann-json3-dev libtinyxml2-dev libspdlog-dev libboost-dev libopengl-dev jq
}

function sources_2s2h() {
    gitPullOrClone
}

function increase_swap() {
    original_swap=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
    sudo dphys-swapfile swapoff
    sudo sed -i 's/^CONF_SWAPSIZE=.*/CONF_SWAPSIZE=4096/' /etc/dphys-swapfile
    sudo dphys-swapfile setup
    sudo dphys-swapfile swapon
}

function restore_swap() {
    sudo dphys-swapfile swapoff
    sudo sed -i "s/^CONF_SWAPSIZE=.*/CONF_SWAPSIZE=$((original_swap / 1024))/" /etc/dphys-swapfile
    sudo dphys-swapfile setup
    sudo dphys-swapfile swapon
}

function copy_rom_2s2h() {
    local romdir="$home/RetroPie/roms/n64"
    local destdir="$md_build/OTRExporter"

    mkdir -p "$destdir"

    # Define the hashes to check against
    local hash1="d6133ace5afaa0882cf214cf88daba39e266c078"
    local hash2="9743aa026e9269b339eb0e3044cd5830a440c1fd"

    # Iterate through the files in the ROM directory
    for file in "$romdir"/*; do
        if [[ -f "$file" ]]; then
            local sha1=$(sha1sum "$file" | awk '{print $1}')
            # Check if the calculated SHA1 matches either of the specified hashes
            if [[ "$sha1" == "$hash1" || "$sha1" == "$hash2" ]]; then
                cp "$file" "$destdir"
                echo "Copied $file to $destdir"
                return 0
            fi
        fi
    done

    echo "No matching ROM file found in $romdir"
    return 1
}

function build_2s2h() {
    copy_rom_2s2h
    if [[ $? -ne 0 ]]; then
        echo "Build cannot proceed without a valid ROM file."
        return 1
    fi

    increase_swap
    cmake -H. -Bbuild-cmake -GNinja
    cmake --build build-cmake --target ExtractAssets
    cmake --build build-cmake
    md_ret_require="$md_build/build-cmake/mm"
    restore_swap
}

function install_2s2h() {
    md_ret_files=(
       'build-cmake/mm/2s2h.elf'
       'build-cmake/mm/2ship.o2r'
       'build-cmake/mm/mm.o2r'
    )
}

function configure_2s2h() {

# Create the boot .sh file
    cat > "$md_inst/2s2h.sh" << _EOF_
#!/bin/bash

# Change directory
cd "$md_inst" || exit
 
# Run the 2s2h.elf file
./2s2h.elf
_EOF_
    chmod +x "$md_inst/2s2h.sh"
    
# Create the config file to default to fullscreen
    cat > "$md_inst/2ship2harkinian.json" << _EOF_
{
    "Window": {
        "AudioBackend": "sdl",
        "Backend": {
            "Id": 3,
            "Name": "OpenGL"
        },
        "Fullscreen": {
            "Enabled": true,
            "Height": 1080,
            "Width": 1920
        },
        "Height": 1080,
        "PositionX": 0,
        "PositionY": 0,
        "Width": 1920
    }
}
_EOF_
    chmod +x "$md_inst/2ship2harkinian.json"

    addPort "$md_id" "2s2h" "2ship2harkinian - Majora's Mask" "$md_inst/2s2h.sh"
    
    chown -R $user:$user "$md_inst"
}
