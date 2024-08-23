<# Tools For Migration To Azure customized


Explanation of the Script:
Variables:

$SourceServerName: The name or IP address of your on-premises SQL Server.
$YourUsername and $YourPassword: Credentials for your on-premises SQL Server.
$AzureServerName: The name of your Azure SQL Server.
$ElasticPoolName: The name of the Elastic Pool where the databases will be moved.
$AzureUser and $AzurePassword: Credentials for your Azure SQL Server.
Databases List:

$Databases: An array containing the names of the databases you want to migrate.
Exporting Databases:

The script uses sqlpackage to export each database to a BACPAC file, stored in the specified directory.
Importing to Azure:

After exporting, the script imports each BACPAC file into Azure SQL Database.
Moving to Elastic Pool:

Once the database is imported, it's moved into the specified Elastic Pool using the ALTER DATABASE T-SQL command.
Error Handling:

The script includes basic error handling, skipping databases if the export fails and continuing to the next database.
How to Use the Script:
Update the Script:

Replace the placeholders with your actual server names, credentials, and database names.
Run the Script:

Run the script in PowerShell on a machine that has access to both your on-premises SQL Server and Azure SQL Server.
Monitor the Output:

The script will provide output for each step, showing the progress of the migration for each database.
This script provides a generalized way to migrate multiple databases from an on-premises SQL Server to an Azure SQL Database Elastic Pool, automating much of the process to save time and reduce manual effort.



 #>


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
