set JAVA_HOME=C:\Program Files\Java\jdk-15.0.2
path %JAVA_HOME%\bin;%path%
cd D:\Projects\Pascal\BlackShark2\tests\lazarus\Android\BlackShark
jarsigner -verify -verbose -certs D:\Projects\Pascal\BlackShark2\tests\lazarus\Android\BlackShark\build\outputs\apk\release\BlackShark-release.apk
