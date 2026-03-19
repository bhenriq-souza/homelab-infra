# Bootstrap Checklist

## Host
- [ ] instalar Ubuntu Server 24.04 LTS
- [ ] definir hostname do host (ex.: `hlb-mini01`)
- [ ] configurar usuário administrativo com sudo
- [ ] habilitar SSH e validar acesso remoto por chave
- [ ] definir IP estável (reserva DHCP preferencial ou IP estático)
- [ ] aplicar updates iniciais (`apt update`, `apt full-upgrade`)
- [ ] aplicar baseline de segurança (sshd + UFW)
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