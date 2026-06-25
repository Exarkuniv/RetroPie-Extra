#!/bin/bash
# Common test helper for RetroPie-Extra BATS tests
#
# Sets up isolated temp directories and provides utilities for sourcing
# install-extras.sh functions without triggering side effects.

setup_test_dirs() {
    TEST_TMPDIR="$(mktemp -d)"
    FAKE_SCRIPTDIR="$TEST_TMPDIR/repo"
    FAKE_RPS_HOME="$TEST_TMPDIR/RetroPie-Setup"
    FAKE_RP_EXTRA="$FAKE_RPS_HOME/ext/RetroPie-Extra"

    mkdir -p "$FAKE_SCRIPTDIR/scriptmodules/emulators"
    mkdir -p "$FAKE_SCRIPTDIR/scriptmodules/libretrocores"
    mkdir -p "$FAKE_SCRIPTDIR/scriptmodules/ports"
    mkdir -p "$FAKE_SCRIPTDIR/scriptmodules/supplementary"
    mkdir -p "$FAKE_RPS_HOME"

    # Create sample scriptmodule files
    echo 'rp_module_id="fakemu"' > "$FAKE_SCRIPTDIR/scriptmodules/emulators/fakemu.sh"
    echo 'rp_module_id="fakecore"' > "$FAKE_SCRIPTDIR/scriptmodules/libretrocores/fakecore.sh"
    echo 'rp_module_id="fakeport"' > "$FAKE_SCRIPTDIR/scriptmodules/ports/fakeport.sh"
    echo 'rp_module_id="fakesupp"' > "$FAKE_SCRIPTDIR/scriptmodules/supplementary/fakesupp.sh"

    # Create a sample scriptmodule with a data directory
    mkdir -p "$FAKE_SCRIPTDIR/scriptmodules/supplementary/fakesupp"
    echo "data_file" > "$FAKE_SCRIPTDIR/scriptmodules/supplementary/fakesupp/data.txt"
}

teardown_test_dirs() {
    [[ -d "$TEST_TMPDIR" ]] && rm -rf "$TEST_TMPDIR"
}

# Source only the function definitions from install-extras.sh,
# overriding variables to use test directories.
source_install_functions() {
    local real_script="$BATS_TEST_DIRNAME/../install-extras.sh"

    # Extract function definitions only (skip the top-level execution)
    # We define the variables ourselves, then source functions via eval
    SCRIPTDIR="$FAKE_SCRIPTDIR"
    RPS_HOME="$FAKE_RPS_HOME"
    RP_EXTRA="$FAKE_RP_EXTRA"
    BACKTITLE="Test"
    REGEX='^[0-9]+$'

    # Source functions by extracting them
    eval "$(sed -n '/^function /,/^}/p' "$real_script")"
}
