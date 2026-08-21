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
rp_module_id="mcpelauncher"
rp_module_desc="mcpelauncher - Unofficial launcher for Minecraft: Bedrock Edition (Android) on Linux"
rp_module_licence="GPL3 https://raw.githubusercontent.com/minecraft-linux/mcpelauncher-manifest/ng/LICENSE"
rp_module_help="Minecraft is NOT free. You must provide your own copy of the game.\n\nExtract the contents of a Minecraft: Bedrock Edition Android APK into:\n\n$romdir/ports/mcpelauncher/game\n\nThe folder must contain 'AndroidManifest.xml', the 'assets' folder and the 'lib' folder from the APK. Xbox Live login opens a browser window; a display/keyboard is required for the initial sign-in."
rp_module_repo="git https://github.com/minecraft-linux/mcpelauncher-manifest.git ng"
rp_module_section="exp"
rp_module_flags="!all rpi4 rpi5 x86_64"

function depends_mcpelauncher() {
    getDepends cmake pkg-config libssl-dev libpng-dev libx11-dev libxi-dev libudev-dev libevdev-dev libegl1-mesa-dev libgl1-mesa-dev libgles2-mesa-dev libuv1-dev libzip-dev libprotobuf-dev protobuf-compiler libcurl4-openssl-dev libasound2-dev libpulse-dev zlib1g-dev libatomic1 clang
}

function sources_mcpelauncher() {
    gitPullOrClone
}

function build_mcpelauncher() {
    mkdir -p "$md_build/build"
    cd "$md_build/build"
    cmake \
        -DCMAKE_BUILD_TYPE="Release" \
        -DCMAKE_INSTALL_PREFIX="$md_inst" \
        -DCMAKE_C_COMPILER=clang \
        -DCMAKE_CXX_COMPILER=clang++ \
        -DCMAKE_CXX_STANDARD=17 \
        -DCMAKE_EXE_LINKER_FLAGS="-latomic" \
        -DCMAKE_SHARED_LINKER_FLAGS="-latomic" \
        -DBUILD_UI=OFF \
        -DUSE_OWN_CURL=OFF \
        -DENABLE_DEV_PATHS=OFF \
        ..
    make -j"$(nproc)"
    md_ret_require="$md_build/build/mcpelauncher-client/mcpelauncher-client"
}

function install_mcpelauncher() {
    cd "$md_build/build"
    make install
}

function configure_mcpelauncher() {
    local game_dir="$romdir/ports/mcpelauncher/game"
    if [[ "$md_mode" == "install" ]]; then
        mkRomDir "ports/mcpelauncher"
        mkRomDir "ports/mcpelauncher/game"
        cat > "$md_inst/mcpelauncher.sh" << _EOF_
#!/usr/bin/env bash
xinit "$md_inst/bin/mcpelauncher-client" \
    -dg "$game_dir" \
    -dd "$home/.local/share/mcpelauncher" \
    -dc "$home/.cache/mcpelauncher" \
    -- :1 vt\$(fgconsole)
_EOF_
        chmod +x "$md_inst/mcpelauncher.sh"
        chown -R "$user:$user" "$romdir/ports/mcpelauncher"
    fi
    moveConfigDir "$home/.local/share/mcpelauncher" "$md_conf_root/mcpelauncher"
    addPort "$md_id" "mcpelauncher" "Minecraft: Bedrock Edition" "$md_inst/mcpelauncher.sh"
}
