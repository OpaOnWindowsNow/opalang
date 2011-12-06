@echo off
REM We must replace \ by / before they are discarded by bash
echo %1 | c:\cygwin\bin\sed.exe -ue "s/\\\\/\//g" > ppdebug.tmp

bash -c '../ms_windows/preprocessing/pa_ulex_win `cat ppdebug.tmp`'
