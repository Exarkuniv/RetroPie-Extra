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

rp_module_id="gnukem"
rp_module_desc="Dave Gnukem - Duke Nukem 1 look-a-like"
rp_module_licence="MIT https://github.com/davidjoffe/dave_gnukem/blob/master/MIT-LICENSE.txt"
rp_module_repo="git https://github.com/davidjoffe/dave_gnukem.git main"
rp_module_section="exp"
rp_module_flags=""

function depends_gnukem() {
    getDepends libsdl1.2-dev libsdl-mixer1.2-dev xorg
}

function sources_gnukem() {
    gitPullOrClone
    gitPullOrClone "$md_build/data" https://github.com/davidjoffe/gnukem_data.git main
}

function build_gnukem() {
    make || return 1
    md_ret_require="$md_build/davegnukem"
}

function install_gnukem() {
    md_ret_files=(
        'davegnukem'
        'data'
    )
}

function configure_gnukem() {
    addPort "$md_id" "gnukem" "Dave Gnukem - Duke Nukem 1 look-a-like" "XINIT:$md_inst/dave.sh"
    moveConfigDir "$home/.gnukem" "$md_conf_root/gnukem"

    cat > "$md_inst/dave.sh" << _EOF_
#!/bin/bash
cd "$md_inst"
./davegnukem -640 -f
_EOF_

    chmod +x "$md_inst/dave.sh"
}