@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo === Prueba: un ciclo SIN escribir nada (no crea Excel, no ejecuta SAP, no cambia la app) ===
python bot_reservas.py --una-vez --prueba
pause
