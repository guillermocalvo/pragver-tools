#
# Bumps a pragmatic version identifier
#
# author    Copyright (c) 2018 Guillermo Calvo
# license   GNU General Public License
# website   https://pragver.github.io/pragver-tools/
# repo      https://github.com/pragver/pragver-tools/
#

#
# Usage & Help
#
read -r -d '' HELP_BUMP <<'EOF'

Usage: pragver bump [OPTIONS]
Bumps a pragmatic version identifier.

  -v, --version ID          Bumps the target version identifier specified as a
                              parameter, instead of using STDIN.
  -i, --increment NUMBER    Increments the specified NUMBER of the target
                              version identifier, being NUMBER one of these:
                              - GRADE, MAJOR, MINOR, PATCH or NONE.
  -r, --release METADATA    Replaces the release metadata of the target version
                              identifier with the specified parameter.
                              - METADATA may be empty
                              - It must not include the separator character.
                              - If specified several times, the metadata will
                                be appended and separated by dots.
  -b, --build METADATA      Replaces the build metadata of the target version
                              identifier with the specified parameter:
                              - METADATA may be empty
                              - It must not include the separator character.
                              - If specified several times, the metadata will
                                be appended and separated by dots.
  -t, --timestamp           Appends the current UTC timestamp to the build
                              metadata.
  -f, --filter              Cleans up and replaces all invalid characters from
                              specified metadata with dots.
      --debug               Print verbose messages to error output.
      --help                Display this help and exit.
EOF

#
# Bump
#
function bump(){

	# Default option
	local VERSION=
	local BUMPED=
	local INCREMENT=
	local REPLACE_RELEASE_METADATA=
	local RELEASE=
	local REPLACE_BUILD_METADATA=
	local BUILD=
	local TIMESTAMP=
	local FILTER=
	local GRADE=
	local MAJOR=
	local MINOR=
	local PATCH=
	local RELEASE_METADATA=
	local BUILD_METADATA=

	# Parse options
	while [[ $# -gt 0 ]]; do
		local OPTION="$1"
		shift
		case $OPTION in
			"--help")
				echo "$HELP_BUMP"
				exit $EXIT_SUCCESS
			;;
			"--debug")
				VERBOSITY=YES
			;;
			"-v"|"--version")
				VERSION=$1
				shift
			;;
			"-i"|"--increment")
				INCREMENT=$1
				shift
			;;
			"-r"|"--release")
				if [[ -n $RELEASE ]]; then
					RELEASE+=".$1"
				else
					RELEASE=$1
				fi
				shift
				REPLACE_RELEASE_METADATA=1
			;;
			"-b"|"--build")
				if [[ -n $BUILD ]]; then
					BUILD+=".$1"
				else
					BUILD=$1
				fi
				shift
				REPLACE_BUILD_METADATA=1
			;;
			"-t"|"--timestamp")
				TIMESTAMP=YES
			;;
			"-f"|"--filter")
				FILTER=YES
			;;
			*)
				panic $EXIT_UNKNOWN_OPTION "Unknown option: \"$OPTION\"\n$HELP_BUMP"
			;;
		esac
	done

	# Read the target version identifier (if not specified as a parameter)
	if [[ -z "$VERSION" ]]; then
		verbose "Reading version identifier from standard input..."
		read -r VERSION < /dev/stdin
		verbose "Version identifier successfully read: \"$VERSION\"."
	else
		verbose "Version identifier passed as an argument: \"$VERSION\"."
	fi

	# Parse the target version identifier
	if [[ $VERSION =~ $RE_STRICT_PRAGVER ]]; then
		GRADE=${BASH_REMATCH[1]}
		MAJOR=${BASH_REMATCH[2]}
		MINOR=${BASH_REMATCH[3]}
		PATCH=${BASH_REMATCH[4]}
		RELEASE_METADATA=${BASH_REMATCH[6]}
		BUILD_METADATA=${BASH_REMATCH[11]}
		verbose "Valid version identifier: \"${BASH_REMATCH[0]}\"."
	else
		panic $EXIT_INVALID_VERSION "Invalid pragmatic version identifier: \"$VERSION\"."
	fi

	# Increment numbers
	case $INCREMENT in
		""|"NONE"|"none")
			verbose "Will not increment any number"
		;;
		"GRADE"|"grade")
			verbose "Incrementing GRADE number..."
			GRADE=$((GRADE + 1))
			MAJOR=0
			MINOR=0
			PATCH=0
		;;
		"MAJOR"|"major")
			verbose "Incrementing MAJOR number..."
			MAJOR=$((MAJOR + 1))
			MINOR=0
			PATCH=0
		;;
		"MINOR"|"minor")
			verbose "Incrementing MINOR number..."
			MINOR=$((MINOR + 1))
			PATCH=0
		;;
		"PATCH"|"patch")
			verbose "Incrementing PATCH number..."
			PATCH=$((PATCH + 1))
		;;
		*)
			>&2 echo "Error: Invalid increment parameter: \"$INCREMENT\"."
			>&2 echo "$HELP_BUMP"
			exit $EXIT_INVALID_PARAM
		;;
	esac

	# Replace release metadata
	if [[ -n $REPLACE_RELEASE_METADATA ]]; then
		if ! [[ "$RELEASE" =~ $METADATA_PATTERN ]]; then
			if [[ -z $FILTER ]]; then
				panic $EXIT_INVALID_RELEASE "Illegal release metadata: \"$RELEASE\"."
			fi
			verbose "Replacing illegal release metadata: \"$RELEASE\"."
			RELEASE=`echo "$RELEASE" | sed -E "$METADATA_FILTER"`
		fi
		verbose "Replacing release metadata \"$RELEASE_METADATA\" => \"$RELEASE\"..."
		RELEASE_METADATA="$RELEASE"
	fi

	# Replace build metadata
	if [[ -n $REPLACE_BUILD_METADATA ]]; then
		if ! [[ "$BUILD" =~ $METADATA_PATTERN ]]; then
			if [[ -z $FILTER ]]; then
					panic $EXIT_INVALID_BUILD "Illegal build metadata: \"$BUILD\"."
			fi
			verbose "Replacing illegal build metadata: \"$BUILD\"."
			BUILD=`echo "$BUILD" | sed -E "$METADATA_FILTER"`
		fi
		verbose "Replacing build metadata \"$BUILD_METADATA\" => \"$BUILD\"..."
		BUILD_METADATA="$BUILD"
	fi

	# Append timestamp to build metadata
	if [[ -n $TIMESTAMP ]]; then
		TIMESTAMP=`date -u +%Y%m%d-%H%M%S`
		verbose "Appending timestamp to build metadata \"$TIMESTAMP\"..."
		if [[ -n $BUILD_METADATA ]]; then
			BUILD_METADATA+="."
		fi
		BUILD_METADATA+="$TIMESTAMP"
	fi

	# Result
	[[ -n $RELEASE_METADATA ]] && RELEASE_METADATA="-$RELEASE_METADATA"
	[[ -n $BUILD_METADATA   ]] && BUILD_METADATA="+$BUILD_METADATA"
	BUMPED="${GRADE}.${MAJOR}.${MINOR}.${PATCH}${RELEASE_METADATA}${BUILD_METADATA}"

	verbose "Bumping version identifier: \"$VERSION\" => \"$BUMPED\"..."

	echo $BUMPED
}
