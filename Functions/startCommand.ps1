# Helpful for capturing stdout, stderr and exit codes.
function Start-Command {
    param(
    [parameter (Mandatory=$true)]
    [string]$Command,
    [parameter (Mandatory=$false)]
    [string]$Arguments)

    $pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $pinfo.FileName = $Command
    $pinfo.RedirectStandardError = $true
    $pinfo.RedirectStandardOutput = $true
    $pinfo.CreateNoWindow = $true
    $pinfo.UseShellExecute = $false
    $pinfo.Arguments = $Arguments
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $pinfo
    $p.Start() | Out-Null
    $p.WaitForExit()
    [PSCustomObject]@{
        stdout = $p.StandardOutput.ReadToEnd()
        stderr = $p.StandardError.ReadToEnd()
        ExitCode = $p.ExitCode
    }
}

<# Usage
$a = Start-Command -Command "azcopy.exe" -Arguments "cp $fileName $uri"
$a.stdout
$a.stderr
$a.ExitCode
if ($a.$a.stdout.Contains("Number of Transfers Completed: 1")) {

}
#>