<#
.SYNOPSIS 
    This removes user installs of Alteryx Designer for the curretnly logged on user
.DESCRIPTION 
    This script scans the registry to determine the versions installed, then retreives the win32 uninstall command.
.EXAMPLE 
    .\Remove-AlteryxUserInstall.ps1
.NOTES
    Author: Mark Kerry
    Date:   27/02/2020
#>

function Write-LogEntry {
    param(
        [parameter(Mandatory=$true, HelpMessage="Value added to the RemoveAlteryxUserInstall.log file.")]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [parameter(Mandatory=$false, HelpMessage="Name of the log file that the entry will written to.")]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "RemoveAlteryxUserInstall.log"
    )
    # Determine log file location
    $LogFilePath = Join-Path -Path $ENV:USERPROFILE -ChildPath "Documents\$($FileName)"

    # Add value to log file
    try {
        Out-File -InputObject $Value -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to append log entry to RemoveAlteryxUserInstall.log file"
        exit 1
    }
}

function Stop-ProcessLogged ($Process) {
    # Get the process if its running
    $procName = Get-Process -Name $process -ErrorAction SilentlyContinue
    if ($procName) {
        Write-LogEntry -Value "$(Get-Date -format g): $($procName.ProcessName) is running. Attempting to close"
        # Stop the process
        try {
            Stop-Process -InputObject $procName -Force -ErrorAction Stop
        }
        catch [System.Exception] {
            Write-LogEntry -Value "$(Get-Date -format g): Unable to stop $procName.ProcessName"
            Write-LogEntry -Value "$(Get-Date -format g): Will continue with removal of Tableau Desktop"
        }
        
        # Check the process has stopped
        $exit = Get-Process | Where-Object {$_.HasExited}
        if ($exit.ProcessName -eq $procName.ProcessName) {
            Write-LogEntry -Value "$(Get-Date -format g): $($procName.ProcessName) closed Successfully"
        }
    }
    else {
        Write-LogEntry -Value "$(Get-Date -format g): $process is not running"
    }
}

$regPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall"
$selectProperties = @(
    @{n='GUID'; e={$_.PSChildName}},
    @{n='Name'; e={$_.GetValue('DisplayName')}}, 
    @{n='UninstallString'; e={$_.GetValue('UninstallString')}}
)

$user = $ENV:USERNAME
$userInstall = "$ENV:LOCALAPPDATA\Alteryx\bin\AlteryxGui.exe"
if (Test-Path $userInstall) {
    Write-LogEntry -Value "$(Get-Date -format g): Found a win32 entry for $user"
    Write-LogEntry -Value "$(Get-Date -format g): Attempting to gather the uninstall code from HKCU"
    try {
        $usrInstallPaths = Get-ChildItem $regPath -ErrorAction Stop | Select-Object -Property $selectProperties | Where-Object {$_.Name -like "*Alteryx*"}
    }
    catch {
        Write-LogEntry -Value "$(Get-Date -format g): Failed to gather Alteryx info for $user in HKCU"
        break
    }

    # Close Alteryx  
    Stop-ProcessLogged -Process "AlteryxGui"

    foreach ($usrInstallPath in $usrInstallPaths) {
        $uninstallUser = $($usrInstallPath.UninstallString).Substring(0,$($usrInstallPath.UninstallString).Length-25)
        Write-LogEntry -Value "$(Get-Date -format g): Removing the user win32 entry for $($usrInstallPath.GUID) for $user"
        Write-LogEntry -Value "$(Get-Date -format g): Command: $uninstallUser /s REMOVE=TRUE MODIFY=FALSE UNINSTALL=YES"
        try {
            Start-Process -FilePath $uninstallUser -ArgumentList "/s REMOVE=TRUE MODIFY=FALSE UNINSTALL=YES" -NoNewWindow -Wait
        }
        catch {
            Write-Warning $_.exception.message
        }
    }
}
else {
    Write-LogEntry -Value "$(Get-Date -format g): No user installation of Alteryx not found for $user"
}

Write-LogEntry -Value "$(Get-Date -format g): Script complete"