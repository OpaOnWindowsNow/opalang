@echo off
REM USING A TEMPORARY FILE FOR SOMETHING THAT SURELY DONT NEED IT, BATCH EXPERTS GO ON
echo %1 | c:\cygwin\bin\sed.exe -ue "s/\\\\/\//g" > ppdebug.tmp

bash -c '../ms_windows/preprocessing/mlstate_nodebug `cat ppdebug.tmp`'
