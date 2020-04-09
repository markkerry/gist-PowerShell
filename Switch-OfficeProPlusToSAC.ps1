$UpdateChannel = "http://officecdn.microsoft.com/pr/7ffbc6bf-bc32-4f92-8982-f9dd17fd3114" 
$CTRConfigurationPath = "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" 
$CDNBaseUrl = Get-ItemProperty -Path $CTRConfigurationPath -Name "CDNBaseUrl" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty "CDNBaseUrl" 
if ($CDNBaseUrl -ne $null) { 
    if ($CDNBaseUrl -notmatch $UpdateChannel) { 
        # Set new update channel 
        Set-ItemProperty -Path $CTRConfigurationPath -Name "CDNBaseUrl" -Value $UpdateChannel -Force 
 
        # Trigger hardware inventory 
        Invoke-WmiMethod -Namespace "root\ccm" -Class "SMS_Client" -Name "TriggerSchedule" -ArgumentList "{00000000-0000-0000-0000-000000000001}" 
    } 
}