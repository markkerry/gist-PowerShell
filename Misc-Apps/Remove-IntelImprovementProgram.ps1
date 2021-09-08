function Write-LogEntry {
    param(
        [parameter(Mandatory=$true, HelpMessage="Value added to the RemoveIntelImprovementProgram.log file.")]
        [ValidateNotNullOrEmpty()]
        [string]$Value,

        [parameter(Mandatory=$false, HelpMessage="Name of the log file that the entry will written to.")]
        [ValidateNotNullOrEmpty()]
        [string]$FileName = "RemoveIntelImprovementProgram.log"
    )
    # Determine log file location
    $LogFilePath = Join-Path -Path $env:windir -ChildPath "Logs\$($FileName)"

    # Add value to log file
    try {
        Out-File -InputObject $Value -Append -NoClobber -Encoding Default -FilePath $LogFilePath -ErrorAction Stop
    }
    catch [System.Exception] {
        Write-Warning -Message "Unable to append log entry to RemoveIntelImprovementProgram.log file"
        exit 1
    }
}

$productCodes = @(
    "{699E6891-25C3-443A-9B8E-80C74F0172C8}",
    "{F0385150-FF86-4A18-AA55-6ED9E5F87DA7}",
    "{F6B5BD59-21F0-47F8-A6C6-63BAEB1A6569}",
    "{58FBAE3A-E602-47E6-9F32-AE25D48B378A}",
    "{A9133872-C9FE-45CC-8F01-D1947B0F09EA}",
    "{D40D4164-EEDB-4F0F-85C6-2058A9E34CC7}"
)

foreach ($productCode in $productCodes) {
    if (Test-Path -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$productCode") {
        Write-LogEntry -Value "$(Get-Date -format g): FOUND: Intel(R) Computing Improvement Program with product code: $productCode. Uninstalling"
        Start-Process -FilePath "C:\Windows\System32\msiexec.exe" -ArgumentList "/x $productCode /qn /norestart /l*v C:\Windows\Logs\RemoveIntelImprovementProgramVerbose.log" -NoNewWindow -Wait
    }
    else {
        Write-LogEntry -Value "$(Get-Date -format g): NOT FOUND: $productCode"
    }
}