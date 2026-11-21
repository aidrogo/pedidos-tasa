@echo off
chcp 65001 >nul
cd /d "%~dp0"
python bot_reservas.py --diagnostico
pause
