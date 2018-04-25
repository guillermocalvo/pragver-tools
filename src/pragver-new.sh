#
# Creates a new pragmatic version identifier.
#
# author    Copyright (c) 2018 Guillermo Calvo
# license   GNU General Public License
# website   https://pragver.github.io/pragver-tools/
# repo      https://github.com/pragver/pragver-tools/
#

#
# Usage & Help
#
read -r -d '' HELP_NEW <<'EOF'

Usage: pragver new [OPTION]

Creates a new pragmatic version identifier.

  -s, --stable              Print the version identifier for a first stable
                              release (1.0.0.0) and exit.
  -u, --unstable            Print the version identifier for a first unstable
                              release (1.0.0.0) and exit.
      --help                Display this help and exit.
EOF

# Constants
readonly NEW_UNSTABLE="0.1.0.0"
readonly NEW_STABLE="1.0.0.0"

#
# New
#
function new(){
	OPTION=$1
	case $OPTION in
		""|"--help")
			echo -e "$HELP_NEW"
		;;
		"-s"|"--stable")
			echo $NEW_STABLE
		;;
		"-u"|"--unstable")
			echo $NEW_UNSTABLE
		;;
		*)
			panic $EXIT_UNKNOWN_OPTION "Unknown option: \"$OPTION\"\n$HELP_NEW"
		;;
	esac
}
