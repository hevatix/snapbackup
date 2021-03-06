@echo off
::::::::::::::::::::::::::::::::
:: Snap Backup                ::
:: Build on Microsoft Windows ::
::::::::::::::::::::::::::::::::

:: Script tested on:
::    Windows 10 Pro

:: JDK
:: ===
:: Install the Java SE Developer Kit:
::    http://www.oracle.com/technetwork/java/javase/downloads ("Windows x86")
::
:: Ant
:: ===
:: Download and unzip Ant into the "\Apps\Ant" folder:
::    Download --> http://ant.apache.org/bindownload.cgi (".zip archive")
::    Example install folder --> \Apps\Ant\apache-ant-1.10.1\bin
::
:: ImageMagick
:: ===========
:: Download and install ImageMagick with the default settings:
::    http://www.imagemagick.org/script/binary-releases.php ("Win64 dynamic at 16 bits-per-pixel component")
::
:: WiX Toolset
:: ===========
:: Download and install the WiX toolset with the default settings:
::   http://wixtoolset.org ("RECOMMENDED DOWNLOAD")

:: Set JAVA_HOME
for /d %%i in ("\Program Files\Java\jdk*") do set JAVA_HOME=%%i

:: Set ANT_HOME
for /d %%i in ("\Apps\Ant\apache-ant*") do set ANT_HOME=%%i

:: Add Wix to path
for /d %%i in ("\Program Files (x86)\Wix Toolset*") do set WIX_HOME=%%i\bin

:: Display variables and launch Ant
set JAVA_HOME
set ANT_HOME
set WIX_HOME
call "%JAVA_HOME%\bin\javac" -version
call "%ANT_HOME%\bin\ant" -version
call "%ANT_HOME%\bin\ant" build
set PATH=%PATH%;%WIX_HOME%
echo.

:: Create native installer (javapackager)
call "%JAVA_HOME%\bin\javapackager" -version
cd ..\build
copy ..\src\resources\graphics\application\snap-backup-icon.png .
magick convert snap-backup-icon.png SnapBackup.ico
mkdir package\windows
move SnapBackup.ico package\windows
call "%JAVA_HOME%\bin\javapackager" -deploy -native msi ^
   -srcfiles snapbackup.jar -appclass org.snapbackup.SnapBackup ^
   -name SnapBackup -vendor "Snap Backup" -outdir deploy -outfile SnapBackup -v

:: TODO: Replace with ->
::    attributesFile=src/java/org/snapbackup/settings/SystemAttributes.java
::    version=$(grep --max-count 1 appVersion $attributesFile | awk -F'"' '{ print $2 }')
:     ...
::    for /f "tokens=3" %%v in (findstr "appVersion =" ?attributesFile?) do version=%%v
set /p version=<version.txt

copy deploy\bundles\SnapBackup-1.0.msi snap-backup-installer-%version%.msi
copy deploy\bundles\SnapBackup-1.0.msi ..\releases\snap-backup-installer-%version%.msi
dir *.msi
echo.

pause
