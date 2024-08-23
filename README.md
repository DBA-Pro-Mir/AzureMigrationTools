# AzureMigrationTools
Database Migration to Azure SQL Database Elastic Pool

# Overview
This repository contains a PowerShell script designed to automate the migration of multiple on-premises SQL Server databases to an Azure SQL Database Elastic Pool. The script handles the process from exporting each database to a BACPAC file, importing it into Azure SQL Database, and finally moving the database into a specified Elastic Pool.

# Features
🚀 Automated Database Migration: Streamline the migration of multiple databases with a single script, reducing manual tasks and ensuring consistency.
🔒 Customizable Connection Strings: Supports secure connections to SQL Server, including options to trust unverified SSL certificates.
⚠️ Error Handling: The script includes robust error handling, allowing it to skip databases that fail to export and continue with the rest.
🏗️ Elastic Pool Integration: Automatically moves each imported database into a specified Azure SQL Database Elastic Pool.
📜 Logging and Output: Provides detailed output for each step, making it easy to monitor and troubleshoot the migration process.

# Prerequisites

**PowerShell:** Ensure PowerShell is installed and available on your system.
**SQLPackage:** Install the sqlpackage utility to handle BACPAC exports and imports.
**SQL Server Management Studio (SSMS):** Optional but recommended for database assessments and post-migration validation.
**Azure SQL Database:**  Ensure you have an Azure SQL Server instance with an Elastic Pool configured for the target databases.


# Update the Script:

Open the script and update it with your specific server names, credentials, and the list of databases to be migrated.

# Run the Script:

 Execute the script in PowerShell to initiate the migration process.
# Monitor the Process:

Follow the output in PowerShell to ensure that each database is migrated successfully.

# Contributing
Contributions are welcome! If you have suggestions for improvements or additional features, feel free to fork the repository, make your changes, and submit a pull request.

# License
This project is licensed under the MIT License - see the LICENSE file for details.
