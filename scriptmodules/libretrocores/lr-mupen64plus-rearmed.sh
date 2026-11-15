#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="lr-mupen64plus-rearmed"
rp_module_desc="N64 emu - Experimental Mupen64Plus-ReARMed restoration core with working frameskip for Glide64 and Rice"
rp_module_help="ROM Extensions: .z64 .n64 .v64\n\nCopy your N64 roms to $romdir/n64"
rp_module_licence="GPL2 https://raw.githubusercontent.com/Renetrox/Mupen64Plus-ReARMed/frameskip-modern/mupen64plus-core/LICENSES"
rp_module_repo="git https://github.com/Renetrox/Mupen64Plus-ReARMed.git frameskip-modern"
rp_module_section="exp x86=main"

function depends_lr-mupen64plus-rearmed() {
    local depends=(build-essential pkg-config zlib1g-dev)
    isPlatform "x11" && depends+=(libgl1-mesa-dev)
    isPlatform "videocore" && depends+=(libraspberrypi-dev)
    # EGL/GLES headers are required by the legacy Glide64, Rice and glN64 paths.
    isPlatform "gles" && depends+=(libegl1-mesa-dev libgles2-mesa-dev)
    getDepends "${depends[@]}"
}

# The core originally shipped as parallel_n64_libretro.so. A separate
# Mupen64Plus-ReARMed binary name is introduced by the renderer-fix branch.
# Support both during migration, without moving/overwriting ParaLLEl-N64.
function _binary_lr-mupen64plus-rearmed() {
    local dir="$1"
    if [[ -f "$dir/mupen64plus_rearmed_libretro.so" ]]; then
        echo "mupen64plus_rearmed_libretro.so"
    elif [[ -f "$dir/parallel_n64_libretro.so" ]]; then
        echo "parallel_n64_libretro.so"
    else
        return 1
    fi
}

# Only remove the legacy binary from this module's own installation
# directory and only after the renamed core has been installed successfully.
# RetroPie's stock lr-parallel-n64 lives in a different directory.
function _cleanup_legacy_binary_lr-mupen64plus-rearmed() {
    [[ "${md_mode:-}" == "install" ]] || return 0
    [[ -n "${md_inst:-}" && -n "${md_id:-}" ]] || return 0
    [[ "${md_inst%/}" == */"$md_id" ]] || return 0

    local modern="$md_inst/mupen64plus_rearmed_libretro.so"
    local legacy="$md_inst/parallel_n64_libretro.so"

    # Do nothing while the active source still builds the old filename.
    # The new core must exist and contain data before the old one is removed.
    [[ -s "$modern" && -f "$legacy" ]] || return 0

    rm -f -- "$legacy"
}

function sources_lr-mupen64plus-rearmed() {
    gitPullOrClone
}

function build_lr-mupen64plus-rearmed() {
    rpSwap on 1000
    local params=()
    if isPlatform "videocore" || isPlatform "odroid-c1"; then
        params+=(platform="$__platform")
    else
        # FORCE_GLES enables GLES on generic Debian/Armbian while letting
        # the core Makefile select the correct linker flags.
        isPlatform "gles" && params+=(FORCE_GLES=1)
        if isPlatform "arm"; then
            params+=(CPUFLAGS="-DNO_ASM -DARM -D__arm__ -DARM_ASM -D__NEON_OPT -DNOSSE -DARM_FIX")
            params+=(WITH_DYNAREC=arm)
            isPlatform "neon" && params+=(HAVE_NEON=1)
        elif isPlatform "aarch64"; then
            params+=(CPUFLAGS="-DARM_FIX")
            params+=(WITH_DYNAREC=aarch64)
        fi
    fi
    # The upstream branch can change output names between builds. Remove
    # both old artifacts so the installer never picks up a stale .so file.
    rm -f "$md_build/parallel_n64_libretro.so" "$md_build/mupen64plus_rearmed_libretro.so"

    # Always disable temporary swap, even when the compiler fails.
    local build_status=0
    make "${params[@]}" clean || build_status=$?
    if (( build_status == 0 )); then
        make "${params[@]}" || build_status=$?
    fi
    rpSwap off
    (( build_status == 0 )) || return "$build_status"

    local binary
    if ! binary="$(_binary_lr-mupen64plus-rearmed "$md_build")"; then
        md_ret_errors+=("Neither the ReARMed nor the legacy ParaLLEl-named binary was built")
        return 1
    fi
    md_ret_require="$md_build/$binary"
}

function install_lr-mupen64plus-rearmed() {
    local binary
    if ! binary="$(_binary_lr-mupen64plus-rearmed "$md_build")"; then
        md_ret_errors+=("Mupen64Plus-ReARMed binary missing: run Build first")
        return 1
    fi
    md_ret_files=(
        "$binary"
        'README.md'
        'mupen64plus-core/LICENSES'
    )
}

