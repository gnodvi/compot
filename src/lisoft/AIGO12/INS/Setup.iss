; -- Example1.iss --
; Demonstrates copying 3 files and creating an icon.

; SEE THE DOCUMENTATION FOR DETAILS ON CREATING .ISS SCRIPT FILES!

[Languages]
;Name: "en"; MessagesFile: "compiler:Default.isl"
Name: "ru"; MessagesFile: "Russian.isl"

[Setup]
AppName=¿“¿–»√Œ
AppVerName=¿“¿–»√Œ 1.2
UsePreviousAppDir=no
DefaultDirName={pf}\ATARIGO\1.2
UsePreviousGroup=no
DefaultGroupName=ATARIGO\1.2
UninstallDisplayIcon={app}\atarigo.exe

;WindowVisible=yes
;AppCopyright=Copyright © 2004 Goga Software, Inc.
;LicenseFile=readme.txt
;InfoBeforeFile=Output\readme.txt

[Files]
Source: "..\dialog.exe";  DestDir: "{app}"; DestName: "atarigo.exe"
Source: "..\atarigo.ini"; DestDir: "{app}"; DestName: "atarigo.ini"
Source: "README.txt";  DestDir: "{app}" ;


[Icons]
Name: "{group}\¿“¿–»√Œ 1.2"; Filename: "{app}\atarigo.exe";  WorkingDir: "{app}"
Name: "{group}\‘‡ÈÎ README 1.2"; Filename: "{app}\readme.txt"
Name: "{group}\”‰‡ÎÂÌËÂ ¿“¿–»√Œ 1.2"; Filename: "{uninstallexe}"

Name: "{userdesktop}\¿“¿–»√Œ 1.2"; Filename: "{app}\atarigo.exe"; WorkingDir: "{app}"; IconFilename: "{app}\atarigo.exe"

;;===========================================================================

