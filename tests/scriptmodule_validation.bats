#!/usr/bin/env bats

# Validates the structure and required fields of all scriptmodule files.
#
# Every scriptmodule must:
#   - Have a bash shebang line
#   - Declare rp_module_id, rp_module_desc, rp_module_section
#   - Have valid bash syntax
#   - Reside in one of the four expected section directories

REPO_ROOT="$BATS_TEST_DIRNAME/.."
SCRIPTMODULES="$REPO_ROOT/scriptmodules"

# ---------------------------------------------------------------
# Directory structure
# ---------------------------------------------------------------

@test "scriptmodules directory exists" {
    [[ -d "$SCRIPTMODULES" ]]
}

@test "emulators directory exists" {
    [[ -d "$SCRIPTMODULES/emulators" ]]
}

@test "libretrocores directory exists" {
    [[ -d "$SCRIPTMODULES/libretrocores" ]]
}

@test "ports directory exists" {
    [[ -d "$SCRIPTMODULES/ports" ]]
}

@test "supplementary directory exists" {
    [[ -d "$SCRIPTMODULES/supplementary" ]]
}

@test "no unexpected top-level directories in scriptmodules" {
    local expected="emulators libretrocores ports supplementary"
    local actual
    actual="$(find "$SCRIPTMODULES" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort | tr '\n' ' ' | sed 's/ $//')"
    [[ "$actual" == "$expected" ]]
}

@test "scriptmodules contains at least 200 scripts" {
    local count
    count="$(find "$SCRIPTMODULES" -mindepth 2 -maxdepth 2 -name '*.sh' -type f | wc -l)"
    [[ "$count" -ge 200 ]]
}

# ---------------------------------------------------------------
# Shebang line
# ---------------------------------------------------------------

