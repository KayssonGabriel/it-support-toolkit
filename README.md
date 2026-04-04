# 🧰 IT Support Toolkit (Windows Sysadmin Helper)

Um conjunto modular e seguro de scripts de automação projetado para equipes de infraestrutura, NOC e suporte de TI (N1/N2). Atua na correção rápida de anomalias comuns em sistemas operacionais Windows corporativos, respeitando princípios de falha rápida (Fail-Fast) e gerando auditoria automatizada.

## 📐 Arquitetura

O projeto utiliza um padrão de "Wrapper" em Batch (`.bat`) para contornar as Políticas de Execução do PowerShell de forma segura e elevar os privilégios (UAC) apenas no momento da execução. Toda a regra de negócio e tratamento de exceções reside em arquivos isolados do PowerShell (`.ps1`).

### Estrutura de Pastas
```text
/
├── Logs/               (Criada automaticamente: guarda as transcrições das execuções)
├── WindowsRepair/      (Módulo: Reparo de Imagem do SO e Integridade SFC/DISM)
├── NetworkRepair/      (Módulo: Manutenção de DNS e Cache de Rede - Seguro para IP Fixo)
├── PrintRepair/        (Módulo: Limpeza forçada de Spooler de Impressão)
└── ADPolicySync/       (Módulo: Sincronização Kerberos/GPO)
```

---

## 📖 Tutorial de Uso (Procedimento Operacional Padrão)

Este guia é destinado à equipe de suporte. Nenhuma das ferramentas abaixo apaga arquivos pessoais ou documentos do usuário.

### ⚙️ Passo 1: Acesso e Preparação
1. Clone o repositório ou copie a pasta para a máquina de destino (via pendrive ou rede).
2. Identifique o problema relatado para escolher o módulo correto.

### 🛠️ Passo 2: Escolhendo o Módulo de Reparo
* **`WindowsRepair`:** Use para lentidão, telas azuis ou erros no Windows Update.
* **`NetworkRepair`:** Use para falhas de resolução de nomes (DNS), sites que não carregam ou erros de "Servidor não encontrado". (Não altera configurações de IP Estático/Fixo).
* **`PrintRepair`:** Use para documentos presos na fila de impressão que não podem ser cancelados.
* **`ADPolicySync`:** Use para perda de acesso a pastas de rede ou falha de sincronia de senha de domínio.

### 🚀 Passo 3: Execução
1. Entre na pasta do módulo escolhido.
2. Dê um **duplo clique** no arquivo `.bat` (Ex: `Run-WindowsRepair.bat`).
3. O Windows pedirá autorização (UAC). Insira as credenciais de **Administrador da TI**.
4. A tela azul do PowerShell abrirá automaticamente. Aguarde a mensagem verde de sucesso e pressione qualquer tecla para fechar.

---

## 🔒 Segurança e Auditoria (Logs)

Toda execução gera um log detalhado na pasta `/Logs` na raiz do projeto. Caso o incidente precise ser escalado para o Nível 3, anexe o arquivo de log ao ticket do chamado.

**Padrão do Log:** `[Usuario]_[Modulo]_[IP]_[ddMMyyyy_HHmmss].log`
