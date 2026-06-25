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

rp_module_id="piegalaxy"
rp_module_desc="Pie Galaxy - Download and install GOG.com games in RetroPie"
rp_module_licence="GPL https://github.com/sigboe/pie-galaxy/blob/master/LICENSE"
rp_module_section="exp"

function depends_piegalaxy() {
	getDepends jq html2text unar
}

function install_bin_piegalaxy() {
	local innoversion="1.8-dev-2019-01-13"
	local wyvernversion="1.4.1"
	gitPullOrClone "$md_inst" https://github.com/sigboe/pie-galaxy.git master
	isPlatform "x86" && (cd "$md_inst" && curl -o wyvern -O "https://github.com/sigboe/wyvern/releases/latest/download/wyvern-${wyvernversion}.x86")
	isPlatform "arm" && (cd "$md_inst" && curl -o wyvern -O "https://github.com/sigboe/wyvern/releases/latest/download/wyvern-${wyvernversion}.arm")
	isPlatform "x86" && downloadAndExtract "https://constexpr.org/innoextract/files/snapshots/innoextract-${innoversion}/innoextract-${innoversion}-linux.tar.xz" "$md_inst" --strip-components 3 innoextract-${innoversion}-linux/bin/amd64/innoextract
	isPlatform "arm" && downloadAndExtract "https://constexpr.org/innoextract/files/snapshots/innoextract-${innoversion}/innoextract-${innoversion}-linux.tar.xz" "$md_inst" --strip-components 3 innoextract-${innoversion}-linux/bin/armv6j-hardfloat/innoextract
	chmod +x "$md_inst"/wyvern "$md_inst"/innoextract "$md_inst"/pie-galaxy.sh
}

function configure_piegalaxy() {
	addPort "$md_id" "piegalaxy" "Pie Galaxy" "$md_inst/pie-galaxy.sh"
}