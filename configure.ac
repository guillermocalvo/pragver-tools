#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.


# Autoconf requirements
AC_PREREQ([2.68])


# Initialize package
AC_INIT([pragver-tools], [0.1.0.0], [pragver-tools@guillermo.in], [pragver-tools], [https://github.com/pragver/pragver-tools/])


# Information on the package
AC_COPYRIGHT([Copyright 2018 Guillermo Calvo])
AC_REVISION([$PACKAGE_VERSION])
AC_MSG_NOTICE([
                                            _              _
                                           | |            | |
 _ __  _ __ __ _  __ ___   _____ _ __ _____| |_ ___   ___ | |___
| '_ \| '__/ _` |/ _` \ \ / / _ \ '__|_____| __/ _ \ / _ \| / __|
| |_) | | | (_| | (_| |\ V /  __/ |        | || (_) | (_) | \__ \\
| .__/|_|  \__,_|\__, | \_/ \___|_|         \__\___/ \___/|_|___/
| |               __/ |          Create, handle and bump
|_|              |___/        pragmatic version identifiers
])


# Check if the source folder is correct
AC_CONFIG_SRCDIR([src/pragver])


# Check programs
AC_PROG_CC


# Generate files
AC_CONFIG_FILES([
    pragver-tools.pc
    Makefile
])


# Initialize automake
AM_INIT_AUTOMAKE([
    foreign
	subdir-objects
    no-define
])


AC_OUTPUT
