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
rp_module_flags="!mali !all rpi4 rpi3"

function depends_openra() {
    getDepends libfreetype6 libopenal1 liblua5.1-0 libsdl2-2.0-0 xdg-utils zenity wget dbus-x11 apt-transport-https dirmngr gnupg ca-certificates xorg 
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
    echo "deb https://download.mono-project.com/repo/debian stable-raspbianbuster main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
    apt update
    aptInstall mono-devel
    curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --version 6.0.406

}

function sources_openra() {
    mkdir -p openra
    wget https://github.com/OpenRA/OpenRA/releases/download/release-20230225/OpenRA-release-20230225-source.tar.bz2 || return 1
    tar xvjf OpenRA-release-20230225-source.tar.bz2 -C /home/pi/RetroPie-Setup/tmp/build/openra/openra 	 || return 1
}

function build_openra() {
    echo 'export DOTNET_ROOT=$HOME/.dotnet' >> ~/.bashrc
    echo 'export PATH=$PATH:$HOME/.dotnet:$HOME/.dotnet/tools' >> ~/.bashrc
    source ~/.bashrc
    cd openra || return 1
    make RUNTIME=mono || return 1
    md_ret_require="$md_build/openra"
}

function install_openra() {
    md_ret_files=('openra'
 )
}

function configure_openra() {
    mkRomDir "ports/opend2k"
    mkRomDir "ports/openra"
    mkRomDir "ports/opentd"
    mkRomDir "ports/opents"

    moveConfigDir "$home/.config/openra" "$md_conf_root/openra"

    addPort "$md_id" "openra" "Open Red Alert" "XINIT: /opt/retropie/ports/openra/openra/ORA.sh"
    addPort "opentd" "opentd" "Open Tiberian Dawn" "XINIT: /opt/retropie/ports/openra/openra/OTD.sh"
    addPort "opend2k" "opend2k" "Open Dune2000" "XINIT: /opt/retropie/ports/openra/openra/OD2K.sh"
    addPort "opents" "opents" "Open Tiberian Sun" "XINIT: /opt/retropie/ports/openra/openra/OTS.sh"

 #running script for Red Alert
cat >"$md_inst/openra/ORA.sh" << _EOF_

#!/bin/bash
cd "$md_inst/openra"
./launch-game.sh Game.Mod=ra -- :0 vt\$XDG_VTNR

_EOF_

 #running script for Tiberian Dawn
cat >"$md_inst/openra/OTD.sh" << _EOF_

#!/bin/bash
cd "$md_inst/openra"
./launch-game.sh Game.Mod=cnc -- :0 vt\$XDG_VTNR

_EOF_

 #running script for Dune2000
cat >"$md_inst/openra/OD2K.sh" << _EOF_

#!/bin/bash
cd "$md_inst/openra"
./launch-game.sh Game.Mod=d2k -- :0 vt\$XDG_VTNR

_EOF_

 #running script for Tiberian Sun
cat >"$md_inst/openra/OTS.sh" << _EOF_

#!/bin/bash
cd "$md_inst/openra"
./launch-game.sh Game.Mod=ts -- :0 vt\$XDG_VTNR

_EOF_

    chmod +x "$md_inst/openra/OTS.sh"
    chmod +x "$md_inst/openra/OD2K.sh"
    chmod +x "$md_inst/openra/ORA.sh"
    chmod +x "$md_inst/openra/OTD.sh"
}