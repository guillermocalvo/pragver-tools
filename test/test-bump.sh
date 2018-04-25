#!/bin/bash

source test/testing.sh || exit 99

# Help
assert_equals "pragver bump --help" \
	"Usage: pragver bump [OPTIONS]" \
	"`pragver bump --help | grep Usage`"

# Unknown increment
assert_equals "pragver bump --increment foobar --version 1.2.3.4" \
	"$EXIT_INVALID_PARAM" \
	"`pragver bump --increment foobar --version 1.2.3.4 2>/dev/null ; echo $?`"

# Unknown option
assert_equals "pragver bump --foobar" \
	"$EXIT_UNKNOWN_OPTION" \
	"`pragver bump --foobar 2>/dev/null ; echo $?`"

# Invalid version
assert_equals "pragver bump --version foobar" \
	"$EXIT_INVALID_VERSION" \
	"`pragver bump --version foobar >/dev/null ; echo $?`"

# Grade + verbosity
assert_equals "echo 1.2.3.4 | pragver bump --debug --increment grade" \
	"2.0.0.0" \
	"`echo 1.2.3.4 | pragver bump --debug --increment grade`"

# Grade
assert_equals "pragver bump --increment grade --version 1.2.3.4" \
	"2.0.0.0" \
	"`pragver bump --increment grade --version 1.2.3.4`"

# Major
assert_equals "pragver bump --increment major --version 1.2.3.4" \
	"1.3.0.0" \
	"`pragver bump --increment major --version 1.2.3.4`"

# Minor
assert_equals "pragver bump --increment minor --version 1.2.3.4" \
	"1.2.4.0" \
	"`pragver bump --increment minor --version 1.2.3.4`"

# Patch
assert_equals "pragver bump --increment patch --version 1.2.3.4" \
	"1.2.3.5" \
	"`pragver bump --increment patch --version 1.2.3.4`"

# Release
assert_equals "pragver bump --release alpha --version 1.2.3.4" \
	"1.2.3.4-alpha" \
	"`pragver bump --release alpha --version 1.2.3.4`"

# Invalid release
assert_equals "pragver bump --release oops! --version 1.2.3.4" \
	"$EXIT_INVALID_RELEASE" \
	"`pragver bump --release oops! --version 1.2.3.4 ; echo $?`"

# Filtered release
assert_equals "pragver bump --filter --release 'hello world!' --version 1.2.3.4" \
	"1.2.3.4-hello.world" \
	"`pragver bump --filter --release 'hello world!' --version 1.2.3.4`"

# Multiple release
assert_equals "pragver bump --release alpha --release beta --version 1.2.3.4" \
	"1.2.3.4-alpha.beta" \
	"`pragver bump --release alpha --release beta --version 1.2.3.4`"

# Build
assert_equals "pragver bump --build linux --version 1.2.3.4" \
	"1.2.3.4+linux" \
	"`pragver bump --build linux --version 1.2.3.4`"

# Invalid build
assert_equals "pragver bump --build oops! --version 1.2.3.4" \
	"$EXIT_INVALID_BUILD" \
	"`pragver bump --build oops! --version 1.2.3.4 ; echo $?`"

# Filtered build
assert_equals "pragver bump --filter --build filter%%%this{if}you.^can --version 1.2.3.4" \
	"1.2.3.4+filter.this.if.you.can" \
	"`pragver bump --filter --build filter%%%this{if}you.^can --version 1.2.3.4`"

# Multiple build
assert_equals "pragver bump --build linux --build windows --version 1.2.3.4" \
	"1.2.3.4+linux.windows" \
	"`pragver bump --build linux --build windows --version 1.2.3.4`"

# Timestamp
assert_like "pragver bump --timestamp --version 1.2.3.4" \
	"1\.2\.3\.4\+[0-9]{8}-[0-9]{6}" \
	"`pragver bump --timestamp --version 1.2.3.4`"

# Timestamp + build + verbosity
assert_like "pragver bump --debug --build linux --timestamp --version 1.2.3.4" \
	"1\.2\.3\.4\+linux\.[0-9]{8}-[0-9]{6}" \
	"`pragver bump --debug --build linux --timestamp --version 1.2.3.4`"

# None
assert_equals "pragver bump --increment none --version 1.2.3.4" \
	"1.2.3.4" \
	"`pragver bump --increment none --version 1.2.3.4`"

# Empty
assert_equals "pragver bump --version 1.2.3.4" \
	"1.2.3.4" \
	"`pragver bump --version 1.2.3.4`"

test_pass
