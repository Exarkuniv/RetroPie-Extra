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

rp_module_id="openbor-v6510"
rp_module_desc="OpenBOR - Beat 'em Up Game Engine v6510-dev (official!)"
rp_module_help="Place your .pak files in $romdir/openbor."
rp_module_licence="BSD https://raw.githubusercontent.com/crcerror/OpenBOR-Raspberry/master/LICENSE"
rp_module_repo="git https://github.com/crcerror/OpenBOR-Raspberry.git master"
rp_module_section="exp"
rp_module_flags="!mali !x11 !rpi5"

function depends_openbor-v6510() {
    getDepends libsdl2-gfx-dev libvorbisidec-dev libvpx-dev libogg-dev libsdl2-gfx-1.0-0 libvorbisidec1
}

function sources_openbor-v6510() {
    gitPullOrClone
}

function build_openbor-v6510() {
    local params=()
    ! isPlatform "x11" && params+=(BUILD_PANDORA=1)
    make clean-all BUILD_PANDORA=1
    patch -p0 -i ./patch/latest_build.diff
    make "${params[@]}" || return 1
    md_ret_require="$md_build/OpenBOR"
    if isPlatform "rpi3"; then
	echo "Fetching libGL.so.1 for Raspberry Pi 3..."
	wget -q --show-progress "http://raw.githubusercontent.com/crcerror/OpenBOR-63xx-RetroPie-openbeta/master/libGL-binary/libGL-for-RPi-3/libGL.so.1" || return 1
    elif isPlatform "rpi4"; then
	echo "Fetching libGL.so.1 for Raspberry Pi 4..."
	wget -q --show-progress "http://raw.githubusercontent.com/crcerror/OpenBOR-63xx-RetroPie-openbeta/master/libGL-binary/libGL-for-RPi-4/libGL.so.1" || return 1
    elif isPlatform "rpi1"; then
	echo "Fetching libGL.so.1 for Raspberry Pi..."
	wget -q --show-progress "http://raw.githubusercontent.com/crcerror/OpenBOR-63xx-RetroPie-openbeta/master/libGL-binary/libGL-for-RPi-zero/libGL.so.1" || return 1
    elif isPlatform "rpi"; then
        echo "Fetching libGL.so.1 for Raspberry Pi..."
        wget -q --show-progress "http://raw.githubusercontent.com/crcerror/OpenBOR-63xx-RetroPie-openbeta/master/libGL-binary/libGL-for-RPi-zero/libGL.so.1" || return 1
    else
	md_ret_errors+=("This script is intended for Raspberry Pis only and will not work on other hardware.")
	return 1
    fi
}

function install_openbor-v6510() {
    md_ret_files=(
       'OpenBOR'
       'libGL.so.1'
    )
}

function configure_openbor-v6510() {
    mkRomDir "openbor"

    local dir
    for dir in ScreenShots Saves; do
        mkUserDir "$md_conf_root/$md_id/$dir"
        ln -snf "$md_conf_root/$md_id/$dir" "$md_inst/$dir"
    done

    ln -snf "$romdir/ports/$md_id" "$md_inst/Paks"
    ln -snf "/dev/shm" "$md_inst/Logs"
    addEmulator 0 "$md_id" "openbor" "$md_inst/OpenBOR %ROM%"

    addSystem "openbor" "OpenBOR" ".zip .ZIP .pak .PAK"
}