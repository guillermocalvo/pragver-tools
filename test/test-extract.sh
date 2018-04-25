#!/bin/bash

source test/testing.sh || exit 99

# Help
assert_equals "pragver extract --help" \
	"Usage: pragver extract [OPTIONS]" \
	"`pragver extract --help | grep Usage`"

# Unknown option
assert_equals "pragver extract --foobar" \
	"$EXIT_UNKNOWN_OPTION" \
	"`pragver extract --foobar 2>/dev/null ; echo $?`"

# Wrong file
assert_equals "pragver extract --path test/wrong.file" \
	"$EXIT_INVALID_PARAM" \
	"`pragver extract --path test/wrong.file ; echo $?`"

# File
assert_equals "pragver extract --path test/extract.txt" \
	"`cat test/extracted.txt`" \
	"`pragver extract --path test/extract.txt`"

# STDIN
assert_equals "cat test/extract.txt | pragver extract" \
	"`cat test/extracted.txt`" \
	"`cat test/extract.txt | pragver extract`"

# Verbosity while extracting from file
assert_equals "pragver extract --debug -p test/extract.txt" \
	"`cat test/extracted.txt`" \
	"`pragver extract --debug -p test/extract.txt`"

# Extract from invalid file
assert_equals "pragver extract --path test/none.txt" \
	"1" \
	"`pragver extract --path test/none.txt ; echo $?`"

test_pass
