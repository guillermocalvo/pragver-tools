#!/bin/bash

source test/testing.sh || exit 99

# Help
assert_equals "pragver validate --help" \
	"Usage: pragver validate [OPTIONS]" \
	"`pragver validate --help | grep Usage`"

# Valid version
while read -r LINE || [[ -n "$LINE" ]]; do
	assert_equals "pragver validate --version \"$LINE\"" \
		"$LINE" \
		"`pragver validate --version \"$LINE\"`"
done < test/valid.txt

# Valid file
assert_equals "pragver validate --debug --path test/valid.txt" \
	"`cat test/valid.txt`" \
	"`pragver validate --debug --path test/valid.txt`"

# Valid STDIN
assert_equals "cat test/valid.txt | pragver validate" \
	"`cat test/valid.txt`" \
	"`cat test/valid.txt | pragver validate`"

# Invalid version
while read -r LINE || [[ -n "$LINE" ]]; do
	assert_equals "pragver validate --version \"$LINE\"" \
		"" \
		"`pragver validate --version \"$LINE\"`"
done < test/invalid.txt

# Invalid file
assert_equals "pragver validate --path test/invalid.txt" \
	"" \
	"`pragver validate --path test/invalid.txt`"

# Invalid STDIN
assert_equals "cat test/invalid.txt | pragver validate" \
	"" \
	"`cat test/invalid.txt | pragver validate`"

# Mixed file
assert_equals "pragver validate --path test/mixed.txt" \
	"`cat test/filtered.txt`" \
	"`pragver validate --path test/mixed.txt`"

# Mixed STDIN
assert_equals "cat test/mixed.txt | pragver validate" \
	"`cat test/filtered.txt`" \
	"`cat test/mixed.txt | pragver validate`"

# Unknown option
assert_equals "pragver validate --foobar" \
	"$EXIT_UNKNOWN_OPTION" \
	"`pragver validate --foobar 2>/dev/null ; echo $?`"

# Wrong file
assert_equals "pragver validate --path test/wrong.file" \
	"$EXIT_INVALID_PARAM" \
	"`pragver validate --path test/wrong.file ; echo $?`"

test_pass
