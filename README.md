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
├── AdvancedNetworkRepair/   (Redefinição profunda: Winsock, TCP/IP e IP Release/Renew (Obs.: não utilize caso possua IP fixo ou VPN configurada))
├── BrowserBackup/           (Backup/Restauro de Favoritos Chrome/Edge)
├── DriverManagement/        (Backup e Injeção de Drivers via DISM)
├── NetworkRepair/           (Manutenção segura de DNS - Ideal para IP Fixo)
├── PrintRepair/             (Limpeza de Spooler de Impressão)
└── WindowsRepair/           (Reparo de imagem SFC e DISM)
```

## 🚀 Como Usar (POP)

### ⚙️ Passo 1: Preparação
1. Copie a pasta para a máquina de destino.
2. Identifique o problema para escolher o módulo.

### 🛠️ Passo 2: Execução
1. Entre na pasta do módulo desejado.
2. Execute o arquivo `.bat` correspondente (ex: `Run-DriverManagement.bat`).
3. O Windows solicitará privilégios de Administrador.

---

## 🌐 Browser Backup
Gerencie favoritos dos navegadores **Google Chrome** e **Microsoft Edge**.

> [!IMPORTANT]
> As senhas **NÃO** são copiadas devido à criptografia DPAPI do Windows. Devem ser exportadas manualmente.

* **Backup:** Organiza favoritos por Navegador e Perfil (suporte a múltiplos perfis).
* **Restauração:** Fecha os processos do navegador automaticamente para garantir a integridade dos arquivos.

---

## 🔧 Driver Management
Backup e restauração completa de drivers usando as ferramentas nativas `DISM` e `PnPUtil`.

* **Backup:** Extrai todos os drivers `/online` para uma pasta organizada com timestamp.
* **Restauração:** Injeta drivers em massa (`.inf`) a partir de um backup anterior.

---

## 🛠️ Resumo de Módulos de Reparo

| Módulo | Quando usar? | Impacto |
| :--- | :--- | :--- |
| **WindowsRepair** | Lentidão ou erros de arquivos corrompidos. | Baixo |
| **NetworkRepair** | Problemas de DNS ou navegação simples. | Seguro (Mantém IP Fixo) |
| **AdvancedNetwork** | Falhas graves de conexão/VPN. | **Alto (Apaga IP Fixo)** |
| **ADPolicySync** | Erros de permissão em rede ou senhas. | Médio |
| **PrintRepair** | Impressora travada ou erro no spooler. | Baixo |

---

## 🔒 Segurança e Auditoria
Toda execução gera um log detalhado na pasta `/Logs`. Se o problema persistir e precisar de escalonamento para N3, anexe o log ao ticket.

**Padrão do Log:** `[Usuario]_[Modulo]_[IP]_[Data_Hora].log`

### 💾 Recuperação (IP Backup)
Ao usar o `AdvancedNetworkRepair`, um arquivo `IPBackup.txt` é gerado. Use-o para recuperar manualmente configurações de IP Fixo caso necessário.

<div align="center">

<br/>

**Desenvolvido para agilizar o suporte técnico com segurança e transparência.**

</div>
