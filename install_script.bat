@echo off
type ascii.txt
echo version 10.3
echo DEVELOPED BY: MR.SUBODH KUMAR
echo Managed By: "Manu & Rajnish"
echo "================================================================================="
echo WELCOME TO SOFTWARE INSTALLATION OF MAA RUDRA TRANSPORT CARRIERS PVT. LTD.
echo "================================================================================="
pause
if exist "F:\" (
  echo Drive F exists.
) else (
  	echo Drive F does not exist.
  mkdir "F:\"
  	echo Drive F created successfully.
  		 else %errorlevel% neq 0 (
  		echo Error: Neither F exists Nor Created
 
  exit /b 1
)

REM Check if Git is installed
git --version >nul 2>&1
if %errorlevel% NEQ 0 (
  echo Git not found. Installing...
  winget install git.git
) else (
  echo Git is already installed.
)
echo Git Installed.
if %errorlevel% neq 0 (
  echo Error: Unable To Install Git.
  pause
  exit /b 1
)

set "desktop=%USERPROFILE%\Desktop"
echo The desktop location is: %desktop%
cd %USERPROFILE%\Desktop
git clone https://github.com/devmrtc/mrtc_app.git
if %errorlevel% neq 0 (
  echo Error: Git Not Cloned.
  pause
  exit /b 1
)

:menu
cls
echo Main Menu
echo --------------
echo 1. Install
echo 2. Update
echo --------------
set /p choice=Enter your choice (1 or 2):

if "%choice%" == "1" (
  call %USERPROFILE%\Desktop\mrtc_app\install.bat
) else if "%choice%" == "2" (
  call %USERPROFILE%\Desktop\mrtc_app\install.bat
) else (
  echo Invalid choice, please try again.
  pause
  goto menu
)