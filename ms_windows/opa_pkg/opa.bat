@echo off
REM
REM This scripts sets all needed env var before calling the compiler
REM


set WD=%CD%
set ABORT=NO
set OLDPATH=%PATH%

REM get the location of VC from the environment
REM !!! NO SPACE BEFORE & !!!
if defined VS100COMNTOOLS set VSLOCATION=%VS100COMNTOOLS%\..\..& goto :vcvarsallOK
if defined VS90COMNTOOLS set VSLOCATION=%VS90COMNTOOLS%\..\..& goto :vcvarsallOK
if defined VS80COMNTOOLS set VSLOCATION=%VS80COMNTOOLS%\..\..& goto :vcvarsallOK
if defined VS70COMNTOOLS set VSLOCATION=%VS70COMNTOOLS%\..\..& goto :vcvarsallOK
goto :vcvarsallKO
REM if VS is found call the VC var setter
:vcvarsallOK
call "%VSLOCATION%\VC\vcvarsall.bat" > NUL
:vcvarsallKO

REM get the location of flexdll
if exist "c:\flexdll"                       set FLEXDLLLOCATION=c:\flexdll& goto :flexdllOK
if exist "c:\Program Files\flexdll" flexdll set FLEXDLLLOCATION=c:\Program Files\flexdll& goto :flexdllOK
if exist "c:\Program Files (x86)\flexdll"   set FLEXDLLLOCATION=c:\Program Files (x86)\flexdll& goto :flexdllOK
goto :flexdllKO
:flexdllOK
set PATH=%PATH%;%FLEXDLLLOCATION%
:flexdllKO

REM set PATH=""
REM set INCLUDE=""
REM set CLPATH=C:\Program Files\Microsoft Visual Studio 10.0\VC\bin
REM set VSLIBS=C:\Program Files\Microsoft Visual Studio 10.0\Common7\IDE
REM set FLEXDLL=C:\flexdll
REM set MTPATH=C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin
REM set PATH="%OPABASEDIR%/bin";%CLPATH%;%VSLIBS%;%FLEXDLLOCATION%;%MTPATH%;C:\Windows\system32


REM Checking presence of dependencies
REM cl.exe exists
REM chdir %ProgramFiles%
REM attrib /s cl.exe | find "soft" > NUL
REM if not %errorlevel% == 0 goto :noCl
REM cd %WD%

REM cl.exe is callable
cl.exe > %TMP%\\OPACLCHECK 2>&1
if %errorlevel% == 9009 call :noCl
mt.exe /BAD > %TMP%\\OPACLCHECK 2>&1
if %errorlevel% == 9009 call :noCl


REM flexlink is callable

flexlink > %TMP%\\OPAFLEXCHECK 2>&1
if %errorlevel% == 9009 call :noFlexlink


if %ABORT% == YES exit /B 1


set OLDOCAMLLIB=%OCAMLLIB%
set OLDBASEDIR=%BASEDIR%
set MLSTATELIBS=%OPABASEDIR%
REM set OCAMLOPT=ocamlopt.opt.exe
REM set OCAMLC=ocamlc.opt.exe
set PATH="%OPABASEDIR%\bin\ocaml";"%OPABASEDIR%\bin";%PATH%
set OCAMLLIB=%OPABASEDIR%\lib\ocaml

runopa.exe %*

REM Cleaning what have been set
set PATH=%OLDPATH%
set OCAMLLIB=%OLDOCAMLLIB%
set MLSTATELIBS=%OLDBASEDIR%


goto :end

:noFlexlink
echo ERROR: You must install flexlink tool (see http://alain.frisch.fr/flexdll/) or correct your PATH variable (e.g. set PATH=c:\some path\flexdll)
set ABORT=YES
exit /B 1

:noCl
echo ERROR: You must install microsoft compilation tools (see http://msdn.microsoft.com/fr-fr/express/aa975050.aspx) or correct your PATH variable
set ABORT=YES
exit /B 1

:end
