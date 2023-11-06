; Script to run as administrator, execute PowerShell, and extract files

unicode True
!include LogicLib.nsh

Outfile "ATK-Installer.exe"
RequestExecutionLevel admin

BrandingText /TRIMCENTER "ATK 1.4.0 Setup"
Name "ATK 1.4.0 Setup"
ManifestSupportedOS Win10
DetailsButtonText "Show progress"

######### LICENSE ############
PageEx license
    LicenseText "Readme"
    LicenseData LICENSE.txt
    LicenseForceSelection checkbox
PageExEnd

########### COMPONENTS #####################

InstType "Full" IT_FULL
InstType "Minimal" IT_MIN

PageEx components
    ComponentText "Choose files you want to install." \
    "About" \
    "Main program contains all necessary components for basic functioning. \
    Additional programs contain all extra files, mainly used by the context menu."
PageExEnd

SectionGroup "!Main Program" RO
    Section !ATK.exe sec1_id
        DetailPrint "These files go to your TEMP folder. These will be deleted after setup."
        SectionInstType ${IT_FULL} ${IT_MIN} RO
        SectionIn 1 ${sec1_id}
        SetOutPath "$TEMP\ATK"
        File "ATK.exe"
    SectionEnd
    Section !LICENSE.txt sec7_id
        SectionInstType ${IT_FULL} ${IT_MIN} RO
        SectionIn 1 ${sec1_id}
        File "LICENSE.txt"
    SectionEnd
    Section !Uninstall.ps1 sec8_id
        SectionInstType ${IT_FULL} ${IT_MIN} RO
        SectionIn 1 ${sec1_id}
        File "Uninstall.ps1"
    SectionEnd
SectionGroupEnd

SectionGroup "Additional Components"
    Section encrypt_with_atk.cmd sec2_id
        SectionIn 1 ${sec1_id}
        SectionInstType ${IT_FULL}
        File "encrypt_with_atk.cmd"
    SectionEnd

    Section open_with_atk.cmd sec3_id
        SectionIn 1 ${sec1_id}
        SectionInstType ${IT_FULL}
        File "open_with_atk.cmd"
    SectionEnd

    Section atk-ext.ico sec4_id
        SectionIn 1 ${sec1_id}
        SectionInstType ${IT_FULL}
        File "atk-ext.ico"
    SectionEnd

    Section atk-exe.ico sec5_id
        SectionIn 1 ${sec1_id}
        SectionInstType ${IT_FULL}
        File "atk-exe.ico"
    SectionEnd

    Section changelog.txt sec6_id
        SectionIn 1 ${sec1_id}
        SectionInstType ${IT_FULL}
        File "changelog.txt"
    SectionEnd
SectionGroupEnd


############ DIRECTORY ######################
Var INSTALL_DIR

; Set the default installation directory
Function .onInit
    InitPluginsDir
    StrCpy $INSTALL_DIR $PROGRAMFILES64\ATK
FunctionEnd

PageEx directory
    DirVar $INSTALL_DIR
    DirVerify leave
PageExEnd

Function .onVerifyInstDir
    Var /GLOBAL ext
    StrCpy $ext "ATK"
    StrCpy $INSTALL_DIR "$INSTALL_DIR$ext"
FunctionEnd

PageEx instfiles
PageExEnd

############################## START ##############################
Section 


; Delete the $TEMP folder stuff before extracting more files
; and taking up more space from the disk
Delete "$TEMP\ATK\ATK.exe"
Delete "$TEMP\ATK\Uninstall.exe"

Delete "$TEMP\ATK\changelog.txt"
Delete "$TEMP\ATK\LICENSE.txt"

Delete "$TEMP\ATK\atk-ext.ico"
Delete "$TEMP\ATK\atk-exe.ico"

Delete "$TEMP\ATK\Uninstall.ps1"

Delete "$TEMP\ATK\open_with_atk.cmd"
Delete "$TEMP\ATK\encrypt_with_atk.cmd"

; The folder will be deleted in the Uninstall section
# RMDir /r $TEMP\ATK\


; After deletion begin with setup

; Set the installation directory
SetOutPath $INSTALL_DIR

; Create the installation directory if it doesn't exist
CreateDirectory $INSTALL_DIR
SectionEnd


############# SETUP ################
Section 

File "Setup.ps1"

; Execute ps1 script
nsExec::ExecToLog 'Powershell.exe -ExecutionPolicy Bypass -File "$INSTALL_DIR\Setup.ps1" "$INSTALL_DIR" "no"'

Delete "Setup.ps1"

MessageBox MB_YESNO|MB_ICONQUESTION "Do you want to restart explorer.exe? This is needed for icons to refresh." IDYES true IDNO false

true:
    File "RestartExplorer.ps1"
    nsExec::ExecToLog 'Powershell.exe -ExecutionPolicy Bypass -File "$INSTALL_DIR\RestartExplorer.ps1" "$INSTDIR" "yes"'
    Delete "RestartExplorer.ps1"
    Goto done

false:
    Goto done

done:


; Extract uninstallation script
File "Uninstall.ps1"

; Set the file attributes to hidden
System::Call 'kernel32::SetFileAttributes(t "$INSTALL_DIR\Uninstall.ps1", i 2) i .r0'

; Check if the SetFileAttributes call succeeded
${If} $0 != 0
    DetailPrint "Uninstall.ps1 file attributes set to hidden."
${Else}
    DetailPrint "Failed to set Uninstall.ps1 file attributes to hidden."
${EndIf}

########## INSTALLATION AND EXTRACTION ##########
; Extract files based on section selection

########## MAIN PROGRAM ##########
${If} ${SectionIsSelected} ${sec1_id}
    File "ATK.exe"
${EndIf}

${If} ${SectionIsSelected} ${sec7_id}
    File "License.txt"
${EndIf}

########## ADDITIONAL COMPONENTS ##########

${If} ${SectionIsSelected} ${sec2_id}
    File "encrypt_with_atk.cmd"
${EndIf}

${If} ${SectionIsSelected} ${sec3_id}
    File "open_with_atk.cmd"
${EndIf}

${If} ${SectionIsSelected} ${sec4_id}
    File "atk-ext.ico"
${EndIf}

${If} ${SectionIsSelected} ${sec5_id}
    File "atk-exe.ico"
${EndIf}

${If} ${SectionIsSelected} ${sec6_id}
    File "changelog.txt"
${EndIf}

; Create an uninstaller in the same directory as the installer
WriteUninstaller "$INSTALL_DIR\Uninstall.exe"

SectionEnd



########## UNINSTALL ##########


UninstPage uninstConfirm
UninstPage instfiles


Section "Uninstall"
; Execute the PowerShell script with elevated privileges and pass the parameters
nsExec::ExecToLog 'Powershell.exe -ExecutionPolicy Bypass -File "$INSTDIR\Uninstall.ps1" "$INSTDIR"'

########################### DELETE FILES ###########################
; Remove installed files during uninstallation

Delete "$INSTDIR\ATK.exe"
Delete "$INSTDIR\Uninstall.exe"

Delete "$INSTDIR\changelog.txt"
Delete "$INSTDIR\LICENSE.txt"

Delete "$INSTDIR\atk-ext.ico"
Delete "$INSTDIR\atk-exe.ico"

Delete "$INSTDIR\Uninstall.ps1"
Delete "$INSTDIR\Setup.ps1"

Delete "$INSTDIR\open_with_atk.cmd"
Delete "$INSTDIR\encrypt_with_atk.cmd"

; Remove the installation directory
RMDir $INSTDIR
RMDir $TEMP\ATK

SectionEnd