# Current Focus

## Fase ativa
Phase 04 — IaC + GitOps foundation

## Objetivo
Estabelecer a fundação inicial da plataforma do homelab usando Terraform para infraestrutura/bootstrap e Argo CD para GitOps, já preparada para múltiplos ambientes lógicos no mesmo cluster.

## Estado atual
- Ubuntu Server 24.04 instalado no host
- K3s instalado com sucesso e cluster funcional
- Estrutura documental do repositório já criada
- ADRs principais já definidos para Terraform e Argo CD
- Diretório `/terraform` já existente com convenções iniciais
- Decisão confirmada: recursos GitOps ficarão fora de `/terraform`
- Decisão confirmada: por enquanto haverá um único cluster, com segregação de ambientes por namespaces

## Estratégia de ambientes
Nesta etapa, o homelab continuará operando com um único cluster K3s.

A separação entre ambientes será lógica, por namespaces, permitindo suportar desde já:
- `dev`
- `prd`

A estrutura de código deve nascer preparada para múltiplos ambientes, mesmo sem múltiplos clusters neste momento.

Isso significa que:
- Terraform deve refletir ambientes distintos
- GitOps deve refletir ambientes distintos
- namespaces devem seguir convenções por ambiente
- componentes compartilhados do cluster devem ser claramente diferenciados de componentes específicos de ambiente

## Escopo desta fase
- definir a estrutura inicial de `/terraform`
- definir a estrutura inicial de `/gitops`
- criar o bootstrap do Argo CD no cluster K3s existente usando Terraform
- estabelecer uma base simples, reprodutível e fácil de evoluir
- suportar desde já os ambientes `dev` e `prd` no mesmo cluster
- documentar as decisões e preparar o caminho para a fase de observabilidade

## Incluído no escopo
- entrypoints Terraform para os ambientes `dev` e `prd`
- providers necessários para operar o cluster existente
- instalação inicial do Argo CD via Terraform
- estrutura inicial do diretório `/gitops`
- definição do bootstrap inicial do GitOps
- convenções iniciais de namespaces por ambiente
- diferenciação entre recursos cluster-wide e recursos específicos por ambiente
- documentação mínima necessária para suportar a fase

## Fora do escopo
- instalação da stack de observabilidade
- pipelines de CI/CD
- onboarding de aplicações
- integração híbrida com cloud
- gerenciamento avançado de segredos
- hardening avançado de segurança
- automação completa de provisionamento do host

## Decisões vigentes
- usar Terraform para infraestrutura/bootstrap
- usar Argo CD para GitOps
- manter manifests GitOps fora de `/terraform`
- manter `environments/` simples e concentrar lógica em `modules/`
- evitar overengineering na primeira versão
- priorizar simplicidade, clareza e reprodutibilidade
- suportar múltiplos ambientes no código desde já
- usar segregação por namespaces em um único cluster neste momento

## Diretrizes de modelagem
A solução deve deixar explícita a diferença entre:
- componentes compartilhados do cluster
- componentes específicos do ambiente `dev`
- componentes específicos do ambiente `prd`

Exemplos esperados:
- Argo CD como componente compartilhado do cluster
- namespaces específicos por ambiente para workloads e recursos que fizerem sentido
- estrutura de diretórios preparada para crescimento sem depender de múltiplos clusters agora

## Resultado esperado
Ao final desta fase, o repositório deve possuir:
- estrutura coerente de Terraform para os ambientes `dev` e `prd`
- bootstrap inicial do Argo CD no cluster
- estrutura inicial de GitOps separada de Terraform
- convenções iniciais de namespace por ambiente
- base pronta para que a observabilidade seja entregue via GitOps na próxima fase

## Entregáveis
- estrutura inicial de `/terraform/environments/dev`
- estrutura inicial de `/terraform/environments/prd`
- arquivos Terraform necessários para bootstrap do Argo CD
- estrutura inicial de `/gitops`
- definição do padrão inicial de bootstrap GitOps
- convenções documentadas para segregação por namespaces
- documentação atualizada quando necessário

