# C:\IT_Scripts\NetworkRepair\Repair-NetworkStack.ps1

<#
.SYNOPSIS
    Script de manutencao de rede focado em DNS.
.DESCRIPTION
    Realiza apenas a limpeza de cache e registros DNS. 
    Seguro para maquinas com IP fixo ou configuracoes especificas de roteamento.
#>

# 1. Validacao de Privilegios
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { 
    Write-Warning "Acesso Negado. Execute como Administrador."
    Start-Sleep -Seconds 5
    Exit 
}

# 2. Resolucao Dinamica de Diretorio
$BaseDir = (Get-Item $PSScriptRoot).Parent.FullName
$LogDir = Join-Path -Path $BaseDir -ChildPath "Logs"
if (-not (Test-Path -Path $LogDir)) { 
    New-Item -ItemType Directory -Path $LogDir -Force | Out-Null 
}

# 3. Coleta de Metadados para o Log (Auditoria Senior)
try {
    $RawUser = (Get-CimInstance -ClassName Win32_ComputerSystem).UserName
    if (-not [string]::IsNullOrWhiteSpace($RawUser)) { 
        $LoggedUser = $RawUser.Split('\')[-1] 
    } else { 
        $LoggedUser = $env:USERNAME 
    }
} catch { 
    $LoggedUser = $env:USERNAME 
}

try { 
    $ActiveIP = (Get-NetIPConfiguration | Where-Object { $_.IPv4DefaultGateway -ne $null } | Select-Object -First 1).IPv4Address.IPAddress 
} catch { 
    $ActiveIP = "OFFLINE" 
}

# 4. Configuracao do Log
$ActionName = "SafeDNS-Maintenance"
$Timestamp = Get-Date -Format 'ddMMyyyy_HHmmss'
$LogFile = Join-Path -Path $LogDir -ChildPath "${LoggedUser}_${ActionName}_${ActiveIP}_${Timestamp}.log"

# 5. Execucao da Logica de Manutencao
Start-Transcript -Path $LogFile -Append -NoClobber
Write-Host "Iniciando manutencao segura de DNS..." -ForegroundColor Cyan

try {
    # Etapa 1: Limpeza do Cache DNS
    Write-Host "`n[1/2] Limpando Cache DNS..." -ForegroundColor Yellow
    Clear-DnsClientCache
    
    # Etapa 2: Registro de DNS (Atualiza o nome da maquina no servidor da empresa)
    Write-Host "`n[2/2] Forcando registro DNS..." -ForegroundColor Yellow
    ipconfig /registerdns | Out-Null

    Write-Host "`nManutencao concluida com sucesso!" -ForegroundColor Green
    Write-Host "Nenhuma configuracao de interface foi alterada." -ForegroundColor White
}
catch { 
    Write-Error "Falha durante o processo: $_" 
}
finally { 
    Stop-Transcript
    Write-Host "`nLog salvo em: $LogFile" -ForegroundColor Cyan
    Write-Host "Pressione qualquer tecla para sair..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
}