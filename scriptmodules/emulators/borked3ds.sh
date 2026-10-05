#!/usr/bin/env bash

# This file is part of RetroPie-Extra, a supplement to RetroPie.
# For more information, please visit:
#
# https://github.com/RetroPie/RetroPie-Setup
# https://github.com/Exarkuniv/RetroPie-Extra
# https://github.com/FollyMaddy/RetroPie-Share
#
# See the LICENSE file distributed with this source and at
# https://raw.githubusercontent.com/Exarkuniv/RetroPie-Extra/master/LICENSE
#

rp_module_id="borked3ds"
rp_module_desc="Borked3DS – Nintendo 3DS Emulator (Pi5 / x86_64: DTEAM-1 Vulkan / Pi4: gvx64 OpenGL-GLES)"
rp_module_help="ROM Extensions: .3ds .cia .cxi"
rp_module_licence="GPL3 https://github.com/DTEAM-1/Borked3DS-rpi"
rp_module_repo=""
rp_module_section="exp"
rp_module_flags="!all rpi4 rpi5 x86 !32bit"

################################
# TARGET DETECTION (v398, x86_64 added in v400)
#
# One scriptmodule, two forks, three targets:
#   - Raspberry Pi 5 (and Pi 500 / CM5): DTEAM-1/Borked3DS-rpi, Vulkan V3DV by default
#     (code defaults, settings.h), built with Clang.
#   - Raspberry Pi 4 (and Pi 400 / CM4): gvx64/Borked3DS-rpi, OpenGL with GLES, built
#     exactly like RetroPie-Extra (system compiler, RetroPie CFLAGS,
#     DYNARMIC_USE_BUNDLED_EXTERNALS=OFF), the build gvx64 tests on his Pi4s.
#   - x86_64 PC (v400): DTEAM-1/Borked3DS-rpi with the Pi5 runtime defaults (Vulkan, same
#     BORKED3DS_V3DV_* settings, see V389ApplyV3dvDefaults in main.cpp), built with the
#     system compiler, no ARM flags, bundled libraries except Qt and SDL2.
# Supported OS: Raspberry Pi OS / Debian Bookworm (12) and Trixie (13), 64-bit only.
# x86_64: any Debian/Ubuntu RetroPie install; needs GCC >= 13 or Clang >= 16 (C++23).
#
# Overrides (tests only), passed through sudo -E:
#   BORKED3DS_TARGET=pi4|pi5|x86_64   force the target instead of detecting it
#   BORKED3DS_REPO=<git url>   force the repository (default chosen by target)
#   BORKED3DS_LOCAL_SRC=<dir>  build a local tree (see sources_borked3ds)
################################

function _target_borked3ds() {
    case "${BORKED3DS_TARGET:-}" in
        pi4|pi5|x86_64) echo "$BORKED3DS_TARGET"; return ;;
    esac
    # PC: no device tree, the CPU architecture is enough.
    if [ "$(uname -m)" = "x86_64" ]; then echo "x86_64"; return; fi
    # Device tree first: it names the board exactly, whatever the RetroPie-Setup version.
    local model
    model="$( { tr -d '\0' < /proc/device-tree/model; } 2>/dev/null )"
    case "$model" in
        *"Raspberry Pi 5"*|*"Compute Module 5"*) echo "pi5"; return ;;
        *"Raspberry Pi 4"*|*"Compute Module 4"*) echo "pi4"; return ;;
    esac
    # Fallback: RetroPie-Setup platform detection.
    if isPlatform "rpi5"; then echo "pi5"; return; fi
    if isPlatform "rpi4"; then echo "pi4"; return; fi
    echo "inconnu"
}

function _codename_borked3ds() {
    local VERSION_CODENAME=""
    [ -r /etc/os-release ] && . /etc/os-release
    echo "${VERSION_CODENAME:-inconnu}"
}

function _repo_borked3ds() {
    if [ -n "${BORKED3DS_REPO:-}" ]; then
        echo "$BORKED3DS_REPO"
    elif [ "$(_target_borked3ds)" = "pi4" ]; then
        echo "https://github.com/gvx64/Borked3DS-rpi"
    else
        echo "https://github.com/DTEAM-1/Borked3DS-rpi"
    fi
}

# Clang used for the Pi5 build. Trixie: system clang (19), unchanged from earlier builds.
# Bookworm: system clang is 14, too old for this C++23 tree with libstdc++ 12; clang-16 is
# in Bookworm's own repository and is installed by depends_borked3ds().
function _clang_borked3ds() {
    local v
    if [ "$(_codename_borked3ds)" = "bookworm" ]; then
        for v in 19 18 17 16 15; do
            if command -v "clang++-$v" >/dev/null 2>&1; then
                echo "$v"
                return
            fi
        done
    fi
    echo ""
}

# CMake: the tree requires 3.26 or newer. Trixie ships 3.31; Bookworm ships 3.25, so a
# Kitware binary is downloaded once into RetroPie-Setup's tmp directory (nothing is
# installed system-wide, apt sources are not touched).
BORKED3DS_CMAKE_VERSION="3.31.6"

function _cmake_borked3ds() {
    local sys_ver
    sys_ver="$(cmake --version 2>/dev/null | head -1 | awk '{print $3}')"
    if [ -n "$sys_ver" ] && dpkg --compare-versions "$sys_ver" ge 3.26; then
        echo "cmake"
    else
        echo "${__tmpdir:-/tmp}/borked3ds-cmake-$BORKED3DS_CMAKE_VERSION/bin/cmake"
    fi
}

