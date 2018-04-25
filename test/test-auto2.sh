#!/bin/bash

source test/testing.sh || exit 99

# Rename meta directory of the repository temporarily
mv .meta .meta.original

# Config 0
assert_equals "echo | pragver auto config" \
	"Workspace was initialized successfully." \
	"`echo | pragver auto config`"

# Config 1
assert_equals "cat test/config1.txt | pragver auto config" \
	"Existing workspace was configured successfully." \
	"`cat test/config1.txt | pragver auto config`"

# Config 2
assert_equals "cat test/config2.txt | pragver auto config" \
	"$EXIT_INVALID_VERSION" \
	"`cat test/config2.txt | pragver auto config ; echo $?`"

# Patch 1
assert_equals "pragver auto patch" \
	"0" \
	"`pragver auto patch > /dev/null ; echo $?`"

# Remove list of tracked files
rm .meta/TRACKED2

# Status 1
assert_equals "pragver auto status" \
	"0" \
	"`pragver auto status > /dev/null ; echo $?`"

# Patch 2
assert_equals "pragver auto patch" \
	"0" \
	"`pragver auto patch > /dev/null ; echo $?`"

# Configure a wrong list of tracked files
sed -i 's/\.meta\/TRACKED2/test/' .meta/AUTO

# Track
assert_equals "pragver auto track foobar.txt" \
	"$EXIT_IO_ERROR" \
	"`echo Y | pragver auto track foobar.txt > /dev/null ; echo $?`"

# Untrack
assert_equals "pragver auto untrack foobar.txt" \
	"$EXIT_IO_ERROR" \
	"`echo Y | pragver auto untrack foobar.txt > /dev/null ; echo $?`"

# Restore the list of tracked files
sed -i 's/test/.meta\/TRACKED2/' .meta/AUTO

# Overwrite current version file
echo oops > .meta/VERSION2

# Current 1
assert_equals "pragver auto current" \
	"$EXIT_INVALID_STATUS" \
	"`pragver auto current ; echo $?`"

# Delete current version file
rm .meta/VERSION2

# Current 2
assert_equals "pragver auto current" \
	"$EXIT_INVALID_STATUS" \
	"`pragver auto current ; echo $?`"

# Config 3
assert_equals "cat test/config3.txt | pragver auto config" \
	"Existing workspace was configured successfully." \
	"`cat test/config3.txt | pragver auto config`"

# Current 3
assert_equals "pragver auto current" \
	"4.3.2.1" \
	"`pragver auto current`"

# Config 4
assert_equals "cat test/config4.txt | pragver auto config" \
	"$EXIT_IO_ERROR" \
	"`cat test/config4.txt | pragver auto config ; echo $?`"

# Config 5
assert_equals "cat test/config5.txt | pragver auto config" \
	"$EXIT_IO_ERROR" \
	"`cat test/config5.txt | pragver auto config ; echo $?`"

# Config 6
assert_equals "cat test/config6.txt | pragver auto config" \
	"$EXIT_INVALID_STATUS" \
	"`cat test/config6.txt | pragver auto config ; echo $?`"

# Delete auto file and create directory with the same name
rm .meta/AUTO
mkdir .meta/AUTO

# Init
assert_equals "pragver auto init" \
	"$EXIT_IO_ERROR" \
	"`pragver auto init ; echo $?`"

# Delete test data
rm -R .meta

# Restore meta directory of the repository
mv .meta.original .meta

test_pass
