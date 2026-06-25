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

rp_module_id="revolt"
rp_module_desc="REvolt - a radio control car racing themed video game"
rp_module_licence="MIT https://raw.githubusercontent.com/jmcerrejon/PiKISS/master/LICENSE.md"
rp_module_section="exp"
rp_module_flags="rpi5 rpi4"

function depends_revolt() {
    getDepends libsdl2-image-2.0-0 libdumb1-dev libdumb1 libenet7 libunistring-dev zenity matchbox
}

function sources_revolt() {
     wget -O rvgl-data.deb https://github.com/Exarkuniv/Rpi-pikiss-binary/raw/Master/rvgl-data.deb || return 1
     wget -O rvgl.deb https://github.com/Exarkuniv/Rpi-pikiss-binary/raw/Master/rvgl.deb || return 1
}

function install_revolt() {
   	sudo dpkg -i rvgl-data.deb rvgl.deb

     if [ ! -f /usr/lib/libEGL.so ]; then
        sudo ln -s /usr/lib/arm-linux-gnueabihf/libEGL.so.1.1.0 /usr/lib/libEGL.so
    fi

    if [ ! -f /usr/lib/libGLESv2.so ]; then
        sudo ln -s /usr/lib/arm-linux-gnueabihf/libGLESv2.so.2.1.0 /usr/lib/libGLESv2.so
    fi

    if [ ! -f /usr/lib/libunistring.so.0 ]; then
        sudo ln -s /usr/lib/arm-linux-gnueabihf/libunistring.so.2.1.0 /usr/lib/libunistring.so.0
    fi

    if isPlatform "64bit"; then
        sudo ln -s /usr/lib/aarch64-linux-gnu/libunistring.so.2 /usr/lib/aarch64-linux-gnu/libunistring.so.0
    else
        sudo ln -s /usr/lib/arm-linux-gnueabihf/libunistring.so.2 /usr/lib/arm-linux-gnueabihf/libunistring.so.0
    fi

	md_ret_files=(
    )
}

function configure_revolt() {

    local script="$md_inst/$md_id.sh"
    cat > "$script" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
cd /usr/local/bin
rvgl_start
_EOF_

    chmod +x "$script"
    addPort "$md_id" "revolt" "REvolt" "XINIT:$script"
}