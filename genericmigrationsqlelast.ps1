# Define variables for the on-premises SQL Server
$SourceServerName = "YourOnPremServerName"          # On-premises SQL Server name or IP address
$YourUsername = "YourUsername"                      # SQL Server Username
$YourPassword = "YourPassword"                      # SQL Server Password

# Define variables for the Azure SQL Database
$AzureServerName = "YourAzureServerName.database.windows.net"  # Azure SQL Server name
$ElasticPoolName = "YourElasticPoolName"            # Name of the target Elastic Pool
$AzureUser = "YourAzureUser"                        # Azure SQL admin user
$AzurePassword = "YourAzurePassword"                # Azure SQL admin password

# Define the list of databases to migrate
$Databases = @("Database1", "Database2", "Database3") # Add your database names here

# Define the directory to store BACPAC files
$BacpacDirectory = "C:\BackupDB\"                   # Path to save the BACPAC files

# Loop over each database and migrate it
foreach ($DatabaseName in $Databases) {
    
    # Define the BACPAC file path for the current database
    $BacpacFilePath = "$BacpacDirectory$DatabaseName.bacpac"

    # Define the custom connection string with TrustServerCertificate=True
    $SourceConnectionString = "Server=$SourceServerName;Database=$DatabaseName;User ID=$YourUsername;Password=$YourPassword;TrustServerCertificate=True;Encrypt=True"

    # Export the database to a BACPAC file
    Write-Host "Starting export of $DatabaseName to $BacpacFilePath"
    sqlpackage /Action:Export `
        /SourceConnectionString:"$SourceConnectionString" `
        /TargetFile:$BacpacFilePath

    # Verify the BACPAC file exists
    if (-Not (Test-Path $BacpacFilePath)) {
        Write-Host "Error: BACPAC file for $DatabaseName was not created. Skipping to next database."
        continue
    }

    # Import the BACPAC file into Azure SQL Database
    Write-Host "Starting import of $DatabaseName to Azure SQL Database"
    sqlpackage /Action:Import `
        /TargetServerName:$AzureServerName `
        /TargetDatabaseName:$DatabaseName `
        /TargetUser:$AzureUser `
        /TargetPassword:$AzurePassword `
        /SourceFile:$BacpacFilePath

    # Move the database to the Elastic Pool
    Write-Host "Moving $DatabaseName to Elastic Pool $ElasticPoolName"
    try {
        Invoke-Sqlcmd -ServerInstance $AzureServerName -Database "master" -Username $AzureUser -Password $AzurePassword -Query `
        "ALTER DATABASE [$DatabaseName] MODIFY ( SERVICE_OBJECTIVE = ELASTIC_POOL ( name = [$ElasticPoolName] ) );"
    } catch {
        Write-Host "Error executing SQL command for $DatabaseName: $_"
        continue
    }

    Write-Host "Migration of $DatabaseName completed successfully."
}

Write-Host "All database migrations completed."
