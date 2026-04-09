<div align="center">

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=28&duration=3000&pause=1000&color=0078D7&center=true&vCenter=true&width=700&lines=%F0%9F%A7%B0+IT+Support+Toolkit;Windows+Sysadmin+Helper;Automa%C3%A7%C3%A3o+para+Suporte+N1%2FN2" alt="IT Support Toolkit" />

<br/>

[![Windows](https://img.shields.io/badge/Windows-0078D7?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)](https://microsoft.com/powershell)
![Elevação de privilégios](https://img.shields.io/badge/Requer-Administrador-red?style=for-the-badge&logo=shield&logoColor=white)

<br/>

> **Ferramentas de reparo para analistas de infraestrutura e suporte.** <br/> Scripts modulares de rede, sistema, drivers e backup de favoritos em ambientes Windows.

<br/>

[🚀 Como usar](#como-usar) · [📂 Estrutura](#arquitetura) · [🌐 Navegadores](#navegadores) · [🔧 Drivers](#drivers) · [🔒 Logs e auditoria](#logs-e-auditoria)

</div>

---

## 📖 Sobre o projeto

Scripts para atendimento N1/N2 e equipes de infraestrutura Windows. Cada módulo tem um iniciador Batch (`.bat`) que solicita a elevação de privilégios e chama um script do Windows PowerShell.

<a name="como-usar"></a>

## 🚀 Como usar

1. Copie a pasta do toolkit para a máquina Windows em que será feito o atendimento.
2. Escolha o módulo na tabela e execute seu iniciador. O Windows pode pedir credenciais de administrador.
3. Acompanhe a execução na janela e consulte a transcrição gerada ao final.

<a name="arquitetura"></a>

## 📐 Arquitetura

| Módulo | Iniciador | O que faz |
| --- | --- | --- |
| Rede | [Run-NetworkRepair.bat](NetworkRepair/Run-NetworkRepair.bat) | Limpa o cache DNS e solicita novo registro DNS, preservando a configuração de IP |
| Rede avançada | [Run-AdvancedNetworkRepair.bat](AdvancedNetworkRepair/Run-AdvancedNetworkRepair.bat) | Libera e renova DHCP, redefine Winsock e a pilha TCP/IP |
| Políticas de domínio | [Run-ADSync.bat](ADPolicySync/Run-ADSync.bat) | Limpa tickets Kerberos e atualiza políticas de grupo em máquinas integradas ao domínio |
| Navegadores | [Run-BrowserBackup.bat](BrowserBackup/Run-BrowserBackup.bat) | Faz backup e restaura favoritos do Chrome e do Edge por navegador e perfil |
| Drivers | [Run-DriverManagement.bat](DriverManagement/Run-DriverManagement.bat) | Exporta drivers via DISM para uma pasta com data e hora, ou instala os arquivos `.inf` de um backup com PnPUtil |
| Impressão | [Run-PrintRepair.bat](PrintRepair/Run-PrintRepair.bat) | Esvazia a fila de impressão e reinicia o spooler |
| Sistema | [Run-WindowsRepair.bat](WindowsRepair/Run-WindowsRepair.bat) | Executa os diagnósticos e reparos DISM e SFC |

A redefinição de rede avançada pode interromper uma conexão remota e afetar IP fixo ou VPN. Use o módulo básico para atendimento de DNS em interfaces com IP fixo. O módulo avançado registra a configuração anterior em um arquivo com `IPBackup` no nome, para consulta em uma restauração manual.

<a name="navegadores"></a>

## 🌐 Backup de navegadores

O módulo de navegadores fecha os processos durante a restauração. O backup cobre os favoritos. A exportação de senhas deve ser feita pelo navegador quando estiver autorizada.

<a name="drivers"></a>

## 🔧 Gerenciamento de drivers

O módulo exporta os drivers da máquina com DISM. Na restauração, o PnPUtil instala os arquivos `.inf` de um backup selecionado.

<a name="logs-e-auditoria"></a>

## 🔒 Logs e auditoria

As transcrições ficam em `Logs/` na raiz do toolkit. Em caso de erro ao criar a pasta, os scripts recorrem a `%TEMP%\IT_Toolkit_Logs`. Os nomes incluem usuário, módulo, IP e data e hora. O módulo de reparo do Windows interrompe as etapas seguintes se DISM ou SFC falhar. O código de saída `3010` indica que o Windows precisa reiniciar antes da etapa SFC. Antes de anexar o log ao ticket, confira o resultado de cada comando.

<div align="center">

<br/>

**Desenvolvido para agilizar o suporte técnico com segurança e transparência.**

</div>
