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
# This game works on i386, arm64, and amd64 package architectures
#
rp_module_id="ut"
rp_module_desc="Unreal Tournament"
rp_module_licence="PROP https://github.com/OldUnreal/UnrealTournamentPatches/blob/master/LICENSE.md"
rp_module_help="Install game data by coping the contents of Maps/ Music/ Sounds/ System/ Textures/ into their respective directories in $romdir/ports/ut/"
rp_module_section="exp"
rp_module_repo="https://github.com/OldUnreal/UnrealTournamentPatches/"
rp_module_flags="!all x86 64bit"

function _get_branch_ut() {
    local version=$(curl https://api.github.com/repos/OldUnreal/UnrealTournamentPatches/releases/latest 2>&1 | grep -m 1 tag_name | cut -d\" -f4 | cut -dv -f2)
    echo -ne $version
}

function depends_ut() {
    local depends="libsdl2-2.0-0 libopenal1"
    getDepends "${depends[@]}"
}

function install_bin_ut() {
    local version="$(_get_branch_ut)"
    echo $version
    local arch="$(dpkg --print-architecture)"
    # For some reason, it failed when using "$rp_module_repo", this works perfectly.
    local base_url="https://github.com/OldUnreal/UnrealTournamentPatches"
    local dl_file="OldUnreal-UTPatch${version}-Linux-${arch}.tar.bz2"
    local dl_url="${base_url}/releases/download/v${version}/${dl_file}"

    # The download files use "x86" for the i386 architecture
    [[ "${arch}" == "i386" ]] && arch="x86"

    downloadAndExtract "$dl_url" "$md_inst" "--no-same-owner"
}

function __config_game_data() {
    local ut_game_dir=$1

    if [[ ! -d "$romdir/ports/ut/$ut_game_dir" ]]; then
        mkdir -p "$romdir/ports/ut/$ut_game_dir"
        chown -R "$__user":"$__group" "$romdir/ports/ut/$ut_game_dir"
    else
        chown "$__user":"$__group" "$romdir/ports/ut/$ut_game_dir"
    fi

    if [[ -d "$md_inst/$ut_game_dir" ]]; then
        cd "$md_inst/$ut_game_dir"
        for file in $(ls *); do

            # Note we move the files, but we want the permissions to remain owned by root.
            # This is to ensure that when installing game data we do not accidentally
            # replace any files provided by the installer
            mv "$md_inst/$ut_game_dir/$file" "$romdir/ports/ut/$ut_game_dir/$file"
        done

        rm -rf "$md_inst/$ut_game_dir"
    fi

    ln -snf "$romdir/ports/ut/$ut_game_dir" "$md_inst/$ut_game_dir"

}

function game_data_ut() {
    for dir in Help Maps Music Sounds System Textures Web; do
        __config_game_data "$dir"
    done

    local bonus_pack_4_url="https://unreal-archive-files-s3.s3.us-west-002.backblazeb2.com/patches-updates/Unreal%20Tournament/Bonus%20Packs/utbonuspack4-zip.zip"
    downloadAndExtract "$bonus_pack_4_url" "$romdir/ports/ut/"
}


function configure_ut() {
    addPort "$md_id" "ut" "Unreal Tournament" "$md_inst/System64/ut-bin"
    mkRomDir "ports/ut"

    if [[ "$md_mode" == "install" ]]; then
        game_data_ut
    fi
    moveConfigDir "$home/.utpg" "$md_conf_root/ut"
}
