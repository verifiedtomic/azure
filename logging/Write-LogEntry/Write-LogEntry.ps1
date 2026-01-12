# LOGGING SETUP
$executionTimestamp  = Get-Date -Format 'yyyy_MM_ddTHH_mm_ss_fffZ' -AsUTC
# Create logging folder if it doesn't exist
if(!(Test-Path -Path "$($PSScriptRoot)\logs")) {
    try {
       $result = New-Item -ItemType Directory -Path "$($PSScriptRoot)\logs"

       if(!($result.Exists)){
           throw "Failed to create logs directory at $($PSScriptRoot)\logs. Error: $_"
        }
    }
    catch {
        throw "Failed to create logs directory at $($PSScriptRoot)\logs. Error: $_"
    }
}

# Initialize log file
$logFilePath = "$($PSScriptRoot)\logs\logfile-$($executionTimestamp).log"

try {
    $result = New-Item -ItemType File -Path $logFilePath -Force

    if(!($result.Exists)){
        throw "Failed to create log file at $logFilePath. Error: $_"
    }
}
catch {
    throw "Failed to create log file at $logFilePath. Error: $_"
}

function Write-LogEntry {
    param(
        [string]$Level,
        [string]$Message,
        [string]$LogFile
    )
    $timestamp = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fffZ' -AsUTC
    $entry = "$timestamp|$Level|$Message"
    $entry | Out-File -FilePath $LogFile -Append -Encoding UTF8
}