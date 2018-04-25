
# Test Results
readonly TEST_RESULT_PASS=0
readonly TEST_RESULT_FAIL=1
readonly TEST_RESULT_SKIP=77
readonly TEST_RESULT_HARD_ERROR=99

# PragVer Error codes
readonly EXIT_SUCCESS=0
readonly EXIT_IO_ERROR=100
readonly EXIT_CANCELED=101
readonly EXIT_UNKNOWN_COMMAND=102
readonly EXIT_UNKNOWN_OPTION=103
readonly EXIT_INVALID_WORKSPACE=104
readonly EXIT_INVALID_STATUS=105
readonly EXIT_INVALID_VERSION=106
readonly EXIT_INVALID_PARAM=107
readonly EXIT_INVALID_RELEASE=108
readonly EXIT_INVALID_BUILD=109

function test_pass() {
	exit $TEST_RESULT_PASS
}

function test_fail() {
	>&2 echo -e "[FAIL]: $1"
	exit $TEST_RESULT_FAIL
}

function test_skip() {
	>&2 echo -e "[SKIP]: $1"
	exit $TEST_RESULT_SKIP
}

function hard_error() {
	>&2 echo -e "[HARD ERROR]: $1"
	exit $TEST_RESULT_HARD_ERROR
}

function assert_equals() {
	[[ "$3" == "$2" ]] || test_fail "$1\n  Expecting: \"$2\"\n      Found: \"$3\""
	>&2 echo -e "[OK]: $1"
}

function assert_like() {
	[[ $3 =~ $2 ]] || test_fail "$1\n  Expecting: \"$2\"\n      Found: \"$3\""
	>&2 echo -e "[OK]: $1"
}
