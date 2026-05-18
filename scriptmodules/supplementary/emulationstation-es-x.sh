#!/usr/bin/env bash

# ============================================================
#  EmulationStation-X (ES-X) for RetroPie
#  Experimental fork with .ini language support + theme system
#  by Renetrox
#
#  This module installs ES-X as the main EmulationStation frontend.
#  It uses RetroPie's existing EmulationStation build/install logic,
#  but fetches the ES-X source instead.
#
#  Includes:
#  - ES-X language files
#  - Theme Browser previews
#  - Skyscraper helper script
#  - Optional Skyscraper configuration files
#  - ES-X music folders
#  - Default ES-X theme installation
#
#  IMPORTANT:
#  This module does NOT call:
#      rp_callModule "emulationstation" remove
#
#  ES-X reuses the EmulationStation module logic. Removing the base
#  module during configure can remove files needed by ES-X itself.
# ============================================================

# ------------------------------------------------------------
# RetroPie user compatibility
# ------------------------------------------------------------

if [[ -z "$__user" ]]; then
    __user="$SUDO_USER"
    [[ -z "$__user" ]] && __user="$(id -un)"
fi

rp_module_id="emulationstation-es-x"
rp_module_desc="EmulationStation-X (ES-X) - Experimental fork with .ini language and theme enhancements"
rp_module_help="After installing, ES-X becomes the main frontend.\n\nIncludes:\n- .ini language support\n- Theme Browser previews\n- default ES-X theme\n- Skyscraper integration\n- background music folders\n\nMusic folders:\n$home/RetroPie/music\n$home/.emulationstation/music\n\nRecommended: back up $home/.emulationstation before installing."
rp_module_section="exp"
rp_module_flags="frontend"

rp_module_licence="MIT https://github.com/Aloshi/EmulationStation/blob/master/LICENSE"

# ES-X repository
rp_module_repo="git https://github.com/Renetrox/EmulationStation-X main"

# ------------------------------------------------------------
# Link to base EmulationStation build system
# ------------------------------------------------------------

function _update_hook_emulationstation-es-x() {
    _update_hook_emulationstation
}

# ES-X needs SDL2_mixer headers
function depends_emulationstation-es-x() {
    depends_emulationstation
    getDepends libsdl2-mixer-dev rsync
}

function sources_emulationstation-es-x() {
    sources_emulationstation
}

function build_emulationstation-es-x() {
    build_emulationstation
}

function install_emulationstation-es-x() {
    install_emulationstation
}

# ------------------------------------------------------------
# Helpers
# ------------------------------------------------------------

function esx_resolve_path() {
    local p

    for p in "$@"; do
        if [[ -e "$p" ]]; then
            echo "$p"
            return 0
        fi
    done

    return 1
}

function esx_resolve_dir() {
    local p

    for p in "$@"; do
        if [[ -d "$p" ]]; then
            echo "$p"
            return 0
        fi
    done

    return 1
}

function esx_chown() {
    local target="$1"

    if [[ -n "$target" && -e "$target" ]]; then
        chown "$__user:$__user" "$target" 2>/dev/null || true
    fi
}

function esx_chown_recursive() {
    local target="$1"

    if [[ -n "$target" && -e "$target" ]]; then
        chown -R "$__user:$__user" "$target" 2>/dev/null || true
    fi
}

function esx_set_es_setting() {
    local file="$1"
    local type="$2"
    local name="$3"
    local value="$4"

    mkUserDir "$(dirname "$file")"

    if [[ ! -f "$file" ]]; then
        cat > "$file" <<EOF
<?xml version="1.0"?>
<config>
</config>
EOF
    fi

    if ! grep -q "<config>" "$file"; then
        local backup="${file}.bak.$(date +%Y%m%d-%H%M%S)"
        cp -f "$file" "$backup"

        cat > "$file" <<EOF
<?xml version="1.0"?>
<config>
</config>
EOF

        echo "WARNING: Invalid es_settings.cfg detected. Backup created at: $backup"
    fi

    if grep -q "<$type name=\"$name\"" "$file"; then
        sed -i "s|<$type name=\"$name\" value=\".*\" */>|<$type name=\"$name\" value=\"$value\" />|g" "$file"
    else
        sed -i "s|</config>|    <$type name=\"$name\" value=\"$value\" />\n</config>|" "$file"
    fi

    esx_chown "$file"
}

function esx_install_file_with_backup() {
    local src="$1"
    local dst="$2"
    local label="$3"

    if [[ -z "$src" || ! -f "$src" ]]; then
        echo "WARNING: No '$label' found in ES-X source."
        return 1
    fi

    mkUserDir "$(dirname "$dst")"

    if [[ -f "$dst" ]]; then
        local bak="${dst}.bak.$(date +%Y%m%d-%H%M%S)"
        echo "Existing $label found — backing up to $(basename "$bak")"
        cp -f "$dst" "$bak"
        chmod 644 "$bak"
        esx_chown "$bak"
    fi

    cp -f "$src" "$dst"
    chmod 644 "$dst"
    esx_chown "$dst"

    echo "$label installed at $dst"
    return 0
}

