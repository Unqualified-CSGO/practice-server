echo off
:start
"%~dp0/steamcmd/steamcmd.exe" +login anonymous +force_install_dir "%~dp0/game" +app_update 740 validate +quit
pause