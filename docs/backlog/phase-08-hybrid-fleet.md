# Phase 08 - Hybrid Fleet

## Objetivo
Consolidar a base para operacao hibrida entre on-prem e cloud, preparando a evolucao do laboratorio para multiplos clusters com estrutura GitOps consistente.

## Macrotarefas
- revisar topologia híbrida
- preparar recursos cloud adicionais se necessário
- registrar dependências de conectividade e operação
- definir a estrutura GitOps cluster-first para o novo cluster
- separar bootstrap, plataforma e workloads por cluster
- validar estrategia operacional de um Argo CD por cluster

## Diretriz arquitetural desta fase
- o cluster atual permanece como referencia inicial de operacao
- o proximo cluster nao deve reutilizar a mesma organizacao raiz `shared/dev/prd`
- a organizacao alvo passa a ser `clusters/<cluster>/bootstrap|platform|workloads`
- a documentacao base desta estrutura esta em `docs/architecture/gitops-multi-cluster-structure.md`

## Entregaveis esperados
- estrutura GitOps alvo definida e versionada
- estrategia de bootstrap do novo cluster documentada
- naming de clusters e `Application` do Argo CD padronizado
- backlog de migracao do cluster atual para repositorio GitOps dedicado

## Progresso ja realizado
- repositorio dedicado `homelab-gitops` criado
- cluster atual migrado para `clusters/homelab`
- `homelab-root` atualizado via Terraform para consumir o repositorio dedicado
- `shared-platform`, `shared-secrets-config`, `dev-workloads` e `prd-workloads` operando a partir do novo repositorio
- estrutura inicial de `clusters/ai-lab` criada no `homelab-gitops`
- `ai-lab` definido como nome inicial do proximo cluster, preservando `homelab` sem mudancas funcionais
- `Application` do novo cluster padronizadas com prefixo `ai-lab-` para evitar colisao de nomes no Argo CD
- entrypoints GitOps do `ai-lab` validados com `kubectl kustomize` ate o ponto de bootstrap
- entrypoint Terraform `terraform/clusters/ai-lab/bootstrap` preparado, aplicado e validado sem pendencias de plano
- estrutura Terraform reorganizada para `terraform/clusters/<cluster>/<escopo>`
- `ai-lab-root` criado no namespace `argocd` do novo cluster via Terraform
- `argocd` instalado e com pods saudaveis no `ai-lab`
- kubeconfig dedicado criado em `~/.kube/config-ai-lab.yaml` com contexto `ai-lab` e validacao basica de acesso ao cluster
- perfis de shell `use_homelab` e `use_ailab` confirmados como obrigatorios antes de `kubectl` e `terraform`

## Contexto operacional confirmado do ai-lab
- o `ai-lab` e um cluster distinto do `homelab`
- o `ai-lab` esta rodando em uma instancia Ubuntu executada sobre WSL em um host Windows 11
- o acesso administrativo do `ai-lab` usa `~/.kube/config-ai-lab.yaml`
- o contexto `ai-lab` aponta para `https://127.0.0.1:6443`
- o `homelab` permanece separado, com kubeconfig e endpoint proprios

## Status atual do novo cluster
- base GitOps pronta em `clusters/ai-lab/bootstrap`, `clusters/ai-lab/platform` e `clusters/ai-lab/workloads`
- `platform` inicial mantida enxuta com `shared-config` e `external-secrets` minimo, sem copiar observabilidade ou ingress antes da necessidade real
- bootstrap do Argo CD executado com sucesso no novo cluster
- o entrypoint Terraform do `ai-lab` aponta para `ai-lab-root` e `clusters/ai-lab/bootstrap/root`
- `terraform plan` em `terraform/clusters/ai-lab/bootstrap` retorna `No changes`
- a arvore Terraform foi realinhada para `terraform/clusters/<cluster>/<escopo>`, evitando misturar cluster e ambiente no mesmo nivel
- o `ai-lab` usa nesta fase o endpoint local `https://127.0.0.1:6443`, valido porque o cluster roda localmente na instancia Ubuntu sobre WSL

## Bloqueio atual
- a `Application` `ai-lab-root` foi criada, mas permanece com `Sync Status = Unknown`
- o erro atual nao esta no Terraform; esta no `argocd-repo-server`
- mensagem observada no status do Argo CD:

```text
Failed to load target state: failed to generate manifest for source 1 of 1: rpc error: code = Unknown desc = Get "https://github.com/bhenriq-souza/homelab-gitops.git/info/refs?service=git-upload-pack": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
```

- os testes mais recentes mostram que:
	- o host Ubuntu/WSL consegue acessar `https://github.com`
	- um pod comum no `ai-lab` consegue falar com a API do Kubernetes e resolver DNS normalmente
	- um pod comum no `ai-lab` nao consegue abrir conexao TCP `443` para destinos do GitHub
	- o `argocd-repo-server` falha em `git fetch` pelo mesmo motivo

Conclusao operacional atual:
- bootstrap do cluster e do Argo CD concluido
- reconciliacao GitOps do `ai-lab-root` bloqueada por conectividade de saida dos pods para o GitHub
- proxima analise deve focar em rede/egress do K3s rodando sobre Ubuntu em WSL no Windows 11

## Checklist operacional do bootstrap do ai-lab
1. confirmar o perfil correto com `use_ailab` e `kctx_status`
2. validar acesso com `kubectl --context <contexto-ai-lab> get nodes`
3. aplicar o entrypoint `terraform/clusters/ai-lab/bootstrap`
4. verificar a criacao de `argocd` e de `ai-lab-root`
5. validar o acesso Git do `argocd-repo-server` ao repositorio `homelab-gitops`
6. verificar no Argo CD a criacao e sincronizacao de `ai-lab-platform`, `ai-lab-secrets-operator`, `ai-lab-secrets-config`, `ai-lab-workloads-dev` e `ai-lab-workloads-prd`
7. somente depois adicionar componentes reais de plataforma, como ingress, observabilidade e configuracoes de segredo especificas do cluster

## Critérios de aceite
- documentacao hibrida consolidada
- backlog de evolucao multi-cluster definido
- estrutura cluster-first aprovada como alvo arquitetural
- plano de migracao do cluster atual registrado