; *** Inno Setup version 4.0.5+ English messages ***
;
; To download user-contributed translations of this file, go to:
;   http://www.jrsoftware.org/is3rdparty.php
;
; Note: When translating this text, do not add periods (.) to the end of
; messages that didn't have them already, because on those messages Inno
; Setup adds the periods automatically (appending a period would result in
; two periods being displayed).
;
; $jrsoftware: issrc/Files/Default.isl,v 1.32 2003/06/18 19:24:07 jr Exp $

[LangOptions]
LanguageName=Russian
LanguageID=$0409
; If the language you are translating to requires special font faces or
; sizes, uncomment any of the following entries and change them accordingly.
;DialogFontName=MS Shell Dlg
;DialogFontSize=8
;DialogFontStandardHeight=13
;TitleFontName=Arial
;TitleFontSize=29
;WelcomeFontName=Verdana
;WelcomeFontSize=12
;CopyrightFontName=Arial
;CopyrightFontSize=8

[Messages]

; *** Application titles
SetupAppTitle=���������
SetupWindowTitle=��������� - %1
UninstallAppTitle=��������
UninstallAppFullTitle=�������� - %1

; *** Misc. common
InformationTitle=����������
ConfirmTitle=�������������
ErrorTitle=������

; *** SetupLdr messages
SetupLdrStartupMessage=��� ��������� ��������� %1 �� ��� ���������.%n���������� ���������?
LdrCannotCreateTemp=�� ���� ������� ��������� ����. ��������� ��������
LdrCannotExecTemp=�� ���� ��������� ���� �� ��������� �����. ��������� ��������

; *** Startup error messages
LastErrorMessage=%1.%n%n������ %2: %3
SetupFileMissing=���� %1 ����������� � �������� ���������. ��������� �������� ��� �������������� ������ ������ ���������.
SetupFileCorrupt=����� ��������� ����������. ����������� ������ ����� ���������.
SetupFileCorruptOrWrongVer=����� ��������� ���������� ��� ������������ � ���� ������� ��������� ���������. ��������� �������� ��� �������������� ������ ������ ���������.
NotOnThisPlatform=��� ��������� �� �������� � %1.
OnlyOnThisPlatform=��� ��������� �������� ������ � %1.
WinVersionTooLowError=��� ��������� ������� %1 ������ �� ���� %2.
WinVersionTooHighError=��� ��������� �� ����� ���� ����������� � %1 ������ %2 � ������.
AdminPrivilegesRequired=����� ���������� ��� ���������, �� ������ ����� � ������� ��� �������������.
PowerUserPrivilegesRequired=����� ���������� ��� ���������, �� ������ ����� � ������� ��� ������������� ��� ��� ������� ������������.
SetupAppRunningError=� ������� ���������� ���������� ����� %1.%n%n�������� ��� ��������� � ������� 'OK', ����� ����������, ��� '������', ����� �����.
UninstallAppRunningError=� ������� ���������� ���������� ����� %1.%n%n�������� ��� ��������� � ������� 'OK', ����� ����������, ��� '������', ����� �����.

; *** Misc. errors
ErrorCreatingDir=�� ������� ������� ����� "%1"
ErrorTooManyFilesInDir=�� ���� ������� ���� � �������� "%1", ��� ��� �� �������� ������� ����� ������

; *** Setup common messages
ExitSetupTitle=�������� ���������
ExitSetupMessage=��������� �� ���������. ���� ����� ������, ��������� �� ����� �����������.%n%n�� ������ ��������� ��������� �����.%n%n�����?
AboutSetupMenuItem=&� ���������...
AboutSetupTitle=� ���������
AboutSetupMessage=%1 ������ %2%n%3%n%n%1 Web-��������:%n%4
AboutSetupNote=

; *** Buttons
ButtonBack=< &�����
ButtonNext=&����� >
ButtonInstall=&���������
ButtonOK=��
ButtonCancel=������
ButtonYes=�&�
ButtonYesToAll=�� ��� &����
ButtonNo=�&��
ButtonNoToAll=�&�� ��� ����
ButtonFinish=&������
ButtonBrowse=&�����...

; *** "Select Language" dialog messages
SelectLanguageTitle=Select Setup Language
SelectLanguageLabel=Select the language to use during the installation:

