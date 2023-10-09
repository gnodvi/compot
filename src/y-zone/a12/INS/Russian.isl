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
SetupAppTitle=Установка
SetupWindowTitle=Установка - %1
UninstallAppTitle=Удаление
UninstallAppFullTitle=Удаление - %1

; *** Misc. common
InformationTitle=Информация
ConfirmTitle=Подтверждение
ErrorTitle=Ошибка

; *** SetupLdr messages
SetupLdrStartupMessage=Эта программа установит %1 на ваш компьютер.%nПродолжить установку?
LdrCannotCreateTemp=Не могу создать временный файл. Установка прервана
LdrCannotExecTemp=Не могу запустить файл из временной папки. Установка прервана

; *** Startup error messages
LastErrorMessage=%1.%n%nОшибка %2: %3
SetupFileMissing=Файл %1 отсутствует в каталоге установки. Устраните проблему или воспользуйтесь другой копией программы.
SetupFileCorrupt=Файлы установки повреждены. Используйте другую копию программы.
SetupFileCorruptOrWrongVer=Файлы установки повреждены или несовместимы с этой версией программы установки. Устраните проблему или воспользуйтесь другой копией программы.
NotOnThisPlatform=Эта программа не работает в %1.
OnlyOnThisPlatform=Эта программа работает только в %1.
WinVersionTooLowError=Эта программа требует %1 версии не ниже %2.
WinVersionTooHighError=Эта программа не может быть установлена в %1 версии %2 и старше.
AdminPrivilegesRequired=Чтобы установить эту программу, вы должны войти в систему как администратор.
PowerUserPrivilegesRequired=Чтобы установить эту программу, вы должны войти в систему как администратор или как Опытный Пользователь.
SetupAppRunningError=В системе обнаружена работающая копия %1.%n%nЗакройте эту программу и нажмите 'OK', чтобы продолжить, или 'Отмена', чтобы выйти.
UninstallAppRunningError=В системе обнаружена работающая копия %1.%n%nЗакройте эту программу и нажмите 'OK', чтобы продолжить, или 'Отмена', чтобы выйти.

; *** Misc. errors
ErrorCreatingDir=Не удалось создать папку "%1"
ErrorTooManyFilesInDir=Не могу создать файл в каталоге "%1", так как он содержит слишком много файлов

; *** Setup common messages
ExitSetupTitle=Прервать установку
ExitSetupMessage=Установка не завершена. Если выйти сейчас, программа не будет установлена.%n%nВы можете завершить установку позже.%n%nВыйти?
AboutSetupMenuItem=&О программе...
AboutSetupTitle=О программе
AboutSetupMessage=%1 версии %2%n%3%n%n%1 Web-страница:%n%4
AboutSetupNote=

; *** Buttons
ButtonBack=< &Назад
ButtonNext=&Далее >
ButtonInstall=&Установка
ButtonOK=ОК
ButtonCancel=Отмена
ButtonYes=Д&а
ButtonYesToAll=Да для &всех
ButtonNo=Н&ет
ButtonNoToAll=Н&ет для всех
ButtonFinish=&Готово
ButtonBrowse=&Обзор...

; *** "Select Language" dialog messages
SelectLanguageTitle=Select Setup Language
SelectLanguageLabel=Select the language to use during the installation:

; *** Common wizard text 
ClickNext=Нажмите кнопку "Далее" для продолжения или "Отмена" для выхода из установки.
BeveledLabel=

; *** "Welcome" wizard page
WelcomeLabel1=Добро пожаловать! Вас приветствует программа установки [name].
WelcomeLabel2=Она установит версию [name/ver] на ваш компьютер.%n%nПрежде чем продолжить установку, рекомендуется закрыть все другие приложения, чтобы избежать возможных конфликтов.

; *** "Password" wizard page
WizardPassword=Password
PasswordLabel1=This installation is password protected.
PasswordLabel3=Please provide the password, then click Next to continue. Passwords are case-sensitive.
PasswordEditLabel=&Password:
IncorrectPassword=The password you entered is not correct. Please try again.

