[Setup]
AppName=Eustaria Launcher
AppPublisher=Eustaria
UninstallDisplayName=Eustaria
AppVersion=${project.version}
AppSupportURL=https://www.eustaria.com/
DefaultDirName={localappdata}\Eustaria

; ~30 mb for the repo the launcher downloads
ExtraDiskSpaceRequired=30000000
ArchitecturesAllowed=x86 x64
PrivilegesRequired=lowest

WizardSmallImageFile=${basedir}/app_small.bmp
WizardImageFile=${basedir}/left.bmp
SetupIconFile=${basedir}/app.ico
UninstallDisplayIcon={app}\Eustaria.exe

Compression=lzma2
SolidCompression=yes

OutputDir=${basedir}
OutputBaseFilename=EustariaSetup32

[Tasks]
Name: DesktopIcon; Description: "Create a &desktop icon";

[Files]
Source: "${basedir}\native-win32\Eustaria.exe"; DestDir: "{app}"
Source: "${basedir}\native-win32\Eustaria.jar"; DestDir: "{app}"
Source: "${basedir}\native\build32\Release\launcher_x86.dll"; DestDir: "{app}"
Source: "${basedir}\native-win32\config.json"; DestDir: "{app}"
Source: "${basedir}\native-win32\jre\*"; DestDir: "{app}\jre"; Flags: recursesubdirs

[Icons]
; start menu
Name: "{userprograms}\Eustaria\Eustaria"; Filename: "{app}\Eustaria.exe"
Name: "{userprograms}\Eustaria\Eustaria (configure)"; Filename: "{app}\Eustaria.exe"; Parameters: "--configure"
Name: "{userprograms}\Eustaria\Eustaria (safe mode)"; Filename: "{app}\Eustaria.exe"; Parameters: "--safe-mode"
Name: "{userdesktop}\Eustaria"; Filename: "{app}\Eustaria.exe"; Tasks: DesktopIcon

[Run]
Filename: "{app}\Eustaria.exe"; Parameters: "--postinstall"; Flags: nowait
Filename: "{app}\Eustaria.exe"; Description: "&Open Eustaria"; Flags: postinstall skipifsilent nowait

[InstallDelete]
; Delete the old jvm so it doesn't try to load old stuff with the new vm and crash
Type: filesandordirs; Name: "{app}\jre"
; previous shortcut
Type: files; Name: "{userprograms}\Eustaria.lnk"

[UninstallDelete]
Type: filesandordirs; Name: "{%USERPROFILE}\.eustaria\repository2"
; includes install_id, settings, etc
Type: filesandordirs; Name: "{app}"

[Code]
#include "upgrade.pas"