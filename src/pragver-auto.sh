#
# Automatically handles the pragmatic version in a workspace
#
# author    Copyright (c) 2018 Guillermo Calvo
# license   GNU General Public License
# website   https://pragver.github.io/pragver-tools/
# repo      https://github.com/pragver/pragver-tools/
#

#
# Usage & Help
#
read -r -d '' HELP_AUTO <<'EOF'

Usage: pragver auto <SUBCOMMAND>

Available subcommands are:

  init          Initialize the current directory as a new workspace,
                  using the default configuration.
  config        Set up a new workspace in an interactive way,
                  or update the configuration of an existing workspace.
  status        Show information regarding the current workspace.
  current       Display the current version identifier of a workspace.
  track         Add a file to the list of tracked files.
  untrack       Remove a file from the list of tracked files.
  bump          Bump the version identifier of a workspace.
  grade         Increment the grade number of the current workspace version.
  major         Increment the major number of the current workspace version.
  minor         Increment the minor number of the current workspace version.
  patch         Increment the patch number of the current workspace version.
  force         Replace the version identifier of a workspace.
EOF

# Dependencies
import validate
import new
import bump

# Constants
readonly META_DIRECTORY=.meta
readonly AUTO_CONFIG_FILE=$META_DIRECTORY/AUTO
readonly COMMENTED_LINE="^#"
readonly INIT_AUTO_VERSION_FILE=".meta/VERSION"
readonly INIT_AUTO_VERSION_GREP=""
readonly INIT_AUTO_TRACKED_FILE=".meta/TRACKED"
readonly INIT_AUTO_GIT_COMMIT=""
readonly INIT_AUTO_VERSION_ID="$NEW_UNSTABLE"

#
# Find workspace path
#
function find_workspace(){
	local WORKSPACE=`pwd`
	verbose "Looking for metadata in \"$WORKSPACE\"..."
	while [ ! -f "$WORKSPACE/$AUTO_CONFIG_FILE" ]; do
		if [ "$WORKSPACE" == `dirname "$WORKSPACE"` ]; then
			verbose "No metadata found."
			return
		fi
		WORKSPACE=`dirname "$WORKSPACE"`
	done

	verbose "Found metadata in: \"$WORKSPACE\"."
	echo "$WORKSPACE"
}

#
# Get workspace path
#
function get_workspace(){
	local WORKSPACE=`find_workspace`
	if [ ! -f "$WORKSPACE/$AUTO_CONFIG_FILE" ]; then
		panic $EXIT_INVALID_WORKSPACE "Not a valid workspace (or any of the parent directories): \"`pwd`\""
	fi
	echo "$WORKSPACE"
}

#
# Get current version identifier
#
function get_current_version(){
	local WORKSPACE="$1"
	if [ ! -f "$WORKSPACE/$AUTO_VERSION_FILE" ]; then
		panic $EXIT_INVALID_STATUS "Cannot find workspace file containing current version: \"$AUTO_VERSION_FILE\""
	fi
	local FILTER_VERSION_FILE=
	if [ -n "$AUTO_VERSION_GREP" ]; then
		FILTER_VERSION_FILE="grep $AUTO_VERSION_GREP $WORKSPACE/$AUTO_VERSION_FILE | pragver extract | head -n 1"
	else
		FILTER_VERSION_FILE="pragver validate --path $WORKSPACE/$AUTO_VERSION_FILE"
	fi
	verbose "Getting current version number: $FILTER_VERSION_FILE"
	local VERSION=`eval "$FILTER_VERSION_FILE"`
	if [ -z $VERSION ]; then
		panic $EXIT_INVALID_STATUS "Current WORKSPACE has an invalid version identifier in file (\"$WORKSPACE/$AUTO_VERSION_FILE\")."
	fi
	echo "$VERSION"
}

#
# Escape version
#
function escape_version(){
	local VERSION="$1"
	echo "$VERSION" | sed 's/\./\\./g' | sed 's/\-/\\-/g'
}

#
# Replace version identifiers within a file
#
function process_file(){
	local FILE_PATH=$1
	local OLD_VALUE=$2
	local NEW_VALUE=$3
	verbose "Replacing \"$OLD_VALUE\" with \"$NEW_VALUE\" in file: \"$FILE_PATH\"..."
	sed -i "s/\b$OLD_VALUE\b/$NEW_VALUE/g" "$FILE_PATH"
	# Stage file in GIT repository if auto commit is enabled
	if [ -n "$AUTO_GIT_COMMIT" ]; then
		verbose "Staging file: \"$FILE_PATH\"..."
		git stage "$FILE_PATH"
	fi
}

