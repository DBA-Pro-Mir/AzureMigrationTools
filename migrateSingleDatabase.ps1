# PowerShell script to migrate a single database to an Azure SQL Database Elastic Pool
param(
    [Parameter(Mandatory=$true)]
    [string]$SourceServerName,
    [Parameter(Mandatory=$true)]
    [string]$SourceUsername,
    [Parameter(Mandatory=$true)]
    [string]$SourcePassword,
    [Parameter(Mandatory=$true)]
    [string]$DatabaseName,
    [Parameter(Mandatory=$true)]
    [string]$AzureServerName,
    [Parameter(Mandatory=$true)]
    [string]$AzureUser,
    [Parameter(Mandatory=$true)]
    [string]$AzurePassword,
    [Parameter(Mandatory=$true)]
    [string]$ElasticPoolName,
    [string]$BacpacDirectory = "C:\\BackupDB\\"
)

# Build paths and connection strings
$bacpacFile = Join-Path $BacpacDirectory "$DatabaseName.bacpac"
$sourceConn = "Server=$SourceServerName;Database=$DatabaseName;User ID=$SourceUsername;Password=$SourcePassword;TrustServerCertificate=True;Encrypt=True"

Write-Host "Exporting $DatabaseName from $SourceServerName"
sqlpackage /Action:Export /SourceConnectionString:"$sourceConn" /TargetFile:"$bacpacFile"

if (-not (Test-Path $bacpacFile)) {
    Write-Error "Failed to create BACPAC for $DatabaseName"
    exit 1
}

Write-Host "Importing $DatabaseName to Azure SQL"
sqlpackage /Action:Import /TargetServerName:$AzureServerName /TargetDatabaseName:$DatabaseName /TargetUser:$AzureUser /TargetPassword:$AzurePassword /SourceFile:"$bacpacFile"

Write-Host "Moving $DatabaseName to Elastic Pool $ElasticPoolName"
Invoke-Sqlcmd -ServerInstance $AzureServerName -Database master -Username $AzureUser -Password $AzurePassword -Query "ALTER DATABASE [$DatabaseName] MODIFY ( SERVICE_OBJECTIVE = ELASTIC_POOL ( name = [$ElasticPoolName] ) );"

Write-Host "Migration of $DatabaseName completed"
