@echo off

set DEPOT_TOOLS_WIN_TOOLCHAIN=0
set vs2019_install=C:\Program Files (x86)\Microsoft Visual Studio\2019\Enterprise

git.exe clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
set Path=%Path%;%~dp0depot_tools

call gclient.bat
if not exist .\v8 call fetch.bat v8
cd .\v8

git.exe checkout %V8BUILD_VERSION%
call gclient.bat sync

python.exe .\tools\dev\v8gen.py x64.release -- v8_monolithic=true v8_use_external_startup_data=false use_custom_libcxx=false is_component_build=false treat_warnings_as_errors=false v8_symbol_level=0
ninja.exe -C .\out.gn\x64.release v8_monolith -j 14

mkdir ..\_upload\include
mkdir ..\_upload\lib
xcopy .\include\* ..\_upload\include /E /Q /Y
xcopy .\out.gn\x64.release\obj\v8_monolith.lib ..\_upload\lib /S /Q /Y

cd ..

powershell.exe -nologo -noprofile -command "& { param([String]$sourceDirectoryName, [String]$destinationArchiveFileName, [Boolean]$includeBaseDirectory); Add-Type -A 'System.IO.Compression.FileSystem'; Add-Type -A 'System.Text.Encoding'; [IO.Compression.ZipFile]::CreateFromDirectory($sourceDirectoryName, $destinationArchiveFileName, [IO.Compression.CompressionLevel]::Fastest, $includeBaseDirectory, [System.Text.Encoding]::UTF8); exit !$?;}" -sourceDirectoryName .\_upload -destinationArchiveFileName .\v8-%V8BUILD_VERSION%-x64.zip -includeBaseDirectory $false
