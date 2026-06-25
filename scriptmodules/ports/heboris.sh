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

rp_module_id="heboris"
rp_module_desc="HeborisC7EX - Tetris The Grand Master Clone"
rp_module_help="To get mp3 audio working, you will need to change the music type from MIDI to MP3 in the Heboris options menu."
rp_module_repo="git https://github.com/zerojay/HeborisC7EX.git master"
rp_module_section="exp"
rp_module_flags="!mali"

function depends_heboris() {
    getDepends libsdl1.2-dev libsdl-mixer1.2-dev libsdl-image1.2-dev libgl1-mesa-dev xorg
}

function sources_heboris() {
    gitPullOrClone
}

function build_heboris() {
    make || return 1
    md_ret_require="$md_build/heboris"
}

function install_heboris() {
    md_ret_files=(
          'heboris'
          'res'
          'replay'
          'config'
          'heboris.ini'
          'heboris.txt'
    )
}

function configure_heboris() {
    local script="$md_inst/$md_id.sh"
    local conf

    for conf in config replay res; do
        chown -R $user:$user "$md_inst/$conf"
        moveConfigDir "$md_inst/$conf" "$md_conf_root/$md_id/$conf"
    done

    chown $user:$user "$md_inst/heboris.ini"
    moveConfigFile "$md_inst/heboris.ini" "$md_conf_root/$md_id/heboris.ini"

    #create buffer script for launch
    cat > "$script" << _EOF_
#!/bin/bash
pushd "$md_inst"
"./heboris" \$*
popd
_EOF_

    chmod +x "$script"
    addPort "$md_id" "heboris" "HeborisC7EX - Tetris The Grand Master Clone" "XINIT:$script"
}