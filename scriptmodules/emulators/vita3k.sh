#!/usr/bin/env bash
 
# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md

rp_module_id="vita3k"
rp_module_desc="Vita3K - PlayStation Vita Emulator (Exclusive to Pi 5)"
rp_module_help="**** REQUIRES TRIXIE OS ****\nFIRMWARE REQUIREMENT:On first run of Vita3k you need to install the firmware. >https://vita3k.org/quickstart< see here for firmware or use Google search\nInstall firmware files using the GUI File menu\nTo install games place them in ~/RetroPie/roms/ports/vita3k/games\nLaunch Vita3k and on the GUI File menu select 'install .vpk/zip' Browse to the games folder and select your game to install.\nOnce installed game appears on the Vitak 3k GUI.\nCheck Controller section for how to use Vita3k.\nDO NOT use the Download Firmware buttons on the splash screen they do not work!"
rp_module_licence="GPLv3"
rp_module_section="exp"
rp_module_flags="!all 64bit pi5"

function depends_vita3k() {
    # Hardware detection validation check for Raspberry Pi 5
    if [[ "$__platform" != "rpi5" ]]; then
        if ! grep -q "Raspberry Pi 5" /proc/device-tree/model 2>/dev/null; then
            __errors+=("Installation Aborted: Vita3K configuration is optimized and strictly locked to Raspberry Pi 5 devices.")
            return 1
        fi
    fi

    # Core dependencies required to run the AppImage inside the RetroPie environment
    getDepends libsdl2-dev libcurl4-gnutls-dev libepoxy-dev libpixman-1-dev libgtk-3-dev libssl-dev libsamplerate0-dev libpcap-dev libslirp-dev libvulkan-dev libpipewire-0.3-dev mesa-utils xorg matchbox-window-manager mesa-vulkan-drivers mesa-utils vulkan-tools
}

function install_bin_vita3k() {
    mkdir -p "$md_inst"
    
    # URL provided to target the continuous rolling automated nightly builds
    local url="https://github.com/Vita3K/Vita3K/releases/download/continuous/Vita3K-aarch64.AppImage"
    
    if ! wget -O "$md_inst/Vita3K-aarch64.AppImage" "$url"; then
        __errors+=("Download Failure: Unable to fetch Vita3K-aarch64.AppImage from GitHub.")
        return 1
    fi
    
    # Ensure binary execution permissions are active
    chmod +x "$md_inst/Vita3K-aarch64.AppImage"
}

function configure_vita3k() {
      addPort "$md_id" "vita3k" "Vita3K Emulator" "XINIT-WM:$md_inst/Vita3K-aarch64.AppImage"
      mkRomDir "ports/$md_id"
      mkRomDir "ports/$md_id/firmware"
      cat >"/home/pi/RetroPie/roms/ports/vita3k/firmware/firmware.txt" <<_EOF_

Place here the firmware files

This explains where to get the firmware files :-
https://vita3k.org/quickstart

or do a Google Search.

Then go to File / Install Firmware in the GUI.

Note the Download Firmware buttons will not work on the gui
if using an OS Lite version.

_EOF_
      mkRomDir "ports/$md_id/games"
      cat >"/home/pi/RetroPie/roms/ports/vita3k/games/games.txt" <<_EOF_

Place here the game files.
The format is .vbk or .zip
Install using the GUI File menu.

_EOF_

}
