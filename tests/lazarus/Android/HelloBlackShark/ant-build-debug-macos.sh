export PATH=/Lazarus/Stable/ccr/bshark-ant/apache-ant-1.10.12/bin:$PATH
export JAVA_HOME=${/usr/libexec/java_home}
export PATH=${JAVA_HOME}/bin:$PATH
cd /Projects/Pascal/BlackShark2/tests/lazarus/Android/BlackShark
ant -Dtouchtest.enabled=true debug