## Critérios de pronto
- a estrutura de diretórios está clara e coerente com as ADRs
- o Terraform consegue apontar para o cluster K3s existente
- os ambientes `dev` e `prd` estão representados no código
- a segregação lógica por namespaces está definida
- o Argo CD pode ser instalado no cluster via Terraform
- o diretório `/gitops` existe com propósito e organização definidos
- a próxima fase de observabilidade pode começar sem retrabalho estrutural

## Riscos e cuidados
- evitar misturar responsabilidades entre Terraform e GitOps
- evitar criar módulos Terraform desnecessários cedo demais
- evitar tratar ambientes lógicos como se fossem isolamento forte de clusters distintos
- evitar instalar componentes fora do fluxo definido
- não versionar segredos reais
- manter o bootstrap inicial o mais simples possível

## Checklist operacional da fase
- [x] definir árvore inicial de `/terraform`
- [x] definir árvore inicial de `/gitops`
- [x] criar entrypoint Terraform para `dev`
- [x] criar entrypoint Terraform para `prd`
- [x] configurar providers necessários
- [x] implementar código Terraform para bootstrap do Argo CD
- [x] definir bootstrap inicial do GitOps (app-of-apps)
- [x] definir convenções de namespaces por ambiente
- [x] revisar documentação impactada (Terraform e GitOps)
- [ ] aplicar Terraform no cluster (`shared`, `dev`, `prd`)
- [ ] validar Argo CD e sincronização das aplicações raiz
- [ ] ajustar `repoURL` final nos manifests GitOps e tfvars de `shared`
- [ ] registrar evidências operacionais de validação da fase
- [ ] registrar decisões complementares, se necessário

## Status de execução (hoje)
### Concluído
- estrutura de diretórios inicial criada para `/terraform` e `/gitops`
- entrypoints Terraform criados para `shared`, `dev` e `prd`
- módulos Terraform criados para bootstrap do Argo CD e namespaces por ambiente
- providers Kubernetes/Helm/Kubectl configurados para uso com kubeconfig local
- bootstrap GitOps inicial criado no padrão app-of-apps
- aplicações iniciais separadas por escopo:
	- compartilhado: `shared-platform`
	- ambiente: `dev-workloads` e `prd-workloads`
- convenções de namespace estabelecidas:
	- compartilhado: `argocd`, `platform-shared`
	- ambiente: `dev-apps`, `prd-apps`
- documentação de estrutura e responsabilidades atualizada em `terraform/README.md` e `gitops/README.md`

### Pendente para encerrar a fase
- executar o bootstrap no cluster local e validar sucesso end-to-end
- confirmar saúde do Argo CD (`argocd` namespace, pods, aplicação raiz e apps filhas)
- substituir URLs placeholder (`https://github.com/your-org/homelab-infra.git`) pela URL real do repositório
- salvar evidências de validação (comandos e resultados) para fechamento da fase

## Próximo passo após esta fase
Phase 05 — Observabilidade via GitOps

## Objetivo do próximo passo
- instalar a stack inicial de observabilidade usando Argo CD
- começar com componentes mínimos e operacionais
- decidir o que será compartilhado no cluster e o que será segmentado por ambiente
- preparar dashboards, métricas e logs para suportar a evolução do homelab

## Diretriz de compartilhamento vs segregação
A modelagem desta fase deve seguir a seguinte lógica:

### Compartilhado no cluster
- `argocd`
- componentes base de plataforma que sejam naturalmente cluster-wide
- componentes que não precisem ser duplicados por ambiente

### Específico por ambiente
- namespaces como `dev-*` e `prd-*`
- aplicações e workloads
- configurações e values por ambiente
- políticas, quotas e ajustes específicos por ambiente, quando fizer sentido

Princípio:
evitar duplicação desnecessária de componentes compartilhados do cluster entre `dev` e `prd`.