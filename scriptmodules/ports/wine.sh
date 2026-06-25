#!/usr/bin/env bash

# This file is part of The RetroPie Project
#
# The RetroPie Project is the legal property of its developers, whose names are
# too numerous to list here. Please refer to the COPYRIGHT.md file distributed with this source.
#
# See the LICENSE.md file at the top-level directory of this distribution and
# at https://raw.githubusercontent.com/RetroPie/RetroPie-Setup/master/LICENSE.md
#

rp_module_id="wine"
rp_module_desc="WINEHQ - Wine Is Not an Emulator"
rp_module_help="Use your app's Installer or place your x86 Windows binaries into $romdir/wine"
rp_module_licence="LGPL https://wiki.winehq.org/Licensing"
rp_module_section="exp"
rp_module_flags=""

function _get_os_info() {
    local os_info=()
    
    # Detect Debian version
    if grep -q "buster" /etc/os-release; then
        os_info+=(buster)
    elif grep -q "bookworm" /etc/os-release; then
        os_info+=(bookworm)
    else
        md_ret_errors+=("Unsupported Debian version. Only Buster and Bookworm are supported.")
        return 1
    fi
    
    # Detect architecture
    if [ "$(uname -m)" = "i686" ] || [ "$(uname -m)" = "i386" ]; then
        os_info+=(i386)
    elif [ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "aarch64" ]; then
        os_info+=(amd64)
    elif [ "$(uname -m)" = "armv7l" ]; then
        os_info+=(i386) # Use i386 packages for 32-bit ARM
    else
        md_ret_errors+=("Unsupported architecture.")
        return 1
    fi
    
    echo "${os_info[@]}"
}

function _latest_ver_wine() {
    local os_info=($(_get_os_info))
    local distro="${os_info[0]}"
    
    if [ "$distro" = "buster" ]; then
        echo "7.0.0.0"  # Version for Buster
    elif [ "$distro" = "bookworm" ]; then
        echo "10.0.0.0" # Version for Bookworm
    fi
}

function _release_type_wine() {
    echo "stable"
}

function _release_distribution() {
    local os_info=($(_get_os_info))
    local distro="${os_info[0]}"
    local arch="${os_info[1]}"
    
    if [ "$distro" = "buster" ]; then
        if [ "$arch" = "i386" ]; then
            echo "buster-1_i386"
        else
            echo "buster-1_amd64"
        fi
    elif [ "$distro" = "bookworm" ]; then
        echo "bookworm-1_amd64" # Always use amd64 suffix for Bookworm
    fi
}

function depends_wine() {
    if compareVersions $__version lt 4.7.7; then
        md_ret_errors+=("Sorry, you need to be running RetroPie v4.7.7 or later")
        return 1
    fi

    local os_info=($(_get_os_info))
    local arch="${os_info[1]}"
    
    if isPlatform "rpi"; then
        if [ "$(uname -m)" = "armv7l" ] || [ "$(uname -m)" = "i386" ]; then
            if ! rp_isInstalled "box86"; then
                md_ret_errors+=("Sorry, you need to install the Box86 scriptmodule for 32-bit systems")
                return 1
            fi
        elif [ "$(uname -m)" = "x86_64" ] || [ "$(uname -m)" = "aarch64" ]; then
            if ! rp_isInstalled "box64"; then
                md_ret_errors+=("Sorry, you need to install the Box64 scriptmodule for 64-bit systems")
                return 1
            fi
        fi
    fi
    
    getDepends timidity-daemon timidity fluid-soundfont-gm xorg
}

