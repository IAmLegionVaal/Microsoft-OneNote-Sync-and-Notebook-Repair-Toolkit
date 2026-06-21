#requires -Version 5.1
<# Created by Dewald Pretorius. The workflow preserves OneNote cache data as a timestamped backup. #>
[CmdletBinding(SupportsShouldProcess=$true)]
param(
    [ValidateSet('Diagnose','ResetOneNoteCache','FlushDns')][string]$Action='Diagnose',
    [string]$OutputPath=(Join-Path ([Environment]::GetFolderPath('Desktop')) 'OneNote_Sync_Repair')
)
$ErrorActionPreference='Stop'
$CachePath="$env:LOCALAPPDATA\Microsoft\OneNote\16.0\cache"
New-Item -ItemType Directory -Path $OutputPath -Force|Out-Null
$Stamp=Get-Date -Format 'yyyyMMdd_HHmmss';$LogPath=Join-Path $OutputPath "Repair_$Stamp.log"
function Log([string]$Message){$Line='{0:u} {1}' -f (Get-Date),$Message;Write-Host $Line;Add-Content -LiteralPath $LogPath -Value $Line}
$State=[ordered]@{
    Action=$Action
    OneNoteRunning=[bool](Get-Process ONENOTE -ErrorAction SilentlyContinue)
    CacheExists=(Test-Path -LiteralPath $CachePath)
    OneDriveEndpoint=(Test-NetConnection 'onedrive.live.com' -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue)
    IdentityEndpoint=(Test-NetConnection 'login.microsoftonline.com' -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue)
    GraphEndpoint=(Test-NetConnection 'graph.microsoft.com' -Port 443 -InformationLevel Quiet -WarningAction SilentlyContinue)
}
$State|ConvertTo-Json -Depth 5|Set-Content -LiteralPath (Join-Path $OutputPath "PreRepair_$Stamp.json") -Encoding UTF8
if($Action -eq 'Diagnose'){Log '[COMPLETE] Read-only snapshot saved.';exit 0}
try{
    if($Action -eq 'ResetOneNoteCache' -and $PSCmdlet.ShouldProcess($CachePath,'Back up and reset OneNote cache')){
        if(Get-Process ONENOTE -ErrorAction SilentlyContinue){throw 'Close OneNote and confirm notebooks have finished syncing before resetting the cache.'}
        if(Test-Path -LiteralPath $CachePath){$Backup="$CachePath.backup-$Stamp";Move-Item -LiteralPath $CachePath -Destination $Backup -Force;New-Item -ItemType Directory -Path $CachePath -Force|Out-Null;Log "[BACKUP] $Backup"}
    }
    elseif($Action -eq 'FlushDns' -and $PSCmdlet.ShouldProcess('Windows DNS client cache','Clear')){Clear-DnsClientCache}
}catch{Log "[FAILED] $($_.Exception.Message)";exit 5}
if($Action -eq 'ResetOneNoteCache' -and -not(Test-Path -LiteralPath $CachePath)){Log '[VERIFY-FAILED] Cache recreation failed.';exit 6}
Log '[COMPLETE] Repair completed.'
exit 0
