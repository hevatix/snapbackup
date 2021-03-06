#!/bin/sh
####################
## Snap Backup    ##
## Build on macOS ##
####################

# JDK
# ===
# Install the Java SE Devloper Kit for macOS x64:
#    http://www.oracle.com/technetwork/java/javase/downloads
#
# Ant
# ===
# Install Ant or download and unzip into the "~/apps/ant" folder:
#    Download --> http://ant.apache.org/bindownload.cgi (".zip archive")
#    Example install folder --> ~/apps/ant/apache-ant-1.9.7/bin

projectHome=$(cd $(dirname $0)/..; pwd)

setup() {
   cd $projectHome
   JAVA_HOME=$(/usr/libexec/java_home)
   echo $JAVA_HOME
   java -version
   javac -version
   addAnt() {
      antHome=~/apps/ant/$(ls ~/apps/ant | grep apache-ant | tail -1)
      PATH=$PATH:$antHome/bin
      echo "Path: $PATH"
      which ant || echo "*** Must install ant first. See: build.sh.command"
      echo
      }
   which ant || addAnt
   ant -version
   attributesFile=src/java/org/snapbackup/settings/SystemAttributes.java
   version=$(grep --max-count 1 appVersion $attributesFile | awk -F'"' '{ print $2 }')
   echo
   }

buildExecutableJar() {
   cd $projectHome/tools
   ant build
   echo
   }

buildMacInstaller() {
   cd $projectHome/build
   $JAVA_HOME/bin/javapackager -version
   cp ../src/resources/graphics/application/snap-backup-icon.png .
   mkdir SnapBackup.iconset
   sips -z   16   16 snap-backup-icon.png --out SnapBackup.iconset/icon_16x16.png
   sips -z   32   32 snap-backup-icon.png --out SnapBackup.iconset/icon_16x16@2x.png
   sips -z   32   32 snap-backup-icon.png --out SnapBackup.iconset/icon_32x32.png
   sips -z  128  128 snap-backup-icon.png --out SnapBackup.iconset/icon_32x32@2x.png
   sips -z  128  128 snap-backup-icon.png --out SnapBackup.iconset/icon_128x128.png
   sips -z  256  256 snap-backup-icon.png --out SnapBackup.iconset/icon_128x128@2x.png
   sips -z  256  256 snap-backup-icon.png --out SnapBackup.iconset/icon_256x256.png
   sips -z  512  512 snap-backup-icon.png --out SnapBackup.iconset/icon_256x256@2x.png
   sips -z  512  512 snap-backup-icon.png --out SnapBackup.iconset/icon_512x512.png
   sips -z 1024 1024 snap-backup-icon.png --out SnapBackup.iconset/icon_512x512@2x.png
   iconutil --convert icns SnapBackup.iconset
   mkdir -p package/macosx
   mv SnapBackup.icns package/macosx
   echo "javapackager:"
   $JAVA_HOME/bin/javapackager -deploy -native pkg -name SnapBackup \
      -BappVersion=$version -Bicon=package/macosx/SnapBackup.icns \
      -srcdir . -srcfiles snapbackup.jar -appclass org.snapbackup.SnapBackup \
      -outdir out -v
   cp out/SnapBackup-*.pkg snap-backup-installer-$version.pkg
   cp snapbackup.jar snapbackup-$version.jar
   cp -v snapbackup*.jar snap-backup-installer-*.pkg ../releases
   pwd
   ls -l *.pkg
   echo
   }

releaseInstructions() {
   cd $projectHome
   version=v$(grep '"version"' package.json | awk -F'"' '{print $4}')
   echo "Local changes:"
   git status --short
   echo
   echo "Releases:"
   git tag
   echo
   echo "To release this version:"
   echo "   cd $projectHome"
   echo "   git tag -af $version -m \"Stable release\""
   echo "   git tag -af current -m \"Current stable release\""
   echo "   git remote -v"
   echo "   git push origin --tags --force"
   echo
   }

echo
echo "Snap Backup Build"
echo "================="
setup
buildExecutableJar
buildMacInstaller
releaseInstructions
