# Functions
function Write-LogEntry {
    param(
        [parameter(Mandatory=$true, HelpMessage="Value added to the RemoveFirefox.log file.")]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [parameter(Mandatory=$false, HelpMessage="Name of the log file that the entry will written to.")]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "RemoveFirefox.log"
    )
    # Determine log file location
    $LogFilePath = Join-Path -Path $env:windir -ChildPath "Logs\$($FileName)"

    # Add value to log file
    try {
        Out-File -InputObject $Value -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to append log entry to RemoveFirefox.log file"
        exit 1
    }
}

function Get-FirefoxX64 {
    Test-Path "C:\Program Files\Mozilla Firefox\uninstall\helper.exe"
}

function Get-FirefoxX86 {
    Test-Path "C:\Program Files (x86)\Mozilla Firefox\uninstall\helper.exe"
}

function Stop-Firefox {
    $procs = Get-Process -Name Firefox -ErrorAction SilentlyContinue
    if ($procs) {
        Write-LogEntry -Value "$(Get-Date -format g): Firefox is running"
        foreach ($proc in $procs) {
            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        }
    }
    else {
        Write-LogEntry -Value "$(Get-Date -format g): Firefox is not running"
    }
}

Write-LogEntry -Value "$(Get-Date -format g): Starting Remove-Firefox.ps1 on $env:COMPUTERNAME"
Write-LogEntry -Value "$(Get-Date -format g): Killing Firefox if it is running"
Stop-Firefox
Write-LogEntry -Value "$(Get-Date -format g): Checking if Firefox is installed"

if (Get-FirefoxX64) {
    Write-LogEntry -Value "$(Get-Date -format g): Firefox 64-bit is installed on $env:COMPUTERNAME"
    try { 
        $exitCode = (Start-Process -FilePath "C:\Program Files\Mozilla Firefox\uninstall\helper.exe" -ArgumentList "/s" -NoNewWindow -Wait -PassThru).ExitCode
        if (($exitCode -eq 0) -or ($exitCode -eq 3010)) {
            Write-LogEntry -Value "$(Get-Date -format g): Successfully uninstalled Firefox 64-bit"
        }
        else {
            Write-LogEntry -Value "$(Get-Date -format g): Failed with exit code $exitCode"
        }
    }
    catch [System.Exception] {
        Write-LogEntry -Value "$(Get-Date -format g): Unable to remove Firefox 64-bit"
        Write-LogEntry -Value "$(Get-Date -format g): Exit Remove-Firefox.ps1 on $env:COMPUTERNAME"
        exit 1
    }
}
elseif (Get-FirefoxX86) {
    Write-LogEntry -Value "$(Get-Date -format g): Firefox 32-bit is installed on $env:COMPUTERNAME"
    try { 
        $exitCode = (Start-Process -FilePath "C:\Program Files (x86)\Mozilla Firefox\uninstall\helper.exe" -ArgumentList "/s" -NoNewWindow -Wait -PassThru).ExitCode
        if (($exitCode -eq 0) -or ($exitCode -eq 3010)) {
            Write-LogEntry -Value "$(Get-Date -format g): Successfully uninstalled Firefox 32-bit"
        }
        else {
            Write-LogEntry -Value "$(Get-Date -format g): Failed with exit code $exitCode"
        }
    }
    catch [System.Exception] {
        Write-LogEntry -Value "$(Get-Date -format g): Unable to remove Firefox 32-bit"
        Write-LogEntry -Value "$(Get-Date -format g): Exit Remove-Firefox.ps1 on $env:COMPUTERNAME"
        exit 1
    }
}
else {
    Write-LogEntry -Value "$(Get-Date -format g): Firefox is not installed on $env:COMPUTERNAME"
}

Write-LogEntry -Value "$(Get-Date -format g): Finished Remove-Firefox.ps1 on $env:COMPUTERNAME"