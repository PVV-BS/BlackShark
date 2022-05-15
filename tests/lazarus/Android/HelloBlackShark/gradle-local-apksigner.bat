set Path=%PATH%;C:\Users\Admin\AppData\Local\Android\Sdk\platform-tools;C:\Users\Admin\AppData\Local\Android\Sdk\build-tools\32.0.0
set GRADLE_HOME=C:\Lazarus\Stable\ccr\bshark-gradle\gradle-7.3.1
set PATH=%PATH%;%GRADLE_HOME%\bin
zipalign -v -p 4 D:\Projects\Pascal\BlackShark2\tests\lazarus\Android\BlackShark\build\outputs\apk\release\BlackShark-armeabi-release-unsigned.apk D:\Projects\Pascal\BlackShark2\tests\lazarus\Android\BlackShark\build\outputs\apk\release\BlackShark-armeabi-release-unsigned-aligned.apk
apksigner sign --ks D:\Projects\Pascal\BlackShark2\tests\lazarus\Android\BlackShark\blackshark-release.keystore --ks-pass pass:123456 --key-pass pass:123456 --out D:\Projects\Pascal\BlackShark2\tests\lazarus\Android\BlackShark\build\outputs\apk\release\BlackShark-release.apk D:\Projects\Pascal\BlackShark2\tests\lazarus\Android\BlackShark\build\outputs\apk\release\BlackShark-armeabi-release-unsigned-aligned.apk