@test "all top-level scriptmodules have a bash shebang" {
    # Known exceptions (pre-existing issues in the repo):
    #   - golang-1.17.sh: missing shebang, starts with a comment
    local known_exceptions="golang-1.17.sh"
    local failures=()
    while IFS= read -r script; do
        local basename
        basename="$(basename "$script")"
        echo "$known_exceptions" | grep -qw "$basename" && continue
        local first_line
        first_line="$(head -1 "$script")"
        # Allow #!/usr/bin/env bash or #! /usr/bin/env bash or empty (some scripts skip it)
        if [[ -n "$first_line" ]] && ! echo "$first_line" | grep -qE '^#!\s*/usr/bin/env\s+bash'; then
            failures+=("$script: $first_line")
        fi
    done < <(find "$SCRIPTMODULES" -mindepth 2 -maxdepth 2 -name '*.sh' -type f)

    if [[ ${#failures[@]} -gt 0 ]]; then
        printf 'Missing/wrong shebang:\n'
        printf '  %s\n' "${failures[@]}"
        return 1
    fi
}

@test "known shebang issues are documented" {
    # This test ensures we track the known exception; remove entries as they are fixed
    local first_line
    first_line="$(head -1 "$SCRIPTMODULES/supplementary/golang-1.17.sh")"
    # Expect it still lacks a proper shebang (will fail once it's fixed -- update test then)
    ! echo "$first_line" | grep -qE '^#!\s*/usr/bin/env\s+bash'
}

# ---------------------------------------------------------------
# Required metadata fields
# ---------------------------------------------------------------

@test "all scriptmodules declare rp_module_id" {
    local failures=()
    while IFS= read -r script; do
        if ! grep -q 'rp_module_id=' "$script"; then
            failures+=("$script")
        fi
    done < <(find "$SCRIPTMODULES" -mindepth 2 -maxdepth 2 -name '*.sh' -type f)

    if [[ ${#failures[@]} -gt 0 ]]; then
        printf 'Missing rp_module_id:\n'
        printf '  %s\n' "${failures[@]}"
        return 1
    fi
}

@test "all scriptmodules declare rp_module_desc" {
    local failures=()
    while IFS= read -r script; do
        if ! grep -q 'rp_module_desc=' "$script"; then
            failures+=("$script")
        fi
    done < <(find "$SCRIPTMODULES" -mindepth 2 -maxdepth 2 -name '*.sh' -type f)

    if [[ ${#failures[@]} -gt 0 ]]; then
        printf 'Missing rp_module_desc:\n'
        printf '  %s\n' "${failures[@]}"
        return 1
    fi
}

@test "all scriptmodules declare rp_module_section" {
    local failures=()
    while IFS= read -r script; do
        if ! grep -q 'rp_module_section=' "$script"; then
            failures+=("$script")
        fi
    done < <(find "$SCRIPTMODULES" -mindepth 2 -maxdepth 2 -name '*.sh' -type f)

    if [[ ${#failures[@]} -gt 0 ]]; then
        printf 'Missing rp_module_section:\n'
        printf '  %s\n' "${failures[@]}"
        return 1
    fi
}

@test "rp_module_id values are non-empty" {
    local failures=()
    while IFS= read -r script; do
        local id
        id="$(grep -m1 'rp_module_id=' "$script" | sed 's/.*rp_module_id=//;s/"//g;s/'\''//g')"
        if [[ -z "$id" ]]; then
            failures+=("$script")
        fi
    done < <(find "$SCRIPTMODULES" -mindepth 2 -maxdepth 2 -name '*.sh' -type f)

    if [[ ${#failures[@]} -gt 0 ]]; then
        printf 'Empty rp_module_id:\n'
        printf '  %s\n' "${failures[@]}"
        return 1
    fi
}

@test "rp_module_desc values are non-empty" {
    local failures=()
    while IFS= read -r script; do
        local desc
        desc="$(grep -m1 'rp_module_desc=' "$script" | sed 's/.*rp_module_desc=//;s/"//g;s/'\''//g')"
        if [[ -z "$desc" ]]; then
            failures+=("$script")
        fi
    done < <(find "$SCRIPTMODULES" -mindepth 2 -maxdepth 2 -name '*.sh' -type f)

    if [[ ${#failures[@]} -gt 0 ]]; then
        printf 'Empty rp_module_desc:\n'
        printf '  %s\n' "${failures[@]}"
        return 1
    fi
}

@test "rp_module_section values are valid" {
    local valid_sections='exp opt depends'
    local failures=()
    while IFS= read -r script; do
        local section
        section="$(grep -m1 'rp_module_section=' "$script" | sed 's/.*rp_module_section=//;s/"//g;s/'\''//g')"
        # Section may contain platform-specific overrides like "exp x86=opt"
        local base_section
        base_section="$(echo "$section" | awk '{print $1}')"
        if ! echo "$valid_sections" | grep -qw "$base_section"; then
            failures+=("$script: section=$section")
        fi
    done < <(find "$SCRIPTMODULES" -mindepth 2 -maxdepth 2 -name '*.sh' -type f)

    if [[ ${#failures[@]} -gt 0 ]]; then
        printf 'Invalid rp_module_section:\n'
        printf '  %s\n' "${failures[@]}"
        return 1
    fi
}

# ---------------------------------------------------------------
# No duplicate rp_module_id values
# ---------------------------------------------------------------

@test "no duplicate rp_module_id values across all scriptmodules" {
    local ids_file
    ids_file="$(mktemp)"
    while IFS= read -r script; do
        local id
        id="$(grep -m1 'rp_module_id=' "$script" | sed 's/.*rp_module_id=//;s/"//g;s/'\''//g')"
        echo "$id" >> "$ids_file"
    done < <(find "$SCRIPTMODULES" -mindepth 2 -maxdepth 2 -name '*.sh' -type f)

    local dupes
    dupes="$(sort "$ids_file" | uniq -d)"
    rm -f "$ids_file"

    if [[ -n "$dupes" ]]; then
        printf 'Duplicate rp_module_id values:\n%s\n' "$dupes"
        return 1
    fi
}

# ---------------------------------------------------------------
# Bash syntax check
# ---------------------------------------------------------------

@test "all scriptmodules pass bash syntax check (excluding known issues)" {
    # Known pre-existing syntax errors in the repo:
    local known_broken="lr-bsnes-jg.sh lr-gearcoleco.sh lr-bsnes-hd.sh"
    local failures=()
    while IFS= read -r script; do
        local basename
        basename="$(basename "$script")"
        echo "$known_broken" | grep -qw "$basename" && continue
        if ! bash -n "$script" 2>/dev/null; then
            failures+=("$script")
        fi
    done < <(find "$SCRIPTMODULES" -mindepth 2 -maxdepth 2 -name '*.sh' -type f)

    if [[ ${#failures[@]} -gt 0 ]]; then
        printf 'Bash syntax errors:\n'
        printf '  %s\n' "${failures[@]}"
        return 1
    fi
}

@test "known syntax-error scripts are documented" {
    # These scripts have pre-existing syntax errors; remove entries as they are fixed
    ! bash -n "$SCRIPTMODULES/libretrocores/lr-bsnes-jg.sh" 2>/dev/null
    ! bash -n "$SCRIPTMODULES/libretrocores/lr-gearcoleco.sh" 2>/dev/null
    ! bash -n "$SCRIPTMODULES/libretrocores/lr-bsnes-hd.sh" 2>/dev/null
}

@test "install-extras.sh passes bash syntax check" {
    bash -n "$REPO_ROOT/install-extras.sh"
}

# ---------------------------------------------------------------
# File permissions
# ---------------------------------------------------------------

@test "install-extras.sh is executable" {
    [[ -x "$REPO_ROOT/install-extras.sh" ]]
}

@test "remove-extras.sh is executable" {
    [[ -x "$REPO_ROOT/remove-extras.sh" ]]
}

@test "update-extras.sh is executable" {
    [[ -x "$REPO_ROOT/update-extras.sh" ]]
}

# ---------------------------------------------------------------
# Section-specific counts (sanity checks)
# ---------------------------------------------------------------

@test "emulators section has at least 10 scripts" {
    local count
    count="$(find "$SCRIPTMODULES/emulators" -maxdepth 1 -name '*.sh' -type f | wc -l)"
    [[ "$count" -ge 10 ]]
}

@test "libretrocores section has at least 30 scripts" {
    local count
    count="$(find "$SCRIPTMODULES/libretrocores" -maxdepth 1 -name '*.sh' -type f | wc -l)"
    [[ "$count" -ge 30 ]]
}

@test "ports section has at least 100 scripts" {
    local count
    count="$(find "$SCRIPTMODULES/ports" -maxdepth 1 -name '*.sh' -type f | wc -l)"
    [[ "$count" -ge 100 ]]
}

@test "supplementary section has at least 10 scripts" {
    local count
    count="$(find "$SCRIPTMODULES/supplementary" -maxdepth 1 -name '*.sh' -type f | wc -l)"
    [[ "$count" -ge 10 ]]
}

# ---------------------------------------------------------------
# Data directories
# ---------------------------------------------------------------

@test "data directories have corresponding script files" {
    # Some data directories are shared by multiple scripts (e.g. supermodel/
    # is used by supermodel-svn.sh and supermodel-mechafatnick.sh). These are
    # expected and tracked here.
    local known_shared="supermodel openxcom"
    local failures=()
    while IFS= read -r datadir; do
        local dirname
        dirname="$(basename "$datadir")"
        echo "$known_shared" | grep -qw "$dirname" && continue
        local script="${datadir}.sh"
        if [[ ! -f "$script" ]]; then
            failures+=("$datadir (no matching .sh)")
        fi
    done < <(find "$SCRIPTMODULES" -mindepth 2 -maxdepth 2 -type d)

    if [[ ${#failures[@]} -gt 0 ]]; then
        printf 'Data directories without matching scripts:\n'
        printf '  %s\n' "${failures[@]}"
        return 1
    fi
}

@test "shared data directories are documented" {
    # These data dirs are used by multiple scripts with different names
    [[ -d "$SCRIPTMODULES/emulators/supermodel" ]]
    [[ -d "$SCRIPTMODULES/ports/openxcom" ]]
}
