@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo Registrando el bot para que arranque solo al iniciar sesion en Windows...
schtasks /create /f /sc onlogon /tn "Bot reservas TASA" /tr "\"%~dp0iniciar_bot.bat\"" /rl LIMITED
if %errorlevel%==0 (echo Listo. Se iniciara la proxima vez que inicie sesion.) else (echo No se pudo registrar. Pruebe ejecutando este archivo como administrador.)
pause
