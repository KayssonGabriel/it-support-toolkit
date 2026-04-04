# 🧰 IT Support Toolkit (Windows Sysadmin Helper)

Um conjunto modular e seguro de scripts de automação projetado para equipes de infraestrutura, NOC e suporte de TI (N1/N2). Atua na correção rápida de anomalias comuns em sistemas operacionais Windows corporativos, respeitando princípios de falha rápida (Fail-Fast) e gerando auditoria automatizada.

## 📐 Arquitetura

O projeto utiliza um padrão de "Wrapper" em Batch (`.bat`) para contornar as Políticas de Execução do PowerShell de forma segura e elevar os privilégios (UAC) apenas no momento da execução. Toda a regra de negócio e tratamento de exceções reside em arquivos isolados do PowerShell (`.ps1`) com suporte a fallback de logs para diretórios temporários caso a mídia de origem seja somente-leitura.

### Estrutura de Pastas
```text
/
├── Logs/                    (Criada automaticamente: guarda transcrições e backups)
├── ADPolicySync/            (Sincronização Kerberos e atualização de GPOs)
├── AdvancedNetworkRepair/   (Redefinição profunda: Winsock, TCP/IP e IP Release/Renew (Obs.: não utilize caso possua IP fixo ou VPN configurada))
├── NetworkRepair/           (Manutenção segura de DNS e Cache - Seguro para IP Fixo)
├── PrintRepair/             (Limpeza forçada de Spooler de Impressão)
└── WindowsRepair/           (Reparo de Imagem do SO e Integridade SFC/DISM)
```

---

## 📖 Tutorial de Uso (Procedimento Operacional Padrão)

Este guia é destinado à equipe de suporte. Nenhuma das ferramentas abaixo apaga arquivos pessoais ou documentos do usuário.

### ⚙️ Passo 1: Acesso e Preparação
1. Clone o repositório ou copie a pasta para a máquina de destino (via pendrive ou rede).
2. Identifique o problema relatado para escolher o módulo correto.

### 🛠️ Passo 2: Escolhendo o Módulo de Reparo
* **`WindowsRepair`**: Use para lentidão sistêmica, telas azuis ou erros no Windows Update.
* **`NetworkRepair`**: Use para falhas de DNS ou sites que não carregam. **Seguro para ambientes com IP Estático e VPN**.
* **`AdvancedNetworkRepair`**: Use para falhas graves de conexão onde o reparo simples falhou.
    * **Atenção**: Este módulo redefine a pilha TCP/IP e o Winsock. **Apaga IPs fixos** e exige reinicialização.
* **`PrintRepair`**: Use para documentos presos na fila de impressão que bloqueiam novas tarefas.
* **`ADPolicySync`**: Use para perda de acesso a pastas de rede ou falha de sincronia de GPO/Senha.

### 🚀 Passo 3: Execução
1. Entre na pasta do módulo escolhido.
2. Dê um **duplo clique** no arquivo `.bat` correspondente (Ex: `Run-WindowsRepair.bat`).
3. O Windows pedirá autorização (UAC). Insira as credenciais de **Administrador da TI**.
4. No caso do módulo **Advanced**, leia o prompt de segurança e confirme com **"S"** para prosseguir.
5. Aguarde a mensagem verde de sucesso e pressione qualquer tecla para fechar.

---

## 🔒 Segurança e Auditoria (Logs)

Toda execução gera um log detalhado na pasta `/Logs` na raiz do projeto. Caso o incidente precise ser escalado para o Nível 3, anexe o arquivo de log ao ticket do chamado.

**Padrão do Log:** `[Usuario]_[Modulo]_[IP]_[ddMMyyyy_HHmmss].log`

### 💾 Recuperação de Desastres (IP Backup)
Ao executar o módulo `AdvancedNetworkRepair`, o sistema gera automaticamente um backup das configurações de rede antes da redefinição agressiva.
* **Arquivo:** `[Usuario]_IPBackup_[IP]_[Data].txt`
* **Utilidade:** Caso a máquina possuísse um IP Fixo que foi apagado, consulte este arquivo para reconfigurar manualmente os parâmetros de IP, Máscara e Gateway.
