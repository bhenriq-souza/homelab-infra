# Host Setup

## Objetivo
Documentar, em ordem executável, a instalação e preparação do host físico on-prem que sustentará o laboratório.

## Resultado esperado da fase
- Ubuntu Server 24.04 LTS instalado no mini PC
- host com hostname `hlb-beelink01`
- usuário administrativo operacional com acesso remoto por SSH
- IP estável definido
- atualizações iniciais aplicadas
- baseline de segurança inicial aplicada

## Pré-requisitos
- imagem ISO oficial do Ubuntu Server 24.04 LTS validada
- pendrive bootável preparado
- acesso ao roteador para criar reserva DHCP
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
- hostname definido para o projeto: `hlb-beelink01`
- criar usuário administrativo local: `hlb-beelink01-admin`
- usar senha forte e única para acesso local

### 4. Garantir acesso administrativo
- confirmar que o usuário administrativo tem permissão de sudo
- validar login local com o usuário criado

Comando de validação:

```bash
id hlb-beelink01-admin
sudo -l
hostnamectl
```

### 5. Configurar SSH para acesso remoto
- confirmar serviço SSH ativo após boot
- cadastrar chave pública do laptop em `~/.ssh/authorized_keys` do usuário administrativo
- iniciar janela curta de transição para migração segura (recomendação: 24 horas)

#### 5.1. Janela curta de transição SSH (24h)
- durante a transição, manter senha temporariamente habilitada apenas para contingência
- validar acesso por chave em duas sessões independentes a partir do laptop
- validar sudo remoto e reboot remoto antes de desabilitar senha

Sessão A (terminal 1):

```bash
ssh hlb-beelink01-admin@<ip-do-host>
whoami
hostnamectl --static
```

Sessão B (terminal 2, em paralelo):

```bash
ssh hlb-beelink01-admin@<ip-do-host>
sudo -v
sudo whoami
```

Validação de reboot remoto (a partir de uma das sessões):

```bash
sudo reboot
```

Após o host voltar:
- reconectar nas duas sessões por chave
- confirmar que sudo continua funcional
- somente então avançar para desabilitar senha no SSH

Comandos de validação:

```bash
sudo systemctl status ssh
ss -tulpen | grep ':22'
```

### 6. Definir IP estável
- abordagem mandatória para este projeto: reserva DHCP no roteador (MitraStar Vivo)
- usar IP dentro da rede `192.168.15.0/24` e fora de conflitos já existentes
- registrar IP final no inventário operacional

#### 6.1. Procedimento no MitraStar GPT-2742GX4X5v6
- acessar: Configurações > Rede Local > DHCP
- confirmar que DHCP está habilitado
- identificar o mini PC na tabela de renovação por hostname/MAC
- em Criar uma reserva de IP:
	- preencher Hostname com o host do mini PC
	- preencher Endereço MAC com o MAC da interface principal
	- definir Endereço IP reservado (valor pendente de validação do range DHCP)
- clicar em Reservar e depois Aplicar
- reiniciar a interface de rede do host ou renovar lease DHCP

Observação:
- se o firmware exigir IP de reserva dentro do intervalo DHCP atual, escolher um IP livre no range `192.168.15.2-192.168.15.200`.
- nesse caso, priorizar uma faixa alta dedicada ao homelab (exemplo: `192.168.15.180-192.168.15.200`).

Comandos de validação:

```bash
ip -4 a
ip r
ip -br link
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
- após a janela de transição, desabilitar autenticação por senha no SSH
- habilitar firewall com política mínima de entrada
- na Fase 01, liberar somente OpenSSH no firewall

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

### 9. Encerrar janela de transição SSH
- editar `sshd_config` para bloquear autenticação por senha
- validar sintaxe da configuração
- reiniciar serviço SSH
- validar novamente login por chave em duas sessões

Comandos:

```bash
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudoedit /etc/ssh/sshd_config
sudo sshd -t
sudo systemctl restart ssh
```

## Critérios de conclusão deste documento
- acesso SSH por chave funcionando para o usuário administrativo
- autenticação por senha SSH desabilitada após validação em duas sessões e reboot remoto
- host com IP estável e hostname definido
- pacotes atualizados sem pendências críticas
- baseline de segurança aplicada e validada

## Evidências mínimas a registrar
- saída de `hostnamectl`
- saída de `ip -4 a` com IP final
- captura da reserva DHCP criada no roteador (hostname, MAC e IP)
- saída de `sudo ufw status verbose`
- confirmação de login SSH por chave a partir do laptop de administração

## Dependências para próxima fase
- IP final do host consolidado para documentação de rede
- acesso remoto estável para instalação do K3s na Fase 03