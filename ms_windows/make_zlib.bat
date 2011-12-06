

set CUR=%CD%
echo DIR=%CUR%

C:
chdir "C:\Program Files\Microsoft Visual Studio 10.0\VC\bin\"
call vcvars32.bat

chdir %CUR%

nmake -f win32/Makefile.msc LOC="-DASMV -DASMINF" OBJA="inffas32.obj match686.obj"
