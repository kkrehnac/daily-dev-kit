param (
    [string]$target
)

# Get directory of this script
$scriptDir = $PSScriptRoot
$configPath = Join-Path $scriptDir "goto-locations.json"

if (!(Test-Path $configPath)) {
    Write-Error "Config file not found: $configPath"
    return
}

$locations = Get-Content $configPath | ConvertFrom-Json

if ([string]::IsNullOrWhiteSpace($target)) {
    Write-Host "Usage: goto <shortcut>"
    Write-Host "Available shortcuts:"
    $locations.PSObject.Properties | Sort-Object Name | ForEach-Object {
        Write-Host "  $($_.Name)`t-> $($_.Value)"
    }
    return
}

$key = $target.ToLower()
if ($locations.PSObject.Properties.Name -contains $key) {
    Set-Location $locations.$key
} else {
    Write-Error "Unknown shortcut: $target"
}

