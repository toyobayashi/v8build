@echo off

if not exist depot_tools git.exe clone https://chromium.googlesource.com/chromium/tools/depot_tools.git 
set Path=%Path%;%~dp0depot_tools
cd .\depot_tools
git.exe pull
cd ..
call gclient.bat
