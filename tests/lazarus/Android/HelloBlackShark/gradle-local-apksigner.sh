export PATH=/Users/Admin/AppData/Local/Android/Sdk/platform-tools:$PATH
export PATH=/Users/Admin/AppData/Local/Android/Sdk/build-tools/32.0.0:$PATH
export GRADLE_HOME=/Lazarus/Stable/ccr/bshark-gradle/gradle-7.3.1
export PATH=$PATH:$GRADLE_HOME/bin
zipalign -v -p 4 /Projects/Pascal/BlackShark2/tests/lazarus/Android/BlackShark/build/outputs/apk/release/BlackShark-x86_64-release-unsigned.apk /Projects/Pascal/BlackShark2/tests/lazarus/Android/BlackShark/build/outputs/apk/release/BlackShark-x86_64-release-unsigned-aligned.apk
apksigner sign --ks /Projects/Pascal/BlackShark2/tests/lazarus/Android/BlackShark/blackshark-release.keystore --ks-pass pass:123456 --key-pass pass:123456 --out /Projects/Pascal/BlackShark2/tests/lazarus/Android/BlackShark/build/outputs/apk/release/BlackShark-release.apk /Projects/Pascal/BlackShark2/tests/lazarus/Android/BlackShark/build/outputs/apk/release/BlackShark-x86_64-release-unsigned-aligned.apk
