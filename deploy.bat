@echo off
:: Deploy script to constantly check for updates from the GitHub repository and stay open indefinitely

:: Set the working directory for the FiveM server
cd /d "C:\path\to\your\fivem\server"  :: Change this path to where your FiveM server is located

:: GitHub Repository URL (change to your actual GitHub repo URL)
set REPO_URL=https://github.com/username/repository.git  :: Replace with your repo URL

:: Check if Git is installed
echo Checking for Git installation...
git --version >nul 2>nul
if %errorlevel% neq 0 (
    echo Git is not installed. Please install Git for Windows from https://git-scm.com/download/win
    pause
    exit /b 1
)

:: Infinite loop to keep checking for updates every minute (or any other interval)
:loop
echo Checking for updates from the GitHub repository...
git fetch origin

:: Check if there are changes in the public branch
git diff --exit-code origin/public
if %errorlevel% neq 0 (
    echo Changes detected, pulling latest updates...
    git checkout public
    git pull origin public
    if %errorlevel% neq 0 (
        echo Error occurred during 'git pull'. Please check your connection or repository status.
        pause
        exit /b 1
    )
    echo Files updated successfully! The FiveM server files are now up to date.
) else (
    echo No changes detected, waiting for 1 minute before checking again.
)

:: Wait for 1 minute (60 seconds) before checking again
timeout /t 60

:: Loop back to the start
goto loop
