# NetworkRepair\Repair-NetworkStack.ps1

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Write-Warning "Acesso Negado."; Start-Sleep -Seconds 5; Exit }

# Resolucao Dinamica de Diretorio
$BaseDir = (Get-Item $PSScriptRoot).Parent.FullName
$LogDir = Join-Path -Path $BaseDir -ChildPath "Logs"
if (-not (Test-Path -Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }

try {
    $RawUser = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
    if (-not [string]::IsNullOrWhiteSpace($RawUser)) { $LoggedUser = $RawUser.Split('\')[-1] } else { $LoggedUser = $env:USERNAME }
} catch { $LoggedUser = $env:USERNAME }
if ([string]::IsNullOrWhiteSpace($LoggedUser)) { $LoggedUser = "UnknownUser" }

try { $ActiveIP = (Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | Select-Object -First 1).IPv4Address.IPAddress } catch { $ActiveIP = $null }
if ([string]::IsNullOrWhiteSpace($ActiveIP)) { $ActiveIP = "OFFLINE" }

$ActionName = "FlushDNS-Netsh"
$Timestamp = Get-Date -Format 'ddMMyyyy_HHmmss'
$LogFile = "$LogDir\${LoggedUser}_${ActionName}_${ActiveIP}_${Timestamp}.log"

Start-Transcript -Path $LogFile -Append -NoClobber
Write-Host "Iniciando redefinicao da pilha de rede..." -ForegroundColor Cyan

try {
    Write-Host "`n[1/4] Limpando Cache DNS..." -ForegroundColor Yellow
    Clear-DnsClientCache
    Write-Host "`n[2/4] Forcando registro DNS..." -ForegroundColor Yellow
    ipconfig /registerdns | Out-Null
    Write-Host "`n[3/4] Renovando IP..." -ForegroundColor Yellow
    ipconfig /release | Out-Null
    ipconfig /renew | Out-Null
    Write-Host "`n[4/4] Redefinindo Winsock e TCP/IP..." -ForegroundColor Yellow
    netsh winsock reset | Out-Null
    netsh int ip reset | Out-Null
    Write-Host "`nManutencao concluida! REINICIALIZACAO OBRIGATORIA." -ForegroundColor Red
}
catch { Write-Error "Falha: $_" }
finally { Stop-Transcript; $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") }