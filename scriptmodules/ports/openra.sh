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

rp_module_id="openra"
rp_module_desc="Open RA - Real Time Strategy game engine supporting early Westwood classics"
rp_module_licence="GPL3 https://github.com/OpenRA/OpenRA/blob/bleed/COPYING"
rp_module_help="Currently working on how to pull the Data files No ETA"
rp_module_section="exp"
rp_module_flags="!mali !rpi3 rpi4 rpi5"

# .NET for Bookworm/Pi5 path (no mono needed there).
DOTNET_INSTALL_VERSION_BOOKWORM="8.0.404"
# Legacy .NET for Buster/Pi4
DOTNET_INSTALL_VERSION_BUSTER="6.0.406"

function _openra_is_bookworm() {
    grep -qi 'bookworm' /etc/os-release 2>/dev/null
}

function depends_openra() {
    set -e

    local depends=(
        libopenal-dev libfreetype6-dev liblua5.1-0-dev \
        libcurl4-openssl-dev zenity cmake build-essential libtool automake \
        autoconf gettext python3 python3-pip fuseiso libsdl2-dev curl \
        ca-certificates apt-transport-https dirmngr gnupg xorg
    )
    getDepends "${depends[@]}"

    if _openra_is_bookworm; then
        echo "Detected Bookworm - using dotnet runtime, no Mono needed"

        export DOTNET_ROOT="$md_inst/.dotnet"
        mkdir -p "$DOTNET_ROOT"

        if [ ! -x "$DOTNET_ROOT/dotnet" ]; then
            echo "Installing .NET SDK $DOTNET_INSTALL_VERSION_BOOKWORM to $DOTNET_ROOT"
            curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
            bash /tmp/dotnet-install.sh --version "$DOTNET_INSTALL_VERSION_BOOKWORM" --install-dir "$DOTNET_ROOT"
        else
            echo ".NET SDK already present at $DOTNET_ROOT, skipping install"
        fi
    else
        echo "Detected Buster (or older) - using Mono runtime"

        # Modern keyring method instead of the deprecated apt-key.
        mkdir -p /usr/share/keyrings
        curl -sSL https://download.mono-project.com/repo/xamarin.gpg \
            | gpg --dearmor | sudo tee /usr/share/keyrings/mono-keyring.gpg > /dev/null

        echo "deb [signed-by=/usr/share/keyrings/mono-keyring.gpg] https://download.mono-project.com/repo/debian stable-raspbianbuster main" \
            | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
        sudo apt update
        aptInstall mono-devel

        export DOTNET_ROOT="$HOME/.dotnet"
        mkdir -p "$DOTNET_ROOT"

        if [ ! -x "$DOTNET_ROOT/dotnet" ]; then
            echo "Installing .NET SDK $DOTNET_INSTALL_VERSION_BUSTER to $DOTNET_ROOT"
            curl -sSL https://dot.net/v1/dotnet-install.sh -o /tmp/dotnet-install.sh
            bash /tmp/dotnet-install.sh --version "$DOTNET_INSTALL_VERSION_BUSTER" --install-dir "$DOTNET_ROOT"
        else
            echo ".NET SDK already present at $DOTNET_ROOT, skipping install"
        fi
    fi

    set +e
}

function sources_openra() {
    git clone https://github.com/OpenRA/OpenRA.git "$md_build/openra"

    cd "$md_build/openra"

    local latest_release
    latest_release=$(git tag -l 'release-*' --sort=-v:refname | head -n 1)

    if [ -n "$latest_release" ]; then
        git checkout "$latest_release"
    else
        echo "Using default branch (no release tags found)"
    fi
}

function build_openra() {
    if _openra_is_bookworm; then
        export DOTNET_ROOT="$md_inst/.dotnet"
    else
        export DOTNET_ROOT="$HOME/.dotnet"
    fi
    export PATH="$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools"

    if ! grep -q 'DOTNET_ROOT=.*openra' ~/.bashrc 2>/dev/null; then
        {
            echo "export DOTNET_ROOT=$DOTNET_ROOT"
            echo 'export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools'
        } >> ~/.bashrc
    fi

    cd openra

    if _openra_is_bookworm; then
        make RUNTIME=dotnet
    else
        make RUNTIME=mono
    fi

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

# Auto-detect which DOTNET_ROOT was used at install time (Pi5/Bookworm
# installs it under the module dir, Pi4/Buster installs it under \$HOME).
if [ -x "$md_inst/.dotnet/dotnet" ]; then
    export DOTNET_ROOT="$md_inst/.dotnet"
else
    export DOTNET_ROOT="\$HOME/.dotnet"
fi
export PATH="\$PATH:\$DOTNET_ROOT:\$DOTNET_ROOT/tools"

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

    moveConfigDir "$home/.config/openra" "$md_conf_root/openra"

    # Create launch scripts directory if it doesn't exist
    mkdir -p "/opt/retropie/ports/openra"

    # Create individual launch scripts for each game
    create_launch_script "ORA.sh" "ra" "Open Red Alert" "openra"
    create_launch_script "OTD.sh" "cnc" "Open Tiberian Dawn" "opentd"
    create_launch_script "OD2K.sh" "d2k" "Open Dune 2000" "opend2k"
    create_launch_script "OTS.sh" "ts" "Open Tiberian Sun" "opents"

    # Add ports to EmulationStation
    addPort "$md_id" "openra" "Open Red Alert" "XINIT: /opt/retropie/ports/openra/ORA.sh"
    addPort "$md_id" "opentd" "Open Tiberian Dawn" "XINIT: /opt/retropie/ports/openra/OTD.sh"
    addPort "$md_id" "opend2k" "Open Dune2000" "XINIT: /opt/retropie/ports/openra/OD2K.sh"
    addPort "$md_id" "opents" "Open Tiberian Sun" "XINIT: /opt/retropie/ports/openra/OTS.sh"
}
