# Host Setup

## Objetivo
Documentar, em ordem executável, a instalação e preparação do host físico on-prem que sustentará o laboratório.

## Resultado esperado da fase
- Ubuntu Server 24.04 LTS instalado no mini PC
- host com hostname padrão do projeto
- usuário administrativo operacional com acesso remoto por SSH
- IP estável definido
- atualizações iniciais aplicadas
- baseline de segurança inicial aplicada

## Pré-requisitos
- imagem ISO oficial do Ubuntu Server 24.04 LTS validada
- pendrive bootável preparado
- acesso ao roteador para reserva DHCP (preferencial) ou plano de IP estático
- chave SSH pública do laptop de administração
- janela de manutenção para instalação e reboot

## Passo a passo

### 1. Preparar BIOS/UEFI do mini PC
- atualizar BIOS/UEFI para versão estável mais recente do fabricante
- habilitar boot UEFI
- definir pendrive como primeiro dispositivo de boot para a instalação
- manter virtualização habilitada

### 2. Instalar Ubuntu Server 24.04 LTS
- iniciar o instalador pelo pendrive
- selecionar idioma e layout de teclado
- configurar disco conforme simplicidade operacional:
	- opção recomendada: um disco principal com partições padrão do instalador
	- swap: manter padrão sugerido pelo instalador
- selecionar instalação de OpenSSH Server durante o instalador

### 3. Definir identidade do host
- hostname recomendado: `hlb-mini01`
- criar usuário administrativo local (exemplo): `opsadmin`
- usar senha forte e única para acesso local

### 4. Garantir acesso administrativo
- confirmar que o usuário administrativo tem permissão de sudo
- validar login local com o usuário criado

Comando de validação:

```bash
id opsadmin
sudo -l
hostnamectl
```

### 5. Configurar SSH para acesso remoto
- confirmar serviço SSH ativo após boot
- cadastrar chave pública do laptop em `~/.ssh/authorized_keys` do usuário administrativo
- validar acesso remoto por chave antes de encerrar sessão local

Comandos de validação:

```bash
sudo systemctl status ssh
ss -tulpen | grep ':22'
```

### 6. Definir IP estável
- abordagem preferencial: reserva DHCP no roteador para o MAC address do mini PC
- alternativa: IP estático via netplan, se reserva DHCP não for viável
- registrar IP final no inventário operacional

Comandos de validação:

```bash
ip -4 a
ip r
```

### 7. Aplicar updates iniciais
- atualizar índice de pacotes
- aplicar atualizações de segurança e correções recomendadas
- reiniciar o host se kernel ou componentes críticos forem atualizados

Comandos:

```bash
sudo apt update
sudo apt full-upgrade -y
sudo apt autoremove -y
sudo reboot
```

### 8. Aplicar baseline de segurança inicial
- manter autenticação por chave SSH como padrão operacional
- desabilitar login root por SSH
- desabilitar autenticação por senha no SSH após validação de chave
- habilitar firewall com política mínima de entrada
- manter apenas portas necessárias (SSH e futuras portas explicitamente aprovadas)

Referência de configuração (`/etc/ssh/sshd_config`):

```conf
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
```

Comandos de validação:

```bash
sudo sshd -t
sudo systemctl restart ssh
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow OpenSSH
sudo ufw --force enable
sudo ufw status verbose
```

## Critérios de conclusão deste documento
- acesso SSH por chave funcionando para o usuário administrativo
- host com IP estável e hostname definido
- pacotes atualizados sem pendências críticas
- baseline de segurança aplicada e validada

## Evidências mínimas a registrar
- saída de `hostnamectl`
- saída de `ip -4 a` com IP final
- saída de `sudo ufw status verbose`
- confirmação de login SSH por chave a partir do laptop de administração

## Dependências para próxima fase
- IP final do host consolidado para documentação de rede
- acesso remoto estável para instalação do K3s na Fase 03