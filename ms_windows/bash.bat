
C:
chdir "C:\Program Files\Microsoft Visual Studio 10.0\VC\bin\"
call vcvars32.bat

set VS100="C:\Program Files\Microsoft Visual Studio 10.0\VC\bin"
set LIB=C:\ocamlms\lib;C:\ocamlms\lib\zip;C:\Tcl\lib;%LIB%
set INCLUDE=C:\ocamlms\include;C:\Tcl\include;%INCLUDE%

chdir C:\cygwin\bin



bash --login -i
