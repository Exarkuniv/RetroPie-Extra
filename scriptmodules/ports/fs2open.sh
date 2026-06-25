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

rp_module_id="fs2open"
rp_module_desc="FreeSpace 2 Open - Origin Repository for FreeSpace 2"
rp_module_licence="https://raw.githubusercontent.com/scp-fs2open/fs2open.github.com/master/Unlicense.md"
rp_module_help="FreeSpace2 \nInstall files \n
root_fs2.vp\n
smarty_fs2.vp\n
sparky_fs2.vp\n
sparky_hi_fs2.vp\n
stu_fs2.vp\n
tango1_fs2.vp\n
tango2_fs2.vp\n
tango3_fs2.vp\n
warble_fs2.vp"
rp_module_repo="git https://github.com/Shivansps/fs2open.github.com fs2_open_3_7_2_arm"
rp_module_section="exp"
rp_module_flags="noinstclean"

function depends_fs2open() {
	getDepends libopenal-dev libjansson-dev libjpeg-dev liblua5.1-0-dev libogg-dev libpng-dev libsdl-image1.2-dev libsdl2-dev libtheora-dev libvorbis-dev automake libswscale-dev libavcodec-dev libavformat-dev xorg
}

function sources_fs2open() {
    gitPullOrClone
}

function build_fs2open() {
    ./autogen.sh --enable-debug
    sed -i -e 's/-mtune=generic -mfpmath=sse -msse -msse2/ /' ./mongoose/Makefile
    sed -i -e 's/-mtune=generic -mfpmath=sse -msse -msse2/ /' ./code/Makefile
    sed -i -e 's/-mtune=generic -mfpmath=sse -msse -msse2/ /' Makefile
	make -j4 || return 1
	#make -j$(nproc) > output.txt 2> errors.txt
    
	    md_ret_require=(
      )
}

function install_fs2open() {
	md_ret_files=(code/fs2_open_3.7.2_DEBUG
        )
}

function configure_fs2open() {
    mkRomDir "ports/$md_id"
    ln -sf "$romdir/ports/$md_id" "$md_inst"
    local script="$md_inst/$md_id.sh"
    #moveConfigDir "$romdir/ports/$md_id/savedata" "$md_conf_root/$md_id/savedata"
    addPort "$md_id" "fs2open" "FreeSpace 2 Open" "XINIT: $script %ROM%"

    #create buffer script for launch
    cat > "$script" << _EOF_
#!/bin/bash
pushd "$romdir/ports/$md_id"
"$md_inst/fs2_open_3.7.2_DEBUG" \$*
popd
_EOF_

    chmod +x "$script"
}