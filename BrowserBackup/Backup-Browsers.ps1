# \BrowserBackup\Backup-Browsers.ps1

<#
.SYNOPSIS
    Gerenciador interativo de Backup e Restauracao de Favoritos de Navegadores (Edge e Chrome).
#>

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) { Write-Warning "Acesso Negado."; Start-Sleep -Seconds 5; Exit }

# ------------------------------------------------------------------------
# SETUP DE LOGS (Padrao do Toolkit)
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
$LogFile = Join-Path -Path $LogDir -ChildPath "${LoggedUser}_Browsers_${ActiveIP}_${Timestamp}.log"

Start-Transcript -Path $LogFile -Append -NoClobber

# ------------------------------------------------------------------------
# FUNCAO: Obter Lista de Navegadores
# ------------------------------------------------------------------------
function Obter-NavegadoresSelecionados ($Mensagem) {
    Write-Host "`n--- $Mensagem ---" -ForegroundColor Yellow
    Write-Host "  [1] Apenas Google Chrome"
    Write-Host "  [2] Apenas Microsoft Edge"
    Write-Host "  [3] Ambos (Chrome e Edge)"
    Write-Host "  [0] Voltar"
    
    $Escolha = Read-Host "`n  Selecione os navegadores alvo"
    
    $ListaNavs = @()
    if ($Escolha -eq "1" -or $Escolha -eq "3") {
        $ListaNavs += @{ Nome = "Chrome"; Caminho = "$env:LOCALAPPDATA\Google\Chrome\User Data" }
    }
    if ($Escolha -eq "2" -or $Escolha -eq "3") {
        $ListaNavs += @{ Nome = "Edge"; Caminho = "$env:LOCALAPPDATA\Microsoft\Edge\User Data" }
    }
    
    return $ListaNavs
}

