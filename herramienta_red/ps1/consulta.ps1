[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]$RutaDB,

    [Parameter(Mandatory=$true)]
    [string]$Termino
)

# Obtener la ruta del ejecutable sqlite3.exe al lado de este script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SqliteExe = Join-Path $ScriptDir "sqlite3.exe"

if (-not (Test-Path $SqliteExe)) {
    Write-Host "[!] ERROR CRÍTICO: No se encuentra 'sqlite3.exe' en la carpeta 'ps1'." -ForegroundColor Red
    return
}

# Queries SQL limpias
# Escapar comillas simples para evitar errores de sintaxis en SQLite
$TerminoEscapado = $Termino -replace "'", "''"

$CountQuery = "SELECT COUNT(*) FROM urls WHERE url LIKE '%$TerminoEscapado%' OR title LIKE '%$TerminoEscapado%';"
$DataQuery  = "SELECT title, url, datetime((last_visit_time/1000000)-11644473600, 'unixepoch', 'localtime') FROM urls WHERE url LIKE '%$TerminoEscapado%' OR title LIKE '%$TerminoEscapado%' ORDER BY last_visit_time DESC LIMIT 20;"

try {
    $TotalCoincidencias = & $SqliteExe $RutaDB $CountQuery
    $TotalCoincidencias = [int]$TotalCoincidencias.Trim()

    if ($TotalCoincidencias -eq 0) {
        Write-Host "[!] No se encontraron coincidencias para: '$Termino'" -ForegroundColor Yellow
        return
    }

    if ($TotalCoincidencias -gt 20) {
        Write-Host "[!] Se encontraron $TotalCoincidencias conexiones." -ForegroundColor Yellow
        Write-Host "[i] Mostrando las 20 más recientes. Para mayor precisión, sé más específico.`n" -ForegroundColor Cyan
    } else {
        Write-Host "[OK] Se encontraron $TotalCoincidencias coincidencias:`n" -ForegroundColor Green
    }

    $RawData = & $SqliteExe -csv $RutaDB $DataQuery

    $RawData = & $SqliteExe -csv $RutaDB $DataQuery

    # --- NUEVO: Configuración del archivo de exportación en el Escritorio ---
    $FechaActual = (Get-Date).ToString("yyyy-MM-dd")
    $NumRandom   = Get-Random -Minimum 1000 -Maximum 9999
    $RutaEscritorio = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "busqueda_web_resultado_${FechaActual}_${NumRandom}.txt")

    # Encabezado inicial para el archivo de texto limpio
    "====== REPORTE DE BÚSQUEDA DE HISTORIAL ======" | Out-File -FilePath $RutaEscritorio -Encoding utf8
    "Término buscado: '$Termino'" | Out-File -FilePath $RutaEscritorio -Append -Encoding utf8
    "Fecha de reporte: $(Get-Date)" | Out-File -FilePath $RutaEscritorio -Append -Encoding utf8
    "-------------------------------------------------------------------------`n" | Out-File -FilePath $RutaEscritorio -Append -Encoding utf8
    # ------------------------------------------------------------------------

    $ResultadoFormateado = $RawData | ConvertFrom-Csv -Header "Titulo","URL","Fecha" | ForEach-Object {
        $MaxLen = 45
        
        $TxtTitulo = $_.Titulo
        # Corrección del orden de validación nula
        if (-not $TxtTitulo) { $TxtTitulo = "[Sin Titulo]" }
        
        # --- Tu bloque de comentario modificado con la lógica de exportación ---
        if ($TxtTitulo.Length -gt $MaxLen) { 
            # Exportar a escritorio los datos COMPLETOS (sin recortar) de esta coincidencia
            $LineaReporte = "FECHA: $($_.Fecha)`nTÍTULO: $($_.Titulo)`nURL: $($_.URL)`n"
            $LineaReporte | Out-File -FilePath $RutaEscritorio -Append -Encoding utf8
            "-------------------------------------------------------------------------" | Out-File -FilePath $RutaEscritorio -Append -Encoding utf8

            $TxtTitulo = $TxtTitulo.Substring(0, $MaxLen-3) + "..." 
        } else {
            # Opcional: Si el título no mide más de 45 caracteres pero igual quieres que se guarde en el TXT, lo agregamos aquí
            $LineaReporte = "FECHA: $($_.Fecha)`nTÍTULO: $TxtTitulo`nURL: $($_.URL)`n"
            $LineaReporte | Out-File -FilePath $RutaEscritorio -Append -Encoding utf8
            "-------------------------------------------------------------------------" | Out-File -FilePath $RutaEscritorio -Append -Encoding utf8
        }

        $TxtURL = $_.URL
        if ($TxtURL.Length -gt $MaxLen) { $TxtURL = $TxtURL.Substring(0, $MaxLen-3) + "..." }

        [PSCustomObject]@{
            "FECHA DE VISITA" = $_.Fecha
            "TITULO PAGINA"   = $TxtTitulo
            "URL ACCEDIDA"    = $TxtURL
        }
    }

    # Imprimir la tabla perfectamente alineada en la consola (formato recortado)
    $ResultadoFormateado | Format-Table -AutoSize
    
    # Avisar al usuario en la consola que se generó el archivo completo
    Write-Host "`n[i] Se ha exportado el reporte completo con URLs largas en:" -ForegroundColor Cyan
    Write-Host "    $RutaEscritorio" -ForegroundColor Cyan

} catch {
    Write-Host "[!] Error al procesar la base de datos: $_" -ForegroundColor Red
}