function depends_borked3ds() {
    local target codename
    target="$(_target_borked3ds)"
    codename="$(_codename_borked3ds)"

    echo "=========================================================="
    echo "CIBLE : $target | OS : $codename | arch : $(uname -m)"
    echo "DEPOT : $(_repo_borked3ds)"
    echo "=========================================================="

    if [ "$target" = "inconnu" ]; then
        md_ret_errors+=("Machine non reconnue (ni Pi4, ni Pi5, ni x86_64). Forcer avec BORKED3DS_TARGET=pi4, pi5 ou x86_64.")
        return 1
    fi
    # Each target is built for its own 64-bit architecture only (no cross-compilation).
    local want_arch="aarch64"
    [ "$target" = "x86_64" ] && want_arch="x86_64"
    if [ "$(uname -m)" != "$want_arch" ]; then
        md_ret_errors+=("Cible $target : systeme 64 bits $want_arch exige ; detecte : $(uname -m).")
        return 1
    fi
    if [ "$target" != "x86_64" ]; then
        case "$codename" in
            bookworm|trixie) ;;
            *) echo "ATTENTION : OS '$codename' non teste (Bookworm et Trixie seulement)." ;;
        esac
    fi

    local depends=(
        cmake ninja-build build-essential git pkg-config python3 binutils
        clang
        libx11-dev libxrandr-dev libxi-dev libxext-dev libxcb-cursor-dev
        libgl1-mesa-dev libglu1-mesa-dev
        libsdl2-dev libevdev-dev
        libpulse-dev libasound2-dev
        qt6-base-dev qt6-base-private-dev qt6-base-dev-tools
        qt6-tools-dev qt6-tools-dev-tools qt6-l10n-tools qt6-multimedia-dev
        libboost-all-dev libcrypto++-dev
        robin-map-dev
    )
    # robin-map-dev: dynarmic uses the system tsl::robin_map unless
    # DYNARMIC_USE_BUNDLED_EXTERNALS=ON (externals/CMakeLists.txt). It was missing from the
    # list: builds only worked on machines that already had it.

    if [ "$target" = "pi4" ]; then
        # Extra packages of the RetroPie-Extra module used by gvx64.
        depends+=(libssl-dev libfdk-aac-dev)
    elif [ "$target" = "x86_64" ]; then
        # x86_64: Mesa Vulkan drivers (Intel, AMD); an NVIDIA card uses its own driver.
        depends+=(mesa-vulkan-drivers)
    else
        # Pi5: Vulkan driver (already present when Mesa comes from trixie-backports).
        depends+=(mesa-vulkan-drivers)
        [ "$codename" = "bookworm" ] && depends+=(clang-16)
    fi

    getDepends "${depends[@]}"

    # x86_64: the tree is C++23 (upstream builds Linux with Clang 19 or GCC 14). Report the
    # system compiler and stop early if it is clearly too old, rather than after an hour.
    if [ "$target" = "x86_64" ]; then
        local cxx_bin="${CXX:-c++}" cxx_id cxx_major
        cxx_id="$("$cxx_bin" --version 2>/dev/null | head -1)"
        cxx_major="$("$cxx_bin" -dumpversion 2>/dev/null | cut -d. -f1)"
        echo "Compilateur systeme : ${cxx_id:-introuvable}"
        case "$cxx_id" in
            *clang*) [ "${cxx_major:-0}" -lt 16 ] && { md_ret_errors+=("Clang $cxx_major trop ancien pour cet arbre C++23 (16 minimum)."); return 1; } ;;
            *)       [ "${cxx_major:-0}" -lt 13 ] && { md_ret_errors+=("GCC $cxx_major trop ancien pour cet arbre C++23 (13 minimum ; Ubuntu 24.04 ou Debian Trixie)."); return 1; } ;;
        esac
    fi

    # Pi5: report the Mesa version. The fork is tuned on Mesa 26.1.2 (trixie-backports);
    # Raspberry Pi OS Bookworm ships Mesa 24.x, which runs V3DV Vulkan 1.3 but is untested.
    if [ "$target" = "pi5" ]; then
        local mesa_ver
        mesa_ver="$(dpkg-query -W -f='${Version}' mesa-vulkan-drivers 2>/dev/null)"
        echo "Mesa (mesa-vulkan-drivers) : ${mesa_ver:-absent}"
        if [ -n "$mesa_ver" ] && dpkg --compare-versions "$mesa_ver" lt 24.1; then
            echo "ATTENTION : Mesa < 24.1 -- Vulkan V3DV non teste ; OpenGL-GLES reste disponible."
        fi
    fi
}

