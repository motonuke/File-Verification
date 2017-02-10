
## File Verification Script v .01
## - MotoNuke


## Setting up paramters
$logdate = get-date -f yyyy.MM.dd-HHmm
$logpath = "c:\Your Log Path Here"
$logname = "file_check_log-$logdate.log"
$logpathfull = $logpath+$logname
$hashfail = 0
$createdfiles = 0
$hashnoread = 0
$starttime = date

## Start of logging, path set above
Start-Transcript -Path $logpathfull -NoClobber

## Scanning path root. Anything below this base folder will be scanned recursively.
$scanpath = "E:\TestFolder"

## Enumerate Path and filter on file size and extension.
$children = Get-ChildItem -Recurse $scanpath 

$childrenfiltered = $children | Where-Object {$_.Length -gt 50000000} | Where-Object {$_.Name -notmatch "trailer" -and $_.Name -notmatch ".sub"}

## Gauging pain level before starting :)
write-host "`nFound "$childrenfiltered.count" items in "$scanpath" to verify!" -f Green

# Check for and create (if needed) Logging folder
if (-not (Test-Path $logpathfull)) {New-Item $logpathfull -Type Directory}
if (-not (Test-Path $logpathfull\BAD_FILES)) {New-Item $logpathfull\BAD_FILES -Type Directory}
## Start iterating through the found files
foreach ($child in $childrenfiltered) {

## Funky parameter stuff, needs to be cleaned up or find a better way
$md5 = "md5"
$childpath = $child.Directory.FullName
$childmd5 = $child
$childmd5 = $childmd5.Name.Substring(0,$childmd5.Name.Length-3)
$childmd5 = "$childmd5$md5"
$fullpath = $child.FullName
$fullpathmd5 = "$childpath\$childmd5"
#$fullpath
#$fullpathmd5
$filecheck = get-item $fullpathmd5 -ErrorAction SilentlyContinue
#$filecheck.Length

## Check folder is missing md5 file, stores as parameter/object
if ($filecheck -and $filecheck.Length -gt 75) {
## Getting hashes from data file AND stored hash in md5 file
    # write-host "`nHash file found, please wait while I check it against the source file..." -f green
    # write-host "`nSource file is - $fullpath" -f Green
    $datahash = Get-FileHash $fullpath -Algorithm MD5 | select Hash
    # Write-host "Data hash:"
    # $datahash.Hash
    $storedhash = import-csv $fullpathmd5 | select Hash
    # write-host "Stored Hash of data file:"
    # write-host "Stored Hash is - "$storedhash.hash" Hash"
## Hash verification stage
    if ($datahash.hash -eq $storedhash.hash) {
        write-host "`nHashes Match, file $fullpath is still good" -f Green
        }
        else 
        {
		if ($storedhash.hash -is [int]) {write-host "Hash Match Failed. HASH VERIFICATION ERROR. Offending file - "$fullpath"" -f Red
			$hashfail ++
			
			Write-Output $fullpath | out-file $logpath"BAD_FILES\$child.BAD"
			Write-Output "Data File Hash -" $datahash.Hash | out-file $logpath"BAD_FILES\$child.BAD" -Append
			Write-Output "Stored Hash -"$storedhash.Hash | out-file $logpath"BAD_FILES\$child.BAD" -Append
			}
			else 
			{
			write-host "Hash Match Failed. HASH VERIFICATION IS UNREADABLE. Offending file - "$fullpath"" -f Red
			$hashnoread ++
			Write-Output $fullpath | out-file $logpath"BAD_FILES\$child.BAD"
			Write-Output "Data File Hash -" $datahash.Hash | out-file $logpath"BAD_FILES\$child.BAD" -Append
			Write-Output "Stored Hash - UNREADABLE" | out-file $logpath"BAD_FILES\$child.BAD" -Append
			}
		}
    } 
    else 
    {
## Creating the md5 hash file if one is not found
    write-host "Existing Hash not found, I will create one..." -f Yellow
    Get-FileHash $fullpath -Algorithm MD5 | Export-CSV $fullpathmd5
    $createdcheck = Get-Item $fullpathmd5
## Verifiying the file exists and "something" was written to it.
    if ($createdcheck -and $createdcheck.Length -gt 75) {write-host "MD5 file was successfully created - $fullpathmd5" -f green;$createdfiles ++} 
		else {write-host "MD5 file wasn't created, this is unusual. Something went wrong..." -f red}
		}
}
$endtime = date

$totaltime = $endtime - $starttime
## Stats block for end of log file
write-host "************************************"
write-host "I took "$totaltime.minutes" minutes and "$totaltime.seconds" seconds to run" -f Green
write-host "************************************"
write-host "I checked "$childrenfiltered.count" files" -f Green
write-host "************************************"
write-host "I found $hashfail failed Hash verifications!!" -f yellow
write-host "************************************"
write-host "I found $hashnoread Unreadable Hashes!" -f yellow
write-host "************************************"
write-host "I created $createdfiles Hash verification files" -f cyan
write-host "************************************"
Stop-Transcript



 
