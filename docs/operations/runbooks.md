# Runbooks

## Objetivo
Centralizar procedimentos operacionais repetíveis.

## Exemplos
- validar conectividade
- validar Terraform
- preparar plano de mudança
- restaurar configuração

## Runbook - Bootstrap inicial K3s single-node

### Objetivo
Executar, validar e registrar a instalação inicial do K3s no mini PC local, com operação administrativa remota via kubeconfig no laptop.

### Escopo
- cluster local single-node
- Traefik embutido
- canal estável do K3s
- sem observabilidade, GitOps, Terraform ou conectividade híbrida

### Pré-check (host)
1. Conectar por SSH no mini PC com usuário administrativo.
2. Validar identidade e rede básica.
3. Validar saída para internet e relógio do sistema.

```bash
hostnamectl --static
ip -4 a
ip r
timedatectl status
curl -I https://get.k3s.io
```

Critério para seguir:
- host com IP esperado na LAN
- rota default ativa
- acesso HTTPS ao instalador do K3s

### Instalação (host)
4. Instalar K3s server em single-node, mantendo Traefik e usando canal estável.

```bash
curl -sfL https://get.k3s.io | \
	INSTALL_K3S_CHANNEL="stable" \
	INSTALL_K3S_EXEC="server --cluster-cidr=10.42.0.0/16 --service-cidr=10.43.0.0/16" sh -
```

5. Validar estado do serviço e bootstrap inicial do cluster.

```bash
sudo systemctl status k3s --no-pager
sudo systemctl is-enabled k3s
sudo kubectl get nodes -o wide
sudo kubectl get pods -n kube-system
sudo kubectl get svc -A
```

Critério para seguir:
- serviço `k3s` ativo e habilitado
- 1 nó em estado `Ready`
- pods de `kube-system` sem falha persistente

### Organização mínima (host)
6. Criar namespaces base para preparar fases seguintes.

```bash
sudo kubectl create namespace platform-system
sudo kubectl create namespace apps
sudo kubectl get ns
```

### Kubeconfig administrativo remoto (host -> laptop)
7. Obter kubeconfig no host.
8. Copiar para o laptop em diretório protegido.
9. Ajustar endpoint do servidor para o IP LAN do mini PC (se necessário).

Exemplo de caminho no laptop:
- `~/.kube/config-homelab`

Permissões recomendadas no laptop:

```bash
chmod 700 ~/.kube
chmod 600 ~/.kube/config-homelab
```

Validação remota no laptop:

```bash
KUBECONFIG=~/.kube/config-homelab kubectl get nodes -o wide
KUBECONFIG=~/.kube/config-homelab kubectl get pods -n kube-system
```

Regras de segurança obrigatórias:
- tratar kubeconfig administrativo como arquivo sensível
- não enviar kubeconfig por canais inseguros
- não versionar kubeconfig em repositório
- revisar permissões do arquivo após cada atualização

Observação operacional:
- a cópia externa do kubeconfig pode precisar ser atualizada futuramente por rotação/renovação de certificados inline

### Validação final e registro
10. Validar reboot do host e retorno automático do K3s.

```bash
sudo reboot
```

Após reconexão SSH:

```bash
sudo systemctl status k3s --no-pager
sudo kubectl get nodes
```

11. Registrar evidências mínimas:
- saída de `kubectl get nodes -o wide`
- saída de `kubectl get pods -n kube-system`
- confirmação dos CIDRs (`10.42.0.0/16`, `10.43.0.0/16`)
- confirmação de acesso remoto via kubeconfig no laptop

### Troubleshooting rápido
- se `k3s` não subir: `sudo journalctl -u k3s -n 200 --no-pager`
- se `kubectl` remoto falhar: revisar endpoint no kubeconfig e permissões do arquivo
- se houver erro de certificado remoto: renovar a cópia externa do kubeconfig a partir do host

## Runbook - Bootstrap Terraform (shared, dev, prd)

### Objetivo
Executar o bootstrap Terraform do laboratorio a partir do laptop administrador, aplicando os ambientes `shared`, `dev` e `prd` no cluster K3s remoto.

### Escopo
- execucao remota via laptop administrador
- instalacao/bootstrap inicial do Argo CD no ambiente `shared`
- criacao da base logica dos ambientes `dev` e `prd`

### Pre-check (laptop administrador)
1. Validar ferramentas necessarias.

```bash
terraform -version
kubectl version --client
helm version
```

2. Definir kubeconfig e contexto alvo para a sessao atual.

