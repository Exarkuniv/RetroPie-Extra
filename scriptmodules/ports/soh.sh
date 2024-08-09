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

rp_module_id="soh"
rp_module_desc="soh - Ship of Harkinian is an advanced source port for The Legend of Zelda - Ocarina of Time"
rp_module_help="Save your valid PAL .z64 copy of Ocarina of Time and/or Ocarina of Time Master Quest to $romdir/n64"
rp_module_repo="git https://github.com/HarbourMasters/Shipwright 8.0.4"
rp_module_section="exp"
rp_module_flags="!all 64bit"

function depends_soh() {
    getDepends gcc g++ git cmake ninja-build libglew-dev lsb-release libsdl2-dev libpng-dev libsdl2-net-dev libzip-dev zipcmp zipmerge ziptool nlohmann-json3-dev libtinyxml2-dev libspdlog-dev libboost-dev libopengl-dev jq
}

function sources_soh() {
    gitPullOrClone
}

function increase_swap() {
    original_swap=$(grep SwapTotal /proc/meminfo | awk '{print $2}')
    sudo dphys-swapfile swapoff
    sudo sed -i 's/^CONF_SWAPSIZE=.*/CONF_SWAPSIZE=2048/' /etc/dphys-swapfile
    sudo dphys-swapfile setup
    sudo dphys-swapfile swapon
}

function restore_swap() {
    sudo dphys-swapfile swapoff
    sudo sed -i "s/^CONF_SWAPSIZE=.*/CONF_SWAPSIZE=$((original_swap / 1024))/" /etc/dphys-swapfile
    sudo dphys-swapfile setup
    sudo dphys-swapfile swapon
}

function check_and_copy_rom() {
    local romdir="$home/RetroPie/roms/n64"
    local destdir="$md_build/OTRExporter"
    local hashes_file="$md_build/docs/supportedHashes.json"

    mkdir -p "$destdir"

    # Read the JSON file and extract the sha1 hashes
    local hashes=$(jq -r '.[].sha1' "$hashes_file")

    # Iterate through the files in the ROM directory
    for file in "$romdir"/*; do
        if [[ -f "$file" ]]; then
            local sha1=$(sha1sum "$file" | awk '{print $1}')
            # Check if the calculated SHA1 is in the list of supported hashes
            if echo "$hashes" | grep -q "$sha1"; then
                cp "$file" "$destdir"
                echo "Copied $file to $destdir"
                return 0
            fi
        fi
    done

    echo "No matching ROM file found in $romdir"
    return 1
}

function build_soh() {
    check_and_copy_rom
    if [[ $? -ne 0 ]]; then
        echo "Build cannot proceed without a valid ROM file."
        return 1
    fi

    increase_swap
    cmake -H. -Bbuild-cmake -GNinja
    cmake --build build-cmake --target ExtractAssets
    cmake --build build-cmake
    md_ret_require="$md_build/build-cmake/soh"
    restore_swap
}

function install_soh() {
    md_ret_files=(
       'build-cmake/soh/soh.elf'
       'build-cmake/soh/soh.otr'
       'build-cmake/soh/oot.otr'
    )
}

function configure_soh() {

    cat > "$md_inst/soh.sh" << _EOF_
#!/bin/bash

# Change directory
cd "$md_conf_root/soh" || exit
 
# Run the soh.elf file
./soh.elf
_EOF_
    chmod +x "$md_inst/soh.sh"

    addPort "$md_id" "soh" "Ship of Harkinian - Ocarina of Time" "XINIT-WM:$md_inst/soh.sh"
}
