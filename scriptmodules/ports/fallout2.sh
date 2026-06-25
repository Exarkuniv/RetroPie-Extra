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

rp_module_id="fallout2"
rp_module_desc="Fallout 2 Community Edition"
rp_module_licence="GNU https://raw.githubusercontent.com/alexbatalov/fallout2-ce/main/LICENSE.md"
rp_module_help="Copy over the master.dat, critter.dat, patch000.dat, and data folder to ports/fallout2"
rp_module_section="exp"
rp_module_flags=""


function depends_fallout2() {
   getDepends cmake libsdl2-dev xorg
}


function sources_fallout2() {
    git clone "https://github.com/alexbatalov/fallout2-ce.git" || return 1
}

function build_fallout2() {
    cd fallout2-ce || return 1
    mkdir -p build && cd build
    cmake .. || return 1
    cmake --build . || return 1
    md_ret_require="$md_build/fallout2-ce/build/fallout2-ce"
}

function install_fallout2() {
    md_ret_files=(fallout2-ce/build/fallout2-ce
        )
}

function configure_fallout2() {
    mkRomDir "ports/$md_id"
    ln -snf "$romdir/ports/$md_id" "$md_inst"


    moveConfigDir "$romdir/ports/$md_id/save" "$md_conf_root/$md_id/save"
    local scriptcfg="$md_inst/fallout2.cfg"
    local script="$md_inst/fallout2.sh"

    cat > "$scriptcfg" << _EOF_
#!/bin/bash
[sound]
music_path1=$romdir/ports/$md_id/sound/music/
music_path2=$romdir/ports/$md_id/sound/music/

[system]
critter_dat=$romdir/ports/$md_id/critter.dat
critter_patches=$romdir/ports/$md_id/data
master_dat=$romdir/ports/$md_id/master.dat
master_patches=$romdir/ports/$md_id/data
_EOF_

 cat > "$script" << _EOF_
#!/bin/bash
cd $md_inst && ./fallout2-ce
_EOF_

    chmod +x "$script"
    addPort "$md_id" "fallout2" "Fallout 2 Community Edition" "$md_inst/fallout2.sh"
}