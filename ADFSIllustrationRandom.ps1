﻿#params
$CSVFile = ".\Folders.csv" #what if this doesnt exits? 
$FileFilter = "ADFS-*.png"

try
{
    $BaseFolders = Import-Csv $CSVFile
}
catch [System.IO.FileNotFoundException],[System.Management.Automation.ParameterBindingException]
{
    $Error.clear()
}

if($BaseFolders.count -ge 1){
    $BaseFolders | ForEach-Object{
        #DateConversion
        try
        {
            $_.StartDate = [datetime]::Parse($($_.StartDate))
        }
        catch [System.FormatException]
        {
            throw [System.FormatException] "$($_.FolderPath) StartDate is not formatted correctly"
        }
        try
        {
            $_.EndDate = [datetime]::Parse($($_.EndDate))
        }
        catch [System.FormatException]
        {
            throw [System.FormatException] "$($_.FolderPath) EndDate is not formatted correctly"
        }
        if(($_.StartDate.CompareTo($($_.EndDate))) -gt 0 )
        {
            throw "$($_.FolderPath) EndDate Cannot be earlier than StartDate"
        }
    }
    $CurrentDate = Get-Date
    $BaseFolders = $BaseFolders | where {$_.StartDate -LE $CurrentDate -and $_.EndDate -GE $CurrentDate}
    #If there are more than one folders returned after filtered within the date range; then pick one at random and pass it on.
    if($($BaseFolders.count) -gt 1)
    {
        $BaseFolders = $BaseFolders | Get-Random -Count 1
    }
}

#if no folders, use the script operating folder.
else
{
    $BaseFolders = [PSCustomObject]@{FolderPath = "."}
}


#By now there should only be one folder.
$BaseFolders.FolderPath = $BaseFolders.FolderPath + "\$FileFilter"

$files = dir -Path $($BaseFolders.FolderPath)
$sample = $files | Get-Random -Count 1

$sample
#Set-AdfsWebTheme -TargetName default -Illustration @{path=$sample.FullName} -Verbose