#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="xump"
rp_module_desc="Xump - The Final Run"
rp_module_help="Xump - The Final Run is a simple multi-platform puzzler by Retroguru. Help Holger to clean up deserted space fields. As this is a very dangerous task for a human being a headbot named Xump will be the one who has to suffer."
rp_module_licence="Retroguru http://www.retroguru.com/legal/"
rp_module_section="opt"
rp_module_flags="!x86 !mali"

function depends_xump() {
    getDepends libsdl1.2-dev libsdl-mixer1.2 libraspberrypi-dev xorg
}

function install_bin_xump() {
    downloadAndExtract "http://www.retroguru.com/xump/xump-v.latest-raspberrypi.zip" "$md_inst"
    patchVendorGraphics "$md_inst/xump_rpi"
}

function configure_xump() {
    moveConfigDir "$home/.config/xump" "$md_conf_root/xump"

    addPort "$md_id" "xump" "Xump - The Final Run by Retroguru" "XINIT: pushd $md_inst; $md_inst/xump_rpi; popd"

    chmod +x "$md_inst/xump_rpi"
    chmod a+w "$md_inst"
}