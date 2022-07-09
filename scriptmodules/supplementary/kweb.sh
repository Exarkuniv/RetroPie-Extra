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
rp_module_flags="!mali !x86"

function depends_kweb() {
    getDepends evince vlc tint2 lxterminal uget git xterm xorg
}

function sources_kweb() {
    wget -O- -q http://steinerdatenbank.de/software/kweb-1.7.9.8.tar.gz | tar -zxv
    git clone git://github.com/rg3/youtube-dl youtube-dl
}

function install_kweb() {
    cd kweb-1.7.9.8
    ./debinstall
    cd ..
    cp -R youtube-dl/ "$md_inst"
    ln -s "$md_inst/youtube-dl/youtube_dl/__main__.py" /usr/bin/youtube-dl
    chmod 755 /usr/bin/youtube-dl
}

function configure_kweb() {
    mkRomDir "ports"
    addPort "$md_id" "kweb" "kweb - Minimal Kiosk Web Browser" "XINIT: kweb"
}
