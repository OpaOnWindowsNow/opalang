# -*- coding: utf-8 -*-
!include "MUI2.nsh"


### Env variables

!include "WordFunc.nsh"
!define REG_ENVIRONMENT "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
!macro DualUseFunctions_ un_
function ${un_}SetPathVar
        # stack top: <'string to add'> / <AppendFlag>
        Exch $0		; new string
        Exch
        Exch $1		; append = 2, prefix = 1, remove = 0
        Push $R0	; saved working registers

        ReadRegStr $R0 HKLM "${REG_ENVIRONMENT}" "Path"

        ${Select} $1
        ${Case} 0
                ${${un_}WordAdd} "$R0" ";" "-$0" $R0
        ${Case} 1
                ${${un_}WordAdd} "$0" ";" "+$R0" $R0
        ${Case} 2
                ${${un_}WordAdd} "$R0" ";" "+$0" $R0
        ${EndSelect}

        WriteRegExpandStr HKLM "${REG_ENVIRONMENT}" "Path" "$R0"
        System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("PATH", R0).r2'

        Pop $R0				; restore registers
        Pop $1
        Pop $0
functionEnd
!macroend
!insertmacro DualUseFunctions_ ""
!insertmacro DualUseFunctions_ "un."

### end env variables



# General information
!define PRODUCT_NAME "OPA"
!define PRODUCT_PUBLISHER "MLstate"
!define PRODUCT_WEB_SITE "http://www.mlstate.com"


# We support french and english
!insertmacro MUI_LANGUAGE English
!insertmacro MUI_LANGUAGE French

# Language menu
Function .onInit
  !insertmacro MUI_LANGDLL_DISPLAY
FunctionEnd

Name "${PRODUCT_NAME}"
outFile "installer.exe"
Icon bin\uninstall\opa_logo_72x72.ico
CRCCheck on
BrandingText "MLstate"

InstallDir "$PROGRAMFILES\OPA"

# Include license
LicenseLangString license ${LANG_ENGLISH} share/opa/LICENSE
LicenseLangString license ${LANG_FRENCH} share/opa/LICENSE_FR
LicenseData $(license)

LangString MsgLicense ${LANG_ENGLISH} "Please read and accept OPA license"
LangString MsgLicense ${LANG_FRENCH} "Veuillez lire et accepter la licence d'utilisation d'OPA"
LicenseText $(MsgLicense)

#!define MUI_WELCOMEPAGE_TEXT "Hello!"
#!define MUI_WELCOMEPAGE_TITLE "Title!"
#!insertmacro MUI_PAGE_WELCOME

!define REG_UNINSTALL "Software\Microsoft\Windows\CurrentVersion\Uninstall\OPA"

Page license
Page directory
Page components
Page instfiles

Section OPA
DetailPrint "OPA"
SectionIn RO

WriteRegStr HKLM "${REG_UNINSTALL}" "DisplayName" "${PRODUCT_NAME}"
WriteRegStr HKLM "${REG_UNINSTALL}" "Publisher" "${PRODUCT_PUBLISHER}"
WriteRegStr HKLM "${REG_UNINSTALL}" "DisplayIcon" "$INSTDIR\bin\uninstall\opa_logo_72x72.ico"
WriteRegStr HKLM "${REG_UNINSTALL}" "UninstallString" "$INSTDIR\bin\uninstall\Uninstall.exe"
WriteRegDWORD HKLM "${REG_UNINSTALL}" "NoModify" 1
WriteRegDWORD HKLM "${REG_UNINSTALL}" "NoRepair" 1
WriteRegStr HKLM "${REG_UNINSTALL}" "InstallSource" "$INSTDIR\"
# "


SetOutPath "$INSTDIR"
#for i in $(ls -1d * | grep "/" | tr -d "/"); do echo file /r $i ; done to automate
file /r bin
file /r db3
file /r db4
file /r html
file /r lib
file /r libqml
file /r libtrx
file /r opabsl
file /r opalib
file /r qml2ocaml
file /r qmlbsl
file /r qmlcps
file /r qmlfake
file /r qmlflat
file /r share
file /r ulex
file /r utils
file /r weblib
file /r windows_libs
writeUninstaller $INSTDIR\bin\uninstall\Uninstall.exe

Push 1		; prefix
Push "$INSTDIR\bin"
Call SetPathVar

!define env_hklm 'HKLM "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"'
!define env_hkcu 'HKCU "Environment"'
WriteRegExpandStr ${env_hklm} "OPABASEDIR" "$INSTDIR"
# WriteRegExpandStr ${env_hklm} "MLSTATELIBS" "$INSTDIR"
# WriteRegExpandStr ${env_hklm} "OCAMLOPT" "$INSTDIR\bin\ocamlopt.opt.exe"
# WriteRegExpandStr ${env_hklm} "OCAMLC" "$INSTDIR\bin\ocamlc.opt.exe"
#WriteRegExpandStr ${env_hklm} "OCAMLLIB" "$INSTDIR\lib\ocaml"
#WriteRegExpandStr ${env_hklm} "PATH" "$INSTDIR\bin;$INSDIR\openssl\bin;$INSTDIR\zlib;$PATH"
SendMessage ${HWND_BROADCAST} ${WM_WININICHANGE} 0 "STR:Environment" /TIMEOUT=5000

SectionEnd

LangString MsgEx  ${LANG_ENGLISH} "OPA Examples"
LangString MsgEx ${LANG_FRENCH} "Exemples OPA"

Section $(MsgEx)
SetOutPath "$INSTDIR"
file /r examples
SectionEnd


section "Uninstall"

ReadRegStr $0 HKLM "${REG_UNINSTALL}" "InstallSource"
DeleteRegKey /ifempty HKLM "${REG_UNINSTALL}"

Push 0		; remove
Push "$INSTDIR\bin"
Call Un.SetPathVar

# now delete installed files
# for i in $(ls -1d * | grep "/" | tr -d "/"); do echo RMDir /r $i ; done TO AUTOMATE
RMDir /r $0\bin
RMDir /r $0\db3
RMDir /r $0\db4
RMDir /r $0\html
RMDir /r $0\lib
RMDir /r $0\libqml
RMDir /r $0\libtrx
RMDir /r $0\opabsl
RMDir /r $0\opalib
RMDir /r $0\qml2ocaml
RMDir /r $0\qmlbsl
RMDir /r $0\qmlcps
RMDir /r $0\qmlfake
RMDir /r $0\qmlflat
RMDir /r $0\share
RMDir /r $0\ulex
RMDir /r $0\utils
RMDir /r $0\weblib
RMDir /r $0\windows_libs
RMDir /r $0\examples
RMDir $0

sectionEnd
