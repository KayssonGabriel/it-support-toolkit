# /README.md

<div align="center">

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=28&duration=3000&pause=1000&color=0078D7&center=true&vCenter=true&width=700&lines=%F0%9F%A7%B0+IT+Support+Toolkit;Windows+Sysadmin+Helper;Automa%C3%A7%C3%A3o+para+Suporte+N1%2FN2" alt="IT Support Toolkit" />

<br/>

[![Windows](https://img.shields.io/badge/Windows-0078D7?style=for-the-badge&logo=windows&logoColor=white)](https://www.microsoft.com/windows)
[![PowerShell](https://img.shields.io/badge/PowerShell-5391FE?style=for-the-badge&logo=powershell&logoColor=white)](https://microsoft.com/powershell)
[![Admin Required](https://img.shields.io/badge/Requer-Administrador-red?style=for-the-badge&logo=shield&logoColor=white)]()

<br/>

> **Canivete suíço para analistas de Infraestrutura e Suporte.** > Soluções modulares para reparo de rede, sistema, drivers e backup de navegadores em ambientes corporativos.

<br/>

[🚀 Como Usar](#-como-usar) · [📂 Estrutura](#-arquitetura) · [🌐 Navegadores](#-browser-backup) · [🔧 Drivers](#-driver-management) · [🛡️ Segurança](#-segurança-e-auditoria)

</div>

---

## 📖 Sobre o Projeto

O **IT Support Toolkit** é um conjunto modular de scripts projetado para equipes de TI (NOC/Suporte). Ele foca na correção rápida de problemas comuns do Windows, utilizando um padrão de "Wrapper" em Batch (`.bat`) para elevar privilégios e executar lógica complexa em PowerShell (`.ps1`) de forma segura.

---

## 📐 Arquitetura

O toolkit é organizado para garantir que cada intervenção seja isolada e auditada.

```text
/
├── Logs/                    (Criada automaticamente: auditoria e transcrições)
├── ADPolicySync/            (Sincronização Kerberos e GPOs)
├── AdvancedNetworkRepair/   (Reset profundo de TCP/IP e Winsock)
├── BrowserBackup/           (NOVO: Backup/Restauro de Favoritos Chrome/Edge)
├── DriverManagement/        (NOVO: Backup e Injeção de Drivers via DISM)
├── NetworkRepair/           (Manutenção segura de DNS - Ideal para IP Fixo)
├── PrintRepair/             (Limpeza de Spooler de Impressão)
└── WindowsRepair/           (Reparo de imagem SFC e DISM)
```
