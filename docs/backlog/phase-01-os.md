# Phase 01 - OS

## Objetivo
Preparar o host on-prem com um sistema operacional estável e seguro.

## Escopo da fase
- instalar Ubuntu Server 24.04 LTS no mini PC
- definir identidade do host (hostname `hlb-beelink01` e usuário administrativo `hlb-beelink01-admin`)
- habilitar e validar acesso SSH com janela curta de transição
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
4. configuração de SSH por chave com janela de transição de 24h
5. validação de acesso SSH em duas sessões e reboot remoto
6. encerramento da transição com senha SSH desabilitada
7. configuração de IP estável por reserva DHCP (MitraStar)
8. aplicação de updates e reboot quando necessário
9. aplicação de baseline de segurança (SSH e firewall)
10. registro de evidências operacionais

## Critérios de aceite
- host responde em rede no IP estável definido
- hostname `hlb-beelink01` configurado e persistente após reboot
- usuário `hlb-beelink01-admin` possui sudo funcional
- acesso SSH por chave funcional em duas sessões independentes a partir do laptop
- login root remoto desabilitado
- autenticação por senha no SSH desabilitada
- reboot remoto validado com retorno de conectividade SSH por chave
- reserva DHCP criada no roteador para MAC do host
- firewall habilitado com política de entrada restritiva e OpenSSH liberado
- atualizações iniciais aplicadas sem pendências críticas
- documentação operacional atualizada e utilizável como checklist

## Validação objetiva (DoD da fase)
- validar `hostnamectl` com hostname esperado
- validar `id <usuario-admin>` e `sudo -l`
- validar conectividade SSH por chave em 2 sessões simultâneas
- validar reboot remoto e reconexão SSH por chave
- validar `ip -4 a` com IP final planejado
- validar reserva DHCP no roteador (hostname + MAC + IP)
- validar `sudo ufw status verbose`
- validar reinicialização e retorno do acesso remoto

## Dependências desbloqueadas para próximas fases
- Fase 02 (rede): host identificado e endereçado de forma estável
- Fase 03 (k3s): base do sistema operacional pronta e segura