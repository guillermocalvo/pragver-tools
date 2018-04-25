#!/bin/bash

source test/testing.sh || exit 99

# Help
assert_equals "Auto --help" \
	"Usage: pragver auto <SUBCOMMAND>" \
	"`pragver auto --help | grep Usage`"

# Unknown subcommand
assert_equals "Check foobar" \
	"$EXIT_UNKNOWN_COMMAND" \
	"`pragver auto foobar 2>/dev/null ; echo $?`"

# Rename meta directory of the repository temporarily
mv .meta .meta.original

# Current 1
assert_equals "pragver auto current" \
	"$EXIT_INVALID_WORKSPACE" \
	"`pragver auto current ; echo $?`"

# Status 1
assert_equals "pragver auto status" \
	"0" \
	"`pragver auto status > /dev/null ; echo $?`"

# Init
assert_equals "pragver auto init" \
	"Workspace was initialized successfully (initial version: 0.1.0.0)." \
	"`pragver auto init`"

# Already initialized
assert_equals "pragver auto init" \
	"$EXIT_INVALID_STATUS" \
	"`pragver auto init ; echo $?`"

# Version file
assert_equals "cat .meta/VERSION" \
	"0.1.0.0" \
	"`cat .meta/VERSION`"

# Current 2
assert_equals "pragver auto current" \
	"0.1.0.0" \
	"`pragver auto current`"

# Patch
assert_equals "pragver auto patch" \
	"Version bumped to: 0.1.0.1" \
	"`pragver auto patch`"

# Minor
assert_equals "pragver auto minor" \
	"Version bumped to: 0.1.1.0" \
	"`pragver auto minor`"

# Major
assert_equals "pragver auto major" \
	"Version bumped to: 0.2.0.0" \
	"`pragver auto major`"

# Grade
echo "Checking auto grade"
assert_equals "pragver auto grade" \
	"Version bumped to: 1.0.0.0" \
	"`pragver auto grade`"

# Grade invalid option
assert_equals "pragver auto grade oops" \
	"$EXIT_INVALID_VERSION" \
	"`pragver auto grade oops ; echo $?`"

# Force
assert_equals "pragver auto force 1.2.3.4" \
	"Version bumped to: 1.2.3.4" \
	"`pragver auto force 1.2.3.4`"

# Force invalid version
assert_equals "pragver auto force oops" \
	"$EXIT_INVALID_VERSION" \
	"`pragver auto force oops ; echo $?`"

# Track 1
echo "foo 1.2.3.4 bar" > foobar.txt
assert_equals "pragver auto track foobar.txt" \
	"Tracked file: /foobar.txt" \
	"`pragver auto track foobar.txt`"

# Status 2
assert_equals "pragver auto status" \
	"0" \
	"`pragver auto status > /dev/null ; echo $?`"

# Already tracked file
assert_equals "pragver auto track foobar.txt" \
	"$EXIT_INVALID_PARAM" \
	"`pragver auto track foobar.txt ; echo $?`"

# Track invalid file
assert_equals "pragver auto track /foobar.txt" \
	"$EXIT_INVALID_PARAM" \
	"`pragver auto track /foobar.txt ; echo $?`"

# Track non-existing 1
assert_equals "pragver auto track wrong.file.txt" \
	"$EXIT_CANCELED" \
	"`echo N | pragver auto track wrong.file.txt ; echo $?`"

# Track non-existing 2
assert_equals "pragver auto track wrong.file.txt" \
	"Tracked file: /wrong.file.txt" \
	"`echo Y | pragver auto track wrong.file.txt`"

# Bump + release
assert_equals "pragver auto bump --release alpha" \
	"Version bumped to: 1.2.3.4-alpha" \
	"`pragver auto bump --release alpha`"

# Bump empty
assert_equals "pragver auto bump" \
	"$EXIT_INVALID_STATUS" \
	"`pragver auto bump ; echo $?`"

# Bump invalid option
assert_equals "pragver auto bump oops" \
	"$EXIT_INVALID_VERSION" \
	"`pragver auto bump oops ; echo $?`"

# Tracked file
assert_equals "cat foobar.txt" \
	"foo 1.2.3.4-alpha bar" \
	"`cat foobar.txt`"

# Untrack
assert_equals "pragver auto untrack foobar.txt" \
	"Untracked file: /foobar.txt" \
	"`pragver auto untrack foobar.txt`"

# Already untracked file
assert_equals "pragver auto untrack foobar.txt" \
	"$EXIT_INVALID_PARAM" \
	"`pragver auto untrack foobar.txt ; echo $?`"

# Untrack invalid file
assert_equals "pragver auto untrack /foobar.txt" \
	"$EXIT_INVALID_PARAM" \
	"`pragver auto untrack /foobar.txt ; echo $?`"

# Remove list of tracked files
rm .meta/TRACKED

# Untrack 2
assert_equals "pragver auto untrack foobar.txt" \
	"$EXIT_IO_ERROR" \
	"`pragver auto untrack foobar.txt ; echo $?`"

# Patch 2
assert_equals "pragver auto patch" \
	"Version bumped to: 1.2.3.5-alpha" \
	"`pragver auto patch`"

# Delete test data
rm -R .meta

# Restore meta directory of the repository
mv .meta.original .meta

test_pass
