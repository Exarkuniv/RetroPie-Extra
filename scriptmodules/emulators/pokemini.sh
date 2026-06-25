
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

rp_module_id="pokemini"
rp_module_desc="Pokemini - Pokemon Mini emulator"
rp_module_help="ROM Extensions: .min .MIN\n\nYou will need to add the ROM extensions above to your /etc/emulationstation/es_systems.cfg file manually."
rp_module_licence="GPL https://sourceforge.net/p/pokemini/code/ci/master/tree/LICENSE"
rp_module_repo="git https://git.code.sf.net/p/pokemini/code master"
rp_module_section="exp"
rp_module_flags="!mali !kms"

function depends_pokemini() {
    getDepends zlib1g zlib1g-dev libsdl2-dev
}

function sources_pokemini() {
    gitPullOrClone
}

function build_pokemini() {
    cd platform/sdl2 || return 1
    make || return 1
    md_ret_require="$md_build/platform/sdl2/PokeMini"
}

function install_pokemini() {
    md_ret_files=(
        'platform/sdl2/PokeMini'
    )

}

function configure_pokemini() {
    mkRomDir "pokemini"

    addEmulator 1 "pokemini" "pokemini" "$md_inst/PokeMini -fullscreen %ROM%"
    addSystem "pokemini"
}