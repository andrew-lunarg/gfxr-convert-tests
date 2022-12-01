#!/usr/bin/bash

# Run convert on all traces in the directory ../traces and diff the results against
# the blessed golden conversions in the same directory for regressions.
#
# Pass this script:
# Path to a checkout of the gfxreconstruct project
# A build configuration in the form of three path segements as used by the gfxreconstruct build.py (defaults to "dbuild/linux/x64")
# Path to a temporary directory to create some named pipes in (defaults to /tmp if not specified)
#
# An example commandline I use locally (adapt to your paths):
# /home/andrew/dev/gfxr-convert-tests/scripts/test_regressions.sh ~/dev/andrew-lunarg-gfxreconstruct dbuild/linux/x64  ~/temp/gfxr-convert-testing 

# Parameters
BUILD_CONFIG="$2"
TEMP_DIR="$3"
set -e
set -u
GFXR_ROOT="$1" # Pass the location of the root of a GraphicsReconstruct checkout that has been built with the standard path structure of the project's build.py.

if [ -z "$BUILD_CONFIG" ]
then
    BUILD_CONFIG="dbuild/linux/x64"
fi

if [ -z "$TEMP_DIR" ]
then
    TEMP_DIR="/tmp"
fi

CONVERT="$GFXR_ROOT/$BUILD_CONFIG/cmake_output/tools/convert/gfxrecon-convert"

# Work out what to test:
INPUT_DIR="$(dirname $(dirname $(realpath $0)))"
INPUT_DIR="$INPUT_DIR/traces"

#echo "CONVERT:   $CONVERT"
#echo "TEMP_DIR:  $TEMP_DIR"
#echo "INPUT_DIR: $INPUT_DIR"

mkdir -p "$TEMP_DIR" 2>/dev/null
# Delete everything in temp directory on script exit:
trap "rm $TEMP_DIR/* 2>/dev/null" EXIT

for GFXR in $INPUT_DIR/*.gfxr
do
    BASENAME=$(basename -s .gfxr "$GFXR")
    GOLDEN=$(dirname "$GFXR")/$BASENAME.jsonl
    TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")
    PIPE_NAME="$TEMP_DIR/pipe_$BASENAME"_"$TIMESTAMP"
    #echo "    INPUT:     $GFXR"
    #echo "    GOLDEN:    $GOLDEN"
    #echo "    TIMESTAMP: $TIMESTAMP"
    #echo "    PIPE_NAME: $PIPE_NAME"

    mkfifo "$PIPE_NAME"

    #cat "$PIPE_NAME" & 
    #cat "$GOLDEN" | head -n 5 >>"$PIPE_NAME"

    # Launch diff in the background waiting on the named pipe to be
    # pumped with JSON from a future convert, and comparing to the
    # golden reference conversion:
    echo "Diffing conversion of $GFXR for regressions now..." >> /dev/stderr
    diff "$GOLDEN" "$PIPE_NAME" | egrep  -v "^..{\"header\":{\"source-path\":\""  &

    # Run convert, outputting to the named pipe so we don't have to
    # make any temporary files:
    $CONVERT --output "$PIPE_NAME" "$GFXR"


    rm "$PIPE_NAME"
    sleep 1
    wait
done


# Run convert:
# $CONVERT

