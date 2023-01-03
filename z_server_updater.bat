@echo off
:: current dir of this .bat file
SET mypath=%~dp0
SET mypath=%mypath:~0,-1%

:: %cd%
set gamepath=%mypath%

:: %LOCALAPPDATA%\Plutonium
set pluto_path=%gamepath%\Plutonium

"%gamepath%\plutonium.exe" -install-dir "%pluto_path%" -update-only
