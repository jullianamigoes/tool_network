# Tool_Network

*Tool_Network es un conjunto de herramientas portables diseñadas para realizar auditorías de red y seguridad básicas en sistemas Windows.
Funciona como Suite de Auditoría de Red Local, Análisis de Procesos y Recolección de Evidencias (Triage).
El proyecto utiliza un menú interactivo en Batch que actúa como interfaz para scripts avanzados en PowerShell, permitiendo realizar análisis rápidos sin necesidad de instalaciones previas ni configuraciones complejas.*

---

## Funcionalidades Principales

Este script centraliza tareas comunes de diagnóstico y auditoría en un solo lugar:

* ***Conectividad:*** Verificación de red mediante ping.

* ***Gestión de Archivos:*** Localización de rutas y extracción/actualización de historiales para análisis.

* ***Análisis de Datos:*** Consultas SQL sobre historiales (vía integración con SQLite).

* ***Auditoría de Red:*** Detección de puertos en escucha (LISTENING) y conexiones establecidas (ESTABLISHED).

* ***Gestión de Procesos:*** Visualización y terminación de procesos activos, incluyendo búsqueda avanzada por nombre.

* ***Persistencia:*** Auditoría de tareas programadas para identificar posibles riesgos.


---


## Características

- **Portable:** Incluye todos los ejecutables necesarios (sqlite.exe) en la carpeta /ps1.

- **Rápido:** Diseñado para ejecutarse directamente desde la terminal (cmd) con privilegios de administrador.

- **Cero dependencias:** No requiere instalación de software externo ni entornos de desarrollo complejos.


---


## Requisitos

 - ***Sistema operativo:*** **Windows (10/11) x64.**


---


## Estructura del Proyecto

```text
herramienta_red/
├── tool_network.bat   # Interfaz principal
├── ps1/
    ├── script.ps1     # Lógica de procesamiento para consulta SQL
    └── sqlite.exe     # Motor para consultas SQL
```

---


## Cómo utilizarlo

1. Descarga o clona este repositorio.
2. Descomprimir (en caso de descargar) / ingresa al directorio herramienta_red y haz **doble clic** en ***tool_network.bat***

### OJO, el archivo tool_network.bat al abrir te pedira confirmar su ejecución como "administrador".

---

## Imágenes

![img_1](https://github.com/jullianamigoes/assets_proj/blob/main/assets/tool_network_img/herramienta.png)


![img_2](https://github.com/jullianamigoes/assets_proj/blob/main/assets/tool_network_img/power_sql.png)


![img_3](https://github.com/jullianamigoes/assets_proj/blob/main/assets/tool_network_img/menu.png)


## Al seleccionar la opción 3 se **creará** un directorio llamado ***historial_navegacion*** 

![img_4](https://github.com/jullianamigoes/assets_proj/blob/main/assets/tool_network_img/dir_creado.png)


## Dentro del directorio creado se encontrará la copia del archivo de base de datos ***Chrome_History.db***

- Cada vez que se realice una consulta al historial de navegaci+on con la **opción 4**, se ejecurará el script ***consulta.ps1*** que se encargará de conectar con sqlite.exe y realizar la consulta al archivo copiado.

![img_5](https://github.com/jullianamigoes/assets_proj/blob/main/assets/tool_network_img/db_copy.png)

