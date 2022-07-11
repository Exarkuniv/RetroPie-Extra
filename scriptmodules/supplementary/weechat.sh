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

rp_module_id="weechat"
rp_module_desc="Weechat - Console IRC Client"
rp_module_licence="GPL3 https://raw.githubusercontent.com/weechat/weechat/master/COPYING"
rp_module_section="exp"
rp_module_flags="!mali !x86"

function depends_weechat() {
    	getDepends xdg-utils matchbox xorg
}

function install_bin_weechat() {
        aptInstall weechat
}

function configure_weechat() {
    mkRomDir "ports"
    moveConfigDir "$home/.weechat" "$md_conf_root/weechat"

    cat >"$romdir/ports/weechat.sh" << _EOF_
#!/bin/bash
xset -dpms s off s noblank
matchbox-window-manager -use_titlebar no &
xterm -rv /usr/bin/weechat
_EOF_
    chmod +x "$romdir/ports/weechat.sh"

    addPort "$md_id" "weechat" "Weechat - Console IRC Client" "xinit $romdir/ports/weechat.sh"
}
