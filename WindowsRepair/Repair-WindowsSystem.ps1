# \WindowsRepair\Repair-WindowsSystem.ps1

<#
.SYNOPSIS
    Script de reparo do sistema com protecao contra falhas de I/O e energia.
#>

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Write-Warning "Acesso Negado."; Start-Sleep -Seconds 5; exit 1 }

# Resolucao robusta de diretorio raiz
$BaseDir = Split-Path -Path $PSScriptRoot -Parent
$LogDir = Join-Path -Path $BaseDir -ChildPath "Logs"

try {
    if (-not (Test-Path -Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force -ErrorAction Stop | Out-Null }
} catch {
    $LogDir = Join-Path -Path $env:TEMP -ChildPath "IT_Toolkit_Logs"
    if (-not (Test-Path -Path $LogDir)) { New-Item -ItemType Directory -Path $LogDir -Force | Out-Null }
    Write-Warning "Execucao em midia restrita. Logs redirecionados para $LogDir"
}

try { $LoggedUser = (Get-CimInstance Win32_ComputerSystem).UserName.Split('\')[-1] } catch { $LoggedUser = $env:USERNAME }
try { $ActiveIP = (Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | Select-Object -First 1).IPv4Address.IPAddress } catch { $ActiveIP = "OFFLINE" }

$Timestamp = Get-Date -Format 'ddMMyyyy_HHmmss'
$LogFile = Join-Path -Path $LogDir -ChildPath "${LoggedUser}_WinRepair_${ActiveIP}_${Timestamp}.log"

Start-Transcript -Path $LogFile -Append -NoClobber
Write-Host "Iniciando reparo de integridade do Windows..." -ForegroundColor Cyan
$repairExitCode = 0

try {
    Write-Host "`n[1/3] Verificando integridade (DISM ScanHealth)..." -ForegroundColor Yellow
    DISM /Online /Cleanup-Image /ScanHealth
    if ($LASTEXITCODE -ne 0) {
        $repairExitCode = $LASTEXITCODE
        throw "DISM ScanHealth retornou o codigo $repairExitCode."
    }
    Write-Host "`n[2/3] Restaurando repositorio (DISM RestoreHealth)..." -ForegroundColor Yellow
    DISM /Online /Cleanup-Image /RestoreHealth
    if ($LASTEXITCODE -eq 3010) {
        $repairExitCode = $LASTEXITCODE
        Write-Warning "Reinicie o Windows e execute o reparo novamente para concluir o SFC."
        exit $repairExitCode
    }
    if ($LASTEXITCODE -ne 0) {
        $repairExitCode = $LASTEXITCODE
        throw "DISM RestoreHealth retornou o codigo $repairExitCode."
    }
    Write-Host "`n[3/3] Corrigindo arquivos protegidos (SFC ScanNow)..." -ForegroundColor Yellow
    sfc /scannow
    if ($LASTEXITCODE -ne 0) {
        $repairExitCode = $LASTEXITCODE
        throw "SFC retornou o codigo $repairExitCode."
    }
    Write-Host "`nProcesso concluido com sucesso!" -ForegroundColor Green
}
catch {
    if ($repairExitCode -eq 0) {
        $repairExitCode = 1
    }
    Write-Error "Falha critica: $_" -ErrorAction Continue
}
finally { 
    Stop-Transcript
    Write-Host "`nLog gerado em: $LogFile" -ForegroundColor White
    Write-Host "Pressione qualquer tecla para sair..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
exit $repairExitCode