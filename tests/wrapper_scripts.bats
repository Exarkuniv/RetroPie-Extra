#!/usr/bin/env bats

# Tests for remove-extras.sh and update-extras.sh wrapper scripts.
#
# These thin wrappers delegate to install-extras.sh with specific flags.
# We verify their content and structure rather than executing them
# (execution would require a RetroPie-Setup directory).

REPO_ROOT="$BATS_TEST_DIRNAME/.."

# ---------------------------------------------------------------
# remove-extras.sh
# ---------------------------------------------------------------

@test "remove-extras.sh exists" {
    [[ -f "$REPO_ROOT/remove-extras.sh" ]]
}

@test "remove-extras.sh is executable" {
    [[ -x "$REPO_ROOT/remove-extras.sh" ]]
}

@test "remove-extras.sh has bash shebang" {
    local first_line
    first_line="$(head -1 "$REPO_ROOT/remove-extras.sh")"
    [[ "$first_line" == "#!/bin/bash" ]]
}

@test "remove-extras.sh delegates to install-extras.sh with --remove" {
    grep -q '\./install-extras.sh --remove' "$REPO_ROOT/remove-extras.sh"
}

@test "remove-extras.sh passes through arguments" {
    grep -q '"$@"' "$REPO_ROOT/remove-extras.sh"
}

@test "remove-extras.sh is concise (3 lines or fewer)" {
    local lines
    lines="$(wc -l < "$REPO_ROOT/remove-extras.sh")"
    [[ "$lines" -le 3 ]]
}

@test "remove-extras.sh passes bash syntax check" {
    bash -n "$REPO_ROOT/remove-extras.sh"
}

# ---------------------------------------------------------------
# update-extras.sh
# ---------------------------------------------------------------

@test "update-extras.sh exists" {
    [[ -f "$REPO_ROOT/update-extras.sh" ]]
}

@test "update-extras.sh is executable" {
    [[ -x "$REPO_ROOT/update-extras.sh" ]]
}

@test "update-extras.sh has bash shebang" {
    local first_line
    first_line="$(head -1 "$REPO_ROOT/update-extras.sh")"
    [[ "$first_line" == "#!/bin/bash" ]]
}

@test "update-extras.sh delegates to install-extras.sh with --update" {
    grep -q '\./install-extras.sh --update' "$REPO_ROOT/update-extras.sh"
}

@test "update-extras.sh is concise (3 lines or fewer)" {
    local lines
    lines="$(wc -l < "$REPO_ROOT/update-extras.sh")"
    [[ "$lines" -le 3 ]]
}

@test "update-extras.sh passes bash syntax check" {
    bash -n "$REPO_ROOT/update-extras.sh"
}

# ---------------------------------------------------------------
# install-extras.sh top-level structure
# ---------------------------------------------------------------

@test "install-extras.sh exists" {
    [[ -f "$REPO_ROOT/install-extras.sh" ]]
}

@test "install-extras.sh has bash shebang" {
    local first_line
    first_line="$(head -1 "$REPO_ROOT/install-extras.sh")"
    [[ "$first_line" == "#!/bin/bash" ]]
}

@test "install-extras.sh defines runHelp function" {
    grep -q '^function runHelp()' "$REPO_ROOT/install-extras.sh"
}

@test "install-extras.sh defines startCmd function" {
    grep -q '^function startCmd()' "$REPO_ROOT/install-extras.sh"
}

@test "install-extras.sh defines runAuto function" {
    grep -q '^function runAuto()' "$REPO_ROOT/install-extras.sh"
}

@test "install-extras.sh defines removeAll function" {
    grep -q '^function removeAll()' "$REPO_ROOT/install-extras.sh"
}

@test "install-extras.sh defines runGui function" {
    grep -q '^function runGui()' "$REPO_ROOT/install-extras.sh"
}

@test "install-extras.sh defines copyModule function" {
    grep -q '^function copyModule()' "$REPO_ROOT/install-extras.sh"
}

@test "install-extras.sh defines deleteModule function" {
    grep -q '^function deleteModule()' "$REPO_ROOT/install-extras.sh"
}

@test "install-extras.sh defines chooseModules function" {
    grep -q '^function chooseModules()' "$REPO_ROOT/install-extras.sh"
}

@test "install-extras.sh defines viewModules function" {
    grep -q '^function viewModules()' "$REPO_ROOT/install-extras.sh"
}

@test "install-extras.sh defines installBySection function" {
    grep -q '^function installBySection()' "$REPO_ROOT/install-extras.sh"
}

@test "install-extras.sh defines updateExtras function" {
    grep -q '^function updateExtras' "$REPO_ROOT/install-extras.sh"
}

@test "install-extras.sh calls startCmd at the end" {
    local last_line
    last_line="$(tail -1 "$REPO_ROOT/install-extras.sh")"
    [[ "$last_line" == "startCmd" ]]
}

@test "install-extras.sh sets SCRIPTDIR as readonly" {
    grep -q 'readonly SCRIPTDIR' "$REPO_ROOT/install-extras.sh"
}

@test "install-extras.sh sets RPS_HOME default to ~/RetroPie-Setup" {
    grep -q 'RPS_HOME="\$HOME/RetroPie-Setup"' "$REPO_ROOT/install-extras.sh"
}

@test "install-extras.sh checks minimum RetroPie version" {
    grep -q 'dpkg --compare-versions' "$REPO_ROOT/install-extras.sh"
}
