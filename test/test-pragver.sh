#!/bin/bash

source test/testing.sh || exit 99

# Help
assert_equals "pragver --help" \
	"Usage: pragver <COMMAND>" \
	"`pragver --help | grep Usage`"

# Version
assert_equals "pragver --version" \
	"0.1.0.0" \
	"`pragver --version`"

# Unknown option
assert_equals "pragver --foobar" \
	"$EXIT_UNKNOWN_OPTION" \
	"`pragver --foobar 2>/dev/null ; echo $?`"

# Unknown command
assert_equals "pragver foobar" \
	"$EXIT_UNKNOWN_COMMAND" \
	"`pragver foobar 2>/dev/null ; echo $?`"

test_pass
