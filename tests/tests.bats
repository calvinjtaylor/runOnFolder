#!/usr/bin/env bats
#author calvin taylor coolcatt@gmail.com
#Oct 2017

#this is a bats bash testing script run by typing 'bats tests' in the project root directory.

#bats is a bash unit testing framework found here;

#the program under test lets a config file be described to call a program with set of directries and destinations to be run
# in my use case I want to run a photo importing script on several locations from my smartphone backup and have them all output into my photolibrary structure. To do this I place the folders containing photo's I want on the phone and the library location into a json config file and run it each time a phone backup completes.

exe="syncFilesFromBackup.pl"

load CalFuncs
LOG=$LOGDIR/batsTestHelper.log

load batsTestHelper


getConfigText(){
  TXT="{\n"
  TXT+="\t\"SourceRootLocation\": \"#SRL#\",\n"
  TXT+="\t\"SourceLocations\": [\n"
  TXT+="\t\t\"#SL#\"\n"
  TXT+="\t\t],\n"
  TXT+="\t\"DestinationRootLocation\": \"#DRL#\",\n"
  TXT+="\t\"DestinationLocations\": [\n"
  TXT+="\t\t\"#DL#\"\n"
  TXT+="\t\t],\n"
  TXT+="\t\"Executable\": \"#EXE#\"\n"
  TXT+="}\n"
  Log "TXT=$TXT"
  echo $TXT
}

#test setup
@test "test TMP set" {
  echo "test alive" >> $LOG
  [ -n "$TMP" ]
}

@test "test OUT set" {
  [ -n "$OUT" ]
}

@test "test ls" {
  i=0
  configText=$(getConfigText)

  srcLoc=$TMP/one
  [ ! -d "$srcLoc" ] && Log "Making dir $srcLoc" && mkdir -p "$srcLoc"
  [ -d "$srcLoc" ]
  touch $srcLoc/this
  touch $srcLoc/that

  # ${string/pattern/replacement}
  configText=${configText/\#SRL\#/} # set source location for test
  configText=${configText/\#SL\#/$srcLoc} # set source location for test
  configText=${configText/\#DRL\#/} # set dest location for test
  configText=${configText/\#DL\#/$OUT} # set dest location for test
  configText=${configText/\#EXE\#/ls  \$SourceLocations \$DestinationLocations} # set exe test

  #write config text to test location
  exec 33>&1 # Save current stdout
  exec > $TMP/$CONFNAME
  printf "$configText\n"
  exec 1>&33  # Restore stdout

  # printf $configText > $TMP/$CONFNAME
  # conf=$(cat $TMP/$CONFNAME)
  # Log "conf $conf"
  # echo "$configText" 1>&2
  Log "Calling perl $exe $TMP"
  result="$(perl $exe $TMP)"
  Log "result=$result"
  false
}
#
# # @test "test TestDirs set" {
# #   [ -n "$TestDirs" ]
# # }
# #
# @test "test TestFiles exist" {
#   i=0
#   for TestFile in ${TestFiles[@]} ; do
#     [ -f "$TMP/$TestFile" ]
#   done
# }
#
#
#
# @test "full test" {
#   p=$(pwd)
#   testLocation="$TMP"
#   # result="$(bash -x organizeFoldersByDate.sh -s tests/tmp/ -r -t tests/output/
#   result="$(bash $p/$exe $testLocation)"
#   [ ! -z "$result" ]
#
#   # for TestFile in ${ExpectedFiles[@]} ; do
#   #   echo "Testing $OUT/$TestFile exists and is a file"
#   #   [ -f "$OUT/$TestFile" ]
#   # done
# }
