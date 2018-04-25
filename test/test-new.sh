#!/bin/bash

source test/testing.sh || exit 99

# Help
assert_equals "pragver new --help" \
	"Usage: pragver new [OPTION]" \
	"`pragver new --help | grep Usage`"

# Unstable
assert_equals "pragver new --unstable" \
	"0.1.0.0" \
	"`pragver new --unstable`"

# Stable
assert_equals "pragver new --stable" \
	"1.0.0.0" \
	"`pragver new --stable`"

# Unknown option
assert_equals "pragver new --foobar" \
	"$EXIT_UNKNOWN_OPTION" \
	"`pragver new --foobar 2>/dev/null ; echo $?`"

test_pass
