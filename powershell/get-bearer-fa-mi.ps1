# Updated param to accept TriggerMetadata (Native Host)
param($GetFATokenTimer, $TriggerMetadata)

# Hard-code what you want – no flags, no body parsing.
$requireMonitorToken    = $false
$requireGraphApiToken   = $false
$requirePowerBIApiToken = $false

# Make sure MI context exists (Flex: do it explicitly)
try {
    Connect-AzAccount -Identity | Out-Null
}
catch {
    Write-Error "Failed to connect with managed identity. $_"
    throw
}

function Get-And-LogToken {
    param(
        [string]$Name,
        [string]$ResourceUrl
    )

    try {
        if ([string]::IsNullOrEmpty($ResourceUrl)) {
            $secured = Get-AzAccessToken -AsSecureString
        }
        else {
            $secured = Get-AzAccessToken -ResourceUrl $ResourceUrl -AsSecureString
        }
    }
    catch {
        Write-Error "Failed to get $Name token. $_"
        return
    }

    try {
        $plain = $secured.Token | ConvertFrom-SecureString -AsPlainText
    }
    catch {
        Write-Error "Failed to convert $Name token to plain text. $_"
        return
    }

    Write-Information "=== $Name TOKEN START ===" -InformationAction Continue
    Write-Information $plain -InformationAction Continue
    Write-Information "=== $Name TOKEN END ===" -InformationAction Continue
}

# Just get ARM/mgmt token and log it
Get-And-LogToken -Name 'MGMT' -ResourceUrl ''