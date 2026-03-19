# homelab-infra

Repositório de infraestrutura e arquitetura macro do laboratório híbrido on-prem + GCP.

## Objetivos
- definir a arquitetura macro do homelab
- documentar decisões técnicas
- planejar rede local e híbrida
- gerenciar infraestrutura por Terraform
- centralizar backlog técnico da plataforma
- servir como contexto principal para agentes de IA

## Escopo
Este repositório contém:
- documentação arquitetural
- ADRs
- documentação de rede
- baseline de segurança
- documentação operacional
- Terraform da infraestrutura
- backlog técnico e tarefas de infra

## Estrutura principal
- `docs/`: documentação macro
- `terraform/`: infraestrutura como código
- `tasks/`: backlog e foco atual
- `.github/workflows/`: validações do repositório

## Forma de trabalho
1. registrar decisões importantes em `docs/adr/`
2. manter backlog por fase em `docs/backlog/`
3. manter o contexto do agent atualizado
4. tratar Terraform como fonte declarativa da infraestrutura