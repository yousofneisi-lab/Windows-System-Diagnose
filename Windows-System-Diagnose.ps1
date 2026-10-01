
<#
====================================================================
 Autor: Yousof Neisi (neisitech.de)
 Skript: Windows-System-Diagnose.ps1
 Beschreibung: Interaktives Menü zur Systemdiagnose & Berichtserstellung
====================================================================
#>

function Show-Header {
    Clear-Host
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "  Autor: Yousof Neisi (neisitech.de)              " -ForegroundColor Yellow
    Write-Host "==================================================" -ForegroundColor Cyan
    Write-Host "  Windows - WINDOWS SYSTEM DIAGNOSE REPORT        " -ForegroundColor Green
    Write-Host "==================================================" -ForegroundColor Cyan
}

function Get-HardwareInfo {
    Show-Header
    Write-Host "`n[ 1. HARDWARE & SYSTEMINFORMATIONEN ]" -ForegroundColor Yellow
    
    $OS = Get-CimInstance Win32_OperatingSystem$CPU = Get-CimInstance Win32_Processor
    $Uptime = (Get-Date) -$OS.LastBootUpTime

    $RAM_Total = [math]::Round($OS.TotalVisibleMemorySize / 1MB, 2)
    $RAM_Free  = [math]::Round($OS.FreePhysicalMemory / 1MB, 2)

    Write-Host "Computer Name : $env:COMPUTERNAME"
    Write-Host "Betriebssystem: $($OS.Caption) ($($OS.OSArchitecture))"
    Write-Host "Prozessor     : $($CPU.Name)"
    Write-Host "RAM Gesamt    : $RAM_Total GB"
    Write-Host "RAM Frei      : $RAM_Free GB"
    Write-Host "Systemlaufzeit: $($Uptime.Days) Tage, $($Uptime.Hours) Stunden"
}

function Get-DiskInfo {
    Show-Header
    Write-Host "`n[ 2. SPEICHERPLATZ-ANALYSE ]" -ForegroundColor Yellow
    
    Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | ForEach-Object {
        $FreeGB = [math]::Round($_.FreeSpace / 1GB, 2)
        $TotalGB = [math]::Round($_.Size / 1GB, 2)
        $UsedGB = [math]::Round(($_.Size - $_.FreeSpace) / 1GB, 2)
        
        Write-Host "Laufwerk $($_.DeviceID)" -ForegroundColor Cyan
        Write-Host "  Gesamtkapazität: $TotalGB GB"
        Write-Host "  Belegt         : $UsedGB GB"
        Write-Host "  Frei           : $FreeGB GB"
    }
}

function Get-NetworkInfo {
    Show-Header
    Write-Host "`n[ 3. NETZWERK-STATUS ]" -ForegroundColor Yellow
    
    Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" } | ForEach-Object {
        Write-Host "Schnittstelle: $($_.InterfaceAlias)" -ForegroundColor Cyan
        Write-Host "  IPv4-Adresse: $($_.IPAddress)"
    }
}

function Export-FullReport {
    Show-Header
    Write-Host "`n[ 4. BERICHT ERSTELLEN ]" -ForegroundColor Yellow
    
    $DesktopPath = [Environment]::GetFolderPath("Desktop")
    $ReportPath = "$DesktopPath\SystemReport_$env:COMPUTERNAME.txt"
    
    Write-Host "Erstelle Bericht auf dem Desktop..." -ForegroundColor Yellow
    
    $ReportContent = @"
==================================================
 Autor: Yousof Neisi (neisitech.de)
 Windows - WINDOWS SYSTEM DIAGNOSE REPORT
 Datum: $(Get-Date -Format "dd.MM.yyyy HH:mm:ss")
==================================================

[ SYSTEMINFO ]
Computer: $env:COMPUTERNAME
OS: $((Get-CimInstance Win32_OperatingSystem).Caption)
CPU: $((Get-CimInstance Win32_Processor).Name)

[ LAUFWERKE ]
$(Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3" | Out-String)

[ NETZWERK ]
$(Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" } | Select-Object InterfaceAlias, IPAddress | Out-String)
"@

    $ReportContent | Out-File -FilePath $ReportPath -Encoding utf8
    Write-Host "Bericht erfolgreich gespeichert unter:`n$ReportPath" -ForegroundColor Green
}

while ($true) {
    Show-Header
    Write-Host "`nBitte wähle eine Option aus:"
    Write-Host "1) Hardware & Systeminfo anzeigen"
    Write-Host "2) Speicherplatz prüfen"
    Write-Host "3) Netzwerkkonfiguration anzeigen"
    Write-Host "4) Vollständigen Bericht als Textdatei exportieren"
    Write-Host "5) Beenden"
    Write-Host "=================================================="

    $choice = Read-Host "Auswahl (1-5)"

    switch ($choice) {
        "1" { Get-HardwareInfo; Pause }
        "2" { Get-DiskInfo; Pause }
        "3" { Get-NetworkInfo; Pause }
        "4" { Export-FullReport; Pause }
        "5" { 
            Write-Host "`nBeende Skript..." -ForegroundColor Yellow
            Start-Sleep -Seconds 1
            return 
        }
        default { 
            Write-Host "Ungültige Eingabe!" -ForegroundColor Red
            Start-Sleep -Seconds 1 
        }
    }
}


