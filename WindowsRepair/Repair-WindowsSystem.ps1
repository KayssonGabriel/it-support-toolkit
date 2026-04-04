# WindowsRepair\Repair-WindowsSystem.ps1

<#
.SYNOPSIS
    Script de reparo do sistema com proteção contra falhas de I/O e energia.
#>

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Write-Warning "Acesso Negado."; Start-Sleep -Seconds 5; Exit }

# ------------------------------------------------------------------------
# FALLBACK DE LOGS (Proteção contra unidades Somente-Leitura)
# ------------------------------------------------------------------------
$BaseDir = (Get-Item $PSScriptRoot).Parent.FullName
$LogDir = Join-Path -Path $BaseDir -ChildPath "Logs"

try {
    if (-not (Test-Path -Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force -ErrorAction Stop | Out-Null }
} catch {
    # Se falhar (ex: PenDrive bloqueado), grava os logs na pasta temp local do Windows
    $LogDir = Join-Path -Path $env:TEMP -ChildPath "IT_Toolkit_Logs"
    if (-not (Test-Path -Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
    Write-Warning "Execução em mídia restrita. Logs redirecionados para $LogDir"
}

# Coleta de Metadados
try { $LoggedUser = (Get-CimInstance Win32_ComputerSystem).UserName.Split('\')[-1] } catch { $LoggedUser = $env:USERNAME }
try { $ActiveIP = (Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | Select-Object -First 1).IPv4Address.IPAddress } catch { $ActiveIP = "OFFLINE" }

$Timestamp = Get-Date -Format 'ddMMyyyy_HHmmss'
$LogFile = Join-Path -Path $LogDir -ChildPath "${LoggedUser}_WinRepair_${ActiveIP}_${Timestamp}.log"

Start-Transcript -Path $LogFile -Append -NoClobber
Write-Host "Iniciando reparo de integridade do Windows..." -ForegroundColor Cyan

# ------------------------------------------------------------------------
# EXECUÇÃO SEGURA
# ------------------------------------------------------------------------
try {
    Write-Host "`n[1/3] Verificando integridade (DISM ScanHealth)..." -ForegroundColor Yellow
    DISM /Online /Cleanup-Image /ScanHealth
    
    Write-Host "`n[2/3] Restaurando repositório (DISM RestoreHealth)..." -ForegroundColor Yellow
    DISM /Online /Cleanup-Image /RestoreHealth
    
    Write-Host "`n[3/3] Corrigindo arquivos protegidos (SFC ScanNow)..." -ForegroundColor Yellow
    sfc /scannow
    
    Write-Host "`nProcesso concluído com sucesso!" -ForegroundColor Green
}
catch { 
    Write-Error "Falha crítica: $_" 
}
finally { 
    Stop-Transcript
    Write-Host "`nLog gerado em: $LogFile" -ForegroundColor White
    Write-Host "Pressione qualquer tecla para sair..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
}