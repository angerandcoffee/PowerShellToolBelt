<#
.SYNOPSIS
Script allows to fing given text in files under given location.

.DESCRIPTION 
The script searches for files which contians textunder given location. 
Found files are listed in found_files.txt and errors are listed in errorLog.txt.

.PARAMETER Path
Path to destination where text in files should be searched. Script searches text recursively. Default value is '.'

.PARAMETER OldText
Text which should be found.

.PARAMETER FileExtensions
List of file extensions which should be included in text replacing. 

.EXAMPLE
./Find-TextInFiles.ps1 -Text 'value'  -> in all files recursively in the same directory where script is (.) text "value" will be searched and list of files will be created in found_files.txt
.EXAMPLE
./Find-TextInFiles.ps1 -Path 'C:\MyFolder' -Text 'value' -> in all files recursively in directory "C:\MyFolder" text "value" will be searched and list of files will be created in found_files.txt
.EXAMPLE
./Find-TextInFiles.ps1 -Path 'C:\MyFolder' -Text 'value' -FileExtensions 'cs','aspx' -> in .cs and .aspx files recursively in directory "C:\MyFolder" text "value" will be searched and list of files will be created in found_files.txt

#>

param(
    [ValidateScript({Test-Path $_})]
    [string]$Path = '.',
    [Parameter(Mandatory)]
    [string]$Text,
    [string[]]$FileExtensions = '*'
)

[System.Collections.ArrayList]$filesToSearch = @()

$logFilePath = "./found_files.txt"
$errorLogFilePath = "./errorLog.txt"

$logFullPath = Resolve-Path $logFilePath
$errorLogFullPath = Resolve-Path $errorLogFilePath

New-Item $logFilePath -type file -Force
New-Item $errorLogFilePath -type file -Force


try {
    foreach($fileExtension in $FileExtensions){
        $filesToSearch.Add("*.$fileExtension") | Out-Null
    }

    Write-Output "Searching '$Text' in location '$Path' ..."

    $foundFiles = Get-ChildItem $Path -Include $filesToSearch -Recurse | Select-String -Pattern $Text | Group-Object Path
} catch {
    "Reason $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)" | Out-File $errorLogFullPath
    Write-Error "Script execution file. Check error log file: $errorLogFilePath"
    return
}

"$Text was found in: " | Out-File $logFilePath -Append
foreach($file in $foundFiles) {
 "`n$($file.Name) $($file.Count) time(s): " | Out-File $logFilePath -Append
 "$($file.Group)" | Out-File $logFilePath -Append
}


Write-Output "Searching was finished.`n Log file can be found in '$logFullPath'.`n Errors are logged in '$errorLogFullPath'."