; *** "License Agreement" wizard page
WizardLicense=Лицензионное соглашение
LicenseLabel=Please read the following important information before continuing.
LicenseLabel3=Прочитайте это Лицензионное соглашение. You must accept the terms of this agreement before continuing with the installation.
LicenseAccepted=I &accept the agreement
LicenseNotAccepted=I &do not accept the agreement

; *** "Information" wizard pages
WizardInfoBefore=Информация
InfoBeforeLabel=Прочитайте эту информацию, прежде чем продолжить установку.
InfoBeforeClickLabel=Когда будете готовы продолжить установку, нажмите кнопку "Далее".
WizardInfoAfter=Информация
InfoAfterLabel=Прочитайте эту информацию, прежде чем продолжить.
InfoAfterClickLabel=Когда будете готовы продолжить установку, нажмите кнопку "Далее".

; *** "User Information" wizard page
WizardUserInfo=User Information
UserInfoDesc=Please enter your information.
UserInfoName=&User Name:
UserInfoOrg=&Organization:
UserInfoSerial=&Serial Number:
UserInfoNameRequired=You must enter a name.

; *** Страница "Выбор каталога"
WizardSelectDir=Выберите каталог для установки
SelectDirDesc=Куда следует установить [name]?
SelectDirLabel=Выберите каталог, куда бы вы хотели установить [name], и затем нажмите "Далее".
DiskSpaceMBLabel=Программе требуется [mb] Мбайт свободного места на диске.
ToUNCPathname=Setup cannot install to a UNC pathname. If you are trying to install to a network, you will need to map a network drive.
InvalidPath=You must enter a full path with drive letter; for example:%n%nC:\APP%n%nor a UNC path in the form:%n%n\\server\share
InvalidDrive=The drive or UNC share you selected does not exist or is not accessible. Please select another.
DiskSpaceWarningTitle=Недостаточно места на диске
DiskSpaceWarning=Для установки требуется не менее %1 Кбайт свободного пространства, а на выбранном дисководе имеется только %2 Кбайт.%n%nВы настаиваете на продолжении?
BadDirName32=Имя каталога не может включать в себя любые из следующих символов:%n%n%1
DirExistsTitle=Каталог уже существует
DirExists=Выбранный каталог:%n%n%1%n%nуже существует. Хотите установить программу в этот каталог?
DirDoesntExistTitle=Каталога не существует
DirDoesntExist=Каталог:%n%n%1%n%nне существует. Хотите его создать?

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
WizardSelectProgramGroup=Выберите папку в меню "Пуск"  
;Select Start Menu Folder
SelectStartMenuFolderDesc=Куда следует поместить ярлыки приложения? 
;Where should Setup place the program's shortcuts?
SelectStartMenuFolderLabel=Выберите папку в меню "Пуск", где бы вы хотели создать ярлыки приложения, и затем нажмите "Далее". 
;Select the Start Menu folder in which you would like Setup to create the program's shortcuts, then click Next.
NoIconsCheck=&Don't create any icons
MustEnterGroupName=Введите имя группы.
BadGroupName=Имя группы не может включать в себя любые из следующих символов:%n%n%1
NoProgramGroupCheck2=&Don't create a Start Menu folder

; *** "Ready to Install" wizard page ===========================================
WizardReady=Все готово к установке
ReadyLabel1=Программа готова к установке [name] на ваш компьютер.
ReadyLabel2a=Нажмите кнопку "Установка" для начала установки, или "Назад", чтобы проверить или изменить введенную информацию.
ReadyLabel2b=Нажмите кнопку "Установка", чтобы начать инсталляцию.

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
FinishedHeadingLabel=Завершение программы установки [name]
;Completing the [name] Setup Wizard
FinishedLabelNoIcons=Программа [name] успешно установлена на ваш компьютер.
FinishedLabel=Программа [name] успешно установлена на ваш компьютер. Вы можете запустить ее, щелкнув на соответствующем ярлыке.
ClickFinish=Нажмите "Готово" для окончания установки..
FinishedRestartLabel=Чтобы завершить установку [name], требуется перезагрузить компьютер. Хотите сделать это сейчас?
FinishedRestartMessage=Чтобы завершить установку [name], требуется перезагрузить компьютер. %n%nХотите сделать это сейчас?
ShowReadmeCheck=Да, я хочу прочитать файл README
YesRadio=&Да, перезагрузить компьютер сейчас
NoRadio=&Нет, я перезагружу компьютер позже
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
SetupAborted=Установка не завершена.%n%nУстраните проблему и повторите установку.
EntryAbortRetryIgnore=Нажмите "Повтор", чтобы повторить попытку, "Пропустить" для продолжения или "Отмена" для отмены установки.

