@echo off
winget install git
set "desktop=%USERPROFILE%\Desktop"
echo The desktop location is: %desktop%
cd %USERPROFILE%\Desktop
git clone https://github.com/devmrtc/mrtc_app.git
pause
cd mrtc_app
md "C:\MRTC_New"
md "C:\Tmpvfpp"
md "F:\VFPRG"
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
