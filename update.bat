@echo off
type %USERPROFILE%\Desktop\mrtc_app\ascii.txt
echo version 10.3
echo DEVELOPED BY: MR.SUBODH KUMAR
echo Managed By: "Manu & Rajnish"
echo "================================================================================="
echo WELCOME TO SOFTWARE INSTALLATION OF MAA RUDRA TRANSPORT CARRIERS PVT. LTD.
echo "================================================================================="
pause

set "desktop=%USERPROFILE%\Desktop"
echo The desktop location is: %desktop%
cd %USERPROFILE%\Desktop\mrtc_app
xcopy "%USERPROFILE%\Desktop\mrtc_app\mrtc.xps*" "C:\Windows\" /e /i
xcopy "%USERPROFILE%\Desktop\mrtc_app\MRTC_New\*" "C:\MRTC_New" /e /i
xcopy "%USERPROFILE%\Desktop\mrtc_app\VFPRG\*" "F:\VFPRG\" /e /i
if %errorlevel% neq 0 (
  echo Error: File Copy Unsuccessful
	else Updated
  pause
  exit /b 1
)
