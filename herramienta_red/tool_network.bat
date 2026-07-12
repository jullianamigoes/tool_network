@echo off
setlocal

:: Configuracion Global
:: Generamos elevacion de privilegios de manera automatica

NET SESSION >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Solicitando permisos de Administrador...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: -------------------------------------------------- MENU
:menu
:: ---- Limpiar vista
cls
color 0F

echo ********** TOOL_NETWORK ***********
echo -
echo 1. Examinar conexion (ping)
echo 2. Buscar ruta de archivo 
echo 3. Extraer / Actualizar copia del historial (Adquisicion)
echo 4. Buscar coincidencias en el historial copiado (Analisis)
echo 5. Auditoria de Puertos Abiertos (LISTENING)
echo 6. Auditoria de Conexiones Activas (ESTABLISHED)
echo 7. Buscar procesos / matar procesos
echo 8. Buscar procesos avanzada (puedes usar nombre de aplicacion)
echo 9. Auditoria de Tareas Programadas (Persistencia)
echo 0. Salir
echo -
echo ***********************************

:: Limpiar y mostrar opcion
set "opcion="
set /p opcion=OPCION=

if "%opcion%"=="1" (goto fun1
) else if "%opcion%"=="2" (goto fun2
) else if "%opcion%"=="3" (goto fun3
) else if "%opcion%"=="4" (goto fun4
) else if "%opcion%"=="5" (goto fun5
) else if "%opcion%"=="6" (goto fun6
) else if "%opcion%"=="7" (goto fun7
) else if "%opcion%"=="8" (goto fun8
) else if "%opcion%"=="9" (goto fun9
) else if "%opcion%"=="0" (goto fun0
) else (goto error)


:: Ping para conectividad -------------------------------------- fun1
:fun1
cls
echo ====== Ejecutando PING a Google.com
echo.
color 0A
ping www.google.com -n 6
echo.
pause
goto menu


:: Buscar archivo con WHERE ------------------------------------ fun2
:fun2
cls
color 0F
echo ====== Buscando archivo en el sistema
echo.
echo (a) Busqueda rapida (Carpetas de usuario y programas)
echo (b) Busqueda profunda (Todo el disco C: - Lenta)
echo.
set "op="
set /p op=OPCION=

if "%op%"=="a" (goto rapida
) else if "%op%"=="b" (goto lenta
) else (goto error2)


:: Busqueda rapida de archivo
:rapida
cls
color 0F
set "archivo="
echo ====== BUSQUEDA RAPIDA ======
set /p archivo=Escribe el nombre del archivo (o extension, ej: *.txt): 
echo.
color 0E
echo Buscando en carpetas clave...
echo.

:: Busqueda recursiva en el perfil del usuario activo (Escritorio, Documentos, Descargas, etc.)
echo Busqueda recursiva en perfil de usuario activo
where /r "%userprofile%" "%archivo%" 2>nul

:: Busqueda en Archivos de Programa
echo.
echo Busqueda en Archivos de Programa
where /r "%ProgramFiles%" "%archivo%" 2>nul
where /r "%ProgramFiles(x86)%" "%archivo%" 2>nul

echo.
echo ====== Busqueda finalizada ======
pause
color 0F
goto menu


:: Busqueda lenta (profunda) de archivo
:lenta
cls
color 0F
set "archivo="
echo ====== BUSQUEDA PROFUNDA ======
set /p archivo=Escribe el nombre del archivo (o extension, ej: *.txt): 
echo.
color 0E
echo ===== Busqueda profunda activa (Puede tomar algunos minutos)...
echo Por favor, espera...
echo.

where /r C:\ "%archivo%" 2>nul

echo.
echo ====== Busqueda finalizada ======
pause
color 0F
goto menu


:: Extraer Historial de Chrome -------------------------------- fun3
:fun3
cls
color 0F
echo ====== EXTRACCION DE HISTORIAL DE NAVEGACION ======
echo.
echo Extrayendo archivo 'History' actual...

set "destino=%~dp0historial_navegacion"
if not exist "%destino%" mkdir "%destino%"

copy "%LocalAppData%\Google\Chrome\User Data\Default\History" "%destino%\Chrome_History.db" >nul 2>&1

