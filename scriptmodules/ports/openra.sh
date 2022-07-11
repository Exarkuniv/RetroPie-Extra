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
rp_module_repo="file https://github.com/OpenRA/OpenRA/releases/download/release-20210321/OpenRA-release-20210321-source.tar.bz2"
rp_module_section="exp"
rp_module_flags="!mali"

function depends_openra() {
    getDepends libfreetype6 libopenal1 liblua5.1-0 libsdl2-2.0-0 xdg-utils zenity wget dbus-x11 apt-transport-https dirmngr gnupg ca-certificates xorg 
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
    echo "deb https://download.mono-project.com/repo/debian stable-raspbianbuster main" | sudo tee /etc/apt/sources.list.d/mono-official-stable.list
    apt update
    aptInstall mono-devel
}

function sources_openra() {
    downloadAndExtract "$md_repo_url" "$md_build" 
}

function build_openra() {
        curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin --version 5.0.203
	echo 'export DOTNET_ROOT=$HOME/.dotnet' >> ~/.bashrc
	echo 'export PATH=$PATH:$HOME/.dotnet' >> ~/.bashrc
	source ~/.bashrc
	
		cd openra

	make 
    md_ret_require="$md_build/openra"
}

function install_openra() {
    md_ret_files=(
	'openra'
 )
}

function configure_openra() {
    addPort "$md_id" "openra" "Open Red Alert" "XINIT: /opt/retropie/ports/openra/openra/ORA.sh"
	
cat >"$md_inst/openra/ORA.sh" << _EOF_

#!/bin/bash
cd "$md_inst/openra"
./launch-game.sh Game.Mod=ra -- :0 vt\$XDG_VTNR

_EOF_

 chmod +x "$md_inst/openra/ORA.sh"

    mkRomDir "ports/openra"

addPort "$md_id" "opentd" "Open Tiberian Dawn" "XINIT: /opt/retropie/ports/openra/openra/OTD.sh"
	
cat >"$md_inst/openra/OTD.sh" << _EOF_

#!/bin/bash
cd "$md_inst/openra"
./launch-game.sh Game.Mod=cnc -- :0 vt\$XDG_VTNR

_EOF_

 chmod +x "$md_inst/openra/OTD.sh"

    mkRomDir "ports/opentd"

addPort "$md_id" "opentd" "Open Dune2000" "XINIT: /opt/retropie/ports/openra/openra/OD2K.sh"
	
cat >"$md_inst/openra/OD2K.sh" << _EOF_

#!/bin/bash
cd "$md_inst/openra"
./launch-game.sh Game.Mod=d2k -- :0 vt\$XDG_VTNR

_EOF_

 chmod +x "$md_inst/openra/OD2K.sh"

    mkRomDir "ports/opend2k"



}
