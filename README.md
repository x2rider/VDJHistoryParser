# VDJHistoryParser
Powershell script that parses VirtualDJ history files and creates a playcount total CSV file

PC Version, not tested on PowerShell/Mac

Loads Virtual DJ databases across all connected drives
Searches history files and counts how many times a file has been played

# Things to watch out for
History files tend to get out of date, or not match the file path exactly
Pick a song and use a program such as FileLocator Lite/Pro to search all of your history files for that one song to verify the playcount
The file path that maps to the database entry is provided in the output file so you can track down any counts that are off

For example, Brown Eyed Girl had multiple entries when I was doing testing
What I found was that the file location didn't always match, but VDJ still loaded the files from history ok
You can correct these counts by updating the history files
