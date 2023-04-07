#!/usr/bin/env bats

source '../brave-install.sh'

#helper function to check if a function exists
assert_defined() {
  local function_name="$1"
  declare -f "$function_name" >/dev/null || fail "Function '$function_name' is not defined"
}

setup_fake_os_release() {
  local name="$1"
  local version_id="$2"

  export FAKE_OS_RELEASE=$(mktemp)
  echo "NAME=\"$name\"" >"$FAKE_OS_RELEASE"
  echo "VERSION_ID=\"$version_id\"" >>"$FAKE_OS_RELEASE"
}

teardown_fake_os_release() {
  rm -f "$FAKE_OS_RELEASE"
  unset FAKE_OS_RELEASE
}

@test "Check if detect_os function exists" {
  assert_defined detect_os
}

@test "Detect Debian" {
  setup_fake_os_release "Debian GNU/Linux" "11"
  export OS_RELEASE_FILE="$FAKE_OS_RELEASE"
  run detect_os
  assert_equal "$OS" "Debian GNU/Linux"
  assert_equal "$VERSION" "11"
  teardown_fake_os_release
}

@test "Detect unsupported operating system" {
  export OS_RELEASE_FILE="/nonexistent/file"
  run detect_os
  assert_output --partial "Unsupported operating system"
  assert_equal "$status" 1
}
