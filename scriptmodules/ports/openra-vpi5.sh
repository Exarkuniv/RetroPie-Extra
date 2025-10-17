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

rp_module_id="openra-vpi5"
rp_module_desc="Open RA - Real Time Strategy game engine supporting early Westwood classics"
rp_module_licence="GPL3 https://github.com/OpenRA/OpenRA/blob/bleed/COPYING"
rp_module_help="Currently working on how to pull the Data files No ETA"
rp_module_section="exp"
rp_module_flags="!mali !rpi4 !rpi3 rpi5"

function depends_openra() {
    # Determine system architecture
    local ARCH=$(dpkg --print-architecture)
    local MONO_REPO
    
    if [ "$ARCH" = "arm64" ]; then
        echo "Detected 64-bit system (arm64)"
        MONO_REPO="stable-buster"
    elif [ "$ARCH" = "armhf" ]; then
        echo "Detected 32-bit system (armhf)"
        MONO_REPO="stable-raspbianbuster"
    else
        echo "Warning: Unknown architecture - trying default"
        MONO_REPO="stable-buster"
    fi

    # Add Mono repository
    echo "Adding Mono repository for $MONO_REPO"
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
    echo "deb https://download.mono-project.com/repo/debian $MONO_REPO main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
    sudo apt update

    # Install .NET 6.0 runtime
    echo "Installing .NET 6.0 runtime"
    curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --version 6.0.406
    local depends=(
        mono-devel mono-complete mono-source libopenal-dev libfreetype6-dev liblua5.1-0-dev \
        libcurl4-openssl-dev zenity cmake build-essential libtool automake \
        autoconf gettext python3 python3-pip fuseiso libsdl2-dev
    )
    
    getDepends "${depends[@]}"
}

function sources_openra() {
    git clone https://github.com/OpenRA/OpenRA.git "$md_build/openra"
    
    cd "$md_build/openra"
    
    # Find latest stable release
    local latest_release=$(
        git tag -l 'release-*' --sort=-v:refname | head -n 1
    )
    
    if [ -n "$latest_release" ]; then
        git checkout "$latest_release"
    else
        echo "Using default branch (no release tags found)"
    fi
}

function build_openra() {
    echo 'export DOTNET_ROOT=$HOME/.dotnet' >> ~/.bashrc
    echo 'export PATH=$PATH:$HOME/.dotnet:$HOME/.dotnet/tools' >> ~/.bashrc
    source ~/.bashrc
    cd openra
    make RUNTIME=mono
    md_ret_require="$md_build/openra"
}

function install_openra() {
    md_ret_files=('openra/bin'
		'openra/OpenRA.Game'
		'openra/OpenRA.Launcher'
		'openra/OpenRA.Mods.Cnc'
		'openra/OpenRA.Mods.Common'
		'openra/OpenRA.Mods.D2k'
		'openra/glsl'
		'openra/mods'
		'openra/OpenRA.Platforms.Default'
		'openra/OpenRA.Server'
		'openra/OpenRA.Test'
		'openra/OpenRA.Utility'
		'openra/global mix database.dat'
		'openra/IP2LOCATION-LITE-DB1.IPV6.BIN.ZIP'
		'openra/launch-dedicated.cmd'
		'openra/launch-dedicated.sh'
		'openra/launch-game.cmd'
		'openra/launch-game.sh'
)
}

function create_launch_script() {
    local script_name="$1"
    local game_mod="$2"
    local game_name="$3"
    local game_dir="$4"
    local script_path="/opt/retropie/ports/openra/${script_name}"
    
    cat > "$script_path" << _EOF_
#!/bin/bash

# Check for and mount ISO if available
GAME_ISO="\$HOME/RetroPie/roms/ports/${game_dir}/game.iso"
MOUNT_POINT="/tmp/openra-${game_mod}-iso"

if [ -f "\$GAME_ISO" ]; then
    echo "Mounting ISO for ${game_name} from \$GAME_ISO"
    mkdir -p "\$MOUNT_POINT"
    sudo mount -o loop "\$GAME_ISO" "\$MOUNT_POINT"
    cd "$md_inst"
    ./launch-game.sh Game.Mod=${game_mod} --install-data="\$MOUNT_POINT"
    sudo umount "\$MOUNT_POINT"
    rmdir "\$MOUNT_POINT"
else
    echo "Starting ${game_name} without ISO"
    cd "$md_inst"
    ./launch-game.sh Game.Mod=${game_mod}
fi
_EOF_
    
    chmod +x "$script_path"
}

function configure_openra() {
    # Create game-specific rom directories
    mkRomDir "ports/opend2k"
    mkRomDir "ports/openra"
    mkRomDir "ports/opentd"
    mkRomDir "ports/opents"
    
    # Create launch scripts directory if it doesn't exist
    mkdir -p "/opt/retropie/ports/openra"
    
    # Create individual launch scripts for each game
    create_launch_script "ORA.sh" "ra" "Open Red Alert" "openra"
    create_launch_script "OTD.sh" "cnc" "Open Tiberian Dawn" "opentd"
    create_launch_script "OD2K.sh" "d2k" "Open Dune 2000" "opend2k"
    create_launch_script "OTS.sh" "ts" "Open Tiberian Sun" "opents"
    
    # Add ports to EmulationStation
    addPort "openra" "openra" "Open Red Alert" "XINIT: /opt/retropie/ports/openra/ORA.sh"
    addPort "openra" "opentd" "Open Tiberian Dawn" "XINIT: /opt/retropie/ports/openra/OTD.sh"
    addPort "openra" "opend2k" "Open Dune2000" "XINIT: /opt/retropie/ports/openra/OD2K.sh"
    addPort "openra" "opents" "Open Tiberian Sun" "XINIT: /opt/retropie/ports/openra/OTS.sh"
}
