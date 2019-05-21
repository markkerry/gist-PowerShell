<#
.Synopsis
   Starts an manual Snow scan on the machine
.DESCRIPTION
   Requires Snow Inventory agent 5+. Stops and starts the service, starts the scan then sends the scan
.EXAMPLE
   .\Invoke-SnowScan.ps1
.NOTES
   Written by: Mark Kerry
   Date: 21/05/2019
   Version: 1.0
#>

# Functions
function Write-LogEntry {
    param(
        [parameter(Mandatory=$true, HelpMessage="Value added to the ManualSnowScan.log file.")]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [parameter(Mandatory=$false, HelpMessage="Name of the log file that the entry will written to.")]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "ManualSnowScan.log"
    )
    # Determine log file location
    $LogFilePath = Join-Path -Path $env:windir -ChildPath "Logs\$($FileName)"

    # Add value to log file
    try {
        Out-File -InputObject $Value -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to append log entry to ManualSnowScan.log file"
        exit 1
    }
}

function SnowService { 
    $ServiceName = 'SnowInventoryAgent5'
    $SnowService = Get-Service -Name $ServiceName

    if ($SnowService.status -ne 'Running') {
        try {
            Write-LogEntry -Value "$(Get-Date -format g): The Snow service is not running"
            Write-LogEntry -Value "$(Get-Date -format g): Setting it to Automatic"
            $SnowService | Set-Service -StartupType Automatic -ErrorAction Stop
            Start-Sleep 1
            Write-LogEntry -Value "$(Get-Date -format g): Starting the service"
            $SnowService | Start-Service -ErrorAction Stop
            Start-Sleep 1
        }
        catch {
            Write-LogEntry -Value "$(Get-Date -format g): Failed to start the service"
            exit
        }
    }
    else {
        try {
            $SnowService | Restart-Service -Verbose -ErrorAction Stop
        }
        catch {
            Write-LogEntry -Value "$(Get-Date -format g): Failed to start the service"
            exit
        }
    }
}


function Invoke-SnowScan {
    Write-LogEntry -Value "$(Get-Date -format g): Starting Invoke-SnowScan.ps1"
    
    if (!(Test-Path -Path 'C:\Program Files\Snow Software\Inventory\Agent\snowagent.exe')) {
        Write-LogEntry -Value "$(Get-Date -format g): Snow Inventory Agent 5 and above is not installed on this machine"
        Exit
    }
    
    Write-LogEntry -Value "$(Get-Date -format g): Restarting the Snow Inventory Agent"
    SnowService

    Write-LogEntry -Value "$(Get-Date -format g): Starting a Snow scan"
    Start-Process -FilePath 'C:\Program Files\Snow Software\Inventory\Agent\snowagent.exe' -ArgumentList scan -Wait -WindowStyle Hidden

    Write-LogEntry -Value "$(Get-Date -format g): Sending the INV file"
    Start-Process -FilePath 'C:\Program Files\Snow Software\Inventory\Agent\snowagent.exe' -ArgumentList send -Wait -WindowStyle Hidden

    Write-LogEntry -Value "$(Get-Date -format g): Finshed Invoke-SnowScan.ps1"
}
Invoke-SnowScan