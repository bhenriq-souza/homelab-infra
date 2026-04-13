# Troubleshooting

## Objetivo
Registrar problemas recorrentes, hipóteses comuns e formas de validação.

## Estrutura sugerida
- sintoma
- possíveis causas
- passos de validação
- ação corretiva

## Terraform bootstrap - provider kubectl invalido

### Sintoma
Erro durante `terraform init` no ambiente `shared`:

```text
Could not retrieve the list of available versions for provider hashicorp/kubectl
Did you intend to use gavinbunney/kubectl?
```

### Possiveis causas
- modulo Terraform sem `required_providers` explicito para `kubectl`
- resolucao implicita para `hashicorp/kubectl` em vez de `gavinbunney/kubectl`

### Passos de validacao
1. Executar `terraform -chdir=terraform/clusters/homelab/bootstrap providers`
2. Confirmar se aparece `hashicorp/kubectl` na arvore de providers
3. Conferir se o modulo usado por `shared` declara `source = "gavinbunney/kubectl"`

### Acao corretiva
- Declarar `required_providers` no modulo que usa `kubectl_manifest`
- Garantir `kubectl` com source `gavinbunney/kubectl`
- Rodar `terraform init -upgrade` novamente no ambiente afetado

Referencia do modulo:
- `terraform/modules/argocd-bootstrap/versions.tf`

## Terraform bootstrap - contexto Kubernetes inexistente

### Sintoma
Erro durante `terraform plan`/`apply`:

```text
Provider configuration: cannot load Kubernetes client config
context "default" does not exist
```

### Possiveis causas
- provider lendo arquivo diferente do kubeconfig esperado
- `kubeconfig_path` padrao apontando para `~/.kube/config` enquanto o arquivo real esta em outro caminho
- contexto informado em `kubeconfig_context` nao existe no arquivo carregado

### Passos de validacao
1. Verificar contexto e server no arquivo desejado:
	- `kubectl config get-contexts --kubeconfig <kubeconfig>`
	- `kubectl config current-context --kubeconfig <kubeconfig>`
2. Validar conectividade:
	- `kubectl cluster-info --kubeconfig <kubeconfig>`
	- `kubectl get nodes --kubeconfig <kubeconfig>`
3. Confirmar caminho/contexto efetivos usados no Terraform:
	- `echo $KUBECONFIG`
	- `echo $KUBE_CONTEXT`

### Acao corretiva
- Executar o bootstrap informando `KUBECONFIG` e, quando necessario, `KUBE_CONTEXT`
- Ou definir `kubeconfig_path`/`kubeconfig_context` no `terraform.tfvars` de cada ambiente

Exemplo de execucao:

```bash
KUBECONFIG=/home/<usuario>/.kube/config-homelab.yaml \
KUBE_CONTEXT=default \
./terraform/scripts/bootstrap-order.sh
```

Observacao operacional:
- o bootstrap Terraform pode ser executado do laptop administrador, sem SSH no host, desde que haja conectividade com a API do cluster e kubeconfig valido.

## Argo CD lento ou com crash durante sync

### Sintoma
- sincronizacao lenta ao reconciliar mudancas no repositorio GitOps
- pod(s) do Argo CD reiniciando com frequencia durante picos de sync
- UI com varias reconexoes de stream (`Watch`/`WatchResourceTree`)

### Possiveis causas
- pressao de memoria/CPU em `argocd-application-controller` e `argocd-repo-server`
- reconciliacao muito frequente para o tamanho do cluster/repo
- componentes opcionais habilitados sem uso (ex.: notifications/dex)

### Passos de validacao
1. Verificar reinicios e motivo de terminacao dos pods:

```bash
kubectl -n argocd get pods
kubectl -n argocd describe pod <pod-name> | grep -E "Reason|Last State|OOMKilled|Exit Code"
```

2. Verificar eventos recentes no namespace `argocd`:

```bash
kubectl -n argocd get events --sort-by=.lastTimestamp | tail -n 30
```

3. Inspecionar uso de CPU/memoria durante sync:

```bash
kubectl -n argocd top pod
```

4. Confirmar configuracao efetiva do chart:

```bash
helm -n argocd get values argocd -a
```

### Acao corretiva
- aplicar o baseline de tuning no modulo Terraform:
	- `terraform/modules/argocd-bootstrap/main.tf`
- baseline inclui:
	- requests/limits para `controller`, `repoServer`, `server`, `applicationSet` e `redis`
	- `timeout.reconciliation=300s` e `timeout.reconciliation.jitter=60s`
	- `notifications.enabled=false` e `dex.enabled=false` (quando nao utilizados)
- caso necessario, ajustar override por ambiente em:
	- `terraform/clusters/homelab/bootstrap/variables.tf` (`argocd_helm_values_override`)
- para uso diario da UI, preferir exposicao por Ingress/TLS em vez de `kubectl port-forward` recorrente, reduzindo instabilidade de streams gRPC em redes com jitter.

