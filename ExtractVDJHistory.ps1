$documentsDir = [Environment]::GetFolderPath("MyDocuments")
if($documentsDir.Substring(0,1) -eq "/"){
    #MacOS
    $documentsDir = "$($documentsDir)/Documents"
}
$FilePath = "$($documentsDir)\VirtualDj\History"
if($isMacOS){
    $FilePath = $FilePath.Replace("\", "/")
}

$songs = @{} #song database hashtable
$songStats = @{} #statistics used to write CSV file

class SongStat {
    [string]$Author
    [string]$Title
    [int]$PlayCount
    [string]$FileName
}

function AddSongsFromDatabase([xml]$db) {
    foreach ($item in $db.VirtualDJ_Database.Song) {
        if($songs.containsKey($item)) {
            # song already in hashtable
        } else {
            $songs.add($item.FilePath, $item)
            $Host.UI.RawUI.CursorPosition = New-Object System.Management.Automation.Host.Coordinates 0,$Host.UI.RawUI.CursorPosition.Y
            Write-Host -NoNewline $songs.Count
        }
    }
    Write-Host("")
}

# list all disks
$systemDrives = [System.IO.DriveInfo]::getdrives() | Where-Object -Property TotalSize -gt 0 | Where-Object  -Property DriveType -eq "Fixed" | Where-Object -Property Name -notlike /System* | Where-Object -Property Name -notlike /private*
#$systemDrives = @( "Name", "C:" ) # For Windows testing only, or if you want to restrict to just one drive
#$systemDrives = @( "/" ) # For MacOS testing only, or if you want to restrict to just one drive

# Read database files from each drive
# skip first element which is just "Name"
#for ($i = 0; $i -lt $systemDrives.Count; $i++) {
#    [string]$drive = $systemDrives[$i].RootDirectory.Trim()
foreach($disk in $systemDrives) {
    $drive = $disk.RootDirectory
    if($drive -eq "Temp" -or $drive -eq "Name") {
        $databaseFileName = ""
    } elseif($drive -eq "C:\" -or $drive -eq "/"){
        # for HOME drive, database is in documents folder
        $databaseFileName = "$($documentsDir)\VirtualDj\database.xml"
    } else {
        # all others at root
        $databaseFileName = "$($drive)\VirtualDj\database.xml"
    }

    if($isMacOS)
    {
        $databaseFileName = $databaseFileName.Replace("\", "/")
    }

    try {
        if($databaseFileName.Length -gt 0) {
            # If there is a VDJ database file on this drive, load it
            if(Test-Path -Path $databaseFileName) {
                Write-Host("Loading database $($databaseFileName)")
                [xml]$databaseFile = Get-Content $databaseFileName
                AddSongsFromDatabase($databaseFile)
                Write-Host("Loading Complete")
            }
        }
    }
    catch {
        Write-Host "Unable to open database file $($databaseFileName)"
        #Write-Host $_
    }
}

if($songs.Count -gt 0){
    Write-Host("Reading History Files, updating play counts")

    $filter = '#' # ignore comment lines in history files
    $historyFiles = Get-ChildItem -Recurse $FilePath -Filter *.m3u
    
    foreach ($historyFile in $historyFiles) {
        [string]$author = ""
        [string]$title = ""

        try {
            # Read history files
            [string[]]$fileData = Get-Content -Path $historyFile.FullName | Select-String -Pattern $filter -NotMatch
            Write-Host "Parsing History File: $($historyFile.Name)"
            foreach ($songKey in $fileData) {
                $songInfo = $songs[$songKey]

                $author = ""
                $title = ""

                if(-not($null -eq $songInfo.Tags)){
                    $author = $songInfo.Tags.Attributes["Author"].Value
                    $title = $songInfo.Tags.Attributes["Title"].Value
                }

                if($author.Length -eq 0 -or $title.Length -eq 0) 
                {
                    # Attempt to parse Artist/Title from filename
                    # Supported filename convention:
                    # Artist - Title.ext
                    $lastSlashIndex = $songKey.LastIndexOf("\")
                    if($lastSlashIndex -lt 0){
                        $lastSlashIndex = $songKey.LastIndexOf("/")
                    }

                    $tempString = $songKey.Substring($lastSlashIndex+1)
                    $tempString = $tempString.split(".")[0]

                    [string[]]$tempStringArray = $tempString.Replace(" - ", ",").Split(",")
                    if($tempStringArray.Count -gt 1){
                        $author = $tempStringArray[0]
                        for ($i = 1; $i -lt $tempStringArray.Count; $i++) {
                            $title = "$($title)$($tempStringArray[$i])"
                        }
                    } else {
                        $author = $tempString
                    }
                }
                
                $songStatisticExists = $songStats.ContainsKey($songKey)
                if($false -eq $songStatisticExists) {
                    $songStatistic = [SongStat]::new()
                    $songStatistic.Author = $author
                    $songStatistic.Title = $title
                    $songStatistic.PlayCount = 1
                    $songStatistic.FileName = $songKey
                
                    $songStats.Add($songKey, $songStatistic)
                } else {
                    $songStatistic = $songStats[$songKey]
                    $songStatistic.PlayCount = $songStatistic.PlayCount + 1
                }
            }
        }
        catch {
            Write-Host "Unable to open history file $($historyFile.FullName)"
        }
    }

    try {
        # Write out results
        $outfile = "$($documentsDir)\VDJHistoryPlayCount.csv"
        if($isMacOS){
            $outfile = $outfile.Replace("\", "/")
        }
        $songStats.Values | Sort-Object -Descending -Property PlayCount | Export-Csv -NoTypeInformation $outfile
        Write-Host "Statistics written to: $($outfile)"        
    }
    catch {
        Write-Host "Error saving CSV file, do you have it open in another program?"
    }
}
else {
    Write-Host "No songs loaded from database"
}