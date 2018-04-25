#
# Extract pragmatic version identifiers
#
# author    Copyright (c) 2018 Guillermo Calvo
# license   GNU General Public License
# website   https://pragver.github.io/pragver-tools/
# repo      https://github.com/pragver/pragver-tools/
#

#
# Usage & Help
#
read -r -d '' HELP_EXTRACT <<'EOF'

Usage: pragver extract [OPTIONS]

Extracts any pragmatic version identifiers contained

  -p, --path FILE           Extract a list of version identifiers from the
                              specified file path, instead of using STDIN.
      --debug               Print verbose messages to error output.
      --help                Display this help and exit.
EOF

#
# Extract
#
function extract(){
	local FILE=
	local EXIT_CODE=
	# Parse options
	while [[ $# -gt 0 ]]; do
		local OPTION="$1"
		shift
		case $OPTION in
			"--help")
				echo -e "$HELP_EXTRACT"
				exit $EXIT_SUCCESS
			;;
			"--debug")
				VERBOSITY=YES
			;;
			"-p"|"--path")
				FILE=$1
				shift
			;;
			*)
				panic $EXIT_UNKNOWN_OPTION "Unknown option: \"$OPTION\"\n$HELP_EXTRACT"
			;;
		esac
	done
	# Read the target version identifier from a file
	if [[ -n $FILE ]] && [[ ! -f $FILE ]]; then
		panic $EXIT_INVALID_PARAM "No such file: \"$FILE\""
	fi
	verbose "Extracting version identifiers from file: \"${FILE:-standard input}\"..."
	grep -oE "$RE_ANY_PRAGVER" ${FILE:-/dev/stdin}
	EXIT_CODE=$?
	if [ $EXIT_CODE -eq 0 ]; then
		verbose "Extraction finished successfully."
	else
		[[ $EXIT_CODE -gt 1 ]] && panic $EXIT_IO_ERROR "Unexpected error ($EXIT_CODE) while extracting from file: \"${FILE:-standard input}\"."
		verbose "No valid version identifier could be extracted from file: \"${FILE:-standard input}\"."
	fi
	exit $EXIT_CODE
}
