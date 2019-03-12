# CMODTools
Misc utility tools for CMOD

## recreate-retr.sh

This is a small utility to recreate a retr directory. First thing it will delete the existing "retr" directory if it exists
in order to have a clean state where to begin.

At the moment, you need to edit the script to give the path of CMOD home installation directory.
Then then usage is quite "easy":

    ./recreate_retr.sh <ODINSTANCE>

There will be error messages if:

* ars.ini is not found
* problem with permission
* cache directories not found
* check if you are the od instance owner
* cache config file not found or not readable

As always have a backup if something goes wrong :-D

For the moment the OD Instance which is called "ARCHIVE" is not supported yet.
Need to add this use case.