; *** Installation status messages
StatusCreateDirs=Создание папок...
StatusExtractFiles=Извлечение файлов...
StatusCreateIcons=Создание значков...
StatusCreateIniEntries=Модификация INI-файлов...
StatusCreateRegistryEntries=Модификация системного реестра...
StatusRegisterFiles=Регистрация файлов...
StatusSavingUninstall=Сохранение информации для удаления...
StatusRunProgram=Finishing installation...
StatusRollback=Rolling back changes...

; *** Misc. errors
ErrorInternal2=Внутренняя ошибка %1
ErrorFunctionFailedNoCode=Сбой %1
ErrorFunctionFailed=Сбой %1; код %2
ErrorFunctionFailedWithMessage=Сбой %1; код %2.%n%3
ErrorExecutingProgram=Не могу запустить файл:%n%1

; *** Registry errors
ErrorRegOpenKey=Ошибка открытия ключа реестра:%n%1\%2
ErrorRegCreateKey=Ошибка создания ключа реестра:%n%1\%2
ErrorRegWriteKey=Ошибка записи ключа реестра:%n%1\%2

; *** INI errors
ErrorIniEntry=Ошибка создания INI-элемента в файле "%1".

; *** File copying errors
FileAbortRetryIgnore=Нажмите "Повторить" для повторения, "Пропустить" для пропуска (не рекомендуется) или "Отмена" для прерывания установки.
FileAbortRetryIgnore2=Нажмите "Повторить" для повторения, "Пропустить" для пропуска (не рекомендуется) или "Отмена" для прерывания установки.
SourceIsCorrupted=Исходный файл поврежден
SourceDoesntExist=Исходного файла "%1" не существует
ExistingFileReadOnly=Файл имеет атрибут "только для чтения".%n%nНажмите "Повторить", чтобы удалить атрибут и повторить еще раз, "Пропустить" для пропуска файла, или "Отмена" для прерывания установки.
ErrorReadingExistingDest=Ошибка при чтении существующего файла:
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

UninstallNotFound=Файл "%1" не существует. Удаление невозможно.
UninstallOpenError=Файл "%1" не открывается. Удаление невозможно.
UninstallUnsupportedVer=Формат регистрационного файла "%1" не опознается этой версией программы удаления. Удаление невозможно
UninstallUnknownEntry=Неизвестный элемент (%1) в регистрационном файле для удаления
ConfirmUninstall=Вы уверены, что хотите полностью удалить %1 и все ее компоненты?
OnlyAdminCanUninstall=Для удаления этой программы вы должны обладать правами администратора.
UninstallStatusLabel=Подождите, идет удаление %1 из вашего компьютера.
UninstalledAll=Программа %1 успешно удалена из вашего компьютера.
UninstalledMost=Удаление программы "%1" завершено.%n%nОднако некоторые компоненты удалить не удалось. Вы можете удалить их самостоятельно.
UninstalledAndNeedsRestart=To complete the uninstallation of %1, your computer must be restarted.%n%nWould you like to restart now?
UninstallDataCorrupted=Файл "%1" повреждён. Удаление невозможно

; *** Uninstallation phase messages ======================================================

ConfirmDeleteSharedFileTitle=Удалить общий файл?
ConfirmDeleteSharedFile2=Следующий общий файл больше не используется никакими программами. Хотите удалить этот файл?%n%nЕсли какие-либо программы все еще используют этот файл, а вы его удалите, то функционирование этих программ может быть нарушено. Если вы не уверены - откажитесь от удаления. Оставив этот файл в системе, вы не причините ей никакого вреда.
SharedFileNameLabel=Имя файла:
SharedFileLocationLabel=Местоположение:
WizardUninstalling=Статус удаления
StatusUninstalling=Удаление %1...
