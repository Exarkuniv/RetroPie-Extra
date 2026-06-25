#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="ikemen-go"
rp_module_desc="I.K.E.M.E.N GO - Clone of M.U.G.E.N to the Go programming language"
rp_module_licence="MIT https://raw.githubusercontent.com/ikemen-engine/Ikemen-GO/master/License.txt"
rp_module_help="Copy characters, stages, screenpacks, etc. to $romdir/ports/ikemen-go\n\nConfig files can be found at $configdir/ports/ikemen-go/save"
rp_module_repo="git https://github.com/SuperFromND/Ikemen-GO.git develop"
rp_module_section="exp"
rp_module_flags="!all rpi4 rpi3 rpi5"

function depends_ikemen-go() {
    getDepends golang golang-1.19 libgl1-mesa-dev xinit xorg libopenal-dev libgtk-3-dev libasound2-dev
}

function sources_ikemen-go() {
    gitPullOrClone
}

function build_ikemen-go() {
    sed -i 's#120#330#' "$md_build/src/render_gl.go"
    sed -i 's#150#330#' "$md_build/src/render_gl_gl32.go"

    make Ikemen_GO_LinuxARM || return 1
    #grabs default screenpack and content required for the game to run; note that the screenpack has a CC-BY-NC 3.0 license
    git clone https://github.com/ikemen-engine/Ikemen_GO-Elecbyte-Screenpack.git elecbyte || return 1
    md_ret_require="$md_build/bin/Ikemen_GO_LinuxARM"
}

function install_ikemen-go() {
    cp 'elecbyte/LICENCE.txt' 'ScreenpackLicense.txt'

    md_ret_files=(
        'bin/Ikemen_GO_LinuxARM'
        'License.txt'
        'ScreenpackLicense.txt'
        'data'
        'font'
        'external'
        'elecbyte/chars'
        'elecbyte/stages'
        'elecbyte/data'
        'elecbyte/font'
    )
}

function configure_ikemen-go() {
    mkRomDir "ports/ikemen-go"
    addPort "$md_id" "ikemen-go" "I.K.E.M.E.N GO" "XINIT:$md_inst/ikemen-go.sh"

    moveConfigDir "$md_inst/chars" "$romdir/ports/ikemen-go/chars"
    moveConfigDir "$md_inst/stages" "$romdir/ports/ikemen-go/stages"
    moveConfigDir "$md_inst/data" "$romdir/ports/ikemen-go/data"
    moveConfigDir "$md_inst/external" "$romdir/ports/ikemen-go/external"
    moveConfigDir "$md_inst/font" "$romdir/ports/ikemen-go/font"

    mkUserDir "$romdir/ports/ikemen-go/sound"
    mkUserDir "$configdir/ports/ikemen-go/save"
    ln -sf "$romdir/ports/ikemen-go/sound" "$md_inst/sound"
    ln -sf "$configdir/ports/ikemen-go/save" "$md_inst/save"

    cat >"$md_inst/ikemen-go.sh" << _EOF_
#!/bin/bash
export MESA_GL_VERSION_OVERRIDE=3.3
xset -dpms s off s noblank
xterm -g 1x1+0-0 -e 'cd $md_inst && ./Ikemen_GO_LinuxARM'
_EOF_
    chmod +x "$md_inst/ikemen-go.sh"
    chown -R $user:$user "$md_inst"
    chown -R $user:$user "$romdir/ports/ikemen-go"
}