```bash
export KUBECONFIG=/home/<usuario>/.kube/config-homelab.yaml
export KUBE_CONTEXT=default
```

3. Validar contexto e conectividade com a API do cluster.

```bash
kubectl config current-context --kubeconfig "$KUBECONFIG"
kubectl cluster-info --kubeconfig "$KUBECONFIG"
kubectl get nodes --kubeconfig "$KUBECONFIG"
```

Critério para seguir:
- contexto correto selecionado
- API Kubernetes acessivel
- ao menos um no em estado `Ready`

### Execucao (laptop administrador)
4. Rodar bootstrap completo pela ordem padrao (`shared`, `dev`, `prd`).

```bash
./terraform/scripts/bootstrap-order.sh
```

Comportamento esperado:
- `init`, `plan` e `apply` para cada ambiente
- em `shared`, criacao/bootstrap do Argo CD
- em `dev` e `prd`, aplicacao dos namespaces e recursos base

### Validacao pos-apply
5. Validar estado Terraform por ambiente.

```bash
terraform -chdir=terraform/environments/shared output
terraform -chdir=terraform/environments/dev output
terraform -chdir=terraform/environments/prd output
```

6. Validar recursos no cluster.

```bash
kubectl get ns
kubectl -n argocd get pods
kubectl -n argocd get applications.argoproj.io
```

Critério de sucesso:
- apply concluido sem erro nos tres ambientes
- namespace `argocd` existente e pods do Argo CD saudaveis
- aplicacao raiz do bootstrap presente no Argo CD

### Troubleshooting rapido

#### Erro de provider kubectl
Sintoma:

```text
registry.terraform.io does not have a provider named registry.terraform.io/hashicorp/kubectl
```

Validacao:

```bash
terraform -chdir=terraform/environments/shared providers
```

Acao:
- confirmar source `gavinbunney/kubectl` no modulo `terraform/modules/argocd-bootstrap/versions.tf`
- reexecutar `terraform -chdir=terraform/environments/shared init -upgrade`

#### Erro de contexto Kubernetes inexistente
Sintoma:

```text
Provider configuration: cannot load Kubernetes client config
context "default" does not exist
```

Validacao:

```bash
kubectl config get-contexts --kubeconfig "$KUBECONFIG"
kubectl config current-context --kubeconfig "$KUBECONFIG"
```

Acao:
- garantir `KUBECONFIG` apontando para o arquivo correto
- ajustar `KUBE_CONTEXT` para um contexto existente no arquivo carregado

### Evidencias minimas a registrar
- saida do `terraform` com sucesso para `shared`, `dev` e `prd`
- saida de `kubectl get nodes`
- saida de `kubectl -n argocd get pods`
- saida de `kubectl -n argocd get applications.argoproj.io`

## Runbook - Validacao de app de teste e logs

### Objetivo
Validar rapidamente um workload HTTP de teste no ambiente logico `dev`, incluindo chamadas de sucesso, erro e verificacao de logs de aplicacao.

### Escopo
- validar resposta HTTP 200
- validar resposta HTTP de erro (500)
- confirmar geracao de logs no stdout do container

### Pre-check
1. Confirmar que os apps GitOps de workload estao `Synced` e `Healthy` no Argo CD.
2. Confirmar pods do app em execucao.

```bash
kubectl -n dev-apps get pods -l app.kubernetes.io/name=myapp
```

### Teste HTTP (sucesso e erro)
3. Testar endpoint de sucesso (200) no ambiente `dev`.

```bash
kubectl -n dev-apps port-forward svc/myapp 18080:80
curl -i http://127.0.0.1:18080/get
```

Resultado esperado:
- status `200 OK`
- payload JSON retornado pelo servico

4. Testar endpoint de erro controlado (500) no ambiente `dev`.

```bash
curl -i http://127.0.0.1:18080/status/500
```

Resultado esperado:
- status `500 Internal Server Error`

### Validacao de logs de aplicacao
6. Consultar logs do deployment em `dev`.

```bash
kubectl -n dev-apps logs deploy/myapp --tail=100
```

Resultado esperado:
- entradas de log das requisicoes `GET /get`
- entradas de log das requisicoes `GET /status/500`

### Criterios de aceite operacionais
- app responde `200` no endpoint de sucesso
- app responde `500` no endpoint de erro controlado
- logs mostram as requisicoes realizadas no ambiente `dev`

### Evolucao posterior
- promover o mesmo app de teste para `prd` apenas quando a fase de validacao em `dev` estiver concluida