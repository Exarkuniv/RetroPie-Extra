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

rp_module_id="screenshot"
rp_module_desc="Universal Screenshot with Raspi2PNG"
rp_module_help="Usage: 'screenshot [destination]' over SSH. File saved to '$datadir/screenshots/(date)_(time).png' if no destination given.\n\nThis script is incompatible with the OpenGL driver."
rp_module_licence="MIT https://raw.githubusercontent.com/AndrewFromMelbourne/raspi2png/master/LICENSE"
rp_module_repo="git https://github.com/AndrewFromMelbourne/raspi2png.git master b3c5599"
rp_module_section="exp"

function depends_screenshot() {
    getDepends libpng-dev
}

function sources_screenshot() {
    gitPullOrClone
}

function build_screenshot() {
    make clean
    make || return 1
    md_ret_require="$md_build/raspi2png"
}

function install_screenshot() {
    md_ret_files=(
        'raspi2png'
        'LICENSE'
        'README.md'
    )
}

function script_screenshot() {
    # Create script to take screenshot over ssh
    cat > "$md_inst/$md_id.sh" << _EOF_
#!/bin/bash
dest="\$1"
[[ -z "\$dest" ]] && dest="$datadir/screenshots/\$(date +%Y%m%d_%H%M%S).png"
[[ -d "\$dest" ]] && dest="\$dest/\$(date +%Y%m%d_%H%M%S).png"
dest_fileext="\${dest##*.}"
[[ "\${dest_fileext,,}" != "png" ]] && dest="\$dest.png"
$md_inst/raspi2png -p "\$dest" && echo Saved "\$dest"
_EOF_

    chmod +x "$md_inst/$md_id.sh"
    ln -sf "$md_inst/$md_id.sh" /usr/local/bin/Screenshot
}

function configure_screenshot() {
    [[ -h /usr/local/bin/screenshot ]] && rm -f /usr/local/bin/screenshot #remove old link
    if [[ "$md_mode" == "remove" ]]; then
        [[ -h /usr/local/bin/Screenshot ]] && rm -f /usr/local/bin/Screenshot
        remove_share_samba "screenshots"
        restart_samba
        return
    fi
    mkUserDir "$datadir/screenshots"
    script_screenshot
    add_share_samba "screenshots" "$datadir/screenshots"
    restart_samba
}