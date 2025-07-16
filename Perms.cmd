:: Perms
takeown /f %windir%\System32\Oobe\useroobe.dll /A
icacls %windir%\System32\Oobe\useroobe.dll /inheritance:r
icacls "%systemdrive%\Users" /remove "Everyone"
icacls "C:\Users\Public" /reset /T
icacls "%USERPROFILE%\Desktop" /reset /T
icacls "%USERPROFILE%\" /setowner "%username%" /t /c /l
icacls "%USERPROFILE%\" /remove "System" /t /c /l
icacls "%USERPROFILE%\" /remove "Administrators" /t /c /l