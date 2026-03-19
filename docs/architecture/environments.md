# Environments

## shared
Recursos compartilhados e fundacionais do laboratório.

Exemplos:
- APIs habilitadas no projeto
- artefatos compartilhados
- configurações comuns

## gcp-lab
Ambiente cloud de laboratório na GCP.

Exemplos:
- VPC
- subnet
- VM spot
- firewall rules
- artifact registry

## local
Contexto documental do ambiente on-prem.

Observação:
O ambiente local não será totalmente provisionado por Terraform no primeiro momento, mas deve ser documentado aqui para manter consistência entre naming, IP plan e integração híbrida.