<# DODATI AKO VEĆ NIJE ODRAĐENO PRIJE#>
# Automation Account
# Automation Account MI Authentication
# Connect to Azure with system-assigned managed identity
try {
    Write-Output "Connecting Automation Account MI to Azure..."
    $AzureContext = (Connect-AzAccount -Identity).context
    Set-AzContext -SubscriptionId $subscriptionId
}
catch {
    $Error
    Write-Error "Failed to connect Automation Account MI to Azure!"
    throw "FTL: Failed to connect Automation Account MI to Azure!"
}


# Get Monitor.Azure Access Token
try {
    Write-Output "Getting Monitor Azure Access Token..."
    $securedMonitorTokenResponse = Get-AzAccessToken -ResourceUrl "https://monitor.azure.com" -AsSecureString
}
catch {
    $Error
    Write-Error "Failed to get Monitor Azure Access Token!"
}

function Write-LawLogEntry {
    param(
        [string]$Level,
        [string]$Message
    )
    [string]$loggingDcrLogsEndpoint
    [string]$loggingDcrImmutableId
    [string]$loggingDcrStreamName
    [string]$loggingDcrIngestionUri = "$($loggingDcrLogsEndpoint)/dataCollectionRules/$($loggingDcrImmutableId)/streams/$($loggingDcrStreamName)?api-version=2023-01-01"
    $timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fffZ' -AsUTC
    $body = @{
        TimeGenerated = $timestamp
        Computer      = "Azure Sandbox"
        Level         = $Level
        Message       = $Message
    } | ConvertTo-Json -Depth 10 -AsArray

    try {
        $response = Invoke-RestMethod -Uri $loggingDcrIngestionUri -Method Post -Body $body -ContentType 'application/json' -Authentication Bearer -Token $securedMonitorTokenResponse.Token
    }
    catch {
        Write-Error "Failed to write log entry to Log Analytics Workspace: $_"
    }
}