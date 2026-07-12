# Tool_Network

### *Tool_Network es un conjunto de herramientas portables diseñadas para realizar auditorías de red y seguridad básicas en sistemas Windows. El proyecto utiliza un menú interactivo en Batch que actúa como interfaz para scripts avanzados en PowerShell, permitiendo realizar análisis rápidos sin necesidad de instalaciones previas ni configuraciones complejas.*

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

![img_1]()


![img_2]()


![img_3]()