; *** Common wizard text 
ClickNext=������� ������ "�����" ��� ����������� ��� "������" ��� ������ �� ���������.
BeveledLabel=

; *** "Welcome" wizard page
WelcomeLabel1=����� ����������! ��� ������������ ��������� ��������� [name].
WelcomeLabel2=��� ��������� ������ [name/ver] �� ��� ���������.%n%n������ ��� ���������� ���������, ������������� ������� ��� ������ ����������, ����� �������� ��������� ����������.

; *** "Password" wizard page
WizardPassword=Password
PasswordLabel1=This installation is password protected.
PasswordLabel3=Please provide the password, then click Next to continue. Passwords are case-sensitive.
PasswordEditLabel=&Password:
IncorrectPassword=The password you entered is not correct. Please try again.

; *** "License Agreement" wizard page
WizardLicense=������������ ����������
LicenseLabel=Please read the following important information before continuing.
LicenseLabel3=���������� ��� ������������ ����������. You must accept the terms of this agreement before continuing with the installation.
LicenseAccepted=I &accept the agreement
LicenseNotAccepted=I &do not accept the agreement

; *** "Information" wizard pages
WizardInfoBefore=����������
InfoBeforeLabel=���������� ��� ����������, ������ ��� ���������� ���������.
InfoBeforeClickLabel=����� ������ ������ ���������� ���������, ������� ������ "�����".
WizardInfoAfter=����������
InfoAfterLabel=���������� ��� ����������, ������ ��� ����������.
InfoAfterClickLabel=����� ������ ������ ���������� ���������, ������� ������ "�����".

; *** "User Information" wizard page
WizardUserInfo=User Information
UserInfoDesc=Please enter your information.
UserInfoName=&User Name:
UserInfoOrg=&Organization:
UserInfoSerial=&Serial Number:
UserInfoNameRequired=You must enter a name.

; *** �������� "����� ��������"
WizardSelectDir=�������� ������� ��� ���������
SelectDirDesc=���� ������� ���������� [name]?
SelectDirLabel=�������� �������, ���� �� �� ������ ���������� [name], � ����� ������� "�����".
DiskSpaceMBLabel=��������� ��������� [mb] ����� ���������� ����� �� �����.
ToUNCPathname=Setup cannot install to a UNC pathname. If you are trying to install to a network, you will need to map a network drive.
InvalidPath=You must enter a full path with drive letter; for example:%n%nC:\APP%n%nor a UNC path in the form:%n%n\\server\share
InvalidDrive=The drive or UNC share you selected does not exist or is not accessible. Please select another.
DiskSpaceWarningTitle=������������ ����� �� �����
DiskSpaceWarning=��� ��������� ��������� �� ����� %1 ����� ���������� ������������, � �� ��������� ��������� ������� ������ %2 �����.%n%n�� ����������� �� �����������?
BadDirName32=��� �������� �� ����� �������� � ���� ����� �� ��������� ��������:%n%n%1
DirExistsTitle=������� ��� ����������
DirExists=��������� �������:%n%n%1%n%n��� ����������. ������ ���������� ��������� � ���� �������?
DirDoesntExistTitle=�������� �� ����������
DirDoesntExist=�������:%n%n%1%n%n�� ����������. ������ ��� �������?

; *** "Select Components" wizard page
WizardSelectComponents=Select Components
SelectComponentsDesc=Which components should be installed?
SelectComponentsLabel2=Select the components you want to install; clear the components you do not want to install. Click Next when you are ready to continue.
FullInstallation=Full installation
; if possible don't translate 'Compact' as 'Minimal' (I mean 'Minimal' in your language)
CompactInstallation=Compact installation
CustomInstallation=Custom installation
NoUninstallWarningTitle=Components Exist
NoUninstallWarning=Setup has detected that the following components are already installed on your computer:%n%n%1%n%nDeselecting these components will not uninstall them.%n%nWould you like to continue anyway?
ComponentSize1=%1 KB
ComponentSize2=%1 MB
ComponentsDiskSpaceMBLabel=Current selection requires at least [mb] MB of disk space.

; *** "Select Additional Tasks" wizard page
WizardSelectTasks=Select Additional Tasks
SelectTasksDesc=Which additional tasks should be performed?
SelectTasksLabel2=Select the additional tasks you would like Setup to perform while installing [name], then click Next.

