# 🤖 Bot de reservas — Pedidos de Material · Astillero TASA

El bot conecta la app web con la carpeta de reservas y con su `Código_reserva_2.exe`. Corre en una PC de la oficina y repite este ciclo cada 15 minutos:

```
App: solicitud "Validada" (sistema TUBERIAS)
   │  1. el bot genera el Excel "Pedido" (idéntico al de la app)
   ▼
Z:\Diseño\RESERVAS\Reservas\2026\REM HERCULES 1\2. TUBERIAS\Solicitados\   → la app la marca "Cargada"
   │  2. el bot ejecuta Código_reserva_2.exe de esa carpeta (SAP + PDF + correo, como hoy)
   ▼
...\2. TUBERIAS\Reservados\
   │  3. el bot lee el Excel y registra Reserva / Posición / Estado (Reservado o Bloqueado)
   ▼
App: solicitud "Reservada", la contrata ve sus reservas y los bloqueos quedan en seguimiento
```

* **No se modifica el ejecutable**: el bot solo deja los archivos donde ustedes los dejan hoy y lo ejecuta.
* El bot asocia cada Excel de *Reservados* con su solicitud por **proyecto + fecha de solicitud** (columna R). Si no coinciden, usa grafo, Pos. y códigos. Por eso también registra los Excel que ustedes exporten y carguen a mano.
* Los nombres **RM / REM** se reconocen como iguales: "RM HERCULES 1" en la app = carpeta "REM HERCULES 1". La carpeta del sistema se encuentra aunque tenga número ("2. TUBERIAS").
* Por defecto todas las solicitudes validadas (cualquier sistema de la app: ACHIQUE, TUBERIAS…) van a la carpeta de especialidad **TUBERIAS** del proyecto (`carpeta_especialidad`). Para limitar qué sistemas se automatizan use `sistemas`, y para enviar un sistema a otra carpeta use `[carpeta_por_sistema]`.
* Su estado se ve en la app en **Gestión → 🤖 Bot de reservas** (y en un botón en el Tablero). Ahí está **▶ Ejecutar ahora**, que no espera los 15 minutos.

