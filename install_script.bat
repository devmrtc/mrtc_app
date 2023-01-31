@echo off
echo  .----------------.   .----------------.   .----------------.   .----------------.
| .--------------. | | .--------------. | | .--------------. | | .--------------. |
| | ____    ____ | | | |  _______     | | | |  _________   | | | |     ______   | |
| ||_   \  /   _|| | | | |_   __ \    | | | | |  _   _  |  | | | |   .' ___  |  | |
| |  |   \/   |  | | | |   | |__) |   | | | | |_/ | | \_|  | | | |  / .'   \_|  | |
| |  | |\  /| |  | | | |   |  __ /    | | | |     | |      | | | |  | |         | |
| | _| |_\/_| |_ | | | |  _| |  \ \_  | | | |    _| |_     | | | |  \ `.___.'\  | |
| ||_____||_____|| | | | |____| |___| | | | |   |_____|    | | | |   `._____.'  | |
| |              | | | |              | | | |              | | | |              | |
| '--------------' | | '--------------' | | '--------------' | | '--------------' |
 '----------------'   '----------------'   '----------------'   '----------------'
echo WELCOME TO SOFTWARE INSTALLATION OF MAA RUDRA TRANSPORT CARRIERS PVT. LTD.
pause
echo we are installing git now -------------------------------------------------------
winget install git
pause
timeout /t 20

set "desktop=%USERPROFILE%\Desktop"
echo The desktop location is: %desktop%
cd %USERPROFILE%\Desktop
md "C:\Tmpvfpp"
cd "C:\Tmpvfpp"
git clone https://github.com/devmrtc/mrtc_app.git
pause
md "C:\MRTC_New"
md "F:\VFPRG"
cd mrtc_app
xcopy "%USERPROFILE%\Desktop\mrtc_app\mrtc.xps*" "C:\Windows\" /e /i
xcopy "%USERPROFILE%\Desktop\mrtc_app\MRTC_New\*" "C:\MRTC_New" /e /i
xcopy "%USERPROFILE%\Desktop\mrtc_app\VFPRG\*" "F:\VFPRG\" /e /i
pause
set target=C:\Mrtc_new\F.BAT
set shortcut=%USERPROFILE%\Desktop\Desktop\mrtc.lnk

rem Create the shortcut
echo Set oWS = WScript.CreateObject("WScript.Shell") > %temp%\CreateShortcut.vbs
echo sLinkFile = "%shortcut%" >> %temp%\CreateShortcut.vbs
echo Set oLink = oWS.CreateShortcut(sLinkFile) >> %temp%\CreateShortcut.vbs
echo oLink.TargetPath = "%target%" >> %temp%\CreateShortcut.vbs
echo oLink.Save >> %temp%\CreateShortcut.vbs
cscript /nologo %temp%\CreateShortcut.vbs

rem Delete the temporary VBScript file
del %temp%\CreateShortcut.vbs
pause
