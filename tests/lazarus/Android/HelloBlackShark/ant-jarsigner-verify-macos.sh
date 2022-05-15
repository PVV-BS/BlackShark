export JAVA_HOME=${/usr/libexec/java_home}
export PATH=${JAVA_HOME}/bin:$PATH
cd /Projects/Pascal/BlackShark2/tests/lazarus/Android/BlackShark
jarsigner -verify -verbose -certs /Projects/Pascal/BlackShark2/tests/lazarus/Android/BlackShark/bin/BlackShark-release.apk
