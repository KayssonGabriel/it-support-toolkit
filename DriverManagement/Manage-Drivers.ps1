# \DriverManagement\Manage-Drivers.ps1

<#
.SYNOPSIS
    Gerenciador interativo de Backup e Restauracao de Drivers com auditoria e organizacao automatica de pastas.
#>

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Write-Warning "Acesso Negado."; Start-Sleep -Seconds 5; Exit }

# ------------------------------------------------------------------------
# SETUP DE LOGS E METADADOS
# ------------------------------------------------------------------------
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
$LogFile = Join-Path -Path $LogDir -ChildPath "${LoggedUser}_Drivers_${ActiveIP}_${Timestamp}.log"

Start-Transcript -Path $LogFile -Append -NoClobber

# ------------------------------------------------------------------------
# MENU INTERATIVO
# ------------------------------------------------------------------------
while ($true) {
    Clear-Host
    Write-Host "=======================================================" -ForegroundColor Cyan
    Write-Host "     GERENCIADOR DE DRIVERS (BACKUP E RESTAURACAO)     " -ForegroundColor White
    Write-Host "=======================================================" -ForegroundColor Cyan
    Write-Host "`n  [1] Fazer Backup dos Drivers Atuais"
    Write-Host "  [2] Restaurar Drivers de um Backup"
    Write-Host "  [0] Sair"
    
    $Opcao = Read-Host "`n  Escolha uma opcao"

    if ($Opcao -eq "1") {
        Write-Host "`n--- BACKUP DE DRIVERS ---" -ForegroundColor Yellow
        $DestinoRaiz = Read-Host "Informe a pasta base para salvar o backup (Ex: C:\IT_Scripts)"
        
        if ([string]::IsNullOrWhiteSpace($DestinoRaiz)) { continue }
        
        # ARQUITETURA LIMPA: Criacao automatica de subpasta (Isolamento de Arquivos)
        $PastaDrivers = Join-Path -Path $DestinoRaiz -ChildPath "DriversBackup_$Timestamp"
        
        if (-not (Test-Path -Path $PastaDrivers)) { 
            New-Item -ItemType Directory -Path $PastaDrivers -Force | Out-Null 
        }

        Write-Host "`n[INFO] Organizando pasta: $PastaDrivers" -ForegroundColor Gray
        Write-Host "[INFO] Extraindo drivers do sistema... (Isso pode levar alguns minutos)" -ForegroundColor Cyan
        
        $DismProcess = Start-Process -FilePath "dism.exe" -ArgumentList "/online /export-driver /destination:`"$PastaDrivers`"" -Wait -NoNewWindow -PassThru
        
        if ($DismProcess.ExitCode -eq 0) {
            Write-Host "`n[SUCESSO] Backup concluido de forma limpa em: $PastaDrivers" -ForegroundColor Green
        } else {
            Write-Warning "`n[ERRO] Ocorreu uma falha durante o processo."
        }
        
        $null = Read-Host "`nPressione ENTER para voltar ao menu..."
    }
    elseif ($Opcao -eq "2") {
        Write-Host "`n--- RESTAURACAO DE DRIVERS ---" -ForegroundColor Yellow
        Write-Host "AVISO: A tela pode piscar durante a instalacao dos drivers de video." -ForegroundColor Red
        
        # Alterado o texto para orientar o usuario a escolher a pasta criada no passo 1
        $Origem = Read-Host "Informe o caminho da pasta DriversBackup (Ex: C:\IT_Scripts\DriversBackup_08042026_153000)"
        
        if ([string]::IsNullOrWhiteSpace($Origem)) { continue }
        
        if (-not (Test-Path -Path $Origem)) {
            Write-Warning "`n[ERRO] O diretorio informado nao existe!"
            $null = Read-Host "Pressione ENTER para voltar..."
            continue
        }

        Write-Host "`n[INFO] Injetando e instalando drivers..." -ForegroundColor Cyan
        
        Start-Process -FilePath "pnputil.exe" -ArgumentList "/add-driver `"$Origem\*.inf`" /subdirs /install" -Wait -NoNewWindow
        
        Write-Host "`n[SUCESSO] Processo finalizado! Reinicie o computador se necessario." -ForegroundColor Green
        $null = Read-Host "`nPressione ENTER para voltar ao menu..."
    }
    elseif ($Opcao -eq "0") {
        Write-Host "`nSaindo e salvando log..." -ForegroundColor Cyan
        break
    }
}

# ------------------------------------------------------------------------
# ENCERRAMENTO
# ------------------------------------------------------------------------
Stop-Transcript
Write-Host "`nAuditoria salva em: $LogFile"
Start-Sleep -Seconds 3