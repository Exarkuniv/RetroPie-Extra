#! /usr/bin/env bash

# This file is part of RetroPie-Extra, a supplement to RetroPie.
# For more information, please visit:
#
# https://github.com/RetroPie/RetroPie-Setup
# https://github.com/Exarkuniv/RetroPie-Extra
#
# See the LICENSE file distributed with this source and at
# https://raw.githubusercontent.com/Exarkuniv/RetroPie-Extra/master/LICENSE
#

# Known limitations with the 32 bit build of gmloader on RPI5/arm64:
#
# - The setting kernel=kernel8.img is mandatory in /boot/firmware/config.txt
#   (requires reboot). If it is not set you get an error message like:
#   "libisl.so.23: ELF load command address/offset not page-aligned"
#
# - This script can not be exucuted in steps (e.g. depends, sources, build,
#   install, configure) as each step will reset the gcc:armhf installation to
#   gcc:arm64.
#
# - Whenever there is a new SDL2 version available from the
#   RetroPie-Setup package, it should be installed before running this
#   module.

rp_module_id="gmloader"
rp_module_desc="GMLoader - play GameMaker Studio games for Android on non-Android operating systems"
rp_module_help="ROM Extensions: .apk .APK\n\nIncludes free games Maldita Castilla and Spelunky Classic HD. Use a launch script (e.g. 'Spelunky Classic HD.sh') as template for additional games."
rp_module_repo="git https://github.com/JohnnyonFlame/droidports.git master"
rp_module_licence="GPL3 https://raw.githubusercontent.com/JohnnyonFlame/droidports/master/LICENSE.md"
rp_module_section="exp"
rp_module_flags="!all rpi5 rpi4 rpi3"


function depends_gmloader() {
    if isPlatform "64bit" ; then
        if [[ $(grep -c "^\s*kernel\s*=\s*kernel8.img" /boot/firmware/config.txt) -ne 1 ]] ; then
            local _msg="For this module to compile successfully you will need to "
            _msg+="add the line\n\n  kernel=kernel8.img\n\nto your "
            _msg+="/boot/firmware/config.txt.\n\nAfter you applied the "
            _msg+="change reboot and rerun this module."
            printMsgs "dialog" "$_msg"
            exit 1
        fi
        dpkg --add-architecture armhf
        apt-get remove -y gcc:arm64 g++:arm64 binutils:arm64

        local armhf_deps=(
            # gmloader
            libopenal-dev:armhf
            libfreetype6-dev:armhf
            libbz2-dev:armhf
            libpng-dev:armhf
            libzip-dev:armhf
            # armhf toolchain
            gcc:armhf
            g++:armhf
            libgcc-${__os_debian_ver}-dev-armhf-cross
            # generic cmake
            cmake
            # for sdl2
            libgl1-mesa-dev:armhf
            libdbus-1-3:armhf
            # readelf --dynamic /usr/lib/arm-linux-gnueabihf/dri/vc4_dri.so | grep NEEDED
            libegl-mesa0:armhf
            libgl1-mesa-dri:armhf
            libllvm15:armhf
            # implicit dependencies of vc4_dri.so et al. (package libgl1-mesa-dri:armhf)
            libegl1:armhf
            libgles2:armhf
            libudev1:armhf
        )
        getDepends "${armhf_deps[@]}"

        _gmloader_dl_install_bin_sdl2
        if [[ $? -ne 0 ]]; then
            printMsgs console "[!] Premature end of script. Check output above."
            exit 1
        fi
    else
        getDepends libopenal-dev libfreetype6-dev zlib1g-dev libbz2-dev libpng-dev libzip-dev libsdl2-image-dev cmake
    fi
}

