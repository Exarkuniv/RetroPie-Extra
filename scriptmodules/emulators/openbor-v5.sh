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


rp_module_id="openbor-v5"
rp_module_desc="OpenBOR - Beat 'em Up Game Engine -Pi5 edition"
rp_module_help="OpenBOR games need to be extracted to function properly. Place your pak files in $romdir/ports/openbor and then run $rootdir/ports/openbor/extract.sh. When the script is done, your original pak files will be found in $romdir/ports/openbor/originals and can be deleted."
rp_module_licence="BSD https://raw.githubusercontent.com/DCurrent/openbor/refs/heads/master/LICENSE"
rp_module_repo="git https://github.com/DCurrent/openbor.git master"
rp_module_section="exp"
rp_module_flags="sdl1 !mali !x11 !rpi4"

function depends_openbor-v5() {
    getDepends libsdl1.2-dev libsdl-gfx1.2-dev libogg-dev libvorbisidec-dev libvorbis-dev libpng-dev zlib1g-dev libvpx-dev
}

function sources_openbor-v5() {
    gitPullOrClone
}

function build_openbor-v5() {
    cmake -DBUILD_LINUX=ON USE_SDL=ON -DTARGET_ARCH="ARM64" -S . -B build.lin.arm64 && cmake --build build.lin.arm64 --config Release -- -j
    md_ret_require="$md_build/build.lin.arm64/OpenBOR"
}

function install_openbor-v5() {
    md_ret_files=(
       'build.lin.arm64/OpenBOR'
    )
}

function configure_openbor-v5() {
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
	
	chown $__user:$__group -R "$md_conf_root/$md_id/$dir"

	}
