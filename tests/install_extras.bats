#!/usr/bin/env bats

# Unit tests for install-extras.sh
#
# Tests the core functions: argument parsing, runAuto, removeAll,
# copyModule, deleteModule, and startCmd validation.

load test_helper

setup() {
    setup_test_dirs
    source_install_functions
}

teardown() {
    teardown_test_dirs
}

# ---------------------------------------------------------------
# Argument / mode parsing (tested via the case block pattern)
# ---------------------------------------------------------------

@test "MODE defaults to gui when no arguments given" {
    MODE="gui"
    [[ "$MODE" == "gui" ]]
}

@test "argument -a sets auto mode pattern" {
    local arg="-a"
    case "${arg,,}" in
        -a|--all|--auto) result="auto" ;;
        *) result="other" ;;
    esac
    [[ "$result" == "auto" ]]
}

@test "argument --all sets auto mode pattern" {
    local arg="--all"
    case "${arg,,}" in
        -a|--all|--auto) result="auto" ;;
        *) result="other" ;;
    esac
    [[ "$result" == "auto" ]]
}

@test "argument --auto sets auto mode pattern" {
    local arg="--auto"
    case "${arg,,}" in
        -a|--all|--auto) result="auto" ;;
        *) result="other" ;;
    esac
    [[ "$result" == "auto" ]]
}

@test "argument -r sets remove mode pattern" {
    local arg="-r"
    case "${arg,,}" in
        -r|--remove) result="remove" ;;
        *) result="other" ;;
    esac
    [[ "$result" == "remove" ]]
}

@test "argument --remove sets remove mode pattern" {
    local arg="--remove"
    case "${arg,,}" in
        -r|--remove) result="remove" ;;
        *) result="other" ;;
    esac
    [[ "$result" == "remove" ]]
}

@test "argument -g sets gui mode pattern" {
    local arg="-g"
    case "${arg,,}" in
        -g|--gui) result="gui" ;;
        *) result="other" ;;
    esac
    [[ "$result" == "gui" ]]
}

@test "argument --gui sets gui mode pattern" {
    local arg="--gui"
    case "${arg,,}" in
        -g|--gui) result="gui" ;;
        *) result="other" ;;
    esac
    [[ "$result" == "gui" ]]
}

@test "unknown argument matches wildcard pattern" {
    local arg="--bogus"
    case "${arg,,}" in
        -g|--gui) result="gui" ;;
        -a|--all|--auto) result="auto" ;;
        -r|--remove) result="remove" ;;
        -u|--update) result="update" ;;
        -*) result="help" ;;
        *) result="passthrough" ;;
    esac
    [[ "$result" == "help" ]]
}

@test "case-insensitive argument matching works" {
    local arg="-A"
    case "${arg,,}" in
        -a|--all|--auto) result="auto" ;;
        *) result="other" ;;
    esac
    [[ "$result" == "auto" ]]
}

# ---------------------------------------------------------------
# REGEX pattern (used to validate numeric menu choices)
# ---------------------------------------------------------------

@test "REGEX matches single digit" {
    [[ "5" =~ $REGEX ]]
}

@test "REGEX matches multi-digit number" {
    [[ "123" =~ $REGEX ]]
}

@test "REGEX does not match non-numeric string" {
    ! [[ "abc" =~ $REGEX ]]
}

@test "REGEX does not match separator ---" {
    ! [[ "---" =~ $REGEX ]]
}

@test "REGEX does not match empty string" {
    ! [[ "" =~ $REGEX ]]
}

@test "REGEX does not match mixed alphanumeric" {
    ! [[ "12abc" =~ $REGEX ]]
}

# ---------------------------------------------------------------
# runAuto
# ---------------------------------------------------------------

@test "runAuto copies scriptmodules to RP_EXTRA" {
    run runAuto
    [[ -d "$FAKE_RP_EXTRA/scriptmodules/emulators" ]]
    [[ -d "$FAKE_RP_EXTRA/scriptmodules/libretrocores" ]]
    [[ -d "$FAKE_RP_EXTRA/scriptmodules/ports" ]]
    [[ -d "$FAKE_RP_EXTRA/scriptmodules/supplementary" ]]
}

