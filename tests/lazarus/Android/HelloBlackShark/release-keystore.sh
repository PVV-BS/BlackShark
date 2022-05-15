export JAVA_HOME=/Program Files/Java/jdk-15.0.2
cd /Projects/Pascal/BlackShark2/tests/lazarus/Android/BlackShark
LC_ALL=C keytool -genkey -v -keystore blackshark-release.keystore -alias blackshark.keyalias -keyalg RSA -keysize 2048 -validity 10000 < /Projects/Pascal/BlackShark2/tests/lazarus/Android/BlackShark/keytool_input.txt
