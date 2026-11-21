@echo off
chcp 65001 >nul
cd /d "%~dp0"
echo === Instalando dependencias del Bot de reservas ===
python --version || (echo Python no esta instalado. Instale Python 3.10+ desde python.org marcando "Add to PATH". & pause & exit /b 1)
python -m pip install --upgrade requests openpyxl
if not exist config.ini copy config.ini.ejemplo config.ini >nul & echo Se creo config.ini: abralo con el Bloc de notas y complete la clave del usuario bot.
echo.
echo Listo. Para probar sin cambiar nada:  probar_bot.bat
pause
