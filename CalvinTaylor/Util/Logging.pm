#!/usr/bin/perl
package CalvinTaylor::Util::Logging;

use strict;
use warnings;
use POSIX qw(strftime);
use Exporter;
use Cwd 'abs_path';
use Carp qw/longmess/;

our @ISA= qw( Exporter );

# generated export with: egrep -e "sub (\S+)\s*\{*\s*$" Logging.pm | xargs -0 | egrep -oe "(\S+)$" | sort
our @EXPORT = qw(
debug
disableTSLogging
enableTSLogging
error
formatMsg
getDebugMode
getLogDirectory
getLogName
_getScriptId
getTime
getTraceMode
info
initializeLogging
setDebugMode
setTraceMode
trace
warning
writeLog
);

my $debugMode=0; #Enable debug messages.  While that was the original concept, I've since used it to toggle output style
my $traceMode=0; #Enable trace messages.
my $logFile;
my $logToStdout = 0;
my $logTS = 0;
my $pathToScript = abs_path($0);
my $loggable = 1;
my $host = "";

sub setDebugMode
{
	$debugMode=1;
	debug("called from ".longmess, "Logging->setDebugMode");
}

sub setTraceMode
{
	$traceMode=1;
	$debugMode=1;
	debug("called from ".longmess, "Logging->setTraceMode");
	trace("called from ".longmess, "Logging->setTraceMode");
}

sub getDebugMode
{
	return $debugMode;
}

sub getTraceMode
{
	return $traceMode;
}

sub writeLog
{
	my $msg = shift;
	writeToLogFile($msg);
}

sub formatMsg
{
	my $msg = shift;
	if (!$msg)
	{
		if ($debugMode || $traceMode)  #sometimes we need to spit out blank lines, like when showing output of a command.
		{
			return "\n\nWARNING NO logging message defined!\n";
		}else{
			$msg = "";
		}
	}
	# my $scriptId = shift;
	# if (! $scriptId)
	# {
	# 	$scriptId = getScriptId();
	# }
	my $string = " $msg\n";
	#
	# if (($debugMode || $traceMode) && $scriptId)
	# {
	# 	$string =  " $scriptId - $string";
	# }

	return $string;
}

sub trace
{
	my $msg = "\[TRACE\]".formatMsg(@_);
	#if in debug mode trace should got to log only
	#if in trace mode, trace should got to std out and log.
	if ($debugMode || $traceMode)
	{
		if ($traceMode)
		{
			 print "$msg";
		}
		writeLog($msg);
	}
}

sub debug
{
	my $msg = "\[DEBUG\]".formatMsg(@_);
	if ($debugMode || $traceMode)
	{
		print "$msg";
	}
	writeLog($msg);
}

sub info
{
	my ($lmsg, $id) = @_;
	my $mstr = formatMsg($lmsg);
	my $msg = " \[INFO\]$mstr";
	print "$msg";

	$mstr = formatMsg($lmsg, $id);
	$msg = " \[INFO\]$mstr";
	writeLog($msg);
}

sub warning
{
	my ($lmsg, $id) = @_;
	my $mstr = formatMsg($lmsg);
	my $msg = " \[WARN\]$mstr";
	print "$msg";

	$mstr = formatMsg($lmsg, $id);
	$msg = " \[WARN\]$mstr";
	writeLog($msg);
}

sub error
{
	my ($lmsg, $id) = @_;
	my $mstr = formatMsg($lmsg);
	my $msg = "\[ERROR\]$mstr";
	print "$msg";

	$mstr = formatMsg($lmsg, $id);
	$msg = "\[ERROR\]$mstr";
	writeLog($msg);
}

sub _getScriptId
{
	my $scriptId = $0;
	return $scriptId;  #typically we override this method.
}

my $startTime = 0;
sub getTime
{
	my $duration = "";
	if ($debugMode)
	{
		my $now = time;
		if ($startTime == 0)
		{
			$startTime = $now;
		}
		my $runTime = $now - $startTime ; #resolve to minutes
		my $minutes = int ($runTime / 60);
		$duration = " ($minutes m) ";
	}
	my $datestring = strftime "%b %e %H:%M:%S %Y", localtime;

	return $datestring . $duration .":";
}

sub initializeLogging
{
	my ($logf) = @_;
	if ($logf){
		$logFile = $logf;
	}else{
		$logFile = getLogDirectory()."/CalPerl.log";
	}
	debug("initializing $logFile ".longmess, "initializeLogging");
}

sub getLogDirectory
{
	my ($self) = @_;

	my $logDir = "/tmp";
	return $logDir;
}

sub getLogName
{
	return $logFile;
}


sub enableTSLogging
{
	$logTS = 1;
}

########################################################################
# disableTSLogging
#
# Disables timestamp logging.
#
#typical of a unit test, where we want to verify what gets written to log.
sub disableTSLogging
{
	$logTS = 0;
}

sub writeToLogFile
{
	(my $message) = @_;

	if ($logTS)
	{
		$message = getTime() . " $message";
	}
	writeToLogFileBare($message);
}

sub writeToLogFileBare
{
	my ($message) = @_;

	if (defined($logFile))
	{
		if (open(my $LOGFILE, '>>', $logFile))
		{
			print $LOGFILE $message;
			close($LOGFILE);
		}
		else
		{
			print getTime() . "[ERROR] writeToLogFile - could not open logfile $logFile \n";
		}
	}
}


1;
