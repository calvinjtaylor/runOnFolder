# syncFolders.pl

## Description
A perl script to run complicated file syncronization.  A json file holds the configuration information, and the executable requires no arguments.

## Usage

 * syncFolders.pl - looks for config file in ~/.syncFolders/config.json

 * syncFolders.pl <configFile.json> - looks for config file at specified location.

## ConfigFile
  root_location  - the root folder inside which we may find other folders of interest.

  The following is my config file used to direct photo imports
  {
    "RootLocation": "~/myStuff",
    "RootRelativeLocations": [
                          "DCIM/Pictures",
                          "DCIM/Facebook"
                          ],
    "DestinationLocation"
    "Executable": "importPhotos.sh -s $RootRelativeLocation -t $DestinationLocation"
  }
