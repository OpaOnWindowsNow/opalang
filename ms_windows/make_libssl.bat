echo off

set CUR=%CD%
echo DIR=%CUR%

C:
set PATH=%PATH%;C:\nasm

chdir "C:\Program Files\Microsoft Visual Studio 10.0\VC\bin\"
call vcvars32.bat

chdir %CUR%

echo Conf
perl Configure VC-WIN32 no-shared no-zlib-dynamic --prefix="c:\cygwin\windows_libs\openssl" --openssldir="c:\cygwin\windows_libs\openssl"
REM perl Configure VC-WIN32 no-zlib-dynamc --prefix="c:\cygwin\windows_libs\openssl" --openssldir="c:\cygwin\windows_libs\openssl"

echo Create .mak
call ms/do_nasm

echo Compile dll
nmake -f ms\ntdll.mak

echo Compile static
nmake -f ms\nt.mak

echo Installs
nmake -f ms\ntdll.mak install
nmake -f ms\nt.mak install