### Validacao pos-correcao
1. Reaplicar `shared`:

```bash
terraform -chdir=terraform/clusters/homelab/bootstrap plan
terraform -chdir=terraform/clusters/homelab/bootstrap apply
```

2. Forcar uma sincronizacao de app com mudanca pequena e observar estabilidade:

```bash
kubectl -n argocd get pods -w
kubectl -n argocd logs deploy/argocd-application-controller --tail=200 -f
```

3. Criterio de sucesso:
- sem novos `CrashLoopBackOff` no namespace `argocd`
- tempo de sync reduzido/estavel para apps do bootstrap
- ausencia de novos eventos de `OOMKilled`

## Argo CD no ai-lab - root app em `Unknown` por timeout no GitHub

### Sintoma
- a `Application` `ai-lab-root` existe, mas fica com `Sync Status = Unknown`
- o Argo CD mostra erro ao carregar o estado alvo do repositorio GitOps

Erro observado:

```text
Failed to load target state: failed to generate manifest for source 1 of 1: rpc error: code = Unknown desc = Get "https://github.com/bhenriq-souza/homelab-gitops.git/info/refs?service=git-upload-pack": context deadline exceeded (Client.Timeout exceeded while awaiting headers)
```

### Contexto operacional relevante
- o `ai-lab` roda em uma instancia Ubuntu sobre WSL em um host Windows 11
- o acesso administrativo usa `~/.kube/config-ai-lab.yaml`
- antes de qualquer comando, executar `use_ailab` e validar com `kctx_status`
- o erro atual ocorre no `argocd-repo-server`, nao no `argocd-server`

### Possiveis causas
- pods do cluster sem conectividade de saida TCP `443` para endpoints do GitHub
- comportamento especifico de egress/rede do K3s rodando sobre WSL
- bloqueio seletivo fora do Kubernetes, mesmo com DNS funcional e NAT aparente no host

### Passos de validacao
1. Confirmar o status do root app:

```bash
use_ailab
kubectl -n argocd get applications.argoproj.io
kubectl -n argocd describe application ai-lab-root
```

2. Confirmar logs do `repo-server`:

```bash
use_ailab
kubectl -n argocd logs deploy/argocd-repo-server --tail=200
```

3. Comparar egress do host e de um pod:

```bash
curl -I https://github.com

use_ailab
kubectl run netcheck --rm -i --restart=Never --image=curlimages/curl:8.12.1 --command -- sh -c 'curl -4 -v --connect-timeout 5 --max-time 10 https://github.com -o /dev/null'
```

4. Validar alcance de rede basico de um pod:

```bash
use_ailab
kubectl run netcheck --rm -i --restart=Never --image=curlimages/curl:8.12.1 --command -- sh -c 'curl -k -I --max-time 10 https://kubernetes.default.svc && curl -I --max-time 10 https://1.1.1.1'
```

### Evidencia coletada ate agora
- `terraform -chdir=terraform/clusters/ai-lab/bootstrap plan -no-color` retorna `No changes`
- `argocd`, `ai-lab-root` e o secret inicial de admin foram criados com sucesso
- o `argocd-repo-server` registra `git fetch origin --tags --force --prune failed timeout after 1m30s`
- DNS para `github.com` resolve corretamente dentro do cluster
- a conexao TCP para `github.com:443` expira a partir de um pod comum
- a conexao para a API do Kubernetes funciona normalmente a partir do mesmo pod

### Acao corretiva
- ainda nao definida
- a trilha principal de investigacao deve focar em egress dos pods do `ai-lab` no ambiente Ubuntu sobre WSL no Windows 11
- evitar tratar como problema de Terraform ou credencial do Argo CD enquanto o timeout TCP externo persistir

## PostgreSQL em dev - pod nao fica pronto

### Sintoma
- pod `postgresql-0` fica em `CrashLoopBackOff` ou `Pending`
- readiness/liveness falhando

### Possiveis causas
- PVC nao foi provisionado ou nao ficou `Bound`
- credenciais invalidas no Secret `postgresql-auth`
- limite de recursos insuficiente no node

### Passos de validacao
1. Verificar estado geral dos recursos:

```bash
kubectl -n dev-apps get statefulset,pod,pvc,events --sort-by=.lastTimestamp
```

2. Verificar logs do pod:

```bash
kubectl -n dev-apps logs statefulset/postgresql --tail=200
```

3. Verificar Secret carregado no namespace:

```bash
kubectl -n dev-apps get secret postgresql-auth -o yaml
```

4. Validar pressao de recursos no cluster:

```bash
kubectl top node
kubectl -n dev-apps top pod
```

### Acao corretiva
- corrigir credenciais no Secret e ressincronizar o app
- ajustar requests/limits do StatefulSet para o perfil do host
- revisar StorageClass/PV local quando PVC nao estiver `Bound`