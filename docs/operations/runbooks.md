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