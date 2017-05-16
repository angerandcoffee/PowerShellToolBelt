param(
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
        $succededFiles.Add($file)
    } catch {
        "It wan't possible to change text in '$file'. Reason $($_.Exception.Message) - Line Number: $($_.InvocationInfo.ScriptLineNumber)" | Out-File $errorLogFilePath
    }
}

"In folowing files '$OldText' was replaced by '$NewText':" | Out-File $logFilePath -Append
$succededFiles | Out-File $logFilePath -Append

$logFullPath = Resolve-Path $logFilePath
$errorLogFullPath = Resolve-Path $errorLogFilePath

Write-Output "Replaceing was finished.\n Log file can be found in '$logFullPath'.\n Errors are logged in '$errorLogFullPath'."