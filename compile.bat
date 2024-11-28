:: quicker way of compiling and quicky changing things :D
@echo off
echo UPDATING CHANGES IN MODS...
robocopy "export\release\windows\bin\mods" ".\mods" /e /move /njh /ndl /nc /ns /np /nfl
echo DELETING ASSETS (EXPORT) FOLDER...
rmdir /S /Q export\release\windows\bin\assets
echo BEGINNING TEST SESSION
haxelib run lime test windows -release
echo ENDING TEST SESSION
exit