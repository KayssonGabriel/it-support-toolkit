# 🧰 IT Support Toolkit (Windows Sysadmin Helper)

Um conjunto modular e seguro de scripts de automação projetado para equipes de infraestrutura, NOC e suporte de TI (N1/N2). Atua na correção rápida de anomalias comuns em sistemas operacionais Windows corporativos, respeitando princípios de falha rápida (Fail-Fast) e gerando auditoria automatizada.

## 📐 Arquitetura

O projeto utiliza um padrão de "Wrapper" em Batch (`.bat`) para contornar as Políticas de Execução do PowerShell de forma segura e elevar os privilégios (UAC) apenas no momento da execução. Toda a regra de negócio e tratamento de exceções reside em arquivos isolados do PowerShell (`.ps1`).

### Estrutura de Pastas
```text
/
├── Logs/              (Criada automaticamente: guarda as transcrições das execuções)
├── WindowsRepair/     (Módulo: Reparo de Imagem do SO)
├── NetworkRepair/     (Módulo: Redefinição da Pilha TCP/IP)
├── PrintRepair/       (Módulo: Limpeza forçada de Spooler de Impressão)
├── ADPolicySync/      (Módulo: Sincronização Kerberos/GPO)
└── README.md
