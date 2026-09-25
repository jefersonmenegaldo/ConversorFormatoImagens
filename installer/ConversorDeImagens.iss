; Script Inno Setup para Conversor de Imagens
; Requer: Inno Setup 6+ (https://jrsoftware.org/isinfo.php)
; Compile com: ISCC.exe installer\ConversorDeImagens.iss

#define MyAppName "Conversor de Imagens"
#define MyAppVersion "1.1.0.0"
#define MyAppPublisher "Jeferson Menegaldo"
#define MyAppExeName "ConversorDeImagens.exe"

[Setup]
AppId={{B6A6C1B0-6E2B-4C2B-9F0E-8B4C7B2C1A11}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputDir=..\Output
OutputBaseFilename=ConversorDeImagens-Setup-{#MyAppVersion}
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
LicenseFile=..\LICENSE
SetupIconFile=..\Project2_Icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}

[Languages]
Name: "brazilianportuguese"; MessagesFile: "compiler:Languages\BrazilianPortuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "Criar um atalho na área de trabalho"; GroupDescription: "Atalhos adicionais:"; Flags: unchecked

[Files]
Source: "..\Win64\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\redist\win64\*.dll"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{group}\Desinstalar {#MyAppName}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Executar {#MyAppName}"; Flags: nowait postinstall skipifsilent
