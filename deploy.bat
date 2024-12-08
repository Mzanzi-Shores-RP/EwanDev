@echo off
:: ===================================================================
:: 🚨 IMPORTANT 🚨
:: This script needs 2 things to work:
:: 1. Your GitHub repository URL (where your files are stored)
:: 2. The folder where your FiveM server is located
:: Follow the instructions below to update these 2 things. 
:: ===================================================================

:: -----------------------------
:: STEP 1: Edit the GitHub Repository URL
:: -----------------------------
:: Look for this line:
::   set REPO_URL=https://github.com/username/repository.git
:: You need to replace the URL with your GitHub repository URL.
:: Example: set REPO_URL=https://github.com/yourusername/your-repo.git
:: -----------------------------
set REPO_URL=https://github.com/username/repository.git  :: Replace with YOUR GitHub repo URL

:: -----------------------------
:: STEP 2: Edit the FiveM Server Folder Path
:: -----------------------------
:: Look for this line:
::   set SERVER_PATH=C:\path\to\your\fivem\server
:: You need to replace this with the folder path to your FiveM server.
:: Example: set SERVER_PATH=C:\FiveM\server
:: -----------------------------
set SERVER_PATH=C:\path\to\your\fivem\server  :: Replace with YOUR FiveM server folder path

:: -----------------------------
:: STEP 3: Set the Folder to Store the Current Server Files
:: -----------------------------
:: Look for this line:
::   set BACKUP_PATH=%SERVER_PATH%\backup
:: This is where the current server files will be stored.
:: -----------------------------
set BACKUP_PATH="C:\Users\Ewanw\Documents\backups"  :: Replace with YOUR desired folder path for backups

:: Check if the "backup" folder exists; if not, create it
if not exist "%BACKUP_PATH%" (
    echo 🚨 The backup folder does not exist. Creating the folder...
    mkdir "%BACKUP_PATH%"
)

:: -----------------------------
:: STEP 4: Pull the Current Files from GitHub and Store Them in the Backup Folder
:: -----------------------------
echo Pulling the current files from the GitHub repository into the backup folder...
cd /d "%SERVER_PATH%"  :: Navigate to your FiveM server folder
git clone "%REPO_URL%" "%BACKUP_PATH%"  :: Clone the repo into the backup folder

:: -----------------------------
:: Check if Git is installed
echo Checking if Git is installed...
git --version >nul 2>nul
if %errorlevel% neq 0 (
    echo 🚨 Error: Git is not installed. Please install Git from https://git-scm.com/download/win
    pause
    exit /b 1
)

:: Infinite loop to keep checking for updates every minute (or any other interval)
:loop
echo Checking for updates from the GitHub repository...

:: Fetch updates from GitHub
git fetch origin

:: Check if there are changes in the public branch
git diff --exit-code origin/public
if %errorlevel% neq 0 (
    echo ✅ Changes found! Pulling the latest updates from the repository...
    git checkout public
    git pull origin public
    if %errorlevel% neq 0 (
        echo 🚨 Error while pulling updates. Please check the repository or your internet connection.
        pause
        exit /b 1
    )
    echo ✅ The FiveM server files are now up to date!
) else (
    echo 🔄 No changes found. Checking again in 1 minute...
)

:: Wait for 1 minute (60 seconds) before checking again
timeout /t 60

:: Loop back to check again
goto loop
