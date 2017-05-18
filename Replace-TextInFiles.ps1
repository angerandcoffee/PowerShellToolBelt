<#
.SYNOPSIS
Script allows to change given text with anoter text in files under given location.

.DESCRIPTION 
The script searches for files which contians text to be replaced under given location and then changes all occures with new text. 
Effected files are listed in log.txt and errors are listed in errorLog.txt.

.PARAMETER Path
Path to destination where text in files should be changed. Script changes text recursively. Default value is '.'

.PARAMETER OldText
Text which should be replaced.

.PARAMETER NewText
New text.

.PARAMETER FileExtensions
List of file extensions which should be included in text replacing. 

.EXAMPLE
./Replace-TextInFiles.ps1 -NewText 'value1' -OldText 'value2'  -> in all files recursively in the same directory where script is (.) text "value1" will be replaced by "value2"
.EXAMPLE
./Replace-TextInFiles.ps1 -Path 'C:\MyFolder' -NewText 'value1' -OldText 'value2' -> in all files recursively in directory "C:\MyFolder" text "value1" will be replaced by "value2"
.EXAMPLE
./Replace-TextInFiles.ps1 -Path 'C:\MyFolder' -NewText 'value1' -OldText 'value2' -FileExtensions 'cs','aspx' -> in .cs and .aspx files recursively in directory "C:\MyFolder" text "value1" will be replaced by "value2"

#>

param(
    [ValidateScript({Test-Path $_})]
    [string]$Path = '.',
    [Parameter(Mandatory)]
    [string]$OldText,
    [Parameter(Mandatory)]
    [string]$NewText,
    [string[]]$FileExtensions = '*'
)

[System.Collections.ArrayList]$filesToReplace = @()
$logFilePath = "./log.txt"
$errorLogFilePath = "./errorLog.txt"

New-Item $logFilePath -type file -Force
New-Item $errorLogFilePath -type file -Force



foreach($fileExtension in $FileExtensions){
    $filesToReplace.Add("*.$fileExtension") | Out-Null
}

Write-Output "Replaceing '$OldText' by '$NewText' in location '$Path' ..."

$files = (Get-ChildItem $Path -Include $filesToReplace -Recurse | Select-String -Pattern $OldText | Group-Object Path).Name

[System.Collections.ArrayList]$succededFiles = @()

foreach($file in $files)
{   
    try {
        (Get-Content $file).replace($OldText,$NewText) | Set-Content $file
        $succededFiles.Add($file) | Out-Null
    } catch {
        "It wan't possible to change text in '$file'. Reason $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)" | Out-File $errorLogFilePath
    }
}

"In folowing files '$OldText' was replaced by '$NewText':" | Out-File $logFilePath -Append
$succededFiles | Out-File $logFilePath -Append

$logFullPath = Resolve-Path $logFilePath
$errorLogFullPath = Resolve-Path $errorLogFilePath

Write-Output "Replacing was finished.`n Log file can be found in '$logFullPath'.`n Errors are logged in '$errorLogFullPath'."