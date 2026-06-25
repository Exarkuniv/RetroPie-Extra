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

rp_module_id="box64"
rp_module_desc="Box64 - Linux Userspace x86_64 Emulator"
rp_module_licence="MIT https://github.com/ptitSeb/box64/blob/main/LICENSE"
rp_module_repo="git https://github.com/ptitSeb/box64.git main"
rp_module_section="exp"
rp_module_flags="!all rpi5"

function depends_box64() {

    if ! rp_isInstalled "mesa" ; then
        md_ret_errors+=("Sorry, you need to install the Mesa scriptmodule")
        return 1
    fi

    local depends=(
        git cmake build-essential python3 
        gcc-arm-linux-gnueabihf libncurses6:armhf 
        libc6:armhf
    )
    getDepends "${depends[@]}"
}

function sources_box64() {
    gitPullOrClone "$md_build" 
}

function build_box64() {
    cd "$md_build" || return 1
    mkdir -p build
    cd build || return 1
    cmake .. -D RPI5ARM64=1 -DCMAKE_BUILD_TYPE=RelWithDebInfo || return 1
    make -j$(nproc) || return 1
    md_ret_require="$md_build/build/box64"
}

function install_box64() {
    cd "$md_build/build" || return 1
    make install || return 1
    systemctl restart systemd-binfmt
    dpkg --add-architecture amd64
    apt update
    apt install -y libc6:amd64 libstdc++6:amd64
    apt install -y libgl1:amd64 libasound2:amd64 libpulse0:amd64
}

function configure_box64() {
    addPort "$md_id" "box64" "Box64 x86_64 Emulator" "box64"
    mkUserDir "$home/.config/box64"
    # Add to PATH if not already present
    if ! grep -q "/usr/local/bin" "$home/.bashrc"; then
        echo 'export PATH=$PATH:/usr/local/bin' >> "$home/.bashrc"
    fi
}

function remove_box64() {
    cd "$md_build/build" || return 1
    make uninstall || return 1
    rm -rf "$home/.config/box64"
    # Remove from PATH
    sed -i '/\/usr\/local\/bin/d' "$home/.bashrc"
}