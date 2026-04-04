:: WindowsRepair\Run-Repair.bat

@echo off
:: Arquitetura Limpa: Elevacao de UAC nativa sem arquivos .vbs temporarios
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Solicitando privilegios de Administrador de forma segura...
    PowerShell.exe -NoProfile -Command "Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""%~dp0Repair-WindowsSystem.ps1""' -Verb RunAs"
    exit /B
)

pushd "%CD%"
CD /D "%~dp0"
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Repair-WindowsSystem.ps1"