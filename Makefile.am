#
# pragver-tools
#
# Copyright (c) 2018 Guillermo Calvo
# Licensed under the GNU General Public License
#

AUTOMAKE_OPTIONS = foreign subdir-objects

AM_CFLAGS = -Ideps


# Script files

PRAGVER_SCRIPT          = src/pragver
PRAGVER_AUTO_SCRIPT     = src/pragver-auto.sh
PRAGVER_BUMP_SCRIPT     = src/pragver-bump.sh
PRAGVER_EXTRACT_SCRIPT  = src/pragver-extract.sh
PRAGVER_NEW_SCRIPT      = src/pragver-new.sh
PRAGVER_VALIDATE_SCRIPT = src/pragver-validate.sh


# Install

dist_bin_SCRIPTS =                      \
    $(PRAGVER_SCRIPT)                   \
    $(PRAGVER_AUTO_SCRIPT)              \
    $(PRAGVER_BUMP_SCRIPT)              \
    $(PRAGVER_EXTRACT_SCRIPT)           \
    $(PRAGVER_NEW_SCRIPT)               \
    $(PRAGVER_VALIDATE_SCRIPT)


# Documentation

docdir = $(datadir)/doc/pragver-tools
doc_DATA = docs/*


# Cleanup

CLEANFILES =                            \
    *.log                               \
	deps/pragver-tools.h


# Check

TESTS =                                 \
    test/test-auto1.sh                  \
    test/test-auto2.sh                  \
    test/test-bump.sh                   \
    test/test-extract.sh                \
    test/test-new.sh                    \
    test/test-pragver.sh                \
    test/test-validate.sh


tests: check