#
# Display current configuration
#
function display_current_workspace(){
	local WORKSPACE=$1
	local VERSION=$2
	echo "Found workspace:"
	echo
	echo "    path:               $WORKSPACE"
	echo "    version:            $VERSION"
	echo
}

#
# Display current configuration
#
function display_current_config(){
	echo "Configuration:"
	echo
	echo "    AUTO_VERSION_FILE:  $AUTO_VERSION_FILE"
	echo "    AUTO_VERSION_GREP:  $AUTO_VERSION_GREP"
	echo "    AUTO_TRACKED_FILE:  $AUTO_TRACKED_FILE"
	echo "    AUTO_GIT_COMMIT:    ${AUTO_GIT_COMMIT:-no}"
	echo
}

#
# Display tracked files
#
function display_tracked_files(){
	local WORKSPACE=$1
	if [[ -n "$AUTO_TRACKED_FILE" ]] && [[ -f "$WORKSPACE/$AUTO_TRACKED_FILE" ]]; then
		echo "Tracked files:"
		echo

		readarray -t LINES < "$WORKSPACE/$AUTO_TRACKED_FILE"
		for FILE_PATH in "${LINES[@]}"; do
			if [[ -n "$FILE_PATH" ]] && ! [[ $FILE_PATH =~ $COMMENTED_LINE ]]; then
				echo "    $FILE_PATH"
			fi
		done
	else
		echo "No tracked files."
		echo
	fi
}

#
# Ask user for confirmation
#
function confirm(){
	local MESSAGE=$1
	local RESPONSE=
	>&2 echo -e -n "$MESSAGE [y/N]: "
	read RESPONSE
	case $RESPONSE in
		"y"|"yes"|"Y"|"YES")
			return 0
		;;
		*)
			return 1
		;;
	esac
}

