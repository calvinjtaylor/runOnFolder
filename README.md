# runOnDirectories.pl

## Description
A perl script to run complicated file syncronization.  A json file holds the configuration information, and the executable requires no arguments.

## Usage

 * runOnDirectories.pl - looks for config file in ~/.runOnDirectories.json

 * runOnDirectories.pl <location> - looks for config file at specified location.  Location can be the parent directory if config file is named .runOnDirectories.json, otherwise location can be relative or full to a specific json config file.

## ConfigFile
  root_location  - the root folder inside which we may find other folders of interest.

  The following is my config file used to direct photo imports
  ```json
  {
    "RootLocation": "~/myStuff",
    "RootRelativeLocations": [
                          "DCIM/Pictures",
                          "DCIM/Facebook"
                          ],
    "DestinationLocation"
    "Executable": "importPhotos.sh -s $RootRelativeLocation -t $DestinationLocation"
  }
  ```
