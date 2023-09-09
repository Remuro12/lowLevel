@ECHO OFF
ECHO.
set name=%1
echo %name% is myvar
del %name%.OBJ
tasm %name%.asm
tlink %name%.OBJ
td %name%.exe
ECHO.
PAUSE
CLS
EXIT
