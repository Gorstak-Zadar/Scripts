:: Perms
takeown /f %windir%\System32\Oobe\useroobe.dll /A
icacls %windir%\System32\Oobe\useroobe.dll /inheritance:r
icacls "%systemdrive%\Users" /remove "Everyone"
icacls "C:\Users\Public" /reset /T
takeown /f "%USERPROFILE%\Desktop" /r /d y
icacls "%USERPROFILE%\Desktop" /inheritance:r
icacls "%USERPROFILE%\Desktop" /grant:r %username%:(OI)(CI)F /t /l /q /c
icacls "%USERPROFILE%\Desktop" /remove "System" /t /c /l
icacls "%USERPROFILE%\Desktop" /remove "Administrators" /t /c /l