#
# Configure workspace
#
function config_workspace(){
	local WORKSPACE="$1"
	local INTERACTIVE="$2"
	local AUTO_VERSION_FILE
	local AUTO_VERSION_GREP
	local AUTO_TRACKED_FILE
	local AUTO_GIT_COMMIT
	local VERSION
	local DEFAULT_AUTO_VERSION_FILE
	local DEFAULT_AUTO_VERSION_GREP
	local DEFAULT_AUTO_TRACKED_FILE
	local DEFAULT_AUTO_GIT_COMMIT
	local MESSAGE_BEGIN1
	local MESSAGE_BEGIN2
	local MESSAGE_END

	if [ -z "$INTERACTIVE" ]; then
		# Non-interactive mode
		WORKSPACE=`pwd`
		AUTO_VERSION_FILE="$INIT_AUTO_VERSION_FILE"
		AUTO_VERSION_GREP="$INIT_AUTO_VERSION_GREP"
		AUTO_TRACKED_FILE="$INIT_AUTO_TRACKED_FILE"
		AUTO_GIT_COMMIT="$INIT_AUTO_GIT_COMMIT"
		VERSION="$INIT_AUTO_VERSION_ID"
		MESSAGE_END="Workspace was initialized successfully (initial version: $INIT_AUTO_VERSION_ID)."
		verbose "Initializing new wokspace at: \"$WORKSPACE\"..."
	else
		# Interactive mode
		DEFAULT_AUTO_VERSION_FILE="$INIT_AUTO_VERSION_FILE"
		DEFAULT_AUTO_VERSION_GREP="$INIT_AUTO_VERSION_GREP"
		DEFAULT_AUTO_TRACKED_FILE="$INIT_AUTO_TRACKED_FILE"
		DEFAULT_AUTO_GIT_COMMIT="$INIT_AUTO_GIT_COMMIT"
		MESSAGE_BEGIN1="Initializing a new worskpace at:"
		MESSAGE_BEGIN2="You may simply press <ENTER> to use the [default value]."
		MESSAGE_END="Workspace was initialized successfully."

		if [ -z "$WORKSPACE" ]; then
			WORKSPACE=`pwd`
			verbose "Configuring new wokspace at: \"$WORKSPACE\"..."
		else
			# Load configuration
			source "$WORKSPACE/$AUTO_CONFIG_FILE"
			DEFAULT_AUTO_VERSION_FILE="$AUTO_VERSION_FILE"
			DEFAULT_AUTO_VERSION_GREP="$AUTO_VERSION_GREP"
			DEFAULT_AUTO_TRACKED_FILE="$AUTO_TRACKED_FILE"
			DEFAULT_AUTO_GIT_COMMIT="$AUTO_GIT_COMMIT"
			MESSAGE_BEGIN1="Configuring the existing worskpace at:"
			MESSAGE_BEGIN2="You may simply press <ENTER> to use the [current value]."
			MESSAGE_END="Existing workspace was configured successfully."
			verbose "Configuring existing wokspace at: \"$WORKSPACE\"..."
		fi

		>&2 echo "$MESSAGE_BEGIN1"
		>&2 echo
		>&2 echo "  $WORKSPACE"
		>&2 echo
		>&2 echo "Please provide a value for the next configuration options, followed by <ENTER>."
		>&2 echo "$MESSAGE_BEGIN2"
		>&2 echo

		>&2 echo -n "  AUTO_VERSION_FILE: [$DEFAULT_AUTO_VERSION_FILE] "
		read AUTO_VERSION_FILE
		[[ -z $AUTO_VERSION_FILE ]] && AUTO_VERSION_FILE="$DEFAULT_AUTO_VERSION_FILE"

		>&2 echo -n "  AUTO_VERSION_GREP: [$DEFAULT_AUTO_VERSION_GREP] "
		read AUTO_VERSION_GREP
		[[ -z $AUTO_VERSION_GREP ]] && AUTO_VERSION_GREP="$DEFAULT_AUTO_VERSION_GREP"

		>&2 echo -n "  AUTO_TRACKED_FILE: [$DEFAULT_AUTO_TRACKED_FILE] "
		read AUTO_TRACKED_FILE
		[[ -z $AUTO_TRACKED_FILE ]] && AUTO_TRACKED_FILE="$DEFAULT_AUTO_TRACKED_FILE"

		>&2 echo -n "    AUTO_GIT_COMMIT: [$DEFAULT_AUTO_GIT_COMMIT] "
		read AUTO_GIT_COMMIT
		[[ -z $AUTO_GIT_COMMIT ]] && AUTO_GIT_COMMIT="$DEFAULT_AUTO_GIT_COMMIT"

		verbose "Checking if version file already exists: \"$WORKSPACE/$AUTO_VERSION_FILE\"..."
		if [ -f "$WORKSPACE/$AUTO_VERSION_FILE" ]; then
			DETECTED_VERSION=`get_current_version "$WORKSPACE"`
			if [[ $? != 0 ]] ; then
				panic $EXIT_INVALID_STATUS "Could not find a valid version identifier in file: $AUTO_VERSION_FILE"
			fi
			>&2 echo "   Detected version: $DETECTED_VERSION"
		else
			>&2 echo -n "    Initial version: [$INIT_AUTO_VERSION_ID] "
			read VERSION
			if [ -z "$VERSION" ]; then
				VERSION="$INIT_AUTO_VERSION_ID"
			else
				local VALID_VERSION=`validate --version "$VERSION"`
				if [ -z "$VALID_VERSION" ]; then
					panic $EXIT_INVALID_VERSION "Not a valid version identifier: \"$VERSION\"."
				fi
			fi
		fi

		>&2 echo
	fi

	# Export variables for envsubst
	export AUTO_VERSION_FILE
	export AUTO_VERSION_GREP
	export AUTO_TRACKED_FILE
	export AUTO_GIT_COMMIT
	read -r -d '' DATA_AUTO_CONFIG_FILE <<'EOF'
# Automatic Pragmatic Versioning
AUTO_VERSION_FILE="$AUTO_VERSION_FILE"
AUTO_VERSION_GREP="$AUTO_VERSION_GREP"
AUTO_TRACKED_FILE="$AUTO_TRACKED_FILE"
AUTO_GIT_COMMIT="$AUTO_GIT_COMMIT"
EOF

	# Write config file
	verbose "Writing config file: \"$WORKSPACE/$AUTO_CONFIG_FILE\"..."
	mkdir -p `dirname "$WORKSPACE/$AUTO_CONFIG_FILE"`
	echo "$DATA_AUTO_CONFIG_FILE" | envsubst | tr '\r' '\n' > "$WORKSPACE/$AUTO_CONFIG_FILE"
	if [[ $? != 0 ]] ; then
		panic $EXIT_IO_ERROR "Could not write to auto config file: \"$WORKSPACE/$AUTO_CONFIG_FILE\"."
	fi

	# Write version file
	if [ ! -f "$WORKSPACE/$AUTO_VERSION_FILE" ]; then
		verbose "Writing version \"$VERSION\" to file: \"$WORKSPACE/$AUTO_VERSION_FILE\"..."
		mkdir -p `dirname "$WORKSPACE/$AUTO_VERSION_FILE"`
		printf "$VERSION" > "$WORKSPACE/$AUTO_VERSION_FILE"
		if [[ $? != 0 ]] ; then
			panic $EXIT_IO_ERROR "Could not write to auto version file: \"$WORKSPACE/$AUTO_VERSION_FILE\"."
		fi
	fi

	# Write tracked file
	if [ ! -f "$WORKSPACE/$AUTO_TRACKED_FILE" ]; then
		verbose "Writing tracked file: \"$WORKSPACE/$AUTO_TRACKED_FILE\"..."
		mkdir -p `dirname "$WORKSPACE/$AUTO_TRACKED_FILE"`
		echo "# Automatically tracked files" > "$WORKSPACE/$AUTO_TRACKED_FILE"
		if [[ $? != 0 ]] ; then
			panic $EXIT_IO_ERROR "Could not write to auto tracked file: \"$WORKSPACE/$AUTO_TRACKED_FILE\"."
		fi
	fi

	echo "$MESSAGE_END"

	return 0
}