function sources_borked3ds() {

    ################################
    # SOURCE SELECTION
    #
    # Default: clone the fork chosen by the target (Pi5: DTEAM-1, Pi4: gvx64, see
    # _repo_borked3ds). The repository is the source of truth; a local tree is never picked
    # up automatically, so a build can never silently compile a stale copy.
    #
    # To build a local tree (quick test without pushing), ask for it explicitly:
    #     BORKED3DS_LOCAL_SRC=/home/pi/Borked3DS-rpi-master sudo -E ./retropie_setup.sh
    #
    # The selected source is printed in both cases.
    ################################

    local local_src="${BORKED3DS_LOCAL_SRC:-}"
    local target repo
    target="$(_target_borked3ds)"
    repo="$(_repo_borked3ds)"

    ################################
    # BUILD DIRECTORY CLEANUP
    #
    # Empty $md_build without deleting it:
    #   - "rm -rf $md_build/*" skips hidden files, so the previous .git survived and the
    #     next "git clone" failed ("destination path already exists").
    #   - "rm -rf $md_build" is wrong too: RetroPie-Setup has already pushd'ed into
    #     $md_build, so deleting it removes the shell's working directory (git then fails
    #     and "git -C" reports the RetroPie-Setup commit instead of ours).
    # find -mindepth 1 also removes hidden files and keeps the directory itself.
    ################################

    mkdir -p "$md_build"
    find "$md_build" -mindepth 1 -delete 2>/dev/null
    cd "$md_build" || exit 1

    if [ -n "$local_src" ]; then
        if [ ! -f "$local_src/CMakeLists.txt" ] || [ ! -d "$local_src/src" ]; then
            echo "BORKED3DS_LOCAL_SRC=$local_src ne contient pas un arbre valide -- abandon."
            exit 1
        fi
        echo "=========================================================="
        echo "SOURCES: arbre LOCAL (demande explicitement) -> $local_src"
        echo "=========================================================="
        cp -a "$local_src"/. "$md_build"/
        rm -rf "$md_build/build"
        echo "LOCAL-$(date +%Y%m%d-%H%M%S)" > "$md_build/.borked3ds_commit"
        cd "$md_build" || exit 1
        if [ -d "$md_build/.git" ]; then
            git submodule update --init --recursive
        fi
    else
        echo "=========================================================="
        echo "SOURCES: clone GitHub $repo (cible $target)"
        echo "=========================================================="
        ################################
        # CLONE WITH RETRIES, STOP ON FAILURE
        #
        # A network error used to let the script continue: the patches below ran on an
        # empty tree and "git -C" reported the parent RetroPie-Setup commit. The clone is
        # now retried 3 times (GitHub outages are often transient) and the build stops if
        # it still fails. The directory is emptied between attempts.
        ################################

        local clone_ok=0
        local attempt
        for attempt in 1 2 3; do
            echo "Clone du depot -- tentative $attempt/3..."
            if git clone --recursive "$repo" "$md_build"; then
                clone_ok=1
                break
            fi
            echo "Tentative $attempt echouee."
            if [ "$attempt" -lt 3 ]; then
                echo "Nettoyage du repertoire et nouvelle tentative dans 5 s..."
                find "$md_build" -mindepth 1 -delete 2>/dev/null
                sleep 5
            fi
        done

        if [ "$clone_ok" -ne 1 ]; then
            echo ""
            echo "!! CLONE IMPOSSIBLE apres 3 tentatives."
            echo "!! Cause typique : coupure reseau ou GitHub temporairement injoignable."
            echo "!! Verifier la connexion puis relancer :"
            echo "!!     git ls-remote $repo HEAD"
            echo "!! Ne pas poursuivre : le build compilerait autre chose."
            exit 1
        fi

        cd "$md_build" || exit 1

        # Guard: without CMakeLists.txt the clone is incomplete even if git succeeded.
        if [ ! -f "$md_build/CMakeLists.txt" ]; then
            echo "!! Clone incomplet : CMakeLists.txt absent. Abandon."
            exit 1
        fi

        git submodule update --init --recursive

        # Read the commit only if $md_build is the root of a git repository; otherwise
        # "git -C" would climb to the parent repository and report a foreign commit.
        if [ ! -d "$md_build/.git" ]; then
            echo "!! $md_build n'est pas la racine d'un depot git -- commit non fiable. Abandon."
            exit 1
        fi
        git -C "$md_build" rev-parse --short HEAD > "$md_build/.borked3ds_commit"
        echo "Commit compile : $(cat "$md_build/.borked3ds_commit") $(git -C "$md_build" log -1 --format=%s)"
    fi

    echo "$target" > "$md_build/.borked3ds_target"

    ################################
    # CMAKE >= 3.26 (Bookworm ships 3.25)
    ################################

    local cmake_bin
    cmake_bin="$(_cmake_borked3ds)"
    if [ "$cmake_bin" != "cmake" ] && [ ! -x "$cmake_bin" ]; then
        local cmake_dir="${cmake_bin%/bin/cmake}"
        # Kitware names its Linux tarballs after uname -m (aarch64 or x86_64).
        local cmake_arch
        cmake_arch="$(uname -m)"
        echo "CMake systeme < 3.26 : telechargement de CMake $BORKED3DS_CMAKE_VERSION ($cmake_arch) dans $cmake_dir"
        mkdir -p "$cmake_dir"
        downloadAndExtract "https://github.com/Kitware/CMake/releases/download/v$BORKED3DS_CMAKE_VERSION/cmake-$BORKED3DS_CMAKE_VERSION-linux-$cmake_arch.tar.gz" "$cmake_dir" --strip-components 1
        if [ ! -x "$cmake_bin" ]; then
            echo "!! Telechargement de CMake echoue. Abandon."
            exit 1
        fi
    fi
    echo "CMake utilise : $cmake_bin ($("$cmake_bin" --version | head -1))"

    ################################
    # PI4 (gvx64): no source patching. The tree is built exactly as RetroPie-Extra builds
    # it (system compiler), so the fixes below, which target Clang, are not needed.
    ################################

    if [ "$target" = "pi4" ]; then
        if [ ! -f "$md_build/CMakeLists.txt" ] || [ ! -d "$md_build/src" ]; then
            echo "!! ARBRE SOURCE INCOMPLET dans $md_build -- abandon."
            exit 1
        fi
        echo "Arbre source verifie (cible pi4, aucun correctif applique)."
        return 0
    fi

    ################################
    # FIX CMAKE PKGCONFIG BUG
    ################################

    if [ -f "$md_build/externals/cmake-modules/Findcryptopp.cmake" ]; then
        sed -i '1ifind_package(PkgConfig)' \
        "$md_build/externals/cmake-modules/Findcryptopp.cmake"
    fi

    ################################
    # FIX CLANG -Werror INCOMPATIBILITY
    #
    # The fork sets -Werror in its cmake files, so Clang rejects code that GCC accepts.
    # CMAKE_CXX_FLAGS cannot override a -Werror set by target_compile_options().
    #   Fix 1: strip bare -Werror from every cmake file (-Werror=... forms are kept).
    #   Fix 2: patch the two offending source files directly.
    #
    # TODO (packaging): the two source fixes should be committed to the repository and
    # removed from here; if the upstream pattern changes, the sed silently does nothing.
    ################################

    find "$md_build" \( -name "CMakeLists.txt" -o -name "*.cmake" \) | \
        xargs grep -l "\-Werror" 2>/dev/null | while read -r f; do
        echo "Patching -Werror out of: $f"
        sed -i 's/[[:space:]]-Werror[[:space:]]/ /g' "$f"
        sed -i 's/[[:space:]]-Werror"/ "/g' "$f"
        sed -i 's/-Werror\([^=]\)/\1/g; s/-Werror$//' "$f"
    done

    # Check: no bare -Werror may remain (-Werror=... is legitimate).
    local werror_left
    werror_left="$(grep -rn -- "-Werror" "$md_build" --include="CMakeLists.txt" --include="*.cmake" 2>/dev/null | grep -v -- "-Werror=" | wc -l)"
    if [ "$werror_left" -ne 0 ]; then
        echo "ATTENTION : $werror_left occurrence(s) de -Werror subsistent dans les fichiers cmake."
    else
        echo "-Werror nu : aucune occurrence restante."
    fi

    # Source fix 1: glsl_fs_shader_gen.cpp
    # Logical '||' with a constant operand (GL_SHADER_IMAGE_ATOMIC is an int constant).
    # Clang rejects it; bitwise '|' is equivalent here.
    local fs_gen="$md_build/src/video_core/shader/generator/glsl_fs_shader_gen.cpp"
    if [ -f "$fs_gen" ]; then
        if grep -q "GLAD_GL_ARB_shader_image_load_store || GL_SHADER_IMAGE_ATOMIC" "$fs_gen"; then
            sed -i 's/GLAD_GL_ARB_shader_image_load_store || GL_SHADER_IMAGE_ATOMIC/GLAD_GL_ARB_shader_image_load_store | GL_SHADER_IMAGE_ATOMIC/' "$fs_gen"
            echo "Patched glsl_fs_shader_gen.cpp: || -> | pour GL_SHADER_IMAGE_ATOMIC"
        else
            echo "NOTE: motif GL_SHADER_IMAGE_ATOMIC absent de glsl_fs_shader_gen.cpp (deja corrige en amont ?)"
        fi
    fi

    # Source fix 2: texture_decode.cpp
    # Unused function 'MakeBlackAlpha': [[nodiscard]] -> [[maybe_unused]]
    local tex_decode="$md_build/src/video_core/texture/texture_decode.cpp"
    if [ -f "$tex_decode" ]; then
        if grep -q "\[\[nodiscard\]\] constexpr Common::Vec4<u8> MakeBlackAlpha" "$tex_decode"; then
            sed -i 's/\[\[nodiscard\]\] constexpr Common::Vec4<u8> MakeBlackAlpha/[[maybe_unused]] constexpr Common::Vec4<u8> MakeBlackAlpha/' "$tex_decode"
            echo "Patched texture_decode.cpp: [[nodiscard]] -> [[maybe_unused]] pour MakeBlackAlpha"
        else
            echo "NOTE: motif MakeBlackAlpha absent de texture_decode.cpp (deja corrige en amont ?)"
        fi
    fi

    ################################
    # EXIT GUARD
    #
    # Make sure the source tree is in place before build_borked3ds() runs; otherwise a
    # failed clone only shows up later as an obscure CMake error.
    ################################

    if [ ! -f "$md_build/CMakeLists.txt" ] || [ ! -d "$md_build/src" ]; then
        echo ""
        echo "!! ARBRE SOURCE INCOMPLET dans $md_build"
        echo "!! CMakeLists.txt ou src/ manquant -- le clone ou la copie a echoue."
        echo "!! Ne pas poursuivre : le build compilerait autre chose ou echouerait plus loin."
        exit 1
    fi
    echo "Arbre source verifie : CMakeLists.txt et src/ presents."
}

