@echo off
type ascii.txt
echo version 10.3
echo DEVELOPED BY: MR.SUBODH KUMAR
echo Managed By: "Manu & Rajnish"
echo "================================================================================="
echo WELCOME TO SOFTWARE INSTALLATION OF MAA RUDRA TRANSPORT CARRIERS PVT. LTD.
echo "================================================================================="
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
  
)
md "C:\Tmpvfpp"
md "C:\MRTC_New"
md "F:\VFPRG"
set "desktop=%USERPROFILE%\Desktop"
echo The desktop location is: %desktop%
cd %USERPROFILE%\Desktop\mrtc_app
xcopy "%USERPROFILE%\Desktop\mrtc_app\mrtc.xps*" "C:\Windows\" /e /i
xcopy "%USERPROFILE%\Desktop\mrtc_app\MRTC_New\*" "C:\MRTC_New" /e /i
xcopy "%USERPROFILE%\Desktop\mrtc_app\VFPRG\*" "F:\VFPRG\" /e /i
if %errorlevel% neq 0 (
  echo Error: File Copy Unsuccessful
  pause
  exit /b 1
)
pause
set target=C:\Mrtc_new\F.BAT
set shortcut=%USERPROFILE%\Desktop\mrtc.lnk
set icon=%USERPROFILE%\Desktop\mrtc_app\mrtc.ico

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
if %errorlevel% neq 0 (
  echo Error: shortcut Not Created
	else echo Installation Done.
  pause
  exit /b 1
)
pause