#
# Bump
#
function auto(){
	local WORKSPACE=
	# Parse options
	local SUBCOMMAND=$1
	shift
	case $SUBCOMMAND in
		""|"--help")
			echo "$HELP_AUTO"
			exit $EXIT_SUCCESS
		;;
		"init")
			WORKSPACE=`find_workspace`
			if [ -n "$WORKSPACE" ]; then
				panic $EXIT_INVALID_STATUS "Workspace already initialized at: \"$WORKSPACE\"."
			fi
			config_workspace
		;;
		"config")
			WORKSPACE=`find_workspace`
			config_workspace "$WORKSPACE" "INTERACTIVE"
		;;
		"status")
			WORKSPACE=`find_workspace`
			if [ -z "$WORKSPACE" ]; then
				echo "No workspace found at: \"`pwd`\" (or any of the parent directories)."
			else
				# Load configuration
				source "$WORKSPACE/$AUTO_CONFIG_FILE"
				VERSION=`get_current_version "$WORKSPACE"` || exit $?
				display_current_workspace "$WORKSPACE" "$VERSION"
				display_current_config
				display_tracked_files "$WORKSPACE"
			fi
		;;
		"current")
			WORKSPACE=`get_workspace` || exit $?
			# Load configuration
			source "$WORKSPACE/$AUTO_CONFIG_FILE"
			VERSION=`get_current_version "$WORKSPACE"` || exit $?
			echo $VERSION
		;;
		"track")
			local FILE_PATH="$1"
			local ABSOLUTE_PATH=
			WORKSPACE=`get_workspace` || exit $?
			# Load configuration
			source "$WORKSPACE/$AUTO_CONFIG_FILE"
			ABSOLUTE_PATH=`readlink -f "$FILE_PATH"`
			if ! [[ $ABSOLUTE_PATH == $WORKSPACE/* ]]; then
				panic $EXIT_INVALID_PARAM "File is out of scope: \"$ABSOLUTE_PATH\"\nTracked files must be relative to workspace: \"$WORKSPACE\"."
			fi
			TRACKED_PATH="`echo $ABSOLUTE_PATH | cut -c$((${#WORKSPACE} + 1))-${#ABSOLUTE_PATH}`"
			if [ -f "$WORKSPACE/$AUTO_TRACKED_FILE" ]; then
				if grep -q "$TRACKED_PATH" "$WORKSPACE/$AUTO_TRACKED_FILE"; then
					panic $EXIT_INVALID_PARAM "File already being tracked: \"$TRACKED_PATH\"."
				fi
			fi
			if [ ! -f "$ABSOLUTE_PATH" ]; then
				confirm "File does not exist: $ABSOLUTE_PATH\nContinue anyway?"
				if [[ $? != 0 ]] ; then
					panic $EXIT_CANCELED "Canceled by the user."
				fi
			fi
			verbose "Keeping track of a new file: \"$TRACKED_PATH\"..."
			echo "$TRACKED_PATH" >> "$WORKSPACE/$AUTO_TRACKED_FILE"
			if [[ $? != 0 ]] ; then
				panic $EXIT_IO_ERROR "Could not track file in the workspace at: \"$WORKSPACE\"."
			fi
			echo "Tracked file: $TRACKED_PATH"
		;;
		"untrack")
			local FILE_PATH="$1"
			local ABSOLUTE_PATH=
			WORKSPACE=`get_workspace` || exit $?
			# Load configuration
			source "$WORKSPACE/$AUTO_CONFIG_FILE"
			ABSOLUTE_PATH=`readlink -f "$FILE_PATH"`
			if ! [[ $ABSOLUTE_PATH == $WORKSPACE/* ]]; then
				panic $EXIT_INVALID_PARAM "File is out of scope: \"$ABSOLUTE_PATH\"\nTracked files must be relative to workspace: \"$WORKSPACE\"."
			fi
			TRACKED_PATH="`echo $ABSOLUTE_PATH | cut -c$((${#WORKSPACE} + 1))-${#ABSOLUTE_PATH}`"
			if [ -f "$WORKSPACE/$AUTO_TRACKED_FILE" ]; then
				if ! grep -q "$TRACKED_PATH" "$WORKSPACE/$AUTO_TRACKED_FILE"; then
					panic $EXIT_INVALID_PARAM "File not being tracked: \"$TRACKED_PATH\"."
				fi
			fi
			verbose "Losing track of an existing file: \"$TRACKED_PATH\"..."
			cat "$WORKSPACE/$AUTO_TRACKED_FILE" | grep -v "$TRACKED_PATH" | tee "$WORKSPACE/$AUTO_TRACKED_FILE" > /dev/null ; test ${PIPESTATUS[0]} -eq 0
			if [[ $? != 0 ]] ; then
				panic $EXIT_IO_ERROR "Could not untrack file in the workspace at: \"$WORKSPACE\"."
			fi
			echo "Untracked file: $TRACKED_PATH"
		;;
		"bump"|"force"|"grade"|"major"|"minor"|"patch")
			WORKSPACE=`get_workspace` || exit $?
			# Load configuration
			source "$WORKSPACE/$AUTO_CONFIG_FILE"
			VERSION=`get_current_version "$WORKSPACE"` || exit $?
			case $SUBCOMMAND in
				"bump")
					# Normal bump
					BUMPED=`bump -v "$VERSION" "$@"`
					if [ -z "$BUMPED" ]; then
						panic $EXIT_INVALID_VERSION "Current version could not be bumped ($@)"
					fi
				;;
				"grade"|"major"|"minor"|"patch")
					# Speed bump
					BUMPED=`bump -v "$VERSION" -i $SUBCOMMAND "$@"`
					if [ -z "$BUMPED" ]; then
						panic $EXIT_INVALID_VERSION "Current version could not be $SUBCOMMAND-bumped ($@)"
					fi
				;;
				"force")
					# Forced bump
					FORCED="$1"
					shift
					BUMPED=`bump -v "$FORCED" "$@"`
					if [ -z "$BUMPED" ]; then
						panic $EXIT_INVALID_VERSION "Can't force version to: \"$FORCED\" $@"
					fi
				;;
			esac
			if [ $VERSION == $BUMPED ]; then
				panic $EXIT_INVALID_STATUS "Nothing to bump."
			fi
			verbose "Automatically bumping version identifier \"$VERSION\" => \"$BUMPED\"..."
			ESCAPED_VERSION=`escape_version "$VERSION"`
			process_file "$WORKSPACE/$AUTO_VERSION_FILE" "$ESCAPED_VERSION" "$BUMPED"
			verbose "Checking \"$WORKSPACE/$AUTO_TRACKED_FILE\"..."
			if [ -f "$WORKSPACE/$AUTO_TRACKED_FILE" ]; then
				verbose "Looking for additional files to bump..."
				readarray -t LINES < "$WORKSPACE/$AUTO_TRACKED_FILE"
				for FILE_PATH in "${LINES[@]}"; do
					TARGET="${WORKSPACE}${FILE_PATH}"
					if [[ -n "$FILE_PATH" ]] && ! [[ $FILE_PATH =~ $COMMENTED_LINE ]] && [[ -f "$TARGET" ]]; then
						process_file "$TARGET" "$ESCAPED_VERSION" "$BUMPED"
					fi
				done
			else
				verbose "No additional files to bump."
			fi
			# Commit changes to GIT repository if auto commit is enabled
			if [ -n "$AUTO_GIT_COMMIT" ]; then
				verbose "Commiting version bump..."
				git commit --message "Bump version to $BUMPED"
			fi
			echo "Version bumped to: $BUMPED"
		;;
		*)
			panic $EXIT_UNKNOWN_COMMAND "Unknown subcommand: \"$SUBCOMMAND\"\n$HELP_AUTO"
		;;
	esac
}