function build_borked3ds() {

    cd "$md_build" || exit 1

    local target codename cmake_bin
    target="$(cat "$md_build/.borked3ds_target" 2>/dev/null || _target_borked3ds)"
    codename="$(_codename_borked3ds)"
    cmake_bin="$(_cmake_borked3ds)"

    mkdir -p build
    cd build || exit 1

    # USE_SYSTEM_QT=ON: without it CMake tries to download an x86_64 Qt with pip/aqt. That
    # only fails harmlessly today because Debian blocks pip (PEP 668); make it explicit.

    if [ "$target" = "x86_64" ]; then
        ################################
        # x86_64 / DTEAM-1 (v400): system compiler (CC/CXX respected if set), no -march at
        # all: no ARM option, and a binary that runs on any x86_64 CPU (dynarmic and the
        # shader JIT detect SSE/AVX at run time). The top CMakeLists computes its own
        # SIMD_FLAGS before project(), so they are empty and add nothing.
        # Libraries: the bundled submodules (what upstream ships for desktop Linux), except
        # Qt and SDL2 which come from the system like on the Pi. USE_SYSTEM_LIBS=ON would
        # require system dynarmic, glslang, cubeb, Catch2... that x86 distributions lack.
        # -Werror is stripped in sources_borked3ds() and disabled here for GCC.
        ################################
        echo "Compilateur : ${CXX:-c++} ($("${CXX:-c++}" --version 2>/dev/null | head -1))"
        "$cmake_bin" .. \
            -G Ninja \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_C_FLAGS="-O3" \
            -DCMAKE_CXX_FLAGS="-O3" \
            -DENABLE_QT=ON \
            -DENABLE_SDL2=ON \
            -DENABLE_TESTS=OFF \
            -DBORKED3DS_WARNINGS_AS_ERRORS=OFF \
            -DUSE_SYSTEM_LIBS=OFF \
            -DUSE_SYSTEM_QT=ON \
            -DUSE_SYSTEM_SDL2=ON
    elif [ "$target" = "pi4" ]; then
        ################################
        # PI4 / gvx64: OpenGL-GLES build, as in RetroPie-Extra: system compiler (GCC) and
        # RetroPie's CFLAGS for the Cortex-A72. No +crypto: the Pi4 SoC has no ARMv8
        # crypto extension (illegal instruction).
        ################################
        "$cmake_bin" .. \
            -G Ninja \
            -DCMAKE_BUILD_TYPE=Release \
            -DUSE_SYSTEM_QT=ON \
            -DDYNARMIC_USE_BUNDLED_EXTERNALS=OFF
    else
        ################################
        # PI5 / DTEAM-1: Clang, upstream notes that "Vulkan may crash if the executable was
        # compiled with GCC". -Werror is stripped in sources_borked3ds() above.
        # Bookworm: clang-16 (system clang 14 is too old), see _clang_borked3ds().
        ################################
        local cv cc="clang" cxx="clang++"
        cv="$(_clang_borked3ds)"
        if [ -n "$cv" ]; then
            cc="clang-$cv"
            cxx="clang++-$cv"
        elif [ "$codename" = "bookworm" ]; then
            echo "!! Bookworm : aucun clang >= 15 trouve (clang-16 attendu). Abandon."
            exit 1
        fi
        echo "Compilateur : $cxx"

        "$cmake_bin" .. \
            -G Ninja \
            -DCMAKE_BUILD_TYPE=Release \
            -DCMAKE_C_COMPILER="$cc" \
            -DCMAKE_CXX_COMPILER="$cxx" \
            -DCMAKE_C_FLAGS="-march=armv8.2-a+crc+crypto -O3" \
            -DCMAKE_CXX_FLAGS="-march=armv8.2-a+crc+crypto -O3" \
            -DENABLE_QT=ON \
            -DENABLE_SDL2=ON \
            -DENABLE_TESTS=OFF \
            -DUSE_SYSTEM_QT=ON \
            -DUSE_SYSTEM_LIBS=ON
    fi

    if [ $? -ne 0 ]; then
        echo "CMake configuration failed"
        exit 1
    fi

    # Pi4 4 GB: one job per core can run out of RAM on the big translation units.
    local jobs mem_mb
    jobs="$(nproc)"
    mem_mb="$(awk '/MemTotal/ {print int($2/1024)}' /proc/meminfo)"
    if [ "$target" = "pi4" ] && [ "$mem_mb" -lt 6000 ]; then
        jobs=2
        echo "Pi4 avec moins de 6 Go de RAM : compilation sur $jobs coeurs."
    fi
    # x86_64: GCC needs up to ~2 GB per job on the largest files; cap the jobs by RAM.
    if [ "$target" = "x86_64" ] && [ $((mem_mb / 2000)) -lt "$jobs" ]; then
        jobs=$((mem_mb / 2000))
        [ "$jobs" -lt 1 ] && jobs=1
        echo "x86_64 avec $mem_mb Mo de RAM : compilation sur $jobs coeurs."
    fi

    ninja -j"$jobs"

    if [ $? -ne 0 ]; then
        echo "Build failed"
        exit 1
    fi
}

