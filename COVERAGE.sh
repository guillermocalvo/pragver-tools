#!/bin/bash

function code_coverage() {
	TEST_CASE=$1
	echo Calculating code coverage for $1...
	kcov --include-pattern=/src $DATA_DIR ./test-driver --test-name "$TEST_CASE" --log-file "$DATA_DIR/$TEST_CASE.log" --trs-file "$DATA_DIR/$TEST_CASE.trs" test/$TEST_CASE.sh
}

echo Calculating code coverage...

DATA_DIR=coverage
DATA_FILE=coverage-`date -u +%Y%m%d-%H%M%S`

mkdir -p $DATA_DIR

code_coverage test-auto1
code_coverage test-auto2
code_coverage test-bump
code_coverage test-extract
code_coverage test-new
code_coverage test-pragver
code_coverage test-validate

echo Code coverage calculated:
cat $DATA_DIR/test-driver.*/coverage.json

echo Storing code coverage files temporarily...
tar -zchf $DATA_FILE.tar.gz $DATA_DIR
curl -F "file=@$DATA_FILE.tar.gz" https://file.io