; *** "Select Start Menu Folder" wizard page ===================================
WizardSelectProgramGroup=�������� ����� � ���� "����"  
;Select Start Menu Folder
SelectStartMenuFolderDesc=���� ������� ��������� ������ ����������? 
;Where should Setup place the program's shortcuts?
SelectStartMenuFolderLabel=�������� ����� � ���� "����", ��� �� �� ������ ������� ������ ����������, � ����� ������� "�����". 
;Select the Start Menu folder in which you would like Setup to create the program's shortcuts, then click Next.
NoIconsCheck=&Don't create any icons
MustEnterGroupName=������� ��� ������.
BadGroupName=��� ������ �� ����� �������� � ���� ����� �� ��������� ��������:%n%n%1
NoProgramGroupCheck2=&Don't create a Start Menu folder

; *** "Ready to Install" wizard page ===========================================
WizardReady=��� ������ � ���������
ReadyLabel1=��������� ������ � ��������� [name] �� ��� ���������.
ReadyLabel2a=������� ������ "���������" ��� ������ ���������, ��� "�����", ����� ��������� ��� �������� ��������� ����������.
ReadyLabel2b=������� ������ "���������", ����� ������ �����������.

ReadyMemoUserInfo=User information:
ReadyMemoDir=Destination directory:
ReadyMemoType=Setup type:
ReadyMemoComponents=Selected components:
ReadyMemoGroup=Start Menu folder:
ReadyMemoTasks=Additional tasks:

; *** "Preparing to Install" wizard page =======================================
WizardPreparing=Preparing to Install
PreparingDesc=Setup is preparing to install [name] on your computer.
PreviousInstallNotCompleted=The installation/removal of a previous program was not completed. You will need to restart your computer to complete that installation.%n%nAfter restarting your computer, run Setup again to complete the installation of [name].
CannotContinue=Setup cannot continue. Please click Cancel to exit.

; *** "Installing" wizard page
WizardInstalling=Installing
InstallingLabel=Please wait while Setup installs [name] on your computer.

; *** "Setup Completed" wizard page
FinishedHeadingLabel=���������� ��������� ��������� [name]
;Completing the [name] Setup Wizard
FinishedLabelNoIcons=��������� [name] ������� ����������� �� ��� ���������.
FinishedLabel=��������� [name] ������� ����������� �� ��� ���������. �� ������ ��������� ��, ������� �� ��������������� ������.
ClickFinish=������� "������" ��� ��������� ���������..
FinishedRestartLabel=����� ��������� ��������� [name], ��������� ������������� ���������. ������ ������� ��� ������?
FinishedRestartMessage=����� ��������� ��������� [name], ��������� ������������� ���������. %n%n������ ������� ��� ������?
ShowReadmeCheck=��, � ���� ��������� ���� README
YesRadio=&��, ������������� ��������� ������
NoRadio=&���, � ����������� ��������� �����
; used for example as 'Run MyProg.exe'
RunEntryExec=Run %1
; used for example as 'View Readme.txt'
RunEntryShellExec=View %1

; *** "Setup Needs the Next Disk" stuff
ChangeDiskTitle=Setup Needs the Next Disk
SelectDirectory=Select Directory
SelectDiskLabel2=Please insert Disk %1 and click OK.%n%nIf the files on this disk can be found in a folder other than the one displayed below, enter the correct path or click Browse.
PathLabel=&Path:
FileNotInDir2=The file "%1" could not be located in "%2". Please insert the correct disk or select another folder.
SelectDirectoryLabel=Please specify the location of the next disk.

; *** Installation phase messages
SetupAborted=��������� �� ���������.%n%n��������� �������� � ��������� ���������.
EntryAbortRetryIgnore=������� "������", ����� ��������� �������, "����������" ��� ����������� ��� "������" ��� ������ ���������.

; *** Installation status messages
StatusCreateDirs=�������� �����...
StatusExtractFiles=���������� ������...
StatusCreateIcons=�������� �������...
StatusCreateIniEntries=����������� INI-������...
StatusCreateRegistryEntries=����������� ���������� �������...
StatusRegisterFiles=����������� ������...
StatusSavingUninstall=���������� ���������� ��� ��������...
StatusRunProgram=Finishing installation...
StatusRollback=Rolling back changes...

