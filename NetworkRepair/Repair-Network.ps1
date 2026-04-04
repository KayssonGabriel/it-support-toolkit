# \NetworkRepair\Repair-NetworkStack.ps1

<#
.SYNOPSIS
    Script de rede restrito e seguro (Apenas Limpeza DNS).
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
$LogFile = Join-Path -Path $LogDir -ChildPath "${LoggedUser}_NetSafe_${ActiveIP}_${Timestamp}.log"

Start-Transcript -Path $LogFile -Append -NoClobber
Write-Host "Iniciando limpeza de DNS (Modo Seguro)..." -ForegroundColor Cyan

try {
    Write-Host "`n[1/2] Limpando Cache DNS..." -ForegroundColor Yellow
    Clear-DnsClientCache
    
    Write-Host "`n[2/2] Forcando registro DNS..." -ForegroundColor Yellow
    ipconfig /registerdns | Out-Null

    Write-Host "`nManutencao concluida! Configuracoes de rede preservadas." -ForegroundColor Green
}
catch { 
    Write-Error "Falha: $_" 
}
finally { 
    Stop-Transcript
    Write-Host "`nLog: $LogFile"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
}