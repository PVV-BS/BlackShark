export JAVA_HOME=${/usr/libexec/java_home}
export PATH=${JAVA_HOME}/bin:$PATH
cd /Projects/Pascal/BlackShark2/tests/lazarus/Android/BlackShark
keytool -genkey -v -keystore blackshark-release.keystore -alias blackshark.keyalias -keyalg RSA -keysize 2048 -validity 10000 < /Projects/Pascal/BlackShark2/tests/lazarus/Android/BlackShark/keytool_input.txt
