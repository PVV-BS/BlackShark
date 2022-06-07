set Path=%PATH%;C:\Lazarus\Stable\ccr\bshark-ant\apache-ant-1.10.12\bin
set JAVA_HOME=C:\Program Files\Java\jdk-15.0.2
cd D:\Projects\Pascal\BlackShark2\tests\lazarus\Android\BlackShark
call ant clean release
if errorlevel 1 pause
