#!/usr/bin/perl
# package Cal::Sync;
use strict;
use warnings;

use Cwd;
use Data::Dumper;
use File::Copy "cp";
use File::Basename;
use File::Find;

use Carp qw/longmess cluck confess/;

use JSON; # imports encode_json, decode_json, to_json and from_json.

use lib ".";
use Logging;

my $defaultConfigName=".syncFilesFromBackup.json";
my $configFile = "~/$defaultConfigName";

sub usage {
	print "Usage: $0  <config file> \n";
	print "Where:\n";
	print "\t<config file is optional, if ommitted the default used is in ~/.syncFilesFromBackup.json\n";
	print "-h: shows usage screen\n";
  print "";
}

sub readCommandLineParameters {
	my $argNum = 0;
	while ($argNum <= $#ARGV)
	{
    my $arg = $ARGV[$argNum];
    if ( !$arg){
			error ("Argument not understood, $arg ");
      usage();
      exit 1;
    }
    $configFile = $arg;
		$argNum++;
	}
}

sub fileRead {
	my ($fileName) = @_;
	my $fn = "fileRead";
	my $read = undef;
	if ( ! -f $fileName ) 	{
		error( "File '$fileName' does not exist!", $fn);
		return $read;
	}

	my $ret = open(my $fh, '<:encoding(UTF-8)', $fileName);
	if ( $ret )	{
		while (my $row = <$fh>)
		{
			chomp $row;
			if ($row)
			{
				if (not defined $read)
				{
					$read = "";
				}
				else
				{
					$read .= "\n";
				}
				$read .= $row;
			}
		}
	} else {
		error( "Could not open file '$fileName' ret=$ret", $fn);
	}
	return $read;
}

sub actionConfig {
  my ($config) = @_;
  my $fn = "actionConfig";
	my $ret = -1;

  my $srcPrefix = $config->{"SourceRootLocation"};
  $srcPrefix = undef unless ($srcPrefix);
  # debug ("srcPrefix=".Dumper($srcPrefix), $fn);

  my $dstPrefix = $config->{"DestinationRootLocation"};
  $dstPrefix = undef unless ($dstPrefix);
  # debug ("$dstPrefix=".Dumper($dstPrefix), $fn);


  my $sourceLocations = $config->{"SourceLocations"};
  my $destinationLocations = $config->{"DestinationLocations"};

  my $cmd = $config->{"Executable"};

  if ($sourceLocations){
    debug ("SourceLocations=".Dumper($sourceLocations));
    foreach my $sourceLocation (@$sourceLocations){
      if ($srcPrefix){
        $sourceLocation = $srcPrefix . "/" . $sourceLocation;
      }
      if ( -d $sourceLocation) {
				debug ("Source exists; ".$sourceLocation, $fn);
	    } else {
			  error ("Couldn't find source $sourceLocation", $fn);
        next;
      }
      debug ("cmd; ".$cmd, $fn);
      $cmd =~ s/\$SourceLocations/$sourceLocation/g;

      if ($destinationLocations){
        debug ("DestinationLocations=".Dumper($destinationLocations));
        foreach my $destinationLocation (@$destinationLocations){
          if ($dstPrefix){
            $destinationLocation = $dstPrefix . "/" . $destinationLocation;
          }

          unless ( -z "$destinationLocation" || -d $destinationLocation) {
            debug ("Couldn't find destination $destinationLocation", $fn);
            `mkdir -p $destinationLocation`;
          }
          debug ("Destination exists; ".$destinationLocation, $fn);

          $cmd =~ s/\$DestinationLocations/$destinationLocation/g;

          debug ("calling $cmd ", $fn);
          my $output = `$cmd`;
					$ret = $?;
					debug ("returned code $ret");
					debug ("generated output '$output'");
					if ($ret)
					{
						error("Command $cmd failed with output $output");
						return $ret;
					}
        }
      }
    }
  } else {
    error ("Couldn't read SourceLocations from json file", $fn);
  }
	if ($ret)
	{
		error("Failed to execute config");
	}
	return $ret;
}

initializeLogging();
setDebugMode();

if (readCommandLineParameters())
{
	exit 1;
}

debug("parameter configFile=$configFile.");
# $configFile = `ls $configFile`;
# chomp $configFile if ($configFile);
# if(-e $configFile && -f _ && -r _ ){
#    print("File $configFile exists and readable\n");
# }

my $currentDir=getcwd;

if ( $configFile && ! -f $configFile ){
	# $configFile="$currentDir/$configFile";
	debug("configFile=$configFile.");
	if ( -d $configFile ) {
		debug("Config File not found at $configFile, but was meant to represent something, attempting concatonation of default config file name.");
		#append default name to string and see if that file exists
		$configFile.="/$defaultConfigName";
		if ( ! -e "$configFile" ) {
			error("Default Config File not found at $configFile");
		  usage();
		  exit 1;
		}
	}
}

if ( -f $configFile){
	debug("Config File found at $configFile.");
}else{
	error("Config File not found at $configFile");
	usage();
	exit 1;
}

my $fileText = fileRead($configFile);
error "Couldn't read text from configFile $configFile" unless ($fileText) ;
debug "fileText=$fileText";
my $json = from_json($fileText); #[, $optional_hashref]
debug "json=".Dumper($json);

my $ret = actionConfig($json);
if ($ret){
	error ("Failed to Action the configFile found at $configFile successfully.");
}else{
	debug "Complete";
}
exit $ret;
