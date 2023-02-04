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
  
)

pause

set "file1=C:\Windows\mrtc.xps\"
if exist "%file1%" (
  rd /s /q "%file1%"
  echo File "%file1%" deleted successfully.
) else (
  echo File "%file1%" not found.
)
set "fil2e=C:\MRTC_New\"
if exist "%fil2e%" (
  rd /s /q "%fil2e%"
  echo File "%fil2e%" deleted successfully.
) else (
  echo File "%file2%" not found.
)

set "file3=C:\Tmpvfpp\"
if exist "%file3%" (
  rd /s /q "%file3%"
  echo File "%file3%" deleted successfully.
) else (
  echo File "%file3%" not found.
)

set "file4=F:\VFPRG\"
if exist "%file4%" (
  rd /s /q "%file4%"
  echo File "%file4%" deleted successfully.
) else (
  echo File "%file4%" not found.
  
pause

)
REM Check if Git is installed
git --version >nul 2>&1
if %errorlevel% NEQ 0 (
  echo Git not found. Installing...
  winget install git
) else (
  echo Git is already installed.
)
echo Git Installed.
if %errorlevel% neq 0 (
  echo Error: Unable To Install Git.
  pause
  exit /b 1
)
timeout /t 05
set "desktop=%USERPROFILE%\Desktop"
echo The desktop location is: %desktop%
cd %USERPROFILE%\Desktop
md "C:\Tmpvfpp"
cd "C:\Tmpvfpp"
git clone https://github.com/devmrtc/mrtc_app.git
if %errorlevel% neq 0 (
  echo Error: Git Not Cloned.
  pause
  exit /b 1
)
pause
md "C:\MRTC_New"
md "F:\VFPRG"
cd mrtc_app
xcopy "C:\Tmpvfpp\mrtc_app\mrtc.xps*" "C:\Windows\" /e /i
xcopy "C:\Tmpvfpp\mrtc_app\MRTC_New\*" "C:\MRTC_New" /e /i
xcopy "C:\Tmpvfpp\mrtc_app\VFPRG\*" "F:\VFPRG\" /e /i
if %errorlevel% neq 0 (
  echo Error: File Copy Unsuccessful
  pause
  exit /b 1
)
pause
set target=C:\Mrtc_new\F.BAT
set shortcut=%USERPROFILE%\Desktop\mrtc.lnk
set icon=C:\Tmpvfpp\mrtc_app\mrtc.ico

rem Create the shortcut
echo Set oWS = WScript.CreateObject("WScript.Shell") > %temp%\CreateShortcut.vbs
echo sLinkFile = "%shortcut%" >> %temp%\CreateShortcut.vbs
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %temp%\CreateShortcut.vbs
echo oLink.TargetPath = "%target%" >> %temp%\CreateShortcut.vbs
echo oLink.IconLocation = "%icon%" >> "%temp%\CreateShortcut.vbs"
echo oLink.Save >> %temp%\CreateShortcut.vbs
cscript /nologo %temp%\CreateShortcut.vbs

rem Delete the temporary VBScript file
del %temp%\CreateShortcut.vbs
pause
if %errorlevel% neq 0 (
  echo Error: shortcut Not Created
  pause
  exit /b 1
)
echo "installation successful"