if %errorlevel% neq 0 (
    color 0C
    echo [!] ERROR: No se pudo copiar el archivo. 
    echo Asegurate de que Google Chrome este instalado y CERRADO.
    echo.
    pause
    color 0F
    goto menu
)

color 0A
echo [OK] Historial extraido y guardado con exito en:
echo %destino%\Chrome_History.db
echo.
pause
goto menu


:: Consultar Historial Ya Copiado ------------------------------ fun4
:fun4
cls
color 0F
echo ====== CONSULTA RAPIDA DE HISTORIAL COPIADO ======
echo.
set "destino=%~dp0historial_navegacion"

:: Validamos primero que el archivo realmente exista antes de llamar a PowerShell
if not exist "%destino%\Chrome_History.db" (
    color 0C
    echo [!] ERROR: No existe ninguna copia previa del historial.
    echo Por favor, ejecuta primero la opcion de 'Extraer Historial'.
    echo.
    pause
    goto menu
)

set "keyword="
set /p keyword=Ingresa la palabra clave o URL a buscar (ej: facebook, banco): 

cls
color 0E
echo Buscando coincidencias para "%keyword%"...
echo -------------------------------------------------------------------------

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0ps1\consulta.ps1" -RutaDB "%destino%\Chrome_History.db" -Termino "%keyword%"

echo -------------------------------------------------------------------------
echo ====== Busqueda en historial finalizada ======
echo.
pause
goto menu


:: Puertos en Escucha (LISTENING) ------------------------------ fun5
:fun5
cls
color 0F
echo ====== AUDITORIA DE PUERTOS EN ESCUCHA (LISTENING) ======
echo.
echo Este comando listara todas las aplicaciones y servicios de tu PC
echo que mantienen puertos abiertos esperando conexiones.
echo.
pause

cls
color 0E
echo Analizando conexiones y puertos activos...
echo (Esto puede tardar unos segundos en cargar la lista de ejecutables)
echo.
echo -------------------------------------------------------------------------
echo  Proto   Direccion local        Direccion remota       Estado        PID
echo -------------------------------------------------------------------------

:: Ejecutamos netstat buscando solo las lineas que esten en escucha
:: Nota: netstat -anob agrupa el .exe en la linea de abajo, findstr /I /C:
:: nos ayuda a capturar el contexto o filtrar limpiamente.
netstat -anob | findstr /i "LISTENING [."

echo -------------------------------------------------------------------------
echo ====== Analisis de puertos finalizado ======
echo.
pause
color 0F
goto menu


:: Conexiones Activas (ESTABLISHED) --------------------------- fun6
:fun6
cls
color 0F
echo ====== MONITOR FORENSE: CONEXIONES ACTIVAS (ESTABLISHED) ======
echo.
echo Este comando listara los programas que estan transmitiendo o
echo recibiendo datos en internet o en la red local en este segundo.
echo.
pause

cls
color 0E
echo Rastreando conexiones activas en tiempo real...
echo (Esto puede tardar unos segundos en identificar los procesos)
echo.
echo -------------------------------------------------------------------------
echo  Proto   Direccion local        Direccion remota       Estado        PID
echo -------------------------------------------------------------------------

:: Ejecutamos netstat buscando solo las conexiones establecidas
:: Incluimos '[.' para capturar los nombres de los ejecutables .exe
netstat -anob | findstr /i "ESTABLISHED [."

echo -------------------------------------------------------------------------
echo ====== Monitoreo de conexiones finalizado ======
echo.
pause
color 0F
goto menu


:: Buscar y Matar Procesos ------------------------------------ fun7
:fun7
cls
color 0F
echo ====== ADMINISTRADOR DE PROCESOS / MATAR PROCESOS ======
echo.
set "proc_buscar="
set /p proc_buscar=Escribe el nombre del proceso a buscar (ej: chrome, httpd): 

cls
color 0E
echo Buscando coincidencias en el sistema...
echo -------------------------------------------------------------------------
echo Nombre de imagen               PID Nombre de sesion        Num. de sesio Uso de mem
echo ========================= ======== ======================= =========== ============

:: Ejecutamos tasklist y filtramos. Guardamos el resultado en un archivo temporal 
:: para verificar si hubo coincidencias reales.
tasklist | findstr /i "%proc_buscar%" > "%temp%\proc_result.txt"
type "%temp%\proc_result.txt"

