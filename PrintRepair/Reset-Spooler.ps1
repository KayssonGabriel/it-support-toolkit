# PrintRepair\Reset-Spooler.ps1

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

$ActionName = "Reset-Spooler"
$Timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$LogFile = "$LogDir\${LoggedUser}_${ActionName}_${ActiveIP}_${Timestamp}.log"

Start-Transcript -Path $LogFile -Append -NoClobber
Write-Host "Iniciando reset do Spooler de Impressao..." -ForegroundColor Cyan

try {
    Write-Host "`n[1/3] Parando servico de Spooler..." -ForegroundColor Yellow
    Stop-Service -Name Spooler -Force
    Write-Host "`n[2/3] Excluindo arquivos retidos..." -ForegroundColor Yellow
    Remove-Item -Path "$env:windir\System32\spool\PRINTERS\*.*" -Force -Recurse -ErrorAction SilentlyContinue
    Write-Host "`n[3/3] Reiniciando servico..." -ForegroundColor Yellow
    Start-Service -Name Spooler
    Write-Host "`nFila de impressao limpa com sucesso!" -ForegroundColor Green
}
catch { Write-Error "Falha critica: $_" }
finally { Stop-Transcript; $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") }