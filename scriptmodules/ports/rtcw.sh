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

rp_module_id="rtcw"
rp_module_desc="RTCW - IORTCW source port of Return to Castle Wolfenstein."
rp_module_licence="GPL3 https://raw.githubusercontent.com/iortcw/iortcw/master/SP/COPYING.txt"
rp_module_help="IORTCW requires the pak files of the full game to play. Add all your singleplayer and multiplayer pak files (mp_bin.pk3, mp_pak0.pk3, mp_pak1.pk3, mp_pak2.pk3, mp_pak3.pk3, mp_pak4.pk3, mp_pak5.pk3, mp_pakmaps0.pk3, mp_pakmaps1.pk3, mp_pakmaps2.pk3, mp_pakmaps3.pk3, mp_pakmaps4.pk3, mp_pakmaps5.pk3, mp_pakmaps6.pk3, pak0.pk3, sp_pak1.pk3, sp_pak2.pk3, sp_pak3.pk3 and sp_pak4.pk3) from your RTCW installation to $romdir/ports/rtcw."
rp_module_repo="git https://github.com/iortcw/iortcw.git"
rp_module_section="exp"
rp_module_flags=""

function _arch_rtcw() {
    # exact parsing from Makefile
    echo "$(uname -m | sed -e 's/i.86/x86/' | sed -e 's/^arm.*/arm/')"
}

function depends_rtcw() {
    local depends=(cmake libsdl2-dev libsdl2-net-dev libsdl2-mixer-dev libsdl2-image-dev timidity freepats)

    if compareVersions "$__os_debian_ver" lt 10; then
        depends+=(libgles1-mesa-dev)
    fi

    getDepends "${depends[@]}"
}

function sources_rtcw() {
    gitPullOrClone
}

function build_rtcw() {
    cd "$md_build/SP"

    # Use Case switch to allow future expansion to other potential platforms
    if isPlatform "rpi"; then
        USE_CODEC_VORBIS=0\
                        USE_CODEC_OPUS=0\
                        USE_CURL=0\
                        USE_CURL_DLOPEN=0\
                        USE_OPENAL=1\
                        USE_OPENAL_DLOPEN=1\
                        USE_RENDERER_DLOPEN=0\
                        USE_VOIP=0\
                        USE_LOCAL_HEADERS=1\
                        USE_INTERNAL_JPEG=1\
                        USE_INTERNAL_OPUS=1\
                        USE_INTERNAL_ZLIB=1\
                        USE_OPENGLES=1\
                        USE_BLOOM=0\
                        USE_MUMBLE=0\
                        BUILD_GAME_SO=1\
                        BUILD_RENDERER_REND2=0\
                        ARCH=arm\
                        PLATFORM=linux\
                        COMPILE_ARCH=arm\
                        COMPILE_PLATFORM=linux\
                        make
    else
        make
    fi

    cd "$md_build/MP"

    if isPlatform "rpi"; then
        USE_CODEC_VORBIS=0 \
                        USE_CODEC_OPUS=0\
                        USE_CURL=1\
                        USE_CURL_DLOPEN=1\
                        USE_OPENAL=1\
                        USE_OPENAL_DLOPEN=1\
                        USE_RENDERER_DLOPEN=0\
                        USE_VOIP=0\
                        USE_LOCAL_HEADERS=1\
                        USE_INTERNAL_JPEG=1\
                        USE_INTERNAL_OPUS=1\
                        USE_INTERNAL_ZLIB=1\
                        USE_OPENGLES=1\
                        USE_BLOOM=0\
                        USE_MUMBLE=0\
                        BUILD_GAME_SO=1\
                        BUILD_RENDERER_REND2=0\
                        ARCH=arm\
                        PLATFORM=linux\
                        COMPILE_ARCH=arm\
                        COMPILE_PLATFORM=linux\
                        make
    else
        make
    fi

    md_ret_require="$md_build/SP"
    md_ret_require="$md_build/MP"
}

function install_rtcw() {
    md_ret_files=(
        "SP/build/release-linux-$(_arch_rtcw)/iowolfsp.$(_arch_rtcw)"
        "SP/build/release-linux-$(_arch_rtcw)/main/cgame.sp.$(_arch_rtcw).so"
        "SP/build/release-linux-$(_arch_rtcw)/main/qagame.sp.$(_arch_rtcw).so"
        "SP/build/release-linux-$(_arch_rtcw)/main/ui.sp.$(_arch_rtcw).so"
        "MP/build/release-linux-$(_arch_rtcw)/iowolfded.$(_arch_rtcw)"
        "MP/build/release-linux-$(_arch_rtcw)/iowolfmp.$(_arch_rtcw)"
        "MP/build/release-linux-$(_arch_rtcw)/main/cgame.mp.$(_arch_rtcw).so"
        "MP/build/release-linux-$(_arch_rtcw)/main/qagame.mp.$(_arch_rtcw).so"
        "MP/build/release-linux-$(_arch_rtcw)/main/ui.mp.$(_arch_rtcw).so"
        "MP/build/release-linux-$(_arch_rtcw)/main/vm/"
    )

    if isPlatform "x86"; then
        md_ret_files+=(
            "SP/build/release-linux-$(_arch_rtcw)/renderer_sp_opengl1_$(_arch_rtcw).so"
            "SP/build/release-linux-$(_arch_rtcw)/renderer_sp_rend2_$(_arch_rtcw).so"
            "MP/build/release-linux-$(_arch_rtcw)/renderer_mp_opengl1_$(_arch_rtcw).so"
            "MP/build/release-linux-$(_arch_rtcw)/renderer_mp_rend2_$(_arch_rtcw).so"
        )
    fi
}

function game_data_rtcw() {
    mkdir "$home/.wolf/main"
    mv /opt/retropie/ports/rtcw/[^render*]*.so /opt/retropie/ports/rtcw/main
    mv /opt/retropie/ports/rtcw/vm /opt/retropie/ports/rtcw/main
    cp "$md_data/wolfconfig.cfg" "$home/.wolf/main"
    cp "$md_data/wolfconfig_mp.cfg" "$home/.wolf/main"
    chown -R $user:$user "$romdir/ports/rtcw"
    chown -R $user:$user "$md_conf_root/rtcw-sp"
}

function configure_rtcw() {
    rm -R "$home/RetroPie/roms/ports/rtcw/vm"

    addPort "rtcw-sp" "rtcw-sp" "Return to Castle Wolfenstein (SP)" "$md_inst/iowolfsp.$(_arch_rtcw)"
    addPort "rtcw-mp" "rtcw-mp" "Return to Castle Wolfenstein (MP)" "$md_inst/iowolfmp.$(_arch_rtcw)"

    mkRomDir "ports/rtcw"

    moveConfigDir "$home/.wolf" "$md_conf_root/rtcw-sp"
    moveConfigDir "$md_inst/main" "$romdir/ports/rtcw"

    [[ "$md_mode" == "install" ]] && game_data_rtcw
}
function remove_rtcw() {
    rm "$home/.wolf"
    rm "$home/RetroPie/roms/ports/rtcw/*.so"
    rm -R "$home/RetroPie/roms/ports/rtcw/vm"
}
