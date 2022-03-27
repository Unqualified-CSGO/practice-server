@echo off

goto csgo_check

:choice_prompt
SET choice=
SET /p choice="Do you want to start CSGO? You can't start CSGO after starting the server? [Y/N]:"
IF NOT '%choice%'=='' SET choice=%choice:~0,1%
IF /i '%choice%'=='Y' GOTO start_csgo
IF /i '%choice%'=='N' GOTO start_server
IF '%choice%'=='' GOTO start_csgo
ECHO "%choice%" is not valid
goto :choice

:start_csgo
echo "Starting CSGO..." 
explorer "steam://run/730"
timeout /t 5 /nobreak >nul
goto :start_server

:csgo_check
SETLOCAL EnableExtensions
set EXE=csgo.exe
FOR /F %%x IN ('tasklist /NH /FI "IMAGENAME eq %EXE%"') DO IF NOT %%x == %EXE% (
    goto choice_prompt
)

:start_server
echo "Starting server..."
start "" "%cd%\game\srcds.exe" -game csgo -console +game_type 0 +game_mode 1 +mapgroup mg_active +map de_mirage -tickrate 128
