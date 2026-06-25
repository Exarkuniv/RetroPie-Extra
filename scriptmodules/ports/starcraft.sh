#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="starcraft"
rp_module_desc="Starcraft"
rp_module_help="Thanks to PI Labs, Notaz, and Blizzard for release free this game in 2017"
rp_module_licence="MIT https://raw.githubusercontent.com/jmcerrejon/PiKISS/master/LICENSE.md"
rp_module_repo="file https://archive.org/download/starcraft-rpi.7z/starcraft-rpi.7z"
rp_module_section="exp"
rp_module_flags="!armv6 !all rpi4 rpi3"

function depends_starcraft() {
    getDepends xorg wine p7zip-full matchbox
}

function sources_starcraft() {
    wget "$md_repo_url" || return 1
    7z x "starcraft-rpi.7z" 
    chown -R pi:pi "$md_build/$md_id"
    rm "starcraft-rpi.7z"
    mv -f "$md_build/starcraft/libscr_sa_arm.exe.so" "$md_build" || return 1
    chmod 755 "$md_build/libscr_sa_arm.exe.so"

}

function install_starcraft() {
    md_ret_files=('libscr_sa_arm.exe.so'
)
}

function configure_starcraft() {
    mkRomDir "ports/$md_id"
    mv -f "$md_build/starcraft" "$romdir/ports" || return 1
    rm -f "$romdir/ports/starcraft/starcraft.sh"
    ln -snf "$romdir/ports/starcraft" "$md_inst"
    ln -sf "/opt/retropie/ports/starcraft/libscr_sa_arm.exe.so" "/home/pi/RetroPie/roms/ports/starcraft/libscr_sa_arm.exe.so"   
     moveConfigDir "$romdir/ports/$md_id/save" "$md_conf_root/starcraft/save"

    local script="$md_inst/starcraft.sh"
    cat > "$script" << _EOF_
#!/bin/bash
LD_LIBRARY_PATH=. setarch linux32 -L wine $romdir/ports/$md_id/libscr_sa_arm.exe.so
_EOF_

    local script="$md_inst/starcraftr.sh"
    cat > "$script" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
pushd "$md_inst/$md_id"
cd $md_inst && ./starcraft.sh
_EOF_

    chmod +x "$md_inst/starcraftr.sh"
    chmod +x "$md_inst/starcraft.sh"
    chmod 755 "$romdir/ports/starcraft"
    addPort "$md_id" "starcraft" "Starcraft" "XINIT: $md_inst/starcraftr.sh"
}