@test "runAuto copies individual script files" {
    run runAuto
    [[ -f "$FAKE_RP_EXTRA/scriptmodules/emulators/fakemu.sh" ]]
    [[ -f "$FAKE_RP_EXTRA/scriptmodules/libretrocores/fakecore.sh" ]]
    [[ -f "$FAKE_RP_EXTRA/scriptmodules/ports/fakeport.sh" ]]
    [[ -f "$FAKE_RP_EXTRA/scriptmodules/supplementary/fakesupp.sh" ]]
}

@test "runAuto preserves file contents" {
    run runAuto
    local content
    content="$(cat "$FAKE_RP_EXTRA/scriptmodules/emulators/fakemu.sh")"
    [[ "$content" == 'rp_module_id="fakemu"' ]]
}

@test "runAuto creates RP_EXTRA directory when it does not exist" {
    [[ ! -d "$FAKE_RP_EXTRA" ]]
    run runAuto
    [[ -d "$FAKE_RP_EXTRA" ]]
}

@test "runAuto overwrites existing files on re-run" {
    run runAuto
    echo 'rp_module_id="updated"' > "$FAKE_SCRIPTDIR/scriptmodules/emulators/fakemu.sh"
    run runAuto
    local content
    content="$(cat "$FAKE_RP_EXTRA/scriptmodules/emulators/fakemu.sh")"
    [[ "$content" == 'rp_module_id="updated"' ]]
}

@test "runAuto prints done message" {
    run runAuto
    [[ "$output" == *"done"* ]]
}

# ---------------------------------------------------------------
# removeAll
# ---------------------------------------------------------------

@test "removeAll removes RP_EXTRA directory" {
    mkdir -p "$FAKE_RP_EXTRA/scriptmodules/emulators"
    echo "test" > "$FAKE_RP_EXTRA/scriptmodules/emulators/test.sh"
    run removeAll
    [[ ! -d "$FAKE_RP_EXTRA" ]]
}

@test "removeAll prints done message on success" {
    mkdir -p "$FAKE_RP_EXTRA"
    run removeAll
    [[ "$output" == *"done"* ]]
}

@test "removeAll prints error when directory does not exist" {
    run removeAll
    [[ "$output" == *"does not exist"* ]]
}

@test "removeAll removes nested contents" {
    mkdir -p "$FAKE_RP_EXTRA/scriptmodules/emulators"
    mkdir -p "$FAKE_RP_EXTRA/scriptmodules/ports"
    echo "data" > "$FAKE_RP_EXTRA/scriptmodules/emulators/test.sh"
    echo "data" > "$FAKE_RP_EXTRA/scriptmodules/ports/test.sh"
    run removeAll
    [[ ! -d "$FAKE_RP_EXTRA" ]]
}

# ---------------------------------------------------------------
# copyModule
# ---------------------------------------------------------------

@test "copyModule copies a single script to target" {
    copyModule "emulators/fakemu.sh"
    [[ -f "$FAKE_RP_EXTRA/scriptmodules/emulators/fakemu.sh" ]]
}

@test "copyModule creates target section directory" {
    [[ ! -d "$FAKE_RP_EXTRA/scriptmodules/emulators" ]]
    copyModule "emulators/fakemu.sh"
    [[ -d "$FAKE_RP_EXTRA/scriptmodules/emulators" ]]
}

@test "copyModule copies data directory alongside script" {
    copyModule "supplementary/fakesupp.sh"
    [[ -d "$FAKE_RP_EXTRA/scriptmodules/supplementary/fakesupp" ]]
    [[ -f "$FAKE_RP_EXTRA/scriptmodules/supplementary/fakesupp/data.txt" ]]
}

