#!/bin/bash

# source CalFuncs.bash
# LOGDIR=/tmp
# LOG=$LOGDIR/batsTestHelper.log

setup() {

  # {
  #   "RootLocation": "~/myStuff",
  #   "RootRelativeLocations": [
  #                         "DCIM/Pictures",
  #                         "DCIM/Facebook"
  #                         ],
  #   "DestinationLocation"
  #   "Executable": "importPhotos.sh -s $RootRelativeLocation -t $DestinationLocation"
  # }
  #
  # [ -d "$TMP" ] && rm -rf "$TMP"
  local BATS_TEST_DIRNAM=$BATS_TEST_DIRNAM
  if [ -z "$BATS_TEST_DIRNAM" ]; then
    BATS_TEST_DIRNAM=$(pwd)/tests
  fi

  export TMP="$BATS_TEST_DIRNAM/tmp"
  export OUT="$BATS_TEST_DIRNAM/output"
  export CONFNAME=".syncFilesFromBackup.json"

  [ -d "$TMP" ] && rm -rf "$TMP" ; mkdir -p "$TMP"
  [ -d "$OUT" ] && rm -rf "$OUT" ; mkdir -p "$OUT"
}

# teardown() {
#   [ -d "$TMP" ] && rm -rf "$TMP"
# }

setup
