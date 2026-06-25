#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="openclaw"
rp_module_desc="Reimplementation of Captain Claw (1997) platformer"
rp_module_help="you will need original CLAW.REZ from original game in the ports/openclaw folder"
rp_module_licence="GPL2 https://raw.githubusercontent.com/pjasicek/OpenClaw/master/LICENSE.txt"
rp_module_repo="file https://github.com/Exarkuniv/Rpi-pikiss-binary/raw/Master/openclaw-dev-rpi.tar.gz"
rp_module_section="exp"
rp_module_flags="!armv6 rpi4"

function depends_openclaw() {
    getDepends timidity freepats libsdl2-mixer-2.0-0 libsdl2-ttf-2.0-0 libsdl2-image-2.0-0 libsdl2-gfx-1.0-0 libsdl2-dev libsdl2-image-dev libsdl2-mixer-dev libsdl2-ttf-dev libsdl2-gfx-dev
}

function sources_openclaw() {
    downloadAndExtract "$md_repo_url" "$md_build" "--strip-components=1"
}

function install_openclaw() {
    md_ret_files=('openclaw'
		'ASSETS'
		'ASSETS.ZIP'
		'clacon.ttf'
		'config.xml'
		'config_linux_release.xml'
		'config_linux.xml'
		'MENU.xml'
		'SAVES.XML'
		'ClawLauncher.exe.config'
    )
    mkdir -p $home/.config/openclaw
    cp -v "config.xml" "$home/.config/openclaw/config.xml"
}

function configure_openclaw() {
    mkRomDir "ports/captainclaw"
    local script="$md_inst/$md_id.sh"
    cat > "$script" << _EOF_
#!/bin/bash
cd $md_inst && ./openclaw
_EOF_

    chmod +x "$script"
    addPort "$md_id" "openclaw" "Captain Claw" "$script"
}