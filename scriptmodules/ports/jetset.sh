#!/usr/bin/env bash
 
# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md

rp_module_id="jswr"
rp_module_desc="Jet Set Willy Next"
rp_module_help="An updated, modern remake of the definitive platforming classic Jet Set Willy. https://jetsetwilly.net/"
rp_module_licence="Freeware"
rp_module_section="exp"

function depends_jswr() {
    # Install structural tool dependencies and base engine runtimes (like SDL2)
    getDepends wget tar grep unzip libsdl2-2.0-0
}

function install_bin_jswr() {
    mkdir -p "$md_inst"

    # Targets the exact live repository deployment point requested
    local url="https://jetsetwilly.net/download/raspberrypi"
    local temp_file="jswr-raspberrypi-0.91.10.zip"

    # Wget tracks links automatically to pull down the production archive
    wget -q --show-progress "$url" -O "$temp_file"

    if [ -f "$temp_file" ]; then
        echo "Decompressing packages..."
        # Unpack the specific payload structure safely
        unzip -q "$temp_file" -d $md_inst
        rm "$temp_file"
        
        # Make the core platform engine runnable. Change 'jswr' if the binary has an alternate filename.
        find . -type f -executable -exec chmod +x {} \;
        if [ -f "$md_inst/jswr" ]; then
            chmod +x "$md_inst/jswr"
        fi
    else
        echo "Error: Download failed. Verify the URL endpoint matches active network conditions."
        exit 1
    fi
}

function configure_jswr() {
    # Generate the base local system mapping hook for EmulationStation
    mkRomDir "ports"

    # Identify launch instructions to execution layers (looks for binary inside the source track)
    if [ -f "$md_inst/jswr" ]; then
        addPort "$md_id" "jswr" "Jet Set Willy Next" "XINIT-WM:$md_inst/jswr"
    else
        # Fallback if package extracts into a nested directory loop
        local main_bin=$(find "$md_inst" -type f -name "jswr*" -executable | head -n 1)
        addPort "$md_id" "jswr" "Jet Set Willy Next" "$main_bin"
    fi

    # Rectify explicit ownership variables across local storage systems
    chown -R $user:$user "$md_inst"
}
