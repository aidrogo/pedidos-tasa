@echo off
chcp 65001 >nul
title Bot de reservas TASA
cd /d "%~dp0"
:loop
python bot_reservas.py
echo El bot se detuvo. Reiniciando en 60 segundos... (cierre esta ventana para detenerlo)
timeout /t 60 >nul
goto loop