echo -------------------------------------------------------------------------

:: Verificamos si findstr encontró algo (si el archivo temporal está vacío)
findstr "^" "%temp%\proc_result.txt" >nul
if %errorlevel% neq 0 (
    color 0C
    echo [!] No se encontraron procesos activos con el nombre: %proc_buscar%
    del "%temp%\proc_result.txt" >nul 2>&1
    echo.
    pause
    color 0F
    goto menu
)

:: Limpiamos el archivo temporal ya que confirmamos que sí hay datos
del "%temp%\proc_result.txt" >nul 2>&1

echo.
echo [?] Coincidencias encontradas.
set "confirmar="
set /p confirmar=¿Deseas finalizar (matar) alguno de estos procesos? (s/n): 

if /i "%confirmar%"=="s" (
    echo.
    set "pid_matar="
    set /p pid_matar=Ingresa el PID del proceso que quieres cerrar: 
    
    cls
    color 0C
    echo Intentando cerrar el proceso con PID %pid_matar%...
    echo.
    :: Ejecutamos taskkill con /f (forzar) y /t (cerrar procesos hijo si los hay)
    taskkill /f /t /pid %pid_matar%
    echo.
) else (
    echo.
    echo Operacion cancelada por el usuario.
    echo.
)

pause
color 0F
goto menu


:: Buscador Avanzado de Procesos (PowerShell) ----------------- fun8
:fun8
cls
color 0F
echo ====== BUSCADOR AVANZADO DE PROCESOS (PowerShell) ======
echo.
echo Aqui puedes buscar por el nombre comun de la aplicacion
echo (Ejemplo: spotify, edge, steam, discord, chrome).
echo.
set "app_buscar="
set /p app_buscar=Escribe el nombre de la aplicacion: 

cls
color 0E
echo Buscando procesos relacionados con "%app_buscar%"...
echo -------------------------------------------------------------------------
echo  PID       Nombre del .EXE        Descripcion / Nombre de App
echo -------------------------------------------------------------------------

:: Llamada segura: Una sola línea y usando $env:app_buscar para proteger espacios
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-Process | Where-Object { $_.Name -like '*'+$env:app_buscar+'*' -or $_.Description -like '*'+$env:app_buscar+'*' } | Select-Object Id, Name, Description | ForEach-Object { [PSCustomObject]@{ 'PID'=$_.Id; 'Archivo'=$_.Name + '.exe'; 'Aplicacion'=$_.Description } } | Format-Table -HideTableHeaders"

echo -------------------------------------------------------------------------
echo ====== Busqueda avanzada finalizada ======
echo.
pause
color 0F
goto menu


:: Auditoria de Tareas Programadas ----------------------------- fun9
:fun9
cls
color 0F
echo ====== AUDITORIA DE TAREAS PROGRAMADAS (PERSISTENCIA) ======
echo.
echo Este comando listara las tareas programadas en el sistema
echo omitiendo las nativas de Windows, permitiendo identificar
echo programas de terceros o scripts que se inician solos.
echo.
pause

cls
color 0E
echo Analizando el Programador de Tareas...
echo.
echo -------------------------------------------------------------------------
echo ESTADO    RUTA DE LA TAREA                          NOMBRE DE LA TAREA
echo -------------------------------------------------------------------------

:: Llamada segura a PowerShell para filtrar tareas que no pertenezcan a Microsoft
powershell -NoProfile -ExecutionPolicy Bypass -Command "Get-ScheduledTask | Where-Object { $_.TaskPath -notlike '\Microsoft*' } | Select-Object State, TaskPath, TaskName | Format-Table -HideTableHeaders"

echo -------------------------------------------------------------------------
echo ====== Analisis de persistencia finalizado ======
echo.
pause
color 0F
goto menu


:: Mensaje de Error por Opcion Invalida del Menú Principal
:error
cls
color 0C
echo INGRESE UN DATO VALIDO!
pause
goto menu


:: Error por Opcion Invalida en busqueda de archivo
:error2
cls
color 0C
echo INGRESE UN DATO VALIDO (a o b)!
pause
color 0F
goto fun2


:: Salir del programa ------------------------------------------ fun0
:fun0
cls
color 0A
echo Gracias por usar TOOL_NETWORK.
timeout /t 2 >nul
exit /b