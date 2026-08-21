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
rp_module_help="Install game data by coping the contents of Maps/ Music/ Sounds/ Textures/ into their respective directories in $romdir/ports/ut/

Make sure you do not overwrite the Texture files that came with the patch, otherwise the in-game text will render incorrectly.

Post installation:
Open '$home/.utpg/UnrealTournament.ini' and go to the section:

[SDLDrv.SDLClient]
WindowedViewportX=1024
WindowedViewportY=768
WindowedColorBits=32
FullscreenViewportX=1920
FullscreenViewportY=1080
FullscreenColorBits=32

Ensure the Fullscreen* Variables match your resolution.

Note: Some display problems may be solved by removing '$md_inst/System64/libSDL2-2.0.so.0' and creating a symlink pointing to the system libSDL2-2.0.so.0, eg '/usr/lib/$(uname -m)-linux-gnu/libSDL2-2.0.so.0'  This is not a guarantee, but if you have trouble, start with this.
"
rp_module_section="exp"
rp_module_repo="https://github.com/OldUnreal/UnrealTournamentPatches/"
rp_module_flags="!all x86 64bit"

function _get_branch_ut() {
    local version=$(curl https://api.github.com/repos/OldUnreal/UnrealTournamentPatches/releases/latest 2>&1 | grep -m 1 tag_name | cut -d\" -f4 | cut -dv -f2)
    echo -ne $version
}

function depends_ut() {
    local depends=(libsdl2-2.0-0 libopenal1)

    isPlatform "rpi" && depends+=(xorg)
    getDepends "${depends[@]}"
}

function install_bin_ut() {
    local version="$(_get_branch_ut)"
	isPlatform "rpi5" && version="469d"
	local trimversion=$(echo $version | sed 's/-.*//g')
	
    local arch="$(dpkg --print-architecture)"
    # The download files use "x86" for the i386 architecture
    [[ "${arch}" == "i386" ]] && arch="x86"

    # For some reason, it failed when using "$rp_module_repo", this works perfectly.
    local base_url="https://github.com/OldUnreal/UnrealTournamentPatches"
    local dl_file="OldUnreal-UTPatch${trimversion}-Linux-${arch}.tar.bz2"
    local dl_url="${base_url}/releases/download/v${version}/${dl_file}"

    downloadAndExtract "$dl_url" "$md_inst" "--no-same-owner"
}

function __config_game_data() {
    local ut_game_dir=$1

    if [[ ! -d "$romdir/ports/ut/$ut_game_dir" ]]; then
        mkdir -p "$romdir/ports/ut/$ut_game_dir"
        chown -R $__user:$__group "$romdir/ports/ut/$ut_game_dir"
    else
        chown $__user:$__group "$romdir/ports/ut/$ut_game_dir"
    fi

    if [[ -d "$md_inst/$ut_game_dir" ]]; then
        cd "$md_inst/$ut_game_dir"
        for file in $(ls -d *); do

            echo "Moving $md_inst/$ut_game_dir/$file -> $romdir/ports/$ut_game_dir/$file"

            if [[ -d "$md_inst/$ut_game_dir/$file" ]]; then
                if [[ ! -d "$romdir/ports/ut/$ut_game_dir/$file" ]]; then
                    mv "$md_inst/$ut_game_dir/$file" "$romdir/ports/ut/$ut_game_dir/$file"
                else
                    rm -rf "$romdir/ports/ut/$ut_game_dir/$file"
                    mv "$md_inst/$ut_game_dir/$file" "$romdir/ports/ut/$ut_game_dir/$file"
                fi
            else
                mv "$md_inst/$ut_game_dir/$file" "$romdir/ports/ut/$ut_game_dir/$file"
            fi
        done

        rm -rf "$md_inst/$ut_game_dir"
    fi

    ln -snf "$romdir/ports/ut/$ut_game_dir" "$md_inst/$ut_game_dir"
}

function game_data_ut() {

    for dir in Help Maps Music Sounds System Textures Web; do

        # Ensure we aren't moving files that are already in place.
        # Eliminates 'mv: '$src/$file' and '$dst/$file' are the same file' errors.
        if [[ ! -h "$md_inst/$dir" ]]; then
            __config_game_data "$dir"
        fi
    done

    local bonus_pack_4_url="https://unreal-archive-files-s3.s3.us-west-002.backblazeb2.com/patches-updates/Unreal%20Tournament/Bonus%20Packs/utbonuspack4-zip.zip"
    downloadAndExtract "$bonus_pack_4_url" "$romdir/ports/ut/"

    chown -R $__user:$__group "$romdir/ports/ut"
    find  "$romdir/ports/ut" -type f -exec chmod 644 {} \;
    find  "$romdir/ports/ut" -type d -exec chmod 755 {} \;

}

function configure_ut() {
    if isPlatform "x86"; then
        addPort "$md_id" "ut" "Unreal Tournament" "$md_inst/System64/ut-bin"
    else
        local launch_prefix="XINIT-WM:"
        addPort "$md_id" "ut" "Unreal Tournament" "$launch_prefix$md_inst/SystemARM64/ut-bin"
    fi

    mkRomDir "ports/ut"

    if [[ "$md_mode" == "install" ]]; then
        game_data_ut
    fi

    moveConfigDir "$home/.utpg" "$md_conf_root/ut"

    # We only want to install this if it is not already installed.
    if [[ ! -f "$home/.utpg/System/UnrealTournament.ini" ]]; then
        mkdir "$home/.utpg/System/"
        cp "$md_data/UnrealTournament.ini" "$home/.utpg/System/UnrealTournament.ini"
        chown -R $__user:$__group "$home/.utpg/System"
        chmod 644 "$home/.utpg/System/UnrealTournament.ini"
    fi
}
