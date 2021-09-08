<#
.SYNOPSIS 
    This removes all versions of Tableau Desktop
.DESCRIPTION 
    This script scans the registry to determine the versions installed, then retreives the msi uninstall
    command and the win32 uninstall command.
.EXAMPLE 
    .\Remove-TableauDesktopAllVersions.ps1
.NOTES
    Author: Mark Kerry
    Date:   06/02/2020
#>

function Write-LogEntry {
    param(
        [parameter(Mandatory=$true, HelpMessage="Value added to the RemoveTableau.log file.")]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [parameter(Mandatory=$false, HelpMessage="Name of the log file that the entry will written to.")]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "RemoveTableau.log"
    )
    # Determine log file location
    $LogFilePath = Join-Path -Path $env:windir -ChildPath "Logs\$($FileName)"

    # Add value to log file
    try {
        Out-File -InputObject $Value -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to append log entry to RemoveTableau.log file"
        exit 1
    }
}

# Scan the registry for Tableau installations
$x86RegPath = "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
$selectProperties = @(
    @{n='GUID'; e={$_.PSChildName}}, 
    @{n='Name'; e={$_.GetValue('DisplayName')}},
    @{n='QuietUninstallString'; e={$_.GetValue('QuietUninstallString')}}
)

# Add the specified versions to an array with the selected properties
[System.Collections.ArrayList] $installs
$installs += Get-ChildItem $x86RegPath | Select-Object -Property $selectProperties | Where-Object {$_.Name -like "Tableau 10*" -or $_.Name -like "Tableau 20*"}

# Loop thorugh and remove identified versions
if ($installs) {
    foreach ($install in $installs) {

        # Change the Win32 app Uninstall string
        $uninstallW32 = $($install.QuietUninstallString).Substring(0,$($install.QuietUninstallString).Length-18)

        # Remove the MSI
        Write-LogEntry -Value "$(Get-Date -format g): Removing the msi entry for $($install.Name)"
        Write-LogEntry -Value "$(Get-Date -format g): Command: C:\Windows\System32\msiexec.exe /x $($install.GUID) /qn /norestart"
        try {
            Start-Process -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/x $($install.GUID) /qn /norestart" -NoNewWindow -Wait
        }
        catch {
            Write-Warning $_.exception.message
        }
        
        # Remove the Win32 app
        Write-LogEntry -Value "$(Get-Date -format g): Removing the win32 entry for $($install.Name)"
        Write-LogEntry -Value "$(Get-Date -format g): Command: $($install.QuietUninstallString)"
        try {
            Start-Process -FilePath $uninstallW32 -ArgumentList "/uninstall /quiet" -NoNewWindow -Wait
        }
        catch {
            Write-Warning $_.exception.message
        }
    }
    Write-LogEntry -Value "$(Get-Date -format g): Completed uninstall of vulnerable Tableau versions found on $env:COMPUTERNAME" 
}
else {
    Write-LogEntry -Value "$(Get-Date -format g): No vulnerable installations of Tableau found on $env:COMPUTERNAME"
}