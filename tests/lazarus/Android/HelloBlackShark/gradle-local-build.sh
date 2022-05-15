export PATH=/Users/Admin/AppData/Local/Android/Sdk/platform-tools:$PATH
export GRADLE_HOME=/Lazarus/Stable/ccr/bshark-gradle/gradle-7.3.1/
export PATH=$PATH:$GRADLE_HOME/bin
source ~/.bashrc
gradle clean build --info