function install_borked3ds() {

    mkdir -p "$md_inst"

    # The Qt executable is named borked3ds (not borked3ds-qt).
    if [ -f "$md_build/build/bin/Release/borked3ds" ]; then
        cp "$md_build/build/bin/Release/borked3ds" "$md_inst/borked3ds"
        chmod +x "$md_inst/borked3ds"
    else
        echo "Binary borked3ds missing — build may have failed"
        exit 1
    fi

    ################################
    # USER HOME
    #
    # The scriptmodule runs as root ($HOME is /root). Files created below must go to the
    # user's home; RetroPie-Setup provides $home and $__user for that.
    ################################
    local user_home="${home:-/home/${__user:-pi}}"

    ################################
    # MINIMAL SAVEDATA
    #
    # archive_source_sd_savedata.cpp mounts SaveData from
    # sdmc/.../title/{high}/{low}/data/00000001/. Sonic Lost World reads network_id.dat
    # at startup; if it is missing, the unhandled FILE_NOT_FOUND crashes the ARM thread.
    #
    # TODO (packaging): this is specific to the project's test games and does not belong
    # in a distributable package.
    ################################

    local sdmc_base="$user_home/.local/share/borked3ds-emu/sdmc/Nintendo 3DS"
    local sdmc_id0="00000000000000000000000000000000"
    local sdmc_id1="00000000000000000000000000000000"
    local sdmc="$sdmc_base/$sdmc_id0/$sdmc_id1"

    # Sonic Lost World US (00040000000C8C00) — network_id.dat
    # 16 bytes: LocalFriendCodeSeed (8 non-zero bytes) + NetworkID (8 bytes)
    local sonic_us_data="$sdmc/title/00040000/000c8c00/data/00000001"
    if [ ! -f "$sonic_us_data/network_id.dat" ]; then
        mkdir -p "$sonic_us_data"
        python3 -c "
import struct
data = struct.pack('<Q', 0x0123456789ABCDEF) + bytes(8)
open('$sonic_us_data/network_id.dat', 'wb').write(data)
" && echo "Created network_id.dat for Sonic Lost World US" \
          || echo "WARNING: failed to create network_id.dat"
    fi

    # Sonic Lost World EU (00040000000C8D00) — same layout
    local sonic_eu_data="$sdmc/title/00040000/000c8d00/data/00000001"
    if [ ! -f "$sonic_eu_data/network_id.dat" ]; then
        mkdir -p "$sonic_eu_data"
        python3 -c "
import struct
data = struct.pack('<Q', 0x0123456789ABCDEF) + bytes(8)
open('$sonic_eu_data/network_id.dat', 'wb').write(data)
" && echo "Created network_id.dat for Sonic Lost World EU" \
          || echo "WARNING: failed to create network_id.dat EU"
    fi

    ################################
    # POST-INSTALL VERIFICATION
    #
    # Every expected marker string is searched for in the installed binary, so that no
    # test is ever run on a stale binary. A single ABSENT marker invalidates the test
    # cycle: do not launch a game, re-upload the files and rebuild.
    #
    # Each marker proves that a given fix or probe is present, e.g.:
    #   A7Z12_FRAME_CENSUS / swhist_le8= / rp_switch= / cpu_pct= / sub_lag= / f_fb= /
    #     seq_count= / A7Z12_FB_IDENT / c_addr= / A7Z12_RP_END_SITE : frame census fields
    #   BORKED3DS_V3DV_DISABLE_LAZY_COPY_VIEW : escape hatch of the TB33 fix (no image copy
    #     on every draw, on by default); if it disappears, the fix was lost
    #   BORKED3DS_V3DV_TRACE_BLEND / TRACE_DISPLAY_TRANSFER : heavy traces are opt-in (TB34)
    #   V385_SPECIALISATION : vertex shader specialization (v385)
    #   V387_FS_NO_ROBUST / BORKED3DS_V3DV_V387_FS_ROBUST : non-robust fragment shaders (v388)
    #   V389_DEFAUTS_VULKAN : Vulkan defaults set by the program (v389)
    #   V390_PRIORITE_COMPILATION : compile threads run at background priority (v390)
    #   V391_ECLAIRAGE_ALLEGE : reduced lighting for Luigi's Mansion 2 only (v391)
    #   V393_OMBRES : PICA shadow maps in Vulkan, opt-in with BORKED3DS_V3DV_V393_SHADOWS=1 (v393/v394)
    #   V394_LOGICOP : logic op NoOp masks color writes in strict-compat (Mario 3D Land shadows) (v394)
    #   V395_AZAHAR_LOT_A : small Azahar fixes (KeepAll2 cull mode, zero-area draws, invalid vertex arrays, null cube units, malformed GS, FillScreen, present sampler) (v395)
    #   V396_LOT_C : identical PICA shader words no longer mark the program dirty; SIMD index min/max (v396)
    #   V397_CHEMIN_CHAUD : env lookups cached without std::string; descriptor writes batched in strict-compat (v397)
    #   V398_GVX64 / V398_AUDIO_BORNE : gvx64 ports (idle surface eviction, realtime-audio clamp,
    #     memory hot path, GLES copy_image/CopyTextures fixes) (v398)
    #   V399_SVC_TIMING : per-SVC hardware cycle counts (gvx64 99a0d7e / Azahar #1093); escape hatch
    #     BORKED3DS_V3DV_V399_NO_SVC_TIMING=1 restores the old +150 ticks in GetSystemTick (v399)
    #   V400_ARCH= : the Pi5 runtime defaults (V389/V391) are compiled in on x86_64 too (v400)
    # To add a marker, append it to borked3ds_markers.
    ################################

    local target
    target="$(cat "$md_build/.borked3ds_target" 2>/dev/null || _target_borked3ds)"
    echo "$target" > "$md_inst/.borked3ds_target"

    echo ""
    echo "=========================================================="
    echo "VERIFICATION DU BINAIRE INSTALLE (cible $target)"
    echo "=========================================================="
    if [ -f "$md_build/.borked3ds_commit" ]; then
        echo "Commit compile : $(cat "$md_build/.borked3ds_commit")"
        cp "$md_build/.borked3ds_commit" "$md_inst/.borked3ds_commit"
    else
        echo "Commit compile : INCONNU"
    fi

    # The markers and the Vulkan cache below belong to the DTEAM-1 fork (Pi5, x86_64) only.
    if [ "$target" = "pi4" ]; then
        echo "Cible pi4 (gvx64, OpenGL-GLES) : verification des marqueurs DTEAM-1 sans objet."
        echo "=========================================================="
        echo ""
        return 0
    fi

    local borked3ds_markers=(
        "TRACE_DISPLAY_TRANSFER src="
        "shifts the bottom screen"
        "BORKED3DS_V3DV_TRACE_SCREEN_RECT"
        "BORKED3DS_V3DV_DIRA_SW_FALLBACK"
        "BORKED3DS_V3DV_TRACE_SYNC"
        "TRACE_SYNC finish="
        "BORKED3DS_V3DV_STRICT_SERIALIZE_SW_DRAWS"
        "BORKED3DS_V3DV_STRICT_FLUSH_SW_DRAWS"
        "v3dv_zband"
        "streambuf_wait="
        "TRACE_PIPELINE_BUILD compile="
        "TRACE_PIPELINE_POISON hash="
        "BORKED3DS_V3DV_DISABLE_EDS"
        "BORKED3DS_V3DV_DIRA_WIDE"
        "BORKED3DS_V3DV_DIRA_ALL"
        "TRACE_VSDECIDE main_offset="
        "BORKED3DS_V3DV_A7Z12_FRAME_CENSUS"
        "swhist_le8="
        "rp_switch="
        "BORKED3DS_V3DV_MIN_DRAWS_TO_FLUSH"
        "BORKED3DS_V3DV_DISABLE_RENDERPASS_FLUSH"
        "cpu_pct="
        "sub_lag="
        "f_fb="
        "seq_count="
        "A7Z12_FB_IDENT"
        "c_addr="
        "A7Z12_RP_END_SITE"
        "BORKED3DS_V3DV_DISABLE_LAZY_COPY_VIEW"
        "BORKED3DS_V3DV_TRACE_BLEND"
        "BORKED3DS_V3DV_TRACE_DISPLAY_TRANSFER"
        "V385_SPECIALISATION programme="
        "V387_FS_NO_ROBUST actif"
        "BORKED3DS_V3DV_V387_FS_ROBUST"
        "V389_DEFAUTS_VULKAN"
        "V390_PRIORITE_COMPILATION"
        "V391_ECLAIRAGE_ALLEGE"
        "V393_OMBRES actif="
        "V394_LOGICOP actif="
        "V395_AZAHAR_LOT_A actif="
        "V396_LOT_C actif="
        "V397_CHEMIN_CHAUD actif="
        "V398_GVX64 actif="
        "V398_AUDIO_BORNE time_scale="
        "BORKED3DS_V3DV_V398_NO_IDLE_EVICT"
        "V399_SVC_TIMING actif="
        "BORKED3DS_V3DV_V399_NO_SVC_TIMING"
        "V400_ARCH="
    )

    # strings runs once (the binary is ~90 MB) into a temporary file; grep reads the file,
    # so no "strings | grep -q" pipe can be cut short (SIGPIPE under pipefail = false ABSENT).
    local borked3ds_missing=0
    local m bin_strings
    bin_strings="$(mktemp)"
    strings -a "$md_inst/borked3ds" > "$bin_strings"
    for m in "${borked3ds_markers[@]}"; do
        if grep -aqF -- "$m" "$bin_strings"; then
            printf "  OK      %s\n" "$m"
        else
            printf "  ABSENT  %s\n" "$m"
            borked3ds_missing=1
        fi
    done

    # Removed code: finding any of these strings means the binary predates v389.
    local borked3ds_removed=(
        "BORKED3DS_V3DV_V382_TEXSYNC"
        "BORKED3DS_V3DV_V386_EZ"
        "BORKED3DS_V3DV_V386_SKIP_DARK"
        "V386_LUMIERES"
        "BORKED3DS_V3DV_DIRA_Z_BIAS"
        "BORKED3DS_V3DV_DIRA_FULLSCREEN_TRI"
        "BORKED3DS_V3DV_DIRA_FORCE_DYNSTATE"
    )
    for m in "${borked3ds_removed[@]}"; do
        if grep -aqF -- "$m" "$bin_strings"; then
            printf "  PERIME  %s (devrait avoir disparu)\n" "$m"
            borked3ds_missing=1
        fi
    done
    rm -f "$bin_strings"

    if [ "$borked3ds_missing" -ne 0 ]; then
        echo ""
        echo "!! BINAIRE NON CONFORME -- tout releve fait avec celui-ci serait invalide."
        echo "!! Verifier que les fichiers patches ont bien ete pousses avant le build."
    else
        echo ""
        echo "Binaire conforme."
    fi

    ################################
    # VULKAN SHADER CACHE (v392): KEPT ACROSS REBUILDS
    #
    # The caches survive a rebuild, so areas already visited in a game never recompile
    # (Luigi's Mansion 2 needs 1-2 s per new pipeline):
    #   - <cache>/*.bin      : VkPipelineCache, validated by the driver itself (vendor, device,
    #                          pipelineCacheUUID); a Mesa update simply invalidates it.
    #   - <cache>/spirv/*.spv: GLSL -> SPIR-V results, keyed by a hash of the GLSL text, so a
    #                          change in the shader generators produces new keys, never stale hits.
    # Only the GLSL -> SPIR-V conversion itself can make old .spv files wrong (glslang version or
    # vk_shader_util.cpp options). The spirv/ directory is therefore purged only when that key
    # changes. BORKED3DS_PURGE_SHADER_CACHE=1 forces a full purge (cold measurements).
    ################################
    local vk_cache="$user_home/.local/share/borked3ds-emu/shaders/vulkan"
    local spirv_key
    spirv_key="$(git -C "$md_build" rev-parse HEAD:externals/glslang 2>/dev/null)-$(md5sum "$md_build/src/video_core/renderer_vulkan/vk_shader_util.cpp" 2>/dev/null | cut -c1-32)"
    if [ -n "${BORKED3DS_PURGE_SHADER_CACHE:-}" ]; then
        rm -rf "$vk_cache"
        echo "Vulkan shader cache: full purge (BORKED3DS_PURGE_SHADER_CACHE)."
    elif [ -d "$vk_cache" ]; then
        if [ "$(cat "$vk_cache/.spirv_key" 2>/dev/null)" != "$spirv_key" ]; then
            rm -rf "$vk_cache/spirv"
            echo "Vulkan shader cache: kept, SPIR-V part purged (GLSL -> SPIR-V conversion changed)."
        else
            echo "Vulkan shader cache: kept ($(ls "$vk_cache"/spirv 2>/dev/null | wc -l) SPIR-V files)."
        fi
    fi
    mkdir -p "$vk_cache"
    echo "$spirv_key" > "$vk_cache/.spirv_key"
    chown -R "${__user:-pi}": "$user_home/.local/share/borked3ds-emu/shaders" 2>/dev/null
    echo "=========================================================="
    echo ""
}

