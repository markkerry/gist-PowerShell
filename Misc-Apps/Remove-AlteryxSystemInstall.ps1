<#
.SYNOPSIS 
    This removes all system installs of Alteryx Designer
.DESCRIPTION 
    This script scans the registry to determine the versions installed, then retreives the win32 uninstall command.
.EXAMPLE 
    .\Remove-AlteryxSystemInstall.ps1
.NOTES
    Author: Mark Kerry
    Date:   27/02/2020
#>

function Write-LogEntry {
    param(
        [parameter(Mandatory=$true, HelpMessage="Value added to the RemoveAlteryxSystemInstall.log file.")]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [parameter(Mandatory=$false, HelpMessage="Name of the log file that the entry will written to.")]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "RemoveAlteryxSystemInstall.log"
    )
    # Determine log file location
    $LogFilePath = Join-Path -Path $env:windir -ChildPath "Logs\$($FileName)"

    # Add value to log file
    try {
        Out-File -InputObject $Value -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to append log entry to RemoveAlteryxSystemInstall.log file"
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

# Scan the registry for all Alteryx installations
$x86RegPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
$selectProperties = @(
    @{n='GUID'; e={$_.PSChildName}},
    @{n='Name'; e={$_.GetValue('DisplayName')}}, 
    @{n='UninstallString'; e={$_.GetValue('UninstallString')}}
)

# Add the discovered versions to an array with the selected properties
$installs = Get-ChildItem $x86RegPath | Select-Object -Property $selectProperties | Where-Object {$_.Name -like "*Alteryx*"}

# Loop through and remove identified versions
if ($installs) {
    foreach ($install in $installs) {
        # Change the Win32 app Uninstall string
        $uninstallW32 = $($install.UninstallString).Substring(0,$($install.UninstallString).Length-25)
            
        # Close Alteryx  
        Stop-ProcessLogged -Process "AlteryxGui"

        # Remove the Win32 app
        Write-LogEntry -Value "$(Get-Date -format g): Removing the system win32 entry for $($install.GUID)"
        Write-LogEntry -Value "$(Get-Date -format g): Command: $($install.UninstallString) UNINSTALL=YES"
        try {
            Start-Process -FilePath $uninstallW32 -ArgumentList "/s REMOVE=TRUE MODIFY=FALSE UNINSTALL=YES" -NoNewWindow -Wait
        }
        catch {
            Write-Warning $_.exception.message
        }
    }
    Write-LogEntry -Value "$(Get-Date -format g): Completed uninstall of all system Alteryx versions found on $env:COMPUTERNAME" 
}
else {
    Write-LogEntry -Value "$(Get-Date -format g): No system installations of Alteryx found on $env:COMPUTERNAME"
}