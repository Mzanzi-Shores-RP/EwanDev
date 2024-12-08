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
set REPO_URL=https://github.com/username/repository.git  :: Replace with YOUR GitHub repo URL

:: -----------------------------
:: STEP 2: Edit the FiveM Server Folder Path
:: -----------------------------
set SERVER_PATH=C:\path\to\your\fivem\server  :: Replace with YOUR FiveM server folder path

:: -----------------------------
:: STEP 3: Choose Backup Location
:: -----------------------------
:: This will automatically pick the first available drive to create a backup folder
:: If you want to specify a different path for the backup, update BACKUP_PATH variable.
set BACKUP_PATH=%SERVER_PATH%\backup  :: Default backup folder (can be modified)

:: -----------------------------
:: STEP 4: Check for Available Drives and Create a Backup Folder
:: -----------------------------
echo Checking for available drives...

:: Loop through all drives and find the first available one
for /f "tokens=1" %%a in ('wmic logicaldisk where "drivetype=3" get deviceid ^| find ":"') do (
    set DRIVE=%%a
    if not exist "%DRIVE%\FiveMBackup" (
        echo Creating backup folder on drive %DRIVE%...
        mkdir "%DRIVE%\FiveMBackup"
        echo ✅ Backup folder created at %DRIVE%\FiveMBackup
        set BACKUP_PATH=%DRIVE%\FiveMBackup
        goto :found_drive
    )
)

:: If no drive found, exit
echo 🚨 Error: No available drive found to create backup. Please connect an external drive or choose a valid path.
pause
exit /b 1

:found_drive
:: -----------------------------
:: STEP 5: Pull the Current Files from GitHub and Store Them in the Backup Folder
:: -----------------------------
echo Pulling the current files from the GitHub repository into the backup folder...
cd /d "%SERVER_PATH%"  :: Navigate to your FiveM server folder
git clone "%REPO_URL%" "%BACKUP_PATH%"  :: Clone the repo into the backup folder

:: -----------------------------
:: STEP 6: Check if Git is installed
:: -----------------------------
echo Checking if Git is installed...
git --version >nul 2>nul
if %errorlevel% neq 0 (
    echo 🚨 Error: Git is not installed. Please install Git from https://git-scm.com/download/win
    pause
    exit /b 1
)

:: -----------------------------
:: STEP 7: Infinite Loop to Check for Updates Every Minute
:: -----------------------------
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
