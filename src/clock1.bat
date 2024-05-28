if exist masm.err del masm.err
if exist link.err del link.err
if exist clock.asm msdos.exe d:\dosbox\masm51\masm /DTWEAK /DTWEAK2 /V /Z /ZI clock,,,; 2> masm.err
rem if exist clock.asm masm /V /Z /ZI clock,,,; 2> masm.err
if exist clock.crf msdos.exe d:\dosbox\masm51\cref clock;
if exist clock.obj msdos.exe d:\dosbox\masm51\link clock,,,; 2> link.err
if exist clock.exe msdos.exe D:\dosbox\WATCOM\BINW\EXE2BIN.exe clock.exe clock.sys
if exist clock.obj del clock.obj
if exist clock.exe del clock.exe
if exist clock.crf del clock.crf
