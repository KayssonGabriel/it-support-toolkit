# \ADPolicySync\Sync-ADPolicy.ps1

<#
.SYNOPSIS
    Script para atualizacao forcada de GPO e limpeza de tickets Kerberos.
#>

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Write-Warning "Acesso Negado."; Start-Sleep -Seconds 5; Exit }

$BaseDir = Split-Path -Path $PSScriptRoot -Parent
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
$LogFile = Join-Path -Path $LogDir -ChildPath "${LoggedUser}_ADSync_${ActiveIP}_${Timestamp}.log"

Start-Transcript -Path $LogFile -Append -NoClobber
Write-Host "Iniciando sincronizacao com Active Directory..." -ForegroundColor Cyan

try {
    Write-Host "`n[1/2] Expurgando tickets Kerberos (klist purge)..." -ForegroundColor Yellow
    klist purge | Out-Null

    Write-Host "`n[2/2] Forcando atualizacao de Politicas de Grupo (gpupdate /force)..." -ForegroundColor Yellow
    "N" | gpupdate /force

    Write-Host "`nSincronizacao de dominio concluida!" -ForegroundColor Green
    Write-Host "Caso o problema persista, peca ao usuario para bloquear (Win+L) e desbloquear a tela." -ForegroundColor White
}
catch { 
    Write-Error "Falha: $_" 
}
finally { 
    Stop-Transcript
    Write-Host "`nLog: $LogFile"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
}