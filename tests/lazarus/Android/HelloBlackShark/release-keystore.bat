set JAVA_HOME=C:\Program Files\Java\jdk-15.0.2
set PATH=%JAVA_HOME%\bin;%PATH%
set JAVA_TOOL_OPTIONS=-Duser.language=en
cd D:\Projects\Pascal\BlackShark2\tests\lazarus\Android\BlackShark
keytool -genkey -v -keystore blackshark-release.keystore -alias blackshark.keyalias -keyalg RSA -keysize 2048 -validity 10000 < D:\Projects\Pascal\BlackShark2\tests\lazarus\Android\BlackShark\keytool_input.txt
:Error
echo off
cls
echo.
echo Signature file created previously, remember that if you delete this file and it was uploaded to Google Play, you will not be able to upload another app without this signature.
echo.
pause
