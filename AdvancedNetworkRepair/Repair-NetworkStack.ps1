# \AdvancedNetworkRepair\Repair-NetworkStack.ps1

<#
.SYNOPSIS
    Redefinicao profunda da pilha TCP/IP e Winsock com Backup previo.
.DESCRIPTION
    ALERTA: Script destrutivo. Remove configuracoes de IP estatico e pode quebrar softwares de VPN.
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

# ------------------------------------------------------------------------
# TRAVA DE SEGURANCA (UX e Consentimento)
# ------------------------------------------------------------------------
Clear-Host
Write-Host "===============================================================" -ForegroundColor Red
Write-Host " ATENCAO: MANUTENCAO AVANCADA DE REDE " -ForegroundColor Yellow
Write-Host "===============================================================" -ForegroundColor Red
Write-Host "Este script executara uma redefinicao agressiva na placa de rede."
Write-Host "`nRiscos Envolvidos:"
Write-Host "- IPs Estaticos (Fixos) serao apagados."
Write-Host "- Conexoes de VPN corporativas podem parar de funcionar."
Write-Host "===============================================================" -ForegroundColor Red
Write-Host "COMANDOS QUE SERAO EXECUTADOS:" -ForegroundColor Cyan
Write-Host "1. ipconfig /release         (Libera concessao DHCP)"
Write-Host "2. ipconfig /renew           (Renova concessao DHCP)"
Write-Host "3. Clear-DnsClientCache      (Limpa cache DNS)"
Write-Host "4. ipconfig /registerdns     (Registra DNS no AD)"
Write-Host "5. netsh winsock reset       (Reseta catalogo de sockets)"
Write-Host "6. netsh int ip reset        (Reseta pilha TCP/IP)"
Write-Host "===============================================================" -ForegroundColor Red

$Confirm = Read-Host "Deseja prosseguir com o reset profundo? (S/N)"
if ($Confirm -notmatch "^[Ss]$") {
    Write-Host "`nOperacao cancelada. Nenhuma alteracao foi feita." -ForegroundColor Green
    Start-Sleep -Seconds 3
    Exit
}

# ------------------------------------------------------------------------
# EXECUCAO DE BACKUP E REPARO
# ------------------------------------------------------------------------
$LogFile = Join-Path -Path $LogDir -ChildPath "${LoggedUser}_AdvNetRepair_${ActiveIP}_${Timestamp}.log"
Start-Transcript -Path $LogFile -Append -NoClobber

Write-Host "`nIniciando redefinicao PROFUNDA da pilha de rede..." -ForegroundColor Red

try {
    # 1. BACKUP DE ESTADO (A sua sugestao genial aplicada)
    Write-Host "`n[1/5] Gerando backup das configuracoes de IP atuais..." -ForegroundColor Yellow
    $BackupFile = Join-Path -Path $LogDir -ChildPath "${LoggedUser}_IPBackup_${ActiveIP}_${Timestamp}.txt"
    ipconfig /all | Out-File -FilePath $BackupFile -Encoding UTF8
    Write-Host "Backup de IP salvo em: $BackupFile" -ForegroundColor Cyan

    Write-Host "`n[2/5] Liberando e Renovando concessao IP (Release/Renew)..." -ForegroundColor Yellow
    ipconfig /release | Out-Null
    ipconfig /renew | Out-Null

    Write-Host "`n[3/5] Limpando Cache e re-registrando DNS..." -ForegroundColor Yellow
    Clear-DnsClientCache
    ipconfig /registerdns | Out-Null

    Write-Host "`n[4/5] Redefinindo Winsock (Remove filtros de terceiros/VPNs)..." -ForegroundColor Yellow
    netsh winsock reset | Out-Null

    Write-Host "`n[5/5] Redefinindo Pilha TCP/IP..." -ForegroundColor Yellow
    netsh int ip reset | Out-Null

    Write-Host "`nMANUTENCAO AVANCADA CONCLUIDA." -ForegroundColor Red
    Write-Host "ATENCAO: E OBRIGATORIO REINICIAR O COMPUTADOR." -ForegroundColor White
}
catch { 
    Write-Error "Falha critica: $_" 
}
finally { 
    Stop-Transcript
    Write-Host "`nLog e Backup salvos em: $LogDir"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
}