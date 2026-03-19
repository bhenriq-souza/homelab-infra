# Phase 01 - OS

## Objetivo
Preparar o host on-prem com um sistema operacional estável e seguro.

## Escopo da fase
- instalar Ubuntu Server 24.04 LTS no mini PC
- definir identidade do host (hostname e usuário administrativo)
- habilitar e validar acesso SSH
- configurar IP estável
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
4. configuração e validação de SSH por chave
5. configuração de IP estável (preferencialmente por reserva DHCP)
6. aplicação de updates e reboot quando necessário
7. aplicação de baseline de segurança (SSH e firewall)
8. registro de evidências operacionais

## Critérios de aceite
- host responde em rede no IP estável definido
- hostname configurado e persistente após reboot
- usuário administrativo possui sudo funcional
- acesso SSH por chave funcional a partir do laptop de administração
- login root remoto desabilitado
- autenticação por senha no SSH desabilitada
- firewall habilitado com política de entrada restritiva e OpenSSH liberado
- atualizações iniciais aplicadas sem pendências críticas
- documentação operacional atualizada e utilizável como checklist

## Validação objetiva (DoD da fase)
- validar `hostnamectl` com hostname esperado
- validar `id <usuario-admin>` e `sudo -l`
- validar conectividade SSH por chave
- validar `ip -4 a` com IP final planejado
- validar `sudo ufw status verbose`
- validar reinicialização e retorno do acesso remoto

## Dependências desbloqueadas para próximas fases
- Fase 02 (rede): host identificado e endereçado de forma estável
- Fase 03 (k3s): base do sistema operacional pronta e segura