# Keep the renamed core's metadata in RetroPie's actual info directory.
# A sidecar beside the .so alone is not sufficient when libretro_info_path
# points at configs/all/retroarch/cores. Never replace ParaLLEl's metadata.
function _core_info_lr-mupen64plus-rearmed() {
    [[ "$md_mode" == "remove" ]] && return 0
    local name="mupen64plus_rearmed_libretro.info"
    local dir="$configdir/all/retroarch/cores"
    mkdir -p "$dir" || return 1
    cat > "$md_inst/$name" << '_INFO_'
display_name = "Nintendo - Nintendo 64 (Mupen64Plus-ReARMed)"
corename = "Mupen64Plus-ReARMed"
authors = "Mupen64Plus Team|Libretro|Renetrox"
supported_extensions = "n64|v64|z64|bin|u1|ndd|zip"
categories = "Emulator"
license = "GPLv2"
permissions = "dynarec_optional"
manufacturer = "Nintendo"
systemname = "Nintendo 64"
systemid = "nintendo_64"
database = "Nintendo - Nintendo 64|Nintendo - Nintendo 64DD"
supports_no_game = "false"
is_experimental = "true"
savestate = "true"
savestate_features = "basic"
core_options = "true"
_INFO_
    [[ $? -eq 0 ]] || return 1
    cp "$md_inst/$name" "$dir/$name" || return 1
    chown "$__user:$__group" "$dir/$name"
    # RetroArch watches this marker to rebuild an enabled core-info cache.
    touch "$dir/core_info.refresh"
    chown "$__user:$__group" "$dir/core_info.refresh"
}

function configure_lr-mupen64plus-rearmed() {
    mkRomDir "n64"
    defaultRAConfig "n64"

    # Register our own libretro core, never replace the stock ParaLLEl core.
    # On removal the binary may already be gone; addEmulator uses the module
    # ID to remove the entry, so its path is harmless in that case.
    local binary
    binary="$(_binary_lr-mupen64plus-rearmed "$md_inst")" || binary="mupen64plus_rearmed_libretro.so"
    addEmulator 0 "$md_id" "n64" "$md_inst/$binary"
    addSystem "n64"

    # Complete a successful upgrade without leaving the old .so alongside
    # the new one. Never touch lr-parallel-n64 or unrelated core directories.
    _cleanup_legacy_binary_lr-mupen64plus-rearmed

    # Uninstall must not rewrite global RetroArch options or shared BIOS files.
    [[ "$md_mode" == "remove" ]] && return

    _core_info_lr-mupen64plus-rearmed || return 1

    # Preserve the established light-renderer defaults (old option key names
    # are intentional; changing them would discard existing RetroArch setups).
    # Set core options
    setRetroArchCoreOption "parallel-n64-gfxplugin" "glide64"
    setRetroArchCoreOption "parallel-n64-gfxplugin-accuracy" "low"
    setRetroArchCoreOption "parallel-n64-screensize" "640x480"
    setRetroArchCoreOption "parallel-n64-frameskip" "disabled"
    setRetroArchCoreOption "parallel-n64-gles2n64-frameskip" "0"

    # Install the built-in ROM tuning table only on first setup. This is
    # a shared BIOS file and could contain valuable user edits.
    if [[ ! -e "$biosdir/gles2n64rom.conf" ]]; then
        cat > "$biosdir/gles2n64rom.conf" << '_EOF_'
#rom specific settings

rom name=SUPER MARIO 64
target FPS=25

rom name=Kirby64
target FPS=25

rom name=Banjo-Kazooie
framebuffer enable=1
update mode=4
target FPS=25

rom name=BANJO TOOIE
hack banjo tooie=1
ignore offscreen rendering=1
framebuffer enable=1
update mode=4

rom name=STARFOX64
window width=864
window height=520
target FPS=27

rom name=MARIOKART64
target FPS=27

rom name=THE LEGEND OF ZELDA
texture use IA=0
hack zelda=1
target FPS=17

rom name=ZELDA MAJORA'S MASK
texture use IA=0
hack zelda=1
rom name=F-ZERO X
window width=864
window height=520
target FPS=55
rom name=WAVE RACE 64
window width=864
window height=520
target FPS=27
rom name=SMASH BROTHERS
framebuffer enable=1
window width=864
window height=520
target FPS=27
rom name=1080 SNOWBOARDING
update mode=2
target FPS=27
rom name=PAPER MARIO
update mode=4
rom name=STAR WARS EP1 RACER
video force=1
video width=320
video height=480
rom name=JET FORCE GEMINI
framebuffer enable=1
update mode=2
ignore offscreen rendering=1
target FPS=27
rom name=RIDGE RACER 64
window width=864
window height=520
enable lighting=0
target FPS=27
rom name=Diddy Kong Racing
target FPS=27
rom name=MarioParty
update mode=4
rom name=MarioParty3
update mode=4
rom name=Beetle Adventure Rac
window width=864
window height=520
target FPS=27
rom name=EARTHWORM JIM 3D
rom name=LEGORacers
rom name=GOEMONS GREAT ADV
window width=864
window height=520
rom name=Buck Bumble
window width=864
window height=520
rom name=BOMBERMAN64U2
window width=864
window height=520
rom name=ROCKETROBOTONWHEELS
window width=864
window height=520
rom name=GOLDENEYE
force screen clear=1
framebuffer enable=1
window width=864
window height=520
target FPS=25
rom name=Mega Man 64
framebuffer enable=1
target FPS=25
_EOF_
        chown "$__user":"$__group" "$biosdir/gles2n64rom.conf"
    fi
}
