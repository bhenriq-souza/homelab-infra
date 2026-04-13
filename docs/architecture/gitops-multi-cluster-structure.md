# GitOps Multi-cluster Structure

## Objetivo
Definir a estrutura-base recomendada para operar um novo cluster sem repetir o acoplamento atual entre ambiente logico e destino fisico de deploy.

## Contexto atual
Hoje o repositorio possui uma estrutura GitOps adequada para um unico cluster:
- `shared` para componentes cluster-wide
- `dev` e `prd` para workloads segregados por namespace
- `bootstrap/root` como app-of-apps raiz

Esse modelo funciona para o cluster atual do homelab, mas passa a escalar mal quando um segundo cluster entra na topologia. O principal problema e que `dev` e `prd` representam ambientes logicos, enquanto o novo requisito passa a introduzir tambem o eixo de cluster.

## Diretriz principal
Para multiplos clusters, o eixo primario do repositorio deve ser `cluster`.

Em termos praticos:
- cluster primeiro
- plataforma depois
- workloads por ambiente dentro do cluster

## Estrutura recomendada

```text
homelab-gitops/
  clusters/
    homelab/
      bootstrap/
        root/
          kustomization.yaml
          applications/
            platform.yaml
            workloads-dev.yaml
            workloads-prd.yaml
      platform/
        argocd-config/
        ingress/
        observability/
        external-secrets/
        shared-config/
      workloads/
        dev/
          myapp/
          postgresql/
        prd/
          myapp/
    novo-cluster/
      bootstrap/
        root/
          kustomization.yaml
          applications/
            platform.yaml
            workloads-dev.yaml
            workloads-prd.yaml
      platform/
        argocd-config/
        ingress/
        observability/
        external-secrets/
        shared-config/
      workloads/
        dev/
        prd/
  components/
    platform/
      observability/
      external-secrets/
      traefik/
    apps/
      myapp/
        base/
      postgresql/
        base/
```

## Leitura da estrutura

### `clusters/<cluster>/bootstrap`
Ponto de entrada do Argo CD naquele cluster.

Responsabilidades:
- app-of-apps raiz
- declaracao das `Application` filhas
- ordem logica de bootstrap

### `clusters/<cluster>/platform`
Camada de fundacao do cluster.

Responsabilidades:
- ingress controller
- observabilidade
- external secrets
- configuracoes compartilhadas do cluster
- politicas e recursos cluster-wide

Regra:
- tudo que e necessario para o cluster operar de forma padrao entra aqui

### `clusters/<cluster>/workloads`
Camada de aplicacoes e servicos de negocio.

Responsabilidades:
- apps por ambiente logico
- servicos com ciclo de vida proprio
- configuracoes especificas de cada ambiente

Regra:
- `dev` e `prd` continuam existindo, mas subordinados ao cluster

### `components/`
Biblioteca de reaproveitamento.

Responsabilidades:
- bases kustomize ou manifests comuns
- componentes de plataforma repetidos entre clusters
- bases de aplicacoes compartilhadas

Regra:
- `components` nao e um destino de deploy direto; ele existe para ser referenciado pelos clusters

## Modelo recomendado para Argo CD

### Padrao inicial
Usar um Argo CD por cluster.

Motivos:
- menor acoplamento operacional
- bootstrap mais simples
- isolamento de falha entre clusters
- menor dependencia de rede entre on-prem e cloud

### Padrao de sincronizacao
Usar `app-of-apps` por cluster.

Estrutura logica sugerida:
- `root` sincroniza `platform`
- `root` sincroniza `workloads-dev`
- `root` sincroniza `workloads-prd`

### Quando usar `ApplicationSet`
Nao usar como padrao agora.

Adotar apenas quando houver:
- tres ou mais clusters ativos
- grande repeticao de `Application`
- necessidade clara de geracao dinamica por matriz de cluster x ambiente x app

## Convencoes recomendadas

### Nome de cluster
Usar nomes curtos, estaveis e semanticamente claros.

Exemplos:
- `homelab`
- `ai-lab`
- `edge-lab`

Evitar:
- nomes de host como nome primario do cluster
- nomes temporarios ou dependentes de hardware

### Nome de `Application` do Argo CD
Usar o prefixo do cluster quando o repositorio passar a operar multiplos clusters.

Exemplos:
- `homelab-platform`
- `homelab-workloads-dev`
- `homelab-workloads-prd`
- `ai-lab-platform`

### Labels minimas
Padronizar labels para facilitar busca e observabilidade:
- `homelab.io/cluster`
- `homelab.io/environment`
- `homelab.io/layer`
- `app.kubernetes.io/part-of`

## Mapeamento a partir do estado atual
Transicao sugerida do modelo atual para o alvo:

- `gitops/apps/shared/platform` -> `clusters/homelab/platform`
- `gitops/apps/shared/secrets` -> `clusters/homelab/platform/external-secrets`
- `gitops/apps/dev/workloads` -> `clusters/homelab/workloads/dev`
- `gitops/apps/prd/workloads` -> `clusters/homelab/workloads/prd`
- `gitops/bootstrap/root` -> `clusters/homelab/bootstrap/root`

## Estrategia de migracao recomendada

### Etapa 1 - consolidar o modelo alvo
- manter a estrutura atual operando sem mudanca funcional
- registrar a estrutura multi-cluster como alvo oficial
- criar o repositorio dedicado `homelab-gitops`

### Etapa 2 - mover o cluster atual
- migrar o cluster atual para `clusters/homelab`
- preservar os mesmos manifests e `Application` com renomeacao controlada
- validar sincronizacao completa no Argo CD

### Etapa 3 - adicionar o novo cluster
- criar `clusters/<novo-cluster>`
- bootstrapar Argo CD nesse cluster
- ativar `root` proprio apontando para o mesmo repositorio GitOps

### Etapa 4 - extrair reutilizacao
- mover manifests duplicados para `components/`
- manter overlays especificos apenas onde houver diferenca real entre clusters

## Trade-offs

### Beneficios
- separa claramente cluster de ambiente
- reduz ambiguidade operacional
- facilita crescimento para topologia hibrida
- melhora reuso controlado entre clusters

### Custos
- aumenta profundidade de diretorios
- exige disciplina maior de naming
- adiciona migracao planejada antes do segundo cluster entrar em producao

## Decisao proposta
Adotar `cluster-first GitOps` como estrutura-alvo para o proximo cluster, mantendo a arvore atual apenas como estado transitorio do cluster unico.