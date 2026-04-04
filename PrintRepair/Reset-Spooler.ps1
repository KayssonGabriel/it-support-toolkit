# PrintRepair\Repair-PrintSpooler.ps1

<#
.SYNOPSIS
    Script corporativo para limpeza forcada do spooler de impressao.
#>

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Write-Warning "Acesso Negado."; Start-Sleep -Seconds 5; Exit }

# ------------------------------------------------------------------------
# FALLBACK DE LOGS (Proteção de Diretório)
# ------------------------------------------------------------------------
$BaseDir = (Get-Item $PSScriptRoot).Parent.FullName
$LogDir = Join-Path -Path $BaseDir -ChildPath "Logs"

try {
    if (-not (Test-Path -Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force -ErrorAction Stop | Out-Null }
} catch {
    $LogDir = Join-Path -Path $env:TEMP -ChildPath "IT_Toolkit_Logs"
    if (-not (Test-Path -Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
}

try { $LoggedUser = (Get-CimInstance Win32_ComputerSystem).UserName.Split('\')[-1] } catch { $LoggedUser = $env:USERNAME }
try { $ActiveIP = (Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | Select-Object -First 1).IPv4Address.IPAddress } catch { $ActiveIP = "OFFLINE" }

$Timestamp = Get-Date -Format 'ddMMyyyy_HHmmss'
$LogFile = Join-Path -Path $LogDir -ChildPath "${LoggedUser}_PrintRepair_${ActiveIP}_${Timestamp}.log"

Start-Transcript -Path $LogFile -Append -NoClobber
Write-Host "Iniciando manutencao do Spooler de Impressao..." -ForegroundColor Cyan

try {
    Write-Host "`n[1/3] Parando o servico de Spooler..." -ForegroundColor Yellow
    Stop-Service -Name Spooler -Force -WarningAction SilentlyContinue

    Write-Host "`n[2/3] Excluindo arquivos temporarios corrompidos (.SHD e .SPL)..." -ForegroundColor Yellow
    $SpoolFolder = "$env:windir\System32\spool\PRINTERS\*.*"
    Remove-Item -Path $SpoolFolder -Force -Recurse -ErrorAction SilentlyContinue

    Write-Host "`n[3/3] Reiniciando o servico de Spooler..." -ForegroundColor Yellow
    Start-Service -Name Spooler -WarningAction SilentlyContinue

    Write-Host "`nFila de impressao limpa com sucesso!" -ForegroundColor Green
}
catch { 
    Write-Error "Falha: $_" 
}
finally { 
    Stop-Transcript
    Write-Host "Log: $LogFile"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
}