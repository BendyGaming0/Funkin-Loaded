@echo off
color 0a
cd ..
@echo on
echo BUILDING GAME
lime build windows -release
echo GAME BUILT, PRESS ENTER TO OPEN EXPLORER
pause
explorer.exe export\release\windows\bin