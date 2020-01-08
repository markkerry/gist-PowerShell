function Write-LogEntry {
    param(
        [parameter(Mandatory=$true, HelpMessage="Value added to the RemoveIntelSupportAssistant.log file.")]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [parameter(Mandatory=$false, HelpMessage="Name of the log file that the entry will written to.")]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "RemoveIntelSupportAssistant.log"
    )
    # Determine log file location
    $LogFilePath = Join-Path -Path $env:windir -ChildPath "Logs\$($FileName)"

    # Add value to log file
    try {
        Out-File -InputObject $Value -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to append log entry to RemoveIntelSupportAssistant.log file"
        exit 1
    }
}

$productCodes = @(
    "{4d839fe1-a8d3-4edc-b0ca-844394309856}",
    "{4ef0c07c-1ede-4d1c-a593-83184455832b}",
    "{e7adbf16-34ad-490a-a4e8-feb60fb99973}",
    "{65f026f0-ca1d-4c8d-84bb-67ced39a5087}",
    "{3252578f-e595-4827-a6ed-0a278bbbdae8}",
    "{2550a40e-aac6-4d21-9361-744d33bec573}",
    "{f0bbb6e9-80c3-4fe8-8691-b51d1281d69e}",
    "{01f3f6b8-1a81-4b10-b51f-f69af12e1d69}"
)

foreach ($productCode in $productCodes) {
    if (Test-Path -Path "C:\ProgramData\Package Cache\$productCode\Intel Driver and Support Assistant Installer.exe") {
        Write-LogEntry -Value "$(Get-Date -format g): FOUND: $productCode\Intel Driver and Support Assistant Installer.exe. Uninstalling"
        Start-Process -FilePath "C:\ProgramData\Package Cache\$productCode\Intel Driver and Support Assistant Installer.exe" -ArgumentList "/uninstall /quiet" -NoNewWindow -Wait
    }
    else {
        Write-LogEntry -Value "$(Get-Date -format g): NOT FOUND $productCode\Intel Driver and Support Assistant Installer.exe"
        Write-Output "C:\ProgramData\Package Cache\$productCode\Intel Driver and Support Assistant Installer.exe not found on device $env:COMPUTERNAME"
    }
}