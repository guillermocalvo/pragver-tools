#
# Validate pragmatic version identifiers
#
# author    Copyright (c) 2018 Guillermo Calvo
# license   GNU General Public License
# website   https://pragver.github.io/pragver-tools/
# repo      https://github.com/pragver/pragver-tools/
#

#
# Usage & Help
#
read -r -d '' HELP_VALIDATE <<'EOF'

Usage: pragver validate [OPTIONS]

Validates pragmatic version identifiers

  -v, --version VERSION     Validate only one pragmatic version identifier
                              specified as a parameter, instead of using STDIN.
  -p, --path FILE           Validate a list of version identifiers from the
                              specified file path, instead of using STDIN.
      --debug               Print verbose messages to error output.
      --help                Display this help and exit.
EOF

#
# Validate
#
function validate(){
	local VERSION=
	local FILE=
	# Parse options
	while [[ $# -gt 0 ]]; do
		local OPTION="$1"
		shift
		case $OPTION in
			"--help")
				echo -e "$HELP_VALIDATE"
				exit $EXIT_SUCCESS
			;;
			"--debug")
				VERBOSITY=YES
			;;
			"-v"|"--version")
				VERSION=$1
				shift
			;;
			"-p"|"--path")
				FILE=$1
				shift
			;;
			*)
				panic $EXIT_UNKNOWN_OPTION "Unknown option: \"$OPTION\"\n$HELP_VALIDATE"
			;;
		esac
	done
	if [[ -z "$VERSION" ]]; then
		# Read the target version identifier from a file
		if [[ -n $FILE ]] && [[ ! -f $FILE ]]; then
			panic $EXIT_INVALID_PARAM "No such file: \"$FILE\""
		fi
		verbose "Reading version identifiers from ${FILE:-standard input}..."
		readarray -t LINES < ${FILE:-/dev/stdin}
		for VERSION in "${LINES[@]}"; do
			[[ -z $VERSION ]] && continue
			if [[ $VERSION =~ $RE_STRICT_PRAGVER ]]; then
				verbose "Valid version identifier: \"${BASH_REMATCH[0]}\"."
				echo $VERSION
			else
				verbose "Invalid version identifier: \"$VERSION\"."
			fi
		done
		verbose "All version identifiers successfully read."
	else
		# Use the version identifier specified as a parameter
		verbose "Version identifier passed as an argument: \"$VERSION\"."
		if [[ $VERSION =~ $RE_STRICT_PRAGVER ]]; then
			verbose "Valid version identifier: \"${BASH_REMATCH[0]}\"."
			echo $VERSION
		else
			verbose "Invalid version identifier: \"$VERSION\"."
		fi
	fi
}