function _gmloader_dpkg_divert() {
    local action=$1
    local divert_libsdl2_dev=(
        /usr/bin/sdl2-config
        /usr/include/SDL2/SDL_config.h
        /usr/share/doc/libsdl2-dev/changelog.gz
        /usr/share/doc/libsdl2-dev/examples/examples.tar.gz
    )
    local divert_libsdl2=(
        /usr/share/doc/libsdl2-2.0-0/changelog.gz
        /usr/share/doc/libsdl2-2.0-0/copyright
    )
    if apt-mark showmanual | grep -q "^libsdl2-dev$"; then
        # divert only when arm64 dev package is present otherwise SDL_config.h is not found at build time
        for f in "${divert_libsdl2_dev[@]}"; do
            if [[ "$action" == "add" ]] ; then
                dpkg-divert --divert "${f}.$(_gmloader_get_rp_pkg_ver_sdl2)_armhf" --no-rename "${f}"
            else
                dpkg-divert --remove --no-rename "${f}"
            fi
        done
    fi
    for f in "${divert_libsdl2[@]}"; do
        if [[ "$action" == "add" ]] ; then
            dpkg-divert --divert "${f}.$(_gmloader_get_rp_pkg_ver_sdl2)_armhf"  --no-rename "${f}"
        else
            dpkg-divert --remove --no-rename "${f}"
        fi
    done
}

function _gmloader_armhf_libdir() {
    echo "/usr/lib/gcc-cross/arm-linux-gnueabihf/${__os_debian_ver}"
}

function _gmloader_install_rp_sdl2() {
    _gmloader_dpkg_divert "add"
    if ! apt-get -y --allow-downgrades --allow-change-held-packages -o DPkg::options::="--force-overwrite" install \
            "./libsdl2-2.0-0_$(_gmloader_get_rp_pkg_ver_sdl2)_armhf.deb" \
            "./libsdl2-dev_$(_gmloader_get_rp_pkg_ver_sdl2)_armhf.deb"; then
        # if the packages don't install completely due to missing dependencies the apt-get -y -f install will correct it
        apt-get -y -f --no-install-recommends --allow-downgrades --allow-change-held-packages install
    fi
    apt-mark hold libsdl2-2.0-0:armhf
}

# partially yarked from sdl2.h
function _gmloader_get_rp_pkg_ver_sdl2() {
    # assuming the SDL2 version for RaspiOS >= 11 in the second line of function get_ver_sdl2()
    local ver=$(awk '/function get_ver_sdl2/{getline;getline;print $2}' "$scriptdir/scriptmodules/supplementary/sdl2.sh" | tr -d '"')
    ver+="+1"
    isPlatform "rpi" && ver+="rpi"
    isPlatform "mali" && ver+="mali"
    echo "$ver"
}

# yarked from sdl2.sh
function _gmloader_dl_install_bin_sdl2() {
    local tmp="$(mktemp -d)"
    pushd "$tmp" >/dev/null
    chown _apt .
    local ret=1
    if downloadAndVerify "$__binary_url/libsdl2-dev_$(_gmloader_get_rp_pkg_ver_sdl2)_armhf.deb" && \
       downloadAndVerify "$__binary_url/libsdl2-2.0-0_$(_gmloader_get_rp_pkg_ver_sdl2)_armhf.deb"; then
        _gmloader_install_rp_sdl2
        ret=0
    fi
    popd >/dev/null
    rm -rf "$tmp"
    return $ret
}

function sources_gmloader() {
    gitPullOrClone
    applyPatch "$md_data/01_sdl_retropie_exit_emu.patch"
    applyPatch "$md_data/02_sdl_disable_mouse_cursor.patch"
}

function build_gmloader() {
    [[ ! -d build ]] && mkdir build
    cd build || return 1
    local cmflags=(
        -DCMAKE_BUILD_TYPE=Release
        -DPLATFORM=linux
        -DPORT=gmloader
    )

    if isPlatform "64bit" ; then
        sed -e "s;_crosslib_var;$(_gmloader_armhf_libdir);" "$md_data/toolchain_armhf_multiarch.tpl" > "$md_data/toolchain_armhf_multiarch.cmake"
        cmflags+=(-DCMAKE_TOOLCHAIN_FILE="$md_data/toolchain_armhf_multiarch.cmake")
    fi

    [[ -f Makefile ]] && make --ignore-errors clean
    cmake "${cmflags[@]}" .. || return 1
    VERBOSE=1 make -j$(nproc)
    md_ret_require="$md_build/build/gmloader"
}

