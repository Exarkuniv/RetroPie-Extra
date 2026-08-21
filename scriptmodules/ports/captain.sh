#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="captain_s"
rp_module_desc="Captain 'S' The Remake"
rp_module_help="Controls: Arrow: Move, CTRL: Action, ENTER: Change character when get a sausage or change superpower when you are Captain S.

Note: there is bug in the game where you can't change language once you set one. Fix it by deleting the file 'capitan.cfg' in ~/.capitan (reset the full configuration).
The game sometimes resets itself to spanish..."
rp_module_licence="MIT https://raw.githubusercontent.com/jmcerrejon/PiKISS/master/LICENSE.md"
rp_module_repo="file https://github.com/Exarkuniv/Rpi-pikiss-binary/raw/Master/captain_s.tar.gz"
rp_module_section="exp"
rp_module_flags="!armv6"

function depends_captain_s() {
    local depends=(xorg)
	
	if [[ "$__os_debian_ver" -ge 13 ]]; then
		depends+=(liballegro4.4t64 libpng16-16t64)
	else
		depends+=(liballegro4.4 libpng16-16)
	fi
    getDepends "${depends[@]}"
}

function sources_captain_s() {
    downloadAndExtract "$md_repo_url" "$md_build" "--strip-components=1"
}

function install_captain_s() {
    md_ret_files=('data'
		'docs'
		'extra'
		'lang'
		'capitan.cfg'
		'captain'
    )
}

function configure_captain_s() {
    addPort "$md_id" "captain_s" "Captain 'S' The Remake" "XINIT: pushd $md_inst; $md_inst/captain; popd"
}
