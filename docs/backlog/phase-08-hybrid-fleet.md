# Phase 08 - Hybrid Fleet

## Objetivo
Consolidar a base para operacao hibrida entre on-prem e cloud, preparando a evolucao do laboratorio para multiplos clusters com estrutura GitOps consistente, sem antecipar o cluster do `ai-lab` antes da fundacao cloud correta.

## Macrotarefas
- manter a estrutura GitOps `cluster-first` como alvo oficial
- descontinuar o experimento local do `ai-lab` no laptop administrador
- preparar a fundacao cloud do `ai-lab` na GCP
- registrar dependencias para a futura instalacao do K3s e bootstrap do Argo CD
- manter a conectividade hibrida como fase posterior, sem VPN/NAT nesta etapa

## Diretriz arquitetural desta fase
- o cluster atual `homelab` permanece como referencia operacional ativa
- o `ai-lab` continua como o nome do proximo cluster, mas ainda nao deve ser bootstrapado
- a estrutura GitOps em `clusters/ai-lab` permanece versionada como scaffold para a proxima fase
- o passo atual do `ai-lab` e criar a fundacao GCP; o K3s vem depois

## Progresso consolidado
- repositorio dedicado `homelab-gitops` criado
- cluster atual migrado para `clusters/homelab`
- estrutura inicial de `clusters/ai-lab` criada no repositório GitOps dedicado
- naming `cluster-first` consolidado para `homelab` e `ai-lab`
- experimento anterior com K3s local em Ubuntu/WSL tratado como caminho descartado
- entrypoint Terraform `terraform/clusters/ai-lab/foundation` criado para a base cloud do `ai-lab`
- fundacao inicial do `ai-lab` modelada com modulos pequenos e reutilizaveis para rede e compute

## Direcao consolidada do ai-lab
- hospedar o `ai-lab` na GCP
- usar uma topologia inicial simples, com IP publico restritivo e sem VPN nesta fase
- nao instalar o K3s nesta entrega
- nao bootstrapar o Argo CD nesta entrega
- nao aprofundar automacoes especificas para GPU nesta entrega

## Fundacao criada para o ai-lab
- VPC dedicada
- subnet principal sem sobreposicao com LAN e cluster local
- firewall restritivo para SSH administrativo
- opcao de firewall reservado para a futura API do K3s, desabilitado por padrao
- IP publico estatico
- VM base parametrizavel
- disco adicional para dados do futuro cluster
- service account dedicada da VM

## Relacao com GitOps
- `clusters/ai-lab/bootstrap`, `platform` e `workloads` continuam versionados em `homelab-gitops`
- esses manifests nao representam um cluster ativo nesta fase
- o bootstrap Terraform e o kubeconfig do `ai-lab` so voltam ao fluxo quando a VM GCP receber o futuro K3s

## Criterios de aceite atualizados
- caminho arquitetural corrigido para GCP primeiro, cluster depois
- cluster provisório do laptop admin descontinuado
- fundacao Terraform do `ai-lab` criada de forma parametrizavel
- documentacao operacional antiga do experimento local revisada
- backlog pronto para a proxima fase de instalacao do K3s sobre a base cloud