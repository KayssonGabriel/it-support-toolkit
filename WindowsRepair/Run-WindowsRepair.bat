:: \WindowsRepair\Run-WindowsRepair.bat

@echo off
:: Encapsulamento de variável para proteção contra caminhos com espaços
set "SCRIPT_PATH=%~dp0Repair-WindowsSystem.ps1"

>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo Solicitando privilegios de Administrador de forma segura...
    PowerShell.exe -NoProfile -Command "Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File \"%SCRIPT_PATH%\"' -Verb RunAs"
    exit /B
)

pushd "%CD%"
CD /D "%~dp0"
PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%"