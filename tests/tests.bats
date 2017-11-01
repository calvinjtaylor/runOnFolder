#!/usr/bin/env bats
#author calvin taylor coolcatt@gmail.com
#Nov 2017

#this is a bats bash testing script run by typing 'bats tests' in the project root directory.

#bats is a bash unit testing framework found here;

#the program under test lets a config file be described to call a program with set of directries and destinations to be run
# in my use case I want to run a photo importing script on several locations from my smartphone backup and have them all output into my photolibrary structure. To do this I place the folders containing photo's I want on the phone and the library location into a json config file and run it each time a phone backup completes.

exe="runOnDirectories.pl"

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

@test "test ls with working config file directed by relative path to dir source location, and sub locations" {
  i=0
  configText=$(getConfigText)

  srcLoc=$TMP/one
  [ ! -d "$srcLoc" ] && Log "Making dir $srcLoc" && mkdir -p "$srcLoc"
  [ -d "$srcLoc" ]
  touch $srcLoc/this
  touch $srcLoc/that

  #setup important dir and non important, only the important one should be shown by the ls command.
  srcLocI=$TMP/one/important
  srcLocN=$TMP/one/notimportant
  mkdir -p $srcLocN $srcLocI $OUT/out
  touch $srcLocI/this
  touch $srcLocI/that
  touch $srcLocN/nithisthat
  touch $srcLocN/nithatthis

  # ${string/pattern/replacement}
  configText=${configText/\#SRL\#/$srcLoc} # set source location for test
  configText=${configText/\#SL\#/important} # set source location for test
  configText=${configText/\#DRL\#/$OUT} # set dest location for test
  configText=${configText/\#DL\#/out} # set dest location for test
  configText=${configText/\#EXE\#/ls  \$SourceLocations \$DestinationLocations} # set exe test

  #write config text to test location
  exec 33>&1 # Save current stdout
  exec > $TMP/$CONFNAME
  printf "$configText\n"
  exec 1>&33  # Restore stdout

  Log "Calling perl $exe $TMP"
  result="$(perl $exe $TMP)"
  retCode=$?
  Log "result=$result"
  if [ "$retCode" -ne "0" ]; then
    ErrorAndLog "program exited with error $retCode"
    false
  fi
}

@test "test ls with working config file directed by relative path to dir only" {
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

  Log "Calling perl $exe $TMP"
  result="$(perl $exe $TMP)"
  retCode=$?
  Log "result=$result"
  if [ "$retCode" -ne "0" ]; then
    ErrorAndLog "program exited with error $retCode"
    false
  fi
}

@test "test ls with failing exe caused by misconfiguration in config file directed by relative path to dir only" {
  i=0
  configText=$(getConfigText)

  srcLoc=$TMP/one
  # [ ! -d "$srcLoc" ] && Log "Making dir $srcLoc" && mkdir -p "$srcLoc"
  # [ -d "$srcLoc" ]
  # touch $srcLoc/this
  # touch $srcLoc/that

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

  Log "Calling perl $exe $TMP"
  # result=""
  # result="$(perl $exe $TMP)"
  if Run perl $exe $TMP; then
    ErrorAndLog "Program exited with error $retCode"
    true
  else
    false
  fi
}

@test "test ls with working config file directed by relative path to exact config file" {
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

  CONFNAME="donkeyname.json"
  #write config text to test location
  exec 33>&1 # Save current stdout
  exec > $TMP/$CONFNAME
  printf "$configText\n"
  exec 1>&33  # Restore stdout

  Log "Calling perl $exe $TMP/$CONFNAME"
  result="$(perl $exe $TMP/$CONFNAME)"
  retCode=$?
  Log "result=$result"
  if [ "$retCode" -ne "0" ]; then
    ErrorAndLog "program exited with error $retCode"
    false
  fi
}
