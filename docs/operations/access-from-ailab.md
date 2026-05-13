# Acesso ao Homelab a partir do AI Lab

## Objetivo

Configurar acesso administrativo ao host `hlb-beelink01` e ao cluster K3s do homelab a partir da workstation AI Lab, da mesma forma que o laptop admin já opera.

## Contexto

| Máquina | Papel | Localização | IP |
|---|---|---|---|
| `hlb-beelink01` | Homelab server — host K3s | LAN `192.168.15.0/24` | `192.168.15.97` |
| Laptop admin (WSL) | Administração principal | LAN `192.168.15.0/24` | DHCP dinâmico |
| AI Lab (Ubuntu workstation) | Dev environment | LAN `192.168.15.0/24` | `192.168.15.103` |

Tanto o laptop admin quanto o AI Lab estão na mesma LAN que o homelab. O procedimento é idêntico em ambos.

---

## Status de execução (2026-05-11)

| Item | Status |
|---|---|
| Parte 1 — SSH | ✅ Concluído |
| Parte 2 — Kubernetes | ✅ Concluído |

---

## Parte 1 — Acesso SSH

### 1. Verificar conectividade LAN

```bash
ping -c 3 192.168.15.97
```

**Status:** ✅ Concluído — 0% packet loss, RTT ~0.6ms.

---

### 2. Gerar par de chaves SSH no AI Lab

```bash
ssh-keygen -t ed25519 -C "hlb-ailab-admin" -f ~/.ssh/id_ed25519_homelab -N ""
```

**Status:** ✅ Concluído — chave em `~/.ssh/id_ed25519_homelab`.

---

### 3. Registrar a chave pública no homelab

Como o SSH já estava acessível via chave de trabalho no agent, a nova chave foi registrada sem necessidade de senha:

```bash
cat ~/.ssh/id_ed25519_homelab.pub | ssh hlb-beelink01-admin@192.168.15.97 \
  'cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys'
```

> Se o acesso SSH ainda não existir (bootstrap inicial), usar `ssh-copy-id`:
> ```bash
> ssh-copy-id -i ~/.ssh/id_ed25519_homelab.pub hlb-beelink01-admin@192.168.15.97
> ```

**Status:** ✅ Concluído.

---

### 4. Configurar `~/.ssh/config` no AI Lab

Entrada adicionada ao `~/.ssh/config`:

```
Host homelab
  HostName 192.168.15.97
  User hlb-beelink01-admin
  IdentityFile ~/.ssh/id_ed25519_homelab
  IdentitiesOnly yes
  ServerAliveInterval 30
  ServerAliveCountMax 3
```

**Status:** ✅ Concluído.

---

### 5. Validar acesso SSH por chave

```bash
ssh homelab hostnamectl --static
ssh homelab ip -4 a
```

**Status:** ✅ Concluído — login sem senha, hostname `hlb-beelink01` confirmado.

---

## Parte 2 — Acesso ao cluster Kubernetes

### 1. Instalar o `kubectl`

**Status:** ✅ Já instalado — v1.35.3.

---

### 2. Copiar o kubeconfig do homelab

```bash
mkdir -p ~/.kube
scp homelab:/etc/rancher/k3s/k3s.yaml ~/.kube/config-homelab.yaml
```

**Status:** ✅ Concluído — arquivo em `~/.kube/config-homelab.yaml`.

---

### 3. Substituir o endpoint local pelo IP LAN

```bash
sed -i 's|https://127.0.0.1:6443|https://192.168.15.97:6443|g' ~/.kube/config-homelab.yaml
```

**Status:** ✅ Concluído — `server: https://192.168.15.97:6443` confirmado.

---

### 4. Permissões do kubeconfig

```bash
chmod 700 ~/.kube
chmod 600 ~/.kube/config-homelab.yaml
```

**Status:** ✅ Concluído.

---

### 5. Funções de contexto no shell

Adicionado ao `~/.zshrc`:

```bash
# --- Homelab K8s context ---
export HOMELAB_KUBECONFIG="$HOME/.kube/config-homelab.yaml"

use_homelab() {
  export KUBECONFIG="$HOMELAB_KUBECONFIG"
  export KUBE_CONTEXT="default"
  echo "Perfil ativo: homelab"
  kctx_status
}

kctx_status() {
  echo "KUBECONFIG:      ${KUBECONFIG:-<não definido>}"
  echo "KUBE_CONTEXT:    ${KUBE_CONTEXT:-<não definido>}"
  echo "current-context: $(kubectl config current-context 2>/dev/null || echo '<indisponível>')"
  kubectl cluster-info 2>/dev/null | head -1 || echo "cluster-info: indisponível"
}
# ---
```

**Status:** ✅ Concluído — funções presentes no `~/.zshrc`.

---

### 6. Validar acesso ao cluster

```bash
use_homelab
kubectl get nodes -o wide
kubectl get pods -A
```

**Status:** ✅ Concluído — 1 nó `Ready`, todos os pods saudáveis.

---

## Regra operacional

Antes de qualquer operação contra o cluster a partir do AI Lab:

```bash
use_homelab
kctx_status
```

Não confiar em contexto herdado de sessão anterior — sempre selecionar explicitamente.

---

## Referências

- IP do homelab: `192.168.15.97` — documentado em `docs/network/ip-plan.md`
- Usuário administrativo: `hlb-beelink01-admin` — documentado em `docs/operations/host-setup.md`
- Funções de contexto: convenção definida em `docs/operations/runbooks.md`
- Exposure matrix do SSH: `docs/network/exposure-matrix.md`
