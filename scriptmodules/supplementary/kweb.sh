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

rp_module_id="kweb"
rp_module_desc="kweb - Minimal Kiosk Web Browser"
rp_module_licence="GPL3 https://raw.githubusercontent.com/ekapujiw2002/kweb/master/COPYING"
rp_module_section="exp"
rp_module_flags="!mali !x86 !rpi5"

function depends_kweb() {
    getDepends evince vlc tint2 lxterminal uget xterm xorg
}

function sources_kweb() {
    wget -q http://steinerdatenbank.de/software/kweb-1.7.9.8.tar.gz || return 1
    tar -zxvf kweb-1.7.9.8.tar.gz || return 1
    rm -f kweb-1.7.9.8.tar.gz
    git clone git://github.com/rg3/youtube-dl youtube-dl || return 1
}

function install_kweb() {
    cd kweb-1.7.9.8 || return 1
    ./debinstall
    cd .. || return 1
    cp -R youtube-dl/ "$md_inst"
    ln -s "$md_inst/youtube-dl/youtube_dl/__main__.py" /usr/bin/youtube-dl
    chmod 755 /usr/bin/youtube-dl
}

function configure_kweb() {
    mkRomDir "ports"
    addPort "$md_id" "kweb" "kweb - Minimal Kiosk Web Browser" "XINIT: kweb"
    mv "$md_conf_root/$md_id" "$md_conf_root/ports" || return 1
}