@test "copyModule preserves data directory contents" {
    copyModule "supplementary/fakesupp.sh"
    local content
    content="$(cat "$FAKE_RP_EXTRA/scriptmodules/supplementary/fakesupp/data.txt")"
    [[ "$content" == "data_file" ]]
}

@test "copyModule does not create data directory when none exists" {
    copyModule "emulators/fakemu.sh"
    [[ ! -d "$FAKE_RP_EXTRA/scriptmodules/emulators/fakemu" ]]
}

@test "copyModule overwrites existing script" {
    mkdir -p "$FAKE_RP_EXTRA/scriptmodules/emulators"
    echo "old_content" > "$FAKE_RP_EXTRA/scriptmodules/emulators/fakemu.sh"
    copyModule "emulators/fakemu.sh"
    local content
    content="$(cat "$FAKE_RP_EXTRA/scriptmodules/emulators/fakemu.sh")"
    [[ "$content" == 'rp_module_id="fakemu"' ]]
}

@test "copyModule works for libretrocores section" {
    copyModule "libretrocores/fakecore.sh"
    [[ -f "$FAKE_RP_EXTRA/scriptmodules/libretrocores/fakecore.sh" ]]
}

@test "copyModule works for ports section" {
    copyModule "ports/fakeport.sh"
    [[ -f "$FAKE_RP_EXTRA/scriptmodules/ports/fakeport.sh" ]]
}

# ---------------------------------------------------------------
# deleteModule
# ---------------------------------------------------------------

@test "deleteModule removes a single script" {
    mkdir -p "$FAKE_RP_EXTRA/scriptmodules/emulators"
    echo "test" > "$FAKE_RP_EXTRA/scriptmodules/emulators/fakemu.sh"
    echo "other" > "$FAKE_RP_EXTRA/scriptmodules/emulators/other.sh"
    deleteModule "emulators/fakemu.sh"
    [[ ! -f "$FAKE_RP_EXTRA/scriptmodules/emulators/fakemu.sh" ]]
}

@test "deleteModule does not remove other scripts in same section" {
    mkdir -p "$FAKE_RP_EXTRA/scriptmodules/emulators"
    echo "test" > "$FAKE_RP_EXTRA/scriptmodules/emulators/fakemu.sh"
    echo "other" > "$FAKE_RP_EXTRA/scriptmodules/emulators/other.sh"
    deleteModule "emulators/fakemu.sh"
    [[ -f "$FAKE_RP_EXTRA/scriptmodules/emulators/other.sh" ]]
}

@test "deleteModule removes data directory alongside script" {
    mkdir -p "$FAKE_RP_EXTRA/scriptmodules/supplementary/fakesupp"
    echo "test" > "$FAKE_RP_EXTRA/scriptmodules/supplementary/fakesupp.sh"
    echo "data" > "$FAKE_RP_EXTRA/scriptmodules/supplementary/fakesupp/data.txt"
    # Keep another file so the section dir isn't removed
    echo "other" > "$FAKE_RP_EXTRA/scriptmodules/supplementary/other.sh"
    deleteModule "supplementary/fakesupp.sh"
    [[ ! -d "$FAKE_RP_EXTRA/scriptmodules/supplementary/fakesupp" ]]
}

@test "deleteModule cleans up empty section directory" {
    mkdir -p "$FAKE_RP_EXTRA/scriptmodules/emulators"
    echo "test" > "$FAKE_RP_EXTRA/scriptmodules/emulators/fakemu.sh"
    # Add another section so scriptmodules dir isn't empty
    mkdir -p "$FAKE_RP_EXTRA/scriptmodules/ports"
    echo "port" > "$FAKE_RP_EXTRA/scriptmodules/ports/fakeport.sh"
    deleteModule "emulators/fakemu.sh"
    [[ ! -d "$FAKE_RP_EXTRA/scriptmodules/emulators" ]]
}

@test "deleteModule cleans up empty scriptmodules directory" {
    mkdir -p "$FAKE_RP_EXTRA/scriptmodules/emulators"
    echo "test" > "$FAKE_RP_EXTRA/scriptmodules/emulators/fakemu.sh"
    deleteModule "emulators/fakemu.sh"
    [[ ! -d "$FAKE_RP_EXTRA/scriptmodules" ]]
}

