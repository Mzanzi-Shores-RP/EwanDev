@echo off
:: ===================================================================
:: 🚨 IMPORTANT 🚨
:: Please follow the instructions to properly set up this script:
:: 1. Edit the GitHub Repository URL (where you want to upload the files).
:: 2. Edit the FiveM server folder path (where your current server files are stored).
:: ===================================================================

:: -----------------------------
:: STEP 1: Edit the GitHub Repository URL
:: -----------------------------
set "REPO_URL=https://github.com/Mzanzi-Shores-RP/Mzanzi-Shores-RP-MSRP.git"  :: Replace with YOUR GitHub repo URL

:: -----------------------------
:: STEP 2: Edit the FiveM Server Folder Path
:: -----------------------------
set "SERVER_PATH=F:\MSRP_test_server\txData\Mzanzi-Shores-RP-MSRP"  :: Replace with YOUR FiveM server folder path

:: -----------------------------
:: STEP 3: Check if Git is Installed
:: -----------------------------
echo Checking if Git is installed...
git --version >nul 2>nul
if %errorlevel% neq 0 (
    echo 🚨 Git is not installed. Installing Git using winget...
    winget install --id Git.Git -e --source winget  :: Use winget to install Git
    if %errorlevel% neq 0 (
        echo 🚨 Error installing Git. Please check your system or try manually installing Git from https://git-scm.com/.
        pause
        exit /b 1
    )
    echo ✅ Git installed successfully.
)

:: -----------------------------
:: STEP 4: Clone Repository if Not Cloned
:: -----------------------------
echo Checking if the repository is already cloned...
cd /d "%SERVER_PATH%"
if not exist ".git" (
    echo 🚨 Cloning GitHub repository to the server folder...
    git clone --branch public "%REPO_URL%" "%SERVER_PATH%"  :: Clone the specific branch
    if %errorlevel% neq 0 (
        echo 🚨 Error cloning the GitHub repository. Please check the repository URL or your internet connection.
        pause
        exit /b 1
    )
    echo ✅ Repository cloned successfully.
) else (
    echo ✅ Git repository already exists, skipping clone.
)

:: -----------------------------
:: STEP 5: Auto-Update the Server Files (Git Pull)
:: -----------------------------
:loop
echo Checking for updates in the repository...
cd /d "%SERVER_PATH%"

:: Fetch the latest updates silently
git fetch origin public >nul 2>nul

:: Force update the local branch to match the remote public branch
git reset --hard origin/public >nul 2>nul
if %errorlevel% neq 0 (
    echo 🚨 Error updating server files. Please check the repository or your internet connection.
    pause
    exit /b 1
)

echo ✅ Server files updated successfully. Waiting for 30 seconds...

:: Wait for 30 seconds
timeout /t 30 /nobreak >nul

:: Repeat the process
goto loop
