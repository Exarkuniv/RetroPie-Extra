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
platform="apple2"

rp_module_id="gsplus"
rp_module_desc="Apple IIgs emulator"
rp_module_help="ROM Extensions: .dsk .po .2mg\n\nCopy your Apple II games to $romdir/$platform"
rp_module_licence="GNU GPL"
rp_module_repo="git https://github.com/yoyodyne-research/GSplus  :_get_branch_gsplus"
rp_module_section="exp"
rp_module_flags=""

function _get_branch_gsplus() {
    local branch="retropie"
    if [[ x86 ]]; then
        branch="master"
    fi
    echo "$branch"
}

function depends_gsplus() {
    local depends=(cmake libsdl2-dev libsdl2-image-dev libfreetype6-dev libpcap0.8-dev re2c)

    getDepends "${depends[@]}"
}

function sources_gsplus() {
    local revision="$1"
    git clone "$md_repo_url" "$md_build" || return 1
}

function build_gsplus() {
    mkdir -p build
    cd build || return 1
    cmake .. -DCMAKE_INSTALL_PREFIX=/opt/retropie/emulators/$rp_module_id || return 1
    make -j 3 || return 1

    md_ret_require="$md_build/build/bin/GSplus"
}

function install_gsplus() {
    md_ret_files=(
        'build/bin/GSplus'
        'LICENSE.txt'
        'README.md'
    )
}

function configure_gsplus() {
    local def=0
    local launcher_name="+Start GSplus.sh"
    local config_dir="$romdir/$platform"

    mkRomDir "$platform"

    addEmulator "$def" "$md_id" "$platform" "bash $romdir/$platform/${launcher_name// /\\ } %ROM%"
    addSystem "apple2" ".po .dsk .nib .2mg .2gs"

    rm -f "$romdir/$platform/$launcher_name"
    [[ "$md_mode" == "remove" ]] && return

    cat > "$romdir/$platform/$launcher_name" << _EOF_
#!/usr/bin/env bash
$md_inst/gsplus.sh "\$1"
_EOF_
    
    chmod +x "$romdir/$platform/$launcher_name"
    chown -R __user:$__group "$romdir/$platform/$launcher_name"
}