function install_bin_wine() {
    local version="$(_latest_ver_wine)"
    local releaseType="$(_release_type_wine)"
    local releaseDist="$(_release_distribution)"
    local os_info=($(_get_os_info))
    local distro="${os_info[0]}"
    local arch="${os_info[1]}"
    
    # For Bookworm, always use binary-amd64 directory
    local binary_dir="binary-i386"
    if [ "$distro" = "bookworm" ] || [ "$arch" = "amd64" ]; then
        binary_dir="binary-amd64"
    fi

    local baseURL="https://dl.winehq.org/wine-builds/debian/dists/${distro}/main/${binary_dir}/"
    
    local workingDir="$__tmpdir/wine-${releaseType}-${version}/"
    mkdir -p "${workingDir}"
    pushd "${workingDir}"

    # Download architecture-specific package
    local package1="wine-${releaseType}-${arch}_${version}~${releaseDist}.deb"
    local getdeb1="${baseURL}${package1}"
    
    if ! wget -nv -O "$package1" "$getdeb1"; then
        md_ret_errors+=("Failed to download package: $getdeb1")
        return 1
    fi

    # Download common files package (from same directory)
    local package2="wine-${releaseType}_${version}~${releaseDist}.deb"
    local getdeb2="${baseURL}${package2}"
    
    if ! wget -nv -O "$package2" "$getdeb2"; then
        md_ret_errors+=("Failed to download package: $getdeb2")
        return 1
    fi

    # Extract both packages
    for package in "$package1" "$package2"; do
        local pkgdir="${package%.deb}"
        mkdir -p "$pkgdir"
        pushd "$pkgdir"
        ar x "../${package}"
        tar xvf data.tar.xz || return 1
        cp -R opt/wine-${releaseType}/* "$md_inst"
        popd
    done
    
    # Install Winetricks
    wget -nv -O winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks || return 1
    cp winetricks "$md_inst/bin/"
    chmod a+rx "$md_inst/bin/winetricks"
    
    popd
}

function configure_wine() {
    local system="wine"
    local os_info=($(_get_os_info))
    local arch="${os_info[1]}"
    
    # Determine the correct wine binary to use
    local wine_binary="wine"
    if [ "$arch" = "amd64" ]; then  # Includes both x86_64 and arm64
        wine_binary="wine64"
    fi

    local winedesktop_xinit="$md_inst/winedesktop_xinit.sh"
    local wineexplorer_xinit="$md_inst/wineexplorer_xinit.sh"
    local winecfg_xinit="$md_inst/winecfg_xinit.sh"
    local winetricks_xinit="$md_inst/winetricks_xinit.sh"
    
    # Create wine prefix (using correct binary)
    sudo -u pi WINEDEBUG=-all LD_LIBRARY_PATH="/opt/retropie/supplementary/mesa/lib/" \
        setarch linux32 -L "$md_inst/bin/$wine_binary" winecfg /v win7
    
    # Create scripts with correct binary paths
    cat > "$winedesktop_xinit" << _EOFDESKTOP_
#!/bin/bash
export PATH="/opt/retropie/ports/wine/bin:\$PATH"
xset -dpms s off s noblank
matchbox-window-manager &
WINEDEBUG=-all LD_LIBRARY_PATH="/opt/retropie/supplementary/mesa/lib/" \
setarch linux32 -L $wine_binary explorer /desktop=shell,\`xrandr | grep current | sed 's/.*current //; s/,.*//; s/ //g'\`
_EOFDESKTOP_

    cat > "$wineexplorer_xinit" << _EOFEXPLORER_
#!/bin/bash
export PATH="/opt/retropie/ports/wine/bin:\$PATH"
xset -dpms s off s noblank
matchbox-window-manager &
WINEDEBUG=-all LD_LIBRARY_PATH="/opt/retropie/supplementary/mesa/lib/" \
setarch linux32 -L $wine_binary explorer /desktop=shell,\`xrandr | grep current | sed 's/.*current //; s/,.*//; s/ //g'\` explorer
_EOFEXPLORER_

    cat > "$winecfg_xinit" << _EOFCONFIG_
#!/bin/bash
export PATH="/opt/retropie/ports/wine/bin:\$PATH"
xset -dpms s off s noblank
matchbox-window-manager &
WINEDEBUG=-all LD_LIBRARY_PATH="/opt/retropie/supplementary/mesa/lib/" \
setarch linux32 -L $wine_binary explorer /desktop=shell,\`xrandr | grep current | sed 's/.*current //; s/,.*//; s/ //g'\` winecfg
_EOFCONFIG_

    cat > "$winetricks_xinit" << _EOFTRICKS_
#!/bin/bash
export PATH="/opt/retropie/ports/wine/bin:\$PATH"
xset -dpms s off s noblank
matchbox-window-manager &
BOX86_NOBANNER=1 WINEDEBUG=-all LD_LIBRARY_PATH="/opt/retropie/supplementary/mesa/lib/" \
setarch linux32 -L winetricks
_EOFTRICKS_

    # Make scripts executable
    chmod +x "$winedesktop_xinit" "$wineexplorer_xinit" "$winecfg_xinit" "$winetricks_xinit"

    # Add ports
    addPort "$md_id" "winedesktop" "Wine Desktop" "XINIT:$winedesktop_xinit"
    addPort "$md_id" "wineexplorer" "Wine Explorer" "XINIT:$wineexplorer_xinit"
    addPort "$md_id" "winecfg" "Wine Config" "XINIT:$winecfg_xinit"
    addPort "$md_id" "winetricks" "Winetricks" "XINIT:$winetricks_xinit"
}