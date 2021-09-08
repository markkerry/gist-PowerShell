function Write-LogEntry {
    param(
        [parameter(Mandatory=$true, HelpMessage="Value added to the LastPassChromeExtention.log file.")]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [parameter(Mandatory=$false, HelpMessage="Name of the log file that the entry will written to.")]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "LastPassChromeExtention.log"
    )
    # Determine log file location
    $LogFilePath = Join-Path -Path $env:windir -ChildPath "Logs\$($FileName)"

    # Add value to log file
    try {
        Out-File -InputObject $Value -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to append log entry to LastPassChromeExtention.log file"
    }
}

$baselineLastPassExtention = "4.40.2"
$lastPassID = "hdokiejnpimakedhajhdlcegeplioahd"
$users = Get-ChildItem -Path C:\Users | Where-Object {$_ -notlike "*Public*"} | Select-Object Name -ExpandProperty Name

Write-LogEntry "$(Get-Date -format g): Starting Invoke-LastPassChromeExtention.ps1"
Write-LogEntry "$(Get-Date -format g): Checking $users"
foreach ($user in $users) {
    $extentionPath = "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default\Extensions\$lastPassID"
    if (Test-Path -Path $extentionPath) {
        $a = (Get-ChildItem "C:\Users\$user\AppData\Local\Google\Chrome\User Data\Default\Extensions\$lastPassID").Name
        $b = $a.Substring(0,$a.Length-4)
        
        if ($b -lt $baselineLastPassExtention) {
            Write-LogEntry "$(Get-Date -format g): LastPass Chrome extention for $user is $b which is older than baseline $baselineLastPassExtention"
            Write-LogEntry "$(Get-Date -format g): Removing $extentionPath"
            Remove-Item -Path $extentionPath -Recurse -Force -Verbose
        }
        else {
            Write-LogEntry "$(Get-Date -format g): LastPass Chrome extention for $user is $b which is compliant with baseline version $baselineLastPassExtention"
        }
    }
    else {
        Write-LogEntry "$(Get-Date -format g): LastPass Chrome extention not found for user $user"
    }
}

Write-LogEntry "$(Get-Date -format g): Finished Invoke-LastPassChromeExtention.ps1"