# ------------------------------------------------------------------------
# MENU INTERATIVO PRINCIPAL
# ------------------------------------------------------------------------
while ($true) {
    Clear-Host
    Write-Host "=======================================================" -ForegroundColor Cyan
    Write-Host "       GERENCIADOR DE NAVEGADORES (FAVORITOS)          " -ForegroundColor White
    Write-Host "=======================================================" -ForegroundColor Cyan
    Write-Host "`n  [1] Fazer Backup de Favoritos"
    Write-Host "  [2] Restaurar Favoritos de um Backup"
    Write-Host "  [0] Sair"
    
    $Opcao = Read-Host "`n  Escolha uma opcao"

    if ($Opcao -eq "1") {
        # Chama a funcao de sub-menu e retorna apenas os navegadores escolhidos
        $NavsAlvo = Obter-NavegadoresSelecionados "ESCOLHA DO NAVEGADOR"
        
        # Se o usuario escolheu 0 (Voltar) ou valor invalido, a lista volta vazia
        if ($NavsAlvo.Count -eq 0) { continue }
        
        $DestinoRaiz = Read-Host "`nInforme a pasta base para salvar o backup (Ex: C:\IT_Scripts)"
        
        if ([string]::IsNullOrWhiteSpace($DestinoRaiz)) { continue }
        
        $PastaBackup = Join-Path -Path $DestinoRaiz -ChildPath "BrowserBackup_$Timestamp"
        
        if (-not (Test-Path -Path $PastaBackup)) { 
            New-Item -ItemType Directory -Path $PastaBackup -Force | Out-Null 
        }

        Write-Host "`n[INFO] Organizando estrutura em: $PastaBackup" -ForegroundColor Gray
        
        foreach ($Nav in $NavsAlvo) {
            if (Test-Path -Path $Nav.Caminho) {
                Write-Host "`n[INFO] Processando $($Nav.Nome)..." -ForegroundColor Cyan
                
                $Perfis = Get-ChildItem -Path $Nav.Caminho -Directory | Where-Object { $_.Name -eq "Default" -or $_.Name -like "Profile *" }
                $EncontrouFavorito = $false
                
                foreach ($Perfil in $Perfis) {
                    $PerfilBookmarks = Join-Path -Path $Perfil.FullName -ChildPath "Bookmarks"
                    if (Test-Path -Path $PerfilBookmarks) {
                        $Dest = Join-Path -Path $PastaBackup -ChildPath "$($Nav.Nome)\$($Perfil.Name)"
                        New-Item -ItemType Directory -Path $Dest -Force | Out-Null
                        Copy-Item -Path $PerfilBookmarks -Destination $Dest -Force
                        Write-Host "  -> Perfil '$($Perfil.Name)' copiado com sucesso." -ForegroundColor Green
                        $EncontrouFavorito = $true
                    }
                }
                
                if (-not $EncontrouFavorito) {
                    Write-Host "  -> Nenhum favorito encontrado para $($Nav.Nome)." -ForegroundColor DarkGray
                }
                
            } else {
                Write-Host "`n[AVISO] $($Nav.Nome) nao instalado ou nunca aberto pelo usuario." -ForegroundColor DarkGray
            }
        }
        
        Write-Host "`n=======================================================" -ForegroundColor Red
        Write-Host " [ALERTA DE SEGURANCA] AS SENHAS NAO SAO COPIADAS " -ForegroundColor Yellow
        Write-Host "=======================================================" -ForegroundColor Red
        Write-Host "Por politicas de seguranca (Data Protection API do Windows),"
        Write-Host "as senhas devem ser exportadas MANUALMENTE nos navegadores:"
        Write-Host "Edge:   edge://settings/autofill/passwords"
        Write-Host "Chrome: chrome://password-manager/settings"
        
        $null = Read-Host "`nPressione ENTER para voltar ao menu principal..."
    }
    elseif ($Opcao -eq "2") {
        $NavsAlvo = Obter-NavegadoresSelecionados "RESTAURACAO DE NAVEGADOR"
        
        if ($NavsAlvo.Count -eq 0) { continue }
        
        Write-Host "`nNota: Os navegadores selecionados serao fechados." -ForegroundColor Gray
        $Origem = Read-Host "Informe a pasta do backup (Ex: C:\IT_Scripts\BrowserBackup_08042026_153000)"
        
        if ([string]::IsNullOrWhiteSpace($Origem)) { continue }
        if (-not (Test-Path -Path $Origem)) {
            Write-Warning "`n[ERRO] O diretorio informado nao existe!"
            $null = Read-Host "Pressione ENTER para voltar..."
            continue
        }

        # Mata os processos APENAS dos navegadores selecionados pelo usuario
        Write-Host "`n[INFO] Encerrando processos em segundo plano..." -ForegroundColor Yellow
        $ProcessosParaMatar = @()
        if ($NavsAlvo.Nome -contains "Chrome") { $ProcessosParaMatar += "chrome" }
        if ($NavsAlvo.Nome -contains "Edge") { $ProcessosParaMatar += "msedge" }
        
        if ($ProcessosParaMatar.Count -gt 0) {
            Stop-Process -Name $ProcessosParaMatar -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
        }

        foreach ($Nav in $NavsAlvo) {
            $OrigemNav = Join-Path -Path $Origem -ChildPath $Nav.Nome
            if (Test-Path -Path $OrigemNav) {
                Write-Host "`n[INFO] Restaurando favoritos do $($Nav.Nome)..." -ForegroundColor Cyan
                
                $PerfisBackupeados = Get-ChildItem -Path $OrigemNav -Directory
                foreach ($PerfilDir in $PerfisBackupeados) {
                    $OrigemBookmarks = Join-Path -Path $PerfilDir.FullName -ChildPath "Bookmarks"
                    if (Test-Path -Path $OrigemBookmarks) {
                        $DestPerfil = Join-Path -Path $Nav.Caminho -ChildPath $PerfilDir.Name
                        if (-not (Test-Path -Path $DestPerfil)) {
                            New-Item -ItemType Directory -Path $DestPerfil -Force | Out-Null
                        }
                        $DestBookmarks = Join-Path -Path $DestPerfil -ChildPath "Bookmarks"
                        Copy-Item -Path $OrigemBookmarks -Destination $DestBookmarks -Force
                        Write-Host "  -> Perfil '$($PerfilDir.Name)' restaurado." -ForegroundColor Green
                    }
                }
            } else {
                Write-Host "`n[AVISO] Nenhum backup do $($Nav.Nome) encontrado na pasta informada." -ForegroundColor DarkGray
            }
        }
        
        Write-Host "`n[SUCESSO] Restauracao concluida." -ForegroundColor Green
        Write-Host "Lembre-se de importar suas senhas manualmente." -ForegroundColor White
        $null = Read-Host "`nPressione ENTER para voltar ao menu principal..."
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