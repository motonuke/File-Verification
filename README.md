# File-Verification
Initial Publish

This is a first crack at a file verification scheme using native powershell. It's a rudamentary attempt at scanning for file integrity using built-in tools within the OS. The idea is to check for file degradation / bit-rot. An initial hash will be created and stored, which will be used to check the exisiting data files on a schedule basis.

The script will scan a set of folders and do the following:

1. If a hash signature file is found, script will check that it is readable. If readable, proceeds to run a calculation on the current data file and compares to the stored hash. Logs errors if found. 

2. If a hash doesn't exist, create a hash and check that it is valid.

There are some shortcomings. Mainly this is aimed at larger files, as seen by the filters applied. Additionally, ever single file intended to be scanned will have its own paired hash signature file. For larger directories with smaller files (music files, pictures, etc.), this is not going to be feasible. 

Requuirements:

Powershell 5.x or higher. I wrote this on PowerShell v5.1 (Native version in Windows 2016). Running on older versions of PowerShell may work. You results may very, use at your own peril.

Usage:

Edit the file and change the following parameters to suit your environment:

$logpath

$scanpath

You may also change the filtering options if desired. 

Future plans:

-Create hash signature dictionary file for all files contained within a subfolder. This solves the small file issue.

-Modify Script to accept command line parameters. This is mainly for ease of use and portability.
