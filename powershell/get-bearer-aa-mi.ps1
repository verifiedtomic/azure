
param(
    [Parameter(Mandatory=$true)][bool]$requireMonitorToken,
    [Parameter(Mandatory=$true)][bool]$requireGraphApiToken,
    [Parameter(Mandatory=$true)][bool]$requirePowerBIApiToken,
    [Parameter(Mandatory=$true)][string]$automationAccountResourceId
)

# Automation Account
# Automation Account MI Authentication
# Connect to Azure with system-assigned managed identity
try {
    Write-Output "Connecting Automation Account MI to Azure..."
    $AzureContext = (Connect-AzAccount -Identity).context
    Write-Output "Setting Azure Context to $($automationAccountResourceId.Split("/")[2])"
    $AzureContext = Set-AzContext -SubscriptionId $($automationAccountResourceId.Split("/")[2])
}
catch {
    $Error
    throw "Failed to connect Automation Account MI to Azure!"
}

# Get Automation Account Identity AccountId
try {
    Write-Output "Getting Automation Account Resource information..."
    $aaResource = Get-AzResource -Id $automationAccountResourceId
    Write-Output "Getting Automation Account AccountId..."
    $aaInfo = Get-AzAutomationAccount -Name $($aaResource.Name) -ResourceGroupName $($aaResource.ResourceGroupName)
    [string]$aaAccountId = $aaInfo.Identity.PrincipalId
}
catch {
    <#Do this if a terminating exception happens#>
}

# Get Azure Access Token
try {
    Write-Output "Getting Azure Access Token..."
    $securedTokenResponse = Get-AzAccessToken -AsSecureString
}
catch {
    $Error
    throw "Failed to get Azure Access Token!"
}

# Convert from Secure String to Plain Text
Write-Output "Converting from Secure String to Plain Text..."
try {
    $unsecuredToken = $securedTokenResponse.Token | ConvertFrom-SecureString -AsPlainText
}
catch {
    throw "Failed to convert from Secure String to Plain Text!"
}

Write-Output "Automation Account AccountId: $($aaAccountId)"

Write-Output "=== MGMT TOKEN START ==="
Write-Output $unsecuredToken
Write-Output "=== MGMT TOKEN END ==="

Write-Output "To connect to Azure via AccountId and Access token run command:"
Write-Output "=== COMMAND START ==="
Write-Output "Connect-AzAccount -AccountId $($aaAccountId) -AccessToken $($unsecuredToken)"
Write-Output "=== COMMAND END ==="

if($requireGraphApiToken){
    # Get Graph API  Access Token
    try {
        Write-Output "Getting Graph API Azure Access Token..."
        $securedGraphAPITokenResponse = Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com" -AsSecureString
    }
    catch {
        $Error
        Write-Error "Failed to get Graph API Access Token!"
    }

    # Convert from Secure String to Plain Text
    Write-Output "Converting Graph API Token from Secure String to Plain Text..."
    try {
        $unsecuredGraphAPIToken = $securedGraphAPITokenResponse.Token | ConvertFrom-SecureString -AsPlainText
    }
    catch {
        throw "Failed to convert Graph API Token from Secure String to Plain Text!"
    }

    Write-Output "=== GRAPH API TOKEN START ==="
    Write-Output $unsecuredGraphAPIToken
    Write-Output "=== GRAPH API TOKEN END ==="
}

if($requireMonitorToken){
    # Get Monitor Azure Access Token
    try {
        Write-Output "Getting Monitor Azure Access Token..."
        $securedMonitorTokenResponse = Get-AzAccessToken -ResourceUrl "https://monitor.azure.com" -AsSecureString
    }
    catch {
        $Error
        Write-Error "Failed to get Monitor Azure Access Token!"
    }

    # Convert from Secure String to Plain Text
    Write-Output "Converting Monitor Token from Secure String to Plain Text..."
    try {
        $unsecuredMonitorToken = $securedMonitorTokenResponse.Token | ConvertFrom-SecureString -AsPlainText
    }
    catch {
        throw "Failed to convert Monitor Token from Secure String to Plain Text!"
    }

    Write-Output "=== MONITOR TOKEN START ==="
    Write-Output $unsecuredMonitorToken
    Write-Output "=== MONITOR TOKEN END ==="
}

if($requirePowerBIApiToken){
    # Get Power BI API  Access Token
    try {
        Write-Output "Getting Power BI API Azure Access Token..."
        $securedPowerBIAPITokenResponse = Get-AzAccessToken -ResourceUrl "https://analysis.windows.net/powerbi/api" -AsSecureString
    }
    catch {
        $Error
        Write-Error "Failed to get Power BI API Access Token!"
    }

    # Convert from Secure String to Plain Text
    Write-Output "Converting Power BI API Token from Secure String to Plain Text..."
    try {
        $unsecuredPowerBIToken = $securedPowerBIAPITokenResponse.Token | ConvertFrom-SecureString -AsPlainText
    }
    catch {
        throw "Failed to convert Power BI API Token from Secure String to Plain Text!"
    }

    Write-Output "=== POWER BI API TOKEN START ==="
    Write-Output $unsecuredPowerBIToken
    Write-Output "=== POWER BI API TOKEN END ==="
}