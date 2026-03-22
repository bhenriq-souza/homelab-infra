# Phase 03 - K3s

## Objetivo
Instalar e validar um cluster K3s local single-node no mini PC on-prem, com baseline mínima de operação para as próximas fases.

## Escopo desta fase
- instalar K3s em modo server single-node
- validar acesso ao cluster local via `kubectl`
- confirmar estado de saúde dos componentes base do cluster
- preparar namespaces base iniciais
- registrar parâmetros mínimos de rede do cluster (Pod CIDR e Service CIDR)

Referência operacional:
- executar o procedimento em `docs/operations/runbooks.md` na seção `Runbook - Bootstrap inicial K3s single-node`

## Fora de escopo desta fase
- observabilidade
- Argo CD / GitOps
- Terraform
- conectividade híbrida on-prem + cloud
- instalação de aplicações de negócio

## Pré-requisitos do host
- Ubuntu Server 24.04 LTS já validado no mini PC
- acesso SSH funcional a partir do laptop administrativo
- IP estável por reserva DHCP (LAN `192.168.15.0/24`)
- usuário com privilégios de sudo
- conectividade de saída para internet no host (download de binários e imagens)
- baseline inicial de host aplicada ou em estágio controlado (especialmente SSH estável)

## Parâmetros iniciais do cluster
- modelo de implantação: single-node (server único)
- Pod CIDR proposto: `10.42.0.0/16`
- Service CIDR proposto: `10.43.0.0/16`
- política de simplicidade: instalar primeiro, expandir depois

## Estratégia de instalação inicial (incremental)

### 1. Preparar execução no host
- acessar o mini PC por SSH com usuário administrativo
- confirmar hostname, IP e rota padrão
- validar sincronismo de data/hora e conectividade de saída

Validações sugeridas:

```bash
hostnamectl --static
ip -4 a
ip r
timedatectl status
curl -I https://get.k3s.io
```

### 2. Instalar K3s server (single-node)
- executar instalação com parâmetros explícitos de rede do cluster
- seguir canal estável do K3s no bootstrap inicial
- manter a instalação simples, com Traefik embutido nesta etapa

Comando base sugerido:

```bash
curl -sfL https://get.k3s.io | \
	INSTALL_K3S_CHANNEL="stable" \
	INSTALL_K3S_EXEC="server --cluster-cidr=10.42.0.0/16 --service-cidr=10.43.0.0/16" sh -
```

### 3. Validar serviço e bootstrap do cluster
- confirmar serviço `k3s` ativo
- validar `kubectl` local via contexto padrão do K3s
- confirmar nó `Ready`
- confirmar pods de sistema em execução no namespace `kube-system`

Validações sugeridas:

```bash
sudo systemctl status k3s --no-pager
sudo kubectl get nodes -o wide
sudo kubectl get pods -n kube-system
sudo kubectl cluster-info
sudo kubectl get svc -A
```

### 4. Preparar acesso administrativo ao kubeconfig
- registrar caminho padrão do kubeconfig: `/etc/rancher/k3s/k3s.yaml`
- estratégia escolhida para bootstrap inicial:
	- distribuir kubeconfig administrativo para o laptop
	- permitir operação remota via `kubectl` sem depender de sessão SSH ativa no host

Cuidados operacionais obrigatórios:
- tratar o kubeconfig administrativo como artefato sensível (contém credenciais e dados críticos)
- armazenar o arquivo em diretório protegido no laptop, com permissões restritas
- evitar compartilhamento por canais inseguros (chat, e-mail, pastas públicas)
- registrar que a cópia externa do kubeconfig pode exigir atualização futura por rotação/renovação de certificados inline

Comandos de exemplo (host -> laptop):

```bash
# no host
sudo cat /etc/rancher/k3s/k3s.yaml

# no laptop (após copiar o conteúdo), ajustar endpoint para o IP LAN do host
kubectl config view
kubectl get nodes -o wide
```

### 5. Criar namespaces base (mínimo)
- criar namespaces organizacionais iniciais para separar workloads futuros
- sugestão mínima inicial:
	- `platform-system`
	- `apps`

Comandos sugeridos:

```bash
sudo kubectl create namespace platform-system
sudo kubectl create namespace apps
sudo kubectl get ns
```

## Validações esperadas após instalação
- serviço `k3s` ativo e habilitado no boot
- comando `kubectl get nodes` retorna 1 nó em estado `Ready`
- componentes do `kube-system` sem falhas persistentes
- Pod CIDR e Service CIDR aplicados conforme definido
- namespaces base criados com sucesso

Validações de rede do cluster:

```bash
sudo kubectl cluster-info dump | grep -E "cluster-cidr|service-cidr" -n
```

Observação:
- a validação exata de CIDRs pode variar por versão/distribuição; se necessário, complementar com inspeção de argumentos do processo `k3s` via `systemctl cat k3s`.

## Critérios de aceite (concretos)
- K3s instalado no mini PC sem necessidade de rollback
- `k3s` inicia automaticamente após reboot do host
- cluster reporta 1 nó `Ready` de forma estável
- Pod CIDR e Service CIDR do cluster definidos e documentados
- namespaces base iniciais existentes
- documentação da fase atualizada com passos executáveis e validações

## Suposições
- ambiente local seguirá single-node por pelo menos as fases iniciais
- não haverá exposição pública de serviços nesta fase
- manter Traefik embutido no bootstrap inicial não bloqueia a decisão de ingress final em fase posterior

## Decisões definidas para o bootstrap inicial
- ingress inicial: manter Traefik embutido do K3s
- operação administrativa: distribuir kubeconfig para o laptop e operar remotamente via `kubectl`
- política de versão no bootstrap: seguir canal estável do K3s

## Decisões ainda pendentes para fases futuras
- quando (e se) substituir Traefik embutido por outro ingress controller
- política de rotação e distribuição contínua de kubeconfig administrativo
- estratégia de pinagem de versão exata do K3s após estabilização inicial

## Riscos e mitigação mínima
- risco: conflito de rede entre ranges do cluster e LAN/cloud futura
- mitigação: usar CIDRs `10.42.0.0/16` e `10.43.0.0/16`, mantendo revisão antes da fase híbrida
- risco: falha de acesso administrativo pós-instalação
- mitigação: manter SSH validado e registrar procedimento de recuperação do serviço `k3s`