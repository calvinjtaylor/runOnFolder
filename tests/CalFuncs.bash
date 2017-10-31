#!/bin/bash

LOGDIR="/tmp"
LOG=$LOGDIR/CalFunc.log
[ ! -d "$LOGDIR" ] && mkdir -p $(dirname $LOG)

SSH_OPTIONS="-o StrictHostKeyChecking=no -q -o ConnectTimeout=15"
SSH="ssh $SSH_OPTIONS -T"
SCP="scp $SSH_OPTIONS"
SI=$(basename $0)

Log() {
	echo "`date` [$SI] $@" >> $LOG
}

Run() {
	Log "Running '$@' in '`pwd`'"
  $@ 2>&1 | tee -a $LOG
}

RunHide() {
	Log "Running '$@' in '`pwd`'"
	$@ >> $LOG 2>&1
}

PrintAndLog() {
	Log "$@"
	echo "$@"
}

ErrorAndLog() {
	Log "[ERROR] $@ "
	echo "$@" >&2
}

showMilliseconds(){
  date +%s
}

runMethodForDuration(){
  local startT=$(showMilliseconds)
  $1
  local endT=$(showMilliseconds)
  local totalT=$((endT-startT))
  PrintAndLog "that took $totalT seconds to run $1"
  echo $totalT
}

getFSStatDateInt(){
  local f="$@"
  # echo `stat  --format=%Y "$f"`
	stat  --format=%Z "$f" || echo 0
}