function configure_borked3ds() {

    mkRomDir "3ds"

    ################################
    # LAUNCH LINES (v389)
    #
    # The tuned settings no longer live in emulators.cfg:
    #   - BORKED3DS_V3DV_* variables are set by the program when a game starts, only when
    #     the selected API is Vulkan (under OpenGL they make the emulator exit); see
    #     V389ApplyV3dvDefaults() in src/borked3ds_qt/main.cpp, log line V389_DEFAUTS_VULKAN;
    #   - launcher environment (xcb, SDL, GL_OES_texture_buffer, Vulkan layers) is set at
    #     the start of main();
    #   - graphics_api=Vulkan and use_disk_shader_cache=true are code defaults (settings.h).
    # A variable set by hand on a line still takes priority (tests).
    # Escape hatch: BORKED3DS_V3DV_NO_DEFAULTS=1.
    #
    # Never add V3D_DEBUG=opt_compile_time back: with non-robust fragment shaders (v388)
    # it makes V3D spill registers (Luigi's Mansion 2: 38 -> 126 ms per frame).
    #
    # Measurement probes (no longer set by default), to add by hand on a test line:
    #   BORKED3DS_V3DV_A7Z12_FRAME_CENSUS=1 BORKED3DS_V3DV_A7Z12_CENSUS_PERIOD=61
    #   BORKED3DS_V3DV_TRACE_PIPELINE_BUILD=1
    # The census is logged at Info level: log_filter must include Render.Vulkan:Info.
    #
    # Three lines:
    #   borked3ds          : game, OpenGL or Vulkan depending on the setting (default)
    #   borked3ds-ui       : Qt interface only
    #   borked3ds-ui-qt06  : Qt interface only, 0.6 scale (small screens)
    # Old test lines (borked3ds_*) are removed.
    ################################

    addEmulator 1 "$md_id" "3ds" "XINIT-WM:$md_inst/borked3ds -f %ROM%"
    addEmulator 0 "${md_id}-ui" "3ds" "XINIT-WMC:$md_inst/borked3ds"
    addEmulator 0 "${md_id}-ui-qt06" "3ds" "XINIT-WMC:QT_SCALE_FACTOR=0.6 $md_inst/borked3ds"

    local _emucfg="$configdir/3ds/emulators.cfg"
    if [[ -f "$_emucfg" ]]; then
        sed -i '/^borked3ds_/d' "$_emucfg"
    fi

    addSystem "3ds"

    ################################
    # PI4 STARTING SETTINGS (v398): OpenGL with GLES
    #
    # The Pi4 GPU (V3D 4.2) has no usable desktop OpenGL nor Vulkan for this emulator: the
    # renderer must start as OpenGL (graphics_api=1) with "Use OpenGL ES" ticked
    # (use_gles=true). Both keys need the double write key=value + key\default=false,
    # otherwise the code default wins.
    # A key the user already set by hand (key\default=false) is left alone, and nothing
    # else is touched (never the gamepad). The Pi5 and x86_64 need nothing here: Vulkan is
    # the code default of the DTEAM-1 fork.
    ################################
    local target
    target="$(cat "$md_inst/.borked3ds_target" 2>/dev/null || _target_borked3ds)"
    if [ "$target" = "pi4" ]; then
        local user_home="${home:-/home/${__user:-pi}}"
        local qtcfg="$user_home/.config/borked3ds-emu/qt-config.ini"
        mkdir -p "$(dirname "$qtcfg")"
        python3 - "$qtcfg" <<'_EOF_'
import os, sys
path = sys.argv[1]
wanted = [("graphics_api", "1"), ("use_gles", "true")]
lines = open(path, encoding="utf-8").read().splitlines() if os.path.exists(path) else []

# Locate the [Renderer] section (create it if absent).
start = next((i for i, l in enumerate(lines) if l.strip() == "[Renderer]"), None)
if start is None:
    if lines and lines[-1].strip():
        lines.append("")
    lines.append("[Renderer]")
    start = len(lines) - 1
end = next((i for i in range(start + 1, len(lines)) if lines[i].startswith("[")), len(lines))

def find(key):
    for i in range(start + 1, end):
        if lines[i].split("=", 1)[0] == key:
            return i
    return None

for key, value in wanted:
    d = find(key + "\\default")
    if d is not None and lines[d].split("=", 1)[1].strip() == "false":
        cur = find(key)
        print("  %s : choix de l'utilisateur garde (%s)" % (key, lines[cur] if cur is not None else "?"))
        continue
    for k, v in ((key + "\\default", "false"), (key, value)):
        i = find(k)
        if i is None:
            lines.insert(end, k + "=" + v)
            end += 1
        else:
            lines[i] = k + "=" + v
    print("  %s=%s (defaut Pi4)" % (key, value))

open(path, "w", encoding="utf-8").write("\n".join(lines) + "\n")
_EOF_
        chown -R "${__user:-pi}": "$user_home/.config/borked3ds-emu" 2>/dev/null
        echo "Pi4 : reglages de depart OpenGL + GLES verifies dans $qtcfg"
    fi

    echo ""
    echo "Ligne de lancement installee :"
    grep -a "^borked3ds" "$configdir/3ds/emulators.cfg" 2>/dev/null || \
        echo "  (introuvable -- verifier $configdir/3ds/emulators.cfg)"
    echo ""
}
