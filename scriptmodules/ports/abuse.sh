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

rp_module_id="abuse"
rp_module_desc="Abuse"
rp_module_licence="GPL https://raw.githubusercontent.com/Xenoveritas/abuse/master/COPYING"
rp_module_repo="file http://abuse.zoy.org/raw-attachment/wiki/download/abuse-0.8.tar.gz"
rp_module_section="exp"
rp_module_flags="!mali"

# abuse-lib & abuse-sfx will pull in the older abuse package which only works under X
function depends_abuse() {
    getDepends cmake libsdl1.2-dev libsdl-mixer1.2-dev xorg
}

function sources_abuse() {
     downloadAndExtract "$md_repo_url" "$md_build"
}

function build_abuse() {
	cd abuse-0.8
	./configure --enable-debug   
	make
    md_ret_require=()
}

function install_abuse() {
   	cd abuse-0.8
	make install
	md_ret_files=(
    )
}

function configure_abuse() {
    addPort "$md_id" "abuse" "Abuse" "XINIT: /usr/local/bin/abuse -fullscreen"
}
