# Backup and Restore

## Objetivo
Registrar a estratégia mínima de backup e recuperação do laboratório.

## Itens relevantes
- arquivos críticos do host
- estados e artefatos de Terraform
- configurações importantes
- documentação de recuperação

## Diretriz inicial - PostgreSQL no cluster
- iniciar com backup logico (`pg_dump`) com frequência diária no ambiente `dev`
- manter retenção curta no homelab e revisar consumo de disco semanalmente
- registrar local de armazenamento e responsáveis por execução/verificação
- validar restore em ambiente de teste antes de promover mudanças para `prd`