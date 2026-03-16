#!/usr/bin/env bash
 
# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
 
rp_module_id="xemu"
rp_module_desc="** Xbox Emulator **\nYou require 3 further files.\nhttps://xemu.app/docs/required-files/\nBootrom   : mcpx_1.0.bin\nFlashrom  : complex.bin\nHHD Image : xbox_hdd.qcow2\nPlace files in /home/pi/.local/share/xemu/xemu\n"
rp_module_help="ROM Extensions: .xiso.iso \nConvert your Xbox .iso files to .xiso files\nhttps://xemu.app/docs/disc-images/\nuse the PACK function on xdvdfs\nCopy your Xbox games to $romdir/xbox\nRecommend to use ES Zoid theme"
rp_module_licence="https://github.com/xemu-project/xemu/blob/master/LICENSE"
rp_module_repo="git https://github.com/xemu-project/xemu.git v0.8.134"
rp_module_section="exp"
rp_module_flags="!all 64bit pi5"
 
function depends_xemu() {
    getDepends libsdl2-dev libcurl4-gnutls-dev libepoxy-dev libpixman-1-dev libgtk-3-dev libssl-dev libsamplerate0-dev libpcap-dev ninja-build python3-pip python3-tomli python3-yaml libslirp-dev libvulkan-dev libpipewire-0.3-dev mesa-utils xorg matchbox-window-manager
    aptRemove "meson"
    downloadAndExtract "https://github.com/mesonbuild/meson/releases/download/1.10.1/meson-1.10.1.tar.gz" "/home/pi/RetroPie-Setup/tmp/meson"
    sudo ln -s /home/pi/RetroPie-Setup/tmp/meson/meson-1.10.1/meson.py /usr/bin/meson
   
}
 
function sources_xemu() {
    gitPullOrClone
}
 
function build_xemu() {
    ./build.sh || error "Build failed"
 
    if [[ ! -f "$md_build/dist/xemu" ]]; then
        error "xemu binary not found in dist/, build might have failed"
    fi
 
    md_ret_require="$md_build/dist/xemu"
}
 
function install_xemu() {
    md_ret_files=(
        'dist/xemu'
        'dist/LICENSE.txt'
    )
}
 
function configure_xemu() {
    mkRomDir "xbox"

    addEmulator 0 "$md_id" "xbox" "XINIT-WM:LIBGL_ALWAYS_SOFTWARE=true $md_inst/xemu -dvd_path %ROM%"
    addEmulator 0 "$md_id-gui" "xbox" "XINIT-WM:LIBGL_ALWAYS_SOFTWARE=true $md_inst/xemu"
    addSystem "xbox" "Xbox" ".iso"

    [[ "$md_mode" == "remove" ]] && return

    mkUserDir "/home/pi/.local/share/xemu/xemu"
    if [[ ! -f "/home/pi/.local/share/xemu/xemu/xemu.toml" ]]; then
        cat >"/home/pi/.local/share/xemu/xemu/xemu.toml" <<_EOF_
[general]
show_welcome = false
last_viewed_menu_index = 7

[input.bindings]
port1_driver = 'usb-xbox-gamepad'
port1 = 'keyboard'

[display.window]
startup_size = '640x480'
last_width = 1912
last_height = 1056

[display.ui]
use_animations = false
fit = 'center'

[display.debug.video]
advanced_tree_state = true

[sys.files]
bootrom_path = '/home/pi/.local/share/xemu/xemu/mcpx_1.0.bin'
flashrom_path = '/home/pi/.local/share/xemu/xemu/complex.bin'
eeprom_path = '/home/pi/.local/share/xemu/xemu/eeprom.bin'
hdd_path = '/home/pi/.local/share/xemu/xemu/xbox_hdd.qcow2'
_EOF_
    fi

    # Ensure emulator path exists
    mkdir -p "/opt/retropie/emulators/xemu"
 
    if [[ "$md_mode" == "install" ]]; then
        mkUserDir "$md_conf_root/xbox"
        mkUserDir "$md_conf_root/xbox/$md_id"
   fi
 
}
