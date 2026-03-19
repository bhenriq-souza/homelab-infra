# Bootstrap Checklist

## Host
- [ ] instalar Ubuntu Server 24.04 LTS
- [ ] definir hostname do host como `hlb-beelink01`
- [ ] configurar usuário `hlb-beelink01-admin` com sudo
- [ ] habilitar SSH e iniciar janela curta de transição (24h)
- [ ] validar SSH por chave em 2 sessões independentes
- [ ] validar reboot remoto e reconexão por chave
- [ ] encerrar transição desabilitando senha no SSH
- [ ] definir IP estável com reserva DHCP no MitraStar (hostname + MAC + IP)
- [ ] aplicar updates iniciais (`apt update`, `apt full-upgrade`)
- [ ] aplicar baseline de segurança (sshd + UFW com somente OpenSSH liberado)
- [ ] validar conectividade do laptop para o host

## Infra
- [ ] criar estrutura inicial do repositório
- [ ] criar backlog técnico
- [ ] preparar Terraform base
- [ ] definir naming e ranges IP

## Plataforma
- [ ] preparar cluster local
- [ ] preparar conectividade híbrida
- [ ] preparar fundação cloud