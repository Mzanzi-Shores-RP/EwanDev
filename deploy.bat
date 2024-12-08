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
set REPO_URL=https://github.com/username/repository.git  :: Replace with YOUR GitHub repo URL

:: -----------------------------
:: STEP 2: Edit the FiveM Server Folder Path
:: -----------------------------
set SERVER_PATH=C:\path\to\your\fivem\server  :: Replace with YOUR FiveM server folder path

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
:: STEP 4: Create Backup Folder if First Run
:: -----------------------------
set BACKUP_PATH=%SERVER_PATH%\Backup
if not exist "%BACKUP_PATH%" (
    echo 🚨 First time running the script, creating backup folder...
    for /f "tokens=3" %%a in ('wmic logicaldisk get size^,caption ^| findstr /c:"\\"') do (
        set DRIVE=%%a
        goto :found_drive
    )
    :found_drive
    echo Creating backup folder on %DRIVE%\Backup
    mkdir "%DRIVE%\Backup"
    echo Backing up server files...
    xcopy "%SERVER_PATH%" "%DRIVE%\Backup" /E /H /C /I
    if %errorlevel% neq 0 (
        echo 🚨 Error creating backup. Please ensure you have write permissions on the drive.
        pause
        exit /b 1
    )
    echo ✅ Backup completed successfully.
)

:: -----------------------------
:: STEP 5: Set Up the GitHub Repository Locally (Clone the Repo)
:: -----------------------------
echo Checking if the repository is already cloned...
cd /d "%SERVER_PATH%"

:: Check if a .git folder exists (i.e., repo already initialized)
if exist ".git" (
    echo ✅ Git repository already exists, skipping clone.
) else (
    echo 🚨 Cloning GitHub repository...
    git clone "%REPO_URL%" "%SERVER_PATH%"  :: Clone the repo into the server path
    if %errorlevel% neq 0 (
        echo 🚨 Error cloning the GitHub repository. Please check the repository URL or your internet connection.
        pause
        exit /b 1
    )
)

:: -----------------------------
:: STEP 6: Upload the Current Server Files to GitHub
:: -----------------------------
echo Adding current server files to Git...
git add .  :: Stage all files for commit

:: Check if there are any changes
git diff --exit-code >nul
if %errorlevel% neq 0 (
    echo 🚨 Changes detected, committing changes to GitHub...
    git commit -m "Update FiveM server files"  :: Commit changes
    if %errorlevel% neq 0 (
        echo 🚨 Error committing the changes. Please ensure files are correctly staged.
        pause
        exit /b 1
    )
    echo ✅ Committed changes.

    echo Pushing changes to GitHub...
    git push origin public  :: Push to the public branch (you can change this if using a different branch)
    if %errorlevel% neq 0 (
        echo 🚨 Error pushing to GitHub. Please check your repository settings or network connection.
        pause
        exit /b 1
    )
    echo ✅ Changes pushed to GitHub!
) else (
    echo 🔄 No changes detected. No need to upload files.
)

:: -----------------------------
:: STEP 7: Auto-Update the Server Files (Git Pull)
:: -----------------------------
:loop
echo Checking for updates in the repository...
cd /d "%SERVER_PATH%"

:: Pull the latest changes from the public branch
git pull origin public  :: Pull updates from the public branch
if %errorlevel% neq 0 (
    echo 🚨 Error pulling from GitHub. Please check the repository or your internet connection.
    pause
    exit /b 1
)

echo ✅ Server files updated successfully. Sleeping for 5 minutes...

:: Wait for 5 minutes (300 seconds)
timeout /t 300

:: Repeat the process
goto loop
