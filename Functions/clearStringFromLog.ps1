# Function removes a string from a log file
function Clear-Log {
    param (
        [string]$logPath,
        [string]$string
    )

    if (Test-Path -Path $logPath) {
        try {
            Set-Content -Path $logPath -Value (Get-Content -Path $logPath | Select-String -Pattern $string -NotMatch)
        }
        catch {
            Write-Host "Failed to clear the $logPath of $string"
        }
    }
}

# Usage
# Clear-Log -logPath "C:\Path\To\Log\foo.log" -string "Secret to delete"

# Or from a txt file
# Clear-Log -logPath "C:\Path\To\Text\foo.txt" -string "Secret to delete"