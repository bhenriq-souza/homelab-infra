# Local Secrets (nao versionados)

Este diretorio guarda credenciais locais por ambiente para operacoes manuais.

## Estrutura
- `secrets/dev/gcp-sa.json`: chave JSON da service account do ambiente dev (ignorada pelo Git)
- `secrets/prd/gcp-sa.json`: chave JSON da service account do ambiente prd (ignorada pelo Git)
- `secrets/<ambiente>/gcp-sa.json.example`: template seguro sem segredo real

## Regras
- Nunca commitar `gcp-sa.json`.
- Sempre criar/atualizar o Secret Kubernetes usando `scripts/apply-gcp-sa-key-secret.sh`.
- O nome do Secret gerado no cluster segue o padrao `eso-gcp-sa-key-<ambiente>`.
