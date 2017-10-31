#!/usr/bin/perl
package Logging;
#package auPatch;
use strict;
use warnings;

use Test::XML;
use Test::Exception;
use Test::More tests => 1;
use TestPatchData;

use Data::Dumper;
use Logging ;

my $scriptId = "Logging.t::";

#setDebugMode(1);

testDebug();
testInfo();
testWarn();
testError();
testDevel();


sub testDebug
{
	debug ("Hello");
	debug ("Hello","Functionator");
	setLoggingPatchPosition("starting");
	setLoggingHostString("myhost");
	debug ("Hello","Functionator");
}

sub testInfo
{
	info ("Hello");
	info ("Hello","Functionator");
}
sub testWarn
{
	warning ("Hello");
	warning ("Hello","Functionator");
}

sub testError
{
	error ("Hello");
	error ("Hello","Functionator");
}

sub testDevel
{
	LOG_DEVEL ("Hello");
#	PrintAndLog ("Hello");
}

info ("%%%% tests complete", "main");
is (1,1,"does it look ok?");
