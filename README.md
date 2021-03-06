# VDJHistoryParser
This is a Powershell script, that parses VirtualDJ history files and creates a playcount total CSV file

By using this script, you can view the actual playcounts of a track based off of your actual history files.


This Powershell script loads Virtual DJ databases across all connected drives.
Searches history files and counts how many times a file has been played.

PC and Mac compatible

While VirtualDJ does record playcount of a track, the playcount can get out of sync over time due to library maintenance, or maybe someone started fresh with a new database.

VirtualDJ also has a tracklist file in the history folder, I've found that not to be reliable.  For example, I have history files from 2005, but my tracklist history file only goes back to 2019, which is when I switched laptops.  I also have a primary and backup laptop.  The backup laptop is sometimes used for different events.  I keep history files synced over the cloud, so this lets me add history files from all of my VDJ machines, so I'll get better statisitics.

This assumes you have all of your history files, and they are up to date.


# Mac Users

Install PowerShell for mac following instructions by Microsoft: https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos?view=powershell-7.1

# Things to watch out for
History files tend to get out of date, or not match the file path exactly.
Pick a song and use a program such as FileLocator Lite/Pro to search all of your history files for that one song to verify the playcount.
The file path that maps to the database entry is provided in the output file so you can track down any counts that are off.

For example, Brown Eyed Girl had multiple entries when I was doing testing.
What I found was that the file location didn't always match, but VDJ still loaded the files from history ok.
You can correct these counts by updating the history files.

The process cannot access the file if you have the file open in Excel.  Be sure to close the file in Excel before running the script again.
