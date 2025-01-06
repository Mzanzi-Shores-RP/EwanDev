@echo off
setlocal

:: Ask the user for the folder path
set /p "TARGET_FOLDER=Enter the full path where you want the folder to be created (e.g., C:\FiveMResources\LockedFolder): "

:: Ask the user for the Git repository URL
set /p "REPO_URL=Enter the GitHub repository URL: "

:: Validate inputs
if "%TARGET_FOLDER%"=="" (
    echo No folder path provided. Exiting...
    pause
    exit
)

if "%REPO_URL%"=="" (
    echo No repository URL provided. Exiting...
    pause
    exit
)

:: Check if the repository is accessible
echo Checking repository access...
git ls-remote "%REPO_URL%" >nul 2>&1

:: If access is denied, exit immediately
if %ERRORLEVEL% NEQ 0 (
    echo Repository access denied or removed! Exiting...
    pause
    exit
)

:: Create the target folder if it doesn't exist
if not exist "%TARGET_FOLDER%" (
    mkdir "%TARGET_FOLDER%"
)

:: Clone the repository
echo Cloning repository...
git clone "%REPO_URL%" "%TARGET_FOLDER%"

:: Apply permissions
echo Setting folder permissions...

:: Remove inherited permissions
icacls "%TARGET_FOLDER%" /inheritance:r

:: Grant read and write, but deny delete, move, and export permissions
icacls "%TARGET_FOLDER%" /grant Users:(R,W) /deny Users:(DE,DC,WDAC,WO) /T
icacls "%TARGET_FOLDER%" /grant Users:(RX) /T

echo Repository cloned and folder permissions applied!
pause
