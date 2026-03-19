# Agent Context

## Objetivo do repositório
Este repositório centraliza a arquitetura macro, rede, segurança base, operação inicial e infraestrutura declarativa do laboratório híbrido on-prem + GCP.

## O que este repositório pode alterar
- documentação de arquitetura
- backlog e roadmap
- ADRs
- documentação de rede
- documentação operacional
- módulos e ambientes Terraform
- scripts utilitários de infra
- workflows de validação deste repositório

## O que este repositório não deve alterar
- código de frontend
- código de backend
- manifests detalhados do Argo CD
- regras de negócio do app

## Stack e decisões principais
- host local baseado em Ubuntu Server 24.04 LTS
- cluster local com K3s
- GCP como ambiente cloud complementar
- Terraform como IaC principal
- GitHub Actions para automação
- Argo CD como motor de GitOps em repositório separado

## Regras para agentes
- respeitar as ADRs existentes
- não inventar arquitetura fora da documentação
- preferir mudanças pequenas e incrementais
- atualizar documentação quando uma decisão estrutural mudar
- manter módulos Terraform coesos e pequenos
- não misturar responsabilidades entre ambientes

## Antes de implementar qualquer tarefa
Leia nesta ordem:
1. `README.md`
2. `docs/architecture/target-architecture.md`
3. `docs/architecture/roadmap.md`
4. `docs/architecture/naming-conventions.md`
5. `docs/adr/README.md`
6. `tasks/current-focus.md`

## Resultado esperado em cada tarefa
- alteração objetiva
- arquivos impactados listados
- instruções de validação
- documentação mínima atualizada