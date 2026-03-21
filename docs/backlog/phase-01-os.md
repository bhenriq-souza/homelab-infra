# Phase 01 - OS

## Objetivo
Preparar o host on-prem com um sistema operacional estável e seguro.

## Escopo da fase
- instalar Ubuntu Server 24.04 LTS no mini PC
- definir identidade do host (hostname `hlb-beelink01` e usuário administrativo `hlb-beelink01-admin`)
- confirmar OpenSSH instalado no instalador do Ubuntu e validar serviço ativo
- validar acesso SSH com janela curta de transição
- configurar IP estável por reserva DHCP no roteador
- aplicar updates iniciais do sistema
- aplicar baseline mínima de segurança
- consolidar documentação operacional da instalação

## Fora de escopo
- instalação de K3s
- automações por scripts shell
- provisionamento com Terraform
- mudanças em ADRs

## Entregáveis
- `docs/operations/host-setup.md` com passo a passo executável
- host instalado, acessível remotamente e com IP estável
- baseline de segurança inicial aplicada

## Macrotarefas detalhadas
1. instalação do Ubuntu Server 24.04 LTS
2. definição de hostname e usuário administrativo
3. validação de sudo e acesso local
4. validação do serviço OpenSSH instalado no setup (enable + escuta na porta 22)
5. configuração de SSH por chave com janela de transição de 24h
6. validação de acesso SSH em duas sessões a partir do laptop (Windows 11 + WSL)
7. validação de reboot remoto e reconexão por chave
8. encerramento da transição com senha SSH desabilitada
9. configuração de IP estável por reserva DHCP (MitraStar)
10. aplicação de updates e reboot quando necessário
11. aplicação de baseline de segurança (SSH e firewall)
12. registro de evidências operacionais

## Critérios de aceite
- host responde em rede no IP estável definido por reserva DHCP
- hostname `hlb-beelink01` configurado e persistente após reboot
- usuário `hlb-beelink01-admin` existe, autentica localmente e possui sudo funcional
- OpenSSH está ativo e habilitado na inicialização (`systemctl status ssh` e `systemctl is-enabled ssh`)
- porta 22 está em escuta no host (`ss -tulpen | grep ':22'`)
- acesso SSH por chave funcional em duas sessões independentes a partir do laptop (WSL)
- reboot remoto validado com retorno de conectividade SSH por chave
- login root remoto desabilitado (`PermitRootLogin no`)
- autenticação por senha no SSH desabilitada ao final da janela de transição (`PasswordAuthentication no`)
- reserva DHCP criada no roteador para MAC do host com IP do mini PC documentado
- firewall habilitado com política de entrada restritiva e OpenSSH liberado
- atualizações iniciais aplicadas sem pendências críticas
- documentação operacional atualizada e utilizável como checklist executável

## Validação objetiva (DoD da fase)
- validar `hostnamectl` com hostname esperado
- validar `id <usuario-admin>` e `sudo -l`
- validar `sudo systemctl status ssh` e `sudo systemctl is-enabled ssh`
- validar `sudo ss -tulpen | grep ':22'`
- validar conectividade SSH por chave em 2 sessões simultâneas
- validar reboot remoto e reconexão SSH por chave
- validar `ip -4 a` com IP final planejado
- validar reserva DHCP no roteador (hostname + MAC + IP)
- validar `sudo ufw status verbose`
- validar reinicialização e retorno do acesso remoto

## Encerramento da fase 01
Concluir a fase somente quando todos os critérios de aceite forem atendidos e as evidências mínimas estiverem registradas em documentação operacional.

Data formal de encerramento desta fase: `2026-03-21`

Checklist de encerramento:
- confirmar que o host está acessível do laptop exclusivamente por SSH na LAN
- confirmar que a senha SSH foi desabilitada após validação em duas sessões e reboot
- confirmar que IP reservado, MAC e gateway foram registrados no plano de IP
- confirmar ausência de bloqueios para iniciar a fase 02 (rede local)
- registrar data de encerramento da fase e pendências que ficam para fases futuras

## Dependências desbloqueadas para próximas fases
- Fase 02 (rede): host identificado e endereçado de forma estável
- Fase 03 (k3s): base do sistema operacional pronta e segura