function install_gmloader() {
    md_ret_files=(
        'build/gmloader'
        'LICENSE.md'
        'README.md'
    )
    if isPlatform "64bit" ; then
        cd /usr/arm-linux-gnueabihf/lib || return 1
        [[ -L crtbeginS.o ]] || ln -s $(_gmloader_armhf_libdir)/crtbeginS.o
        [[ -L crtendS.o ]] || ln -s $(_gmloader_armhf_libdir)/crtendS.o

        # play nice: clean up for RP sdl2 scriptmodule
        apt-get -y purge libsdl2-dev:armhf
        _gmloader_dpkg_divert "remove"
    fi
}

function configure_gmloader() {
    local apk_dir="$romdir/ports/droidports"
    local am2r_url="https://archive.org/download/am-2-r-1.5.5-for-android/AM2R%20v1.5.5%20for%20Android.apk"
    local maldita_url="https://github.com/Exarkuniv/game-data/raw/main/Maldita_Castilla_ouya.apk"
    local spelunky_url="https://github.com/yancharkin/SpelunkyClassicHD/releases/download/1.1.7-optimized/spelunky_classic_hd-android-armv7.apk"

    if [[ "$md_mode" == "install" ]]; then
        mkUserDir "$apk_dir"
        local dl_url
        for dl_url in "$am2r_url" "$maldita_url" "$spelunky_url"; do
            local dest_file
            dest_file=$(basename ${dl_url})
            if case "$dest_file" in AM2R*) ;; *) false;; esac; then
                dest_file="AM2R.apk"
            fi
            local apk_file="$apk_dir/$dest_file"
            if [[ ! -f "$apk_file" ]]; then
                download "$dl_url" "$apk_file"
                chown $user:$user "$apk_file"
            fi
        done

        local libcpp_eabi="libc++_shared.so"
        # keep copy in apk_dir and not in md_inst. md_inst may get recreated during scriptmodule run
        if [[ ! -e "${apk_dir}/${libcpp_eabi}" ]]; then
            downloadAndExtract "https://chromium.googlesource.com/android_ndk.git/+archive/refs/heads/main/sources/cxx-stl/llvm-libc++/libs/armeabi-v7a.tar.gz" "${apk_dir}" "$libcpp_eabi"
            strip -s "${apk_dir}/${libcpp_eabi}"
        fi
        cp -p "${apk_dir}/${libcpp_eabi}" "${md_inst}"

        # Launcher: Change to install folder md_inst as failsafe to allow gmloader to find
        # libc++_shared.so sibling to gmloader binary for APKs which do not bundle the lib
        cat >"$md_inst/gmlauncher.sh" << _EOF_
#! /usr/bin/env bash
cd "$md_inst"
ROM="\$1"
fn="\${ROM##*/}"
BASENAME="\${fn%.*}"
GMLOADER_SAVEDIR="$home/.config/gmloader/\$BASENAME/" ./gmloader "\$ROM"
_EOF_
        chmod a+x "$md_inst/gmlauncher.sh"

        # restore expected RetroPie-Setup packages
        if isPlatform "64bit"; then
            printMsgs "console" "Restoring desired state of RetroPie-Setup packages ..."
            apt -y install build-essential gldriver-test
        fi
    fi

    local am2r_file
    local maldita_file
    local spelunky_file
    am2r_file="$apk_dir/AM2R.apk"
    maldita_file="$apk_dir/$(basename ${maldita_url})"
    spelunky_file="$apk_dir/$(basename ${spelunky_url})"
    addPort "$md_id" "droidports" "AM2R - Another Metroid 2 Remake" "$md_inst/gmlauncher.sh %ROM%" "$am2r_file"
    addPort "$md_id" "droidports" "Maldita Castilla" "$md_inst/gmlauncher.sh %ROM%" "$maldita_file"
    addPort "$md_id" "droidports" "Spelunky Classic HD" "$md_inst/gmlauncher.sh %ROM%" "$spelunky_file"

    moveConfigDir "$home/.config/gmloader" "$md_conf_root/droidports"
}