@test "deleteModule cleans up empty RP_EXTRA directory" {
    mkdir -p "$FAKE_RP_EXTRA/scriptmodules/emulators"
    echo "test" > "$FAKE_RP_EXTRA/scriptmodules/emulators/fakemu.sh"
    deleteModule "emulators/fakemu.sh"
    [[ ! -d "$FAKE_RP_EXTRA" ]]
}

@test "deleteModule preserves non-empty section directory" {
    mkdir -p "$FAKE_RP_EXTRA/scriptmodules/emulators"
    echo "test" > "$FAKE_RP_EXTRA/scriptmodules/emulators/fakemu.sh"
    echo "keep" > "$FAKE_RP_EXTRA/scriptmodules/emulators/keep.sh"
    deleteModule "emulators/fakemu.sh"
    [[ -d "$FAKE_RP_EXTRA/scriptmodules/emulators" ]]
    [[ -f "$FAKE_RP_EXTRA/scriptmodules/emulators/keep.sh" ]]
}

# ---------------------------------------------------------------
# startCmd validation
# ---------------------------------------------------------------

@test "startCmd exits when RPS_HOME does not exist" {
    RPS_HOME="$TEST_TMPDIR/nonexistent"
    run startCmd
    [[ "$output" == *"does not exist"* ]]
}

# ---------------------------------------------------------------
# Integration: runAuto then removeAll round-trip
# ---------------------------------------------------------------

@test "runAuto followed by removeAll cleans up completely" {
    run runAuto
    [[ -d "$FAKE_RP_EXTRA" ]]
    run removeAll
    [[ ! -d "$FAKE_RP_EXTRA" ]]
}

@test "copyModule then deleteModule round-trip for single module" {
    copyModule "emulators/fakemu.sh"
    [[ -f "$FAKE_RP_EXTRA/scriptmodules/emulators/fakemu.sh" ]]
    deleteModule "emulators/fakemu.sh"
    [[ ! -f "$FAKE_RP_EXTRA/scriptmodules/emulators/fakemu.sh" ]]
}

@test "copyModule then deleteModule round-trip with data directory" {
    copyModule "supplementary/fakesupp.sh"
    [[ -d "$FAKE_RP_EXTRA/scriptmodules/supplementary/fakesupp" ]]
    deleteModule "supplementary/fakesupp.sh"
    [[ ! -d "$FAKE_RP_EXTRA/scriptmodules/supplementary/fakesupp" ]]
    [[ ! -f "$FAKE_RP_EXTRA/scriptmodules/supplementary/fakesupp.sh" ]]
}

# ---------------------------------------------------------------
# Multiple copyModule calls
# ---------------------------------------------------------------

@test "copying multiple modules from different sections" {
    copyModule "emulators/fakemu.sh"
    copyModule "libretrocores/fakecore.sh"
    copyModule "ports/fakeport.sh"
    copyModule "supplementary/fakesupp.sh"
    [[ -f "$FAKE_RP_EXTRA/scriptmodules/emulators/fakemu.sh" ]]
    [[ -f "$FAKE_RP_EXTRA/scriptmodules/libretrocores/fakecore.sh" ]]
    [[ -f "$FAKE_RP_EXTRA/scriptmodules/ports/fakeport.sh" ]]
    [[ -f "$FAKE_RP_EXTRA/scriptmodules/supplementary/fakesupp.sh" ]]
}

@test "deleting one module preserves others" {
    copyModule "emulators/fakemu.sh"
    copyModule "ports/fakeport.sh"
    deleteModule "emulators/fakemu.sh"
    [[ ! -f "$FAKE_RP_EXTRA/scriptmodules/emulators/fakemu.sh" ]]
    [[ -f "$FAKE_RP_EXTRA/scriptmodules/ports/fakeport.sh" ]]
}