function esx_install_executable() {
    local src="$1"
    local dst="$2"
    local label="$3"

    if [[ -z "$src" || ! -f "$src" ]]; then
        echo "WARNING: No '$label' found in ES-X source."
        return 1
    fi

    mkUserDir "$(dirname "$dst")"

    cp -f "$src" "$dst"
    chmod 755 "$dst"
    esx_chown "$dst"

    echo "$label installed at $dst"
    return 0
}

# ------------------------------------------------------------
# ES-X resource installers
# ------------------------------------------------------------

function esx_install_lang_files() {
    echo "Installing ES-X language files..."

    local lang_dst="$home/.emulationstation/lang"
    local lang_src=""

    lang_src="$(esx_resolve_dir \
        "$md_build/lang" \
        "$md_build/resources/lang" \
        "$md_inst/lang" \
        "$md_inst/resources/lang" \
    )"

    if [[ -n "$lang_src" && -d "$lang_src" ]]; then
        mkUserDir "$lang_dst"

        if command -v rsync >/dev/null 2>&1; then
            rsync -a --update "$lang_src"/ "$lang_dst"/ 2>/dev/null
        else
            cp -uv "$lang_src"/*.ini "$lang_dst"/ 2>/dev/null || true
            cp -ru "$lang_src"/. "$lang_dst"/ 2>/dev/null || true
        fi

        esx_chown_recursive "$lang_dst"
        echo "Language files installed at $lang_dst"
    else
        echo "WARNING: No 'lang' folder found for ES-X."
    fi
}

function esx_install_skyscraper_helper() {
    echo "Installing ES-X Skyscraper helper script..."

    local scripts_dir="$home/.emulationstation/scripts"
    local sky_script_dst="$scripts_dir/skyscraper-esx.sh"
    local sky_script_src=""

    sky_script_src="$(esx_resolve_path \
        "$md_build/resources/skyscraper-esx.sh" \
        "$md_build/skyscraper-esx.sh" \
        "$md_inst/resources/skyscraper-esx.sh" \
        "$md_inst/skyscraper-esx.sh" \
    )"

    esx_install_executable "$sky_script_src" "$sky_script_dst" "skyscraper-esx.sh"
}

function esx_install_skyscraper_config() {
    echo "Installing ES-X Skyscraper configuration files..."

    local sky_cfg_dir="$home/.skyscraper"
    local artwork_src=""
    local sky_config_src=""

    mkUserDir "$sky_cfg_dir"

    artwork_src="$(esx_resolve_path \
        "$md_build/resources/artwork.xml" \
        "$md_build/artwork.xml" \
        "$md_inst/resources/artwork.xml" \
        "$md_inst/artwork.xml" \
    )"

    sky_config_src="$(esx_resolve_path \
        "$md_build/resources/config.ini" \
        "$md_build/config.ini" \
        "$md_inst/resources/config.ini" \
        "$md_inst/config.ini" \
    )"

    esx_install_file_with_backup "$artwork_src" "$sky_cfg_dir/artwork.xml" "artwork.xml"
    esx_install_file_with_backup "$sky_config_src" "$sky_cfg_dir/config.ini" "config.ini"

    esx_chown_recursive "$sky_cfg_dir"
}

function esx_install_theme_previews() {
    echo "Installing ES-X theme previews for Theme Browser..."

    local esx_root="$home/.emulationstation/esx"
    local previews_dst="$esx_root/theme-previews"
    local previews_src=""

    previews_src="$(esx_resolve_dir \
        "$md_build/esx/theme-previews" \
        "$md_build/resources/esx/theme-previews" \
        "$md_inst/esx/theme-previews" \
        "$md_inst/resources/esx/theme-previews" \
    )"

    if [[ -n "$previews_src" && -d "$previews_src" ]]; then
        mkUserDir "$previews_dst"

        # INI files are catalog data. Update them.
        if compgen -G "$previews_src"/*.ini > /dev/null; then
            cp -uv "$previews_src"/*.ini "$previews_dst"/ 2>/dev/null || true
        fi

        # Images/folders are merged without deleting user extras.
        if command -v rsync >/dev/null 2>&1; then
            rsync -a --ignore-existing --exclude="*.ini" "$previews_src"/ "$previews_dst"/ 2>/dev/null
        else
            cp -ruv "$previews_src"/. "$previews_dst"/ 2>/dev/null || true
        fi

        find "$previews_dst" -type f -exec chmod 644 {} \; 2>/dev/null || true
        find "$previews_dst" -type d -exec chmod 755 {} \; 2>/dev/null || true

        esx_chown_recursive "$esx_root"
        echo "Theme previews installed/updated at $previews_dst"
    else
        echo "WARNING: No 'esx/theme-previews' folder found in ES-X source."
    fi
}

function esx_create_music_dirs() {
    echo "Ensuring ES-X music folders exist..."

    local music_dir_1="$home/RetroPie/music"
    local music_dir_2="$home/.emulationstation/music"
    local music_src=""

    mkUserDir "$music_dir_1"
    mkUserDir "$music_dir_2"

    music_src="$(esx_resolve_dir \
        "$md_build/music" \
        "$md_build/resources/music" \
        "$md_inst/music" \
        "$md_inst/resources/music" \
    )"

    if [[ -n "$music_src" && -d "$music_src" ]]; then
        if [[ -z "$(ls -A "$music_dir_1" 2>/dev/null)" ]]; then
            echo "Copying bundled default music to $music_dir_1..."
            cp -ruv "$music_src"/. "$music_dir_1"/ 2>/dev/null || true
        else
            echo "Music folder already has files — leaving untouched."
        fi
    else
        echo "No bundled music found. Music folders created only."
    fi

    esx_chown_recursive "$music_dir_1"
    esx_chown_recursive "$music_dir_2"
}

function esx_check_or_install_skyscraper() {
    echo "Checking Skyscraper installation..."

    local skyscraper_bin=""
    skyscraper_bin="$(command -v Skyscraper 2>/dev/null || true)"

    if [[ -z "$skyscraper_bin" ]]; then
        local sky_candidate

        for sky_candidate in \
            "/usr/local/bin/Skyscraper" \
            "/usr/bin/Skyscraper" \
            "$home/RetroPie-Setup/tmp/build/skyscraper/Skyscraper"
        do
            if [[ -x "$sky_candidate" ]]; then
                skyscraper_bin="$sky_candidate"
                break
            fi
        done
    fi

    if [[ -n "$skyscraper_bin" && -x "$skyscraper_bin" ]]; then
        echo "Skyscraper already installed at: $skyscraper_bin"
    else
        echo "Skyscraper not found. Trying to install via RetroPie-Setup module..."

        if rp_callModule "skyscraper"; then
            echo "Skyscraper installation completed."
        else
            echo "WARNING: Skyscraper could not be installed automatically."
            echo "ES-X will still be installed, but scraping integration may not work until Skyscraper is installed."
        fi
    fi
}

function esx_install_theme() {
    local repo="$1"
    local folder="$2"
    local themes_dir="$home/.emulationstation/themes"
    local target="$themes_dir/$folder"

    mkUserDir "$themes_dir"

    if [[ -d "$target/.git" ]]; then
        echo "Checking updates for theme: $folder"

        git -C "$target" fetch --quiet

        if git -C "$target" status -uno | grep -q "behind"; then
            echo "Updating theme: $folder"
            git -C "$target" pull --ff-only
        else
            echo "Theme already up to date: $folder"
        fi

        esx_chown_recursive "$target"

    elif [[ -d "$target" ]]; then
        echo "Theme folder exists but is not a git repository: $folder — leaving untouched."

    else
        echo "Cloning theme: $folder"

        if git clone --depth 1 "$repo" "$target"; then
            esx_chown_recursive "$target"
        else
            echo "WARNING: Could not clone theme: $folder"
        fi
    fi
}

function esx_install_default_themes() {
    echo "Installing ES-X themes..."

    esx_install_theme "https://github.com/Renetrox/Alekfull-nx-retropie" "Alekfull-nx-retropie"

    echo "Themes installed."
}

function esx_apply_default_settings() {
    echo "Applying ES-X default settings if needed..."

    local es_settings="$home/.emulationstation/es_settings.cfg"
    local default_theme="Alekfull-nx-retropie"

    if [[ ! -f "$es_settings" ]] || ! grep -q "<string name=\"ThemeSet\"" "$es_settings"; then
        if [[ -d "$home/.emulationstation/themes/$default_theme" ]]; then
            echo "Applying default ES-X theme: $default_theme"
            esx_set_es_setting "$es_settings" "string" "ThemeSet" "$default_theme"
        else
            echo "Default theme '$default_theme' was not found. Leaving ThemeSet unchanged."
        fi
    else
        echo "Theme already configured by user — not changing."
    fi

    # If IMP is installed, avoid two background music systems fighting.
    if [[ -d "/opt/retropie/configs/imp" ]] || [[ -d "$home/imp" ]]; then
        echo "IMP found. Disabling ES-X built-in background music."
        esx_set_es_setting "$es_settings" "bool" "BackgroundMusic" "false"
    fi
}

# ------------------------------------------------------------
# Configure
# ------------------------------------------------------------

function configure_emulationstation-es-x() {
    echo "Configuring EmulationStation-X..."

    # Do NOT remove the original emulationstation module here.
    # ES-X reuses the base EmulationStation install/configure logic.
    echo "Running base EmulationStation configure logic..."
    configure_emulationstation

    esx_check_or_install_skyscraper
    esx_install_lang_files
    esx_install_skyscraper_helper
    esx_install_skyscraper_config
    esx_install_theme_previews
    esx_create_music_dirs
    esx_install_default_themes
    esx_apply_default_settings

    echo "ES-X configuration complete."
}

# ------------------------------------------------------------
# Remove / GUI
# ------------------------------------------------------------

function remove_emulationstation-es-x() {
    remove_emulationstation
}

function gui_emulationstation-es-x() {
    gui_emulationstation
}