; *** Misc. errors
ErrorInternal2=���������� ������ %1
ErrorFunctionFailedNoCode=���� %1
ErrorFunctionFailed=���� %1; ��� %2
ErrorFunctionFailedWithMessage=���� %1; ��� %2.%n%3
ErrorExecutingProgram=�� ���� ��������� ����:%n%1

; *** Registry errors
ErrorRegOpenKey=������ �������� ����� �������:%n%1\%2
ErrorRegCreateKey=������ �������� ����� �������:%n%1\%2
ErrorRegWriteKey=������ ������ ����� �������:%n%1\%2

; *** INI errors
ErrorIniEntry=������ �������� INI-�������� � ����� "%1".

; *** File copying errors
FileAbortRetryIgnore=������� "���������" ��� ����������, "����������" ��� �������� (�� �������������) ��� "������" ��� ���������� ���������.
FileAbortRetryIgnore2=������� "���������" ��� ����������, "����������" ��� �������� (�� �������������) ��� "������" ��� ���������� ���������.
SourceIsCorrupted=�������� ���� ���������
SourceDoesntExist=��������� ����� "%1" �� ����������
ExistingFileReadOnly=���� ����� ������� "������ ��� ������".%n%n������� "���������", ����� ������� ������� � ��������� ��� ���, "����������" ��� �������� �����, ��� "������" ��� ���������� ���������.
ErrorReadingExistingDest=������ ��� ������ ������������� �����:
FileExists=The file already exists.%n%nWould you like Setup to overwrite it?
ExistingFileNewer=The existing file is newer than the one Setup is trying to install. It is recommended that you keep the existing file.%n%nDo you want to keep the existing file?
ErrorChangingAttr=An error occurred while trying to change the attributes of the existing file:
ErrorCreatingTemp=An error occurred while trying to create a file in the destination directory:
ErrorReadingSource=An error occurred while trying to read the source file:
ErrorCopying=An error occurred while trying to copy a file:
ErrorReplacingExistingFile=An error occurred while trying to replace the existing file:
ErrorRestartReplace=RestartReplace failed:
ErrorRenamingTemp=An error occurred while trying to rename a file in the destination directory:
ErrorRegisterServer=Unable to register the DLL/OCX: %1
ErrorRegisterServerMissingExport=DllRegisterServer export not found
ErrorRegisterTypeLib=Unable to register the type library: %1

; *** Post-installation errors
ErrorOpeningReadme=An error occurred while trying to open the README file.
ErrorRestartingComputer=Setup was unable to restart the computer. Please do this manually.

; *** Uninstaller messages ============================================================

UninstallNotFound=���� "%1" �� ����������. �������� ����������.
UninstallOpenError=���� "%1" �� �����������. �������� ����������.
UninstallUnsupportedVer=������ ���������������� ����� "%1" �� ���������� ���� ������� ��������� ��������. �������� ����������
UninstallUnknownEntry=����������� ������� (%1) � ��������������� ����� ��� ��������
ConfirmUninstall=�� �������, ��� ������ ��������� ������� %1 � ��� �� ����������?
OnlyAdminCanUninstall=��� �������� ���� ��������� �� ������ �������� ������� ��������������.
UninstallStatusLabel=���������, ���� �������� %1 �� ������ ����������.
UninstalledAll=��������� %1 ������� ������� �� ������ ����������.
UninstalledMost=�������� ��������� "%1" ���������.%n%n������ ��������� ���������� ������� �� �������. �� ������ ������� �� ��������������.
UninstalledAndNeedsRestart=To complete the uninstallation of %1, your computer must be restarted.%n%nWould you like to restart now?
UninstallDataCorrupted=���� "%1" ��������. �������� ����������

; *** Uninstallation phase messages ======================================================

ConfirmDeleteSharedFileTitle=������� ����� ����?
ConfirmDeleteSharedFile2=��������� ����� ���� ������ �� ������������ �������� �����������. ������ ������� ���� ����?%n%n���� �����-���� ��������� ��� ��� ���������� ���� ����, � �� ��� �������, �� ���������������� ���� �������� ����� ���� ��������. ���� �� �� ������� - ���������� �� ��������. ������� ���� ���� � �������, �� �� ��������� �� �������� �����.
SharedFileNameLabel=��� �����:
SharedFileLocationLabel=��������������:
WizardUninstalling=������ ��������
StatusUninstalling=�������� %1...