## Requisitos de la PC
1. Windows con acceso a la unidad **Z:** y a **SAP GUI** con *scripting* habilitado: la misma PC donde hoy funciona el `Código_reserva_2.exe`.
2. **Python 3.10 o superior** ([python.org](https://www.python.org/downloads/)). Al instalar, marque **"Add python.exe to PATH"**.
3. La sesión de Windows debe quedar **iniciada y sin bloquear**, porque SAP GUI no funciona con la pantalla bloqueada. Lo ideal es una PC dedicada o una máquina virtual, sin bloqueo de pantalla ni suspensión.
4. Mientras el bot ejecuta el Código_reserva, **no use SAP en esa PC**: el script toma el control de la ventana.

## Instalación (una sola vez)
1. **En la app**: Gestión → Usuarios → **Nuevo usuario**
   * Usuario: `bot`, nombre: `Bot de reservas`, rol: **Planificador**, sin empresa.
   * Anote su contraseña.
2. **En Firebase**: Firestore Database → Reglas. Pegue el contenido actualizado de `firestore.rules` (agrega la colección `botEstado`) → **Publicar**.
3. Copie la carpeta `bot` del repositorio a la PC, por ejemplo a `C:\BotReservas`.
4. Ejecute **`instalar.bat`**. Instala `requests` y `openpyxl` y crea `config.ini`.
5. Abra **`config.ini`** con el Bloc de notas y escriba la `clave` del usuario bot. Revise también `raices` y `sistemas`.
6. Ejecute **`diagnostico.bat`**: lista las solicitudes que ve el bot y a qué carpeta irían. Luego **`probar_bot.bat`**: hace un ciclo **sin escribir nada**. Revise que:
   * diga qué solicitudes exportaría y a qué carpeta;
   * no aparezcan líneas `ATENCIÓN: No encuentro la carpeta…`. Si aparecen, agregue el alias en `[alias_proyectos]`.
7. Cuando la prueba se vea bien, ejecute **`iniciar_bot.bat`**. Deje esa ventana abierta (puede minimizarla).
8. Opcional: **`arranque_automatico.bat`** hace que el bot se inicie solo cada vez que se inicia sesión en esa PC.

## Primera puesta en marcha recomendada
* Al primer arranque el bot **solo lee los Excel de *Reservados* que aparezcan desde ese momento**: no toca el histórico. Para registrar algo anterior, ponga una fecha en `procesar_desde`.
* Por defecto `ejecutar_exe = no`: el bot deja los Excel en *Solicitados* y lee *Reservados*, y ustedes siguen ejecutando el Reservatron a mano. La versión actual del Reservatron abre una ventana, espera **▶ INICIAR PROCESO** y pide confirmar cada archivo, así que no puede correr sin una persona. Active `ejecutar_exe = si` solo con una versión que tenga modo automático.

## Etapa 2: el bot también ejecuta el Reservatron
Requiere la versión del Reservatron con **modo automático** (`--auto`). Compílela y reemplace el `.exe` en las carpetas TUBERIAS de los proyectos.

1. En la PC del bot: **SAP abierto y con sesión iniciada**, pantalla **sin bloqueo** y sin suspensión (Configuración → Sistema → Inicio/apagado: "Nunca"). Parlantes con volumen para la sirena.
2. En `config.ini`:
   ```
   ejecutar_exe = si
   operador_sap = AIDROGO
   espera_respuesta_minutos = 10
   reintentar_minutos = 60
   ```
3. Reinicie el bot (cierre la ventana y abra `iniciar_bot.bat`).

Qué pasa en cada ciclo:
* El bot deja el Excel en *Solicitados* y ejecuta `Código_reserva_2.exe --auto --operador AIDROGO --espera 10` en esa carpeta. No hay ventana ni botón INICIAR.
* Si la actividad coincide: carga, graba, PDF, correo y mueve a *Reservados*, sin intervención. En el siguiente ciclo la app queda **Reservada**.
* Si la actividad **no coincide** o el **grafo está en uso**: suena la sirena y aparece la pregunta encima de todo. Si nadie responde en 10 min, ese archivo se omite y queda en *Solicitados*. El bot lo reintenta cada 60 min y lo muestra en "Requiere atención".
* Si SAP no está disponible (sesión cerrada, SAP caído): el Reservatron termina con error, suena la sirena 6 s y el panel lo muestra en rojo.
* El bot solo ejecuta el Reservatron en carpetas donde **él** dejó un Excel. Aun así, el Reservatron procesa *todos* los Excel de esa carpeta *Solicitados*: no deje archivos viejos ahí.
* Cada carpeta guarda el registro del modo automático en `Reservatron_auto.log`.
* Si alguien abre el Reservatron a mano mientras el bot lo está usando en la misma carpeta, verá "Reservatron en uso" (y viceversa): nunca procesan los mismos archivos a la vez.

## Archivos
| Archivo | Para qué |
|---|---|
| `bot_reservas.py` | El bot |
| `config.ini` | Su configuración (no se sube a GitHub: tiene la clave) |
| `bot_reservas.log` | Registro detallado (se rota solo) |
| `estado_bot.json` | Qué Excel de Reservados ya leyó (no lo borre) |

## Problemas frecuentes
| Mensaje | Qué hacer |
|---|---|
| `No se pudo iniciar sesión como "bot"` | Revise usuario y clave en `config.ini` y que el usuario esté activo en la app. |
| `No se puede acceder a la carpeta de reservas` | La unidad Z: no está conectada en esa sesión de Windows. |
| `No encuentro la carpeta del proyecto…` | Agregue `Nombre en la app = Nombre de carpeta` en `[alias_proyectos]`. |
| `Quedó en Solicitados sin procesar` | El Código_reserva no pudo cargarlo (revise SAP / la ventana del .exe). Corrija y pulse **Ejecutar ahora** en la app. |
| `Excel sin solicitud en la app` | Ese Excel no corresponde a ninguna solicitud registrada (por ejemplo, uno armado a mano). Impórtelo desde la app si hace falta. |
| El bot aparece **Desconectado** en la app | La PC está apagada o bloqueada, o se cerró la ventana del bot. |

## Convertir en .exe (opcional)
```
python -m pip install pyinstaller
pyinstaller --onefile --name BotReservas bot_reservas.py
```
Copie `dist\BotReservas.exe` junto a `config.ini`. Así la PC no necesita tener Python instalado.
