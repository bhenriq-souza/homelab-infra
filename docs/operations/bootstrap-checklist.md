# Bootstrap Checklist

## Host
- [x] instalar Ubuntu Server 24.04 LTS
- [x] definir hostname do host como `hlb-beelink01`
- [x] configurar usuário `hlb-beelink01-admin` com sudo
- [x] confirmar OpenSSH instalado no setup e validar serviço ativo
- [x] iniciar janela curta de transição SSH (24h)
- [x] validar SSH por chave em 2 sessões independentes
- [x] validar reboot remoto e reconexão por chave
- [ ] encerrar transição desabilitando senha no SSH
- [x] definir IP estável com reserva DHCP no MitraStar (hostname + MAC + IP)
- [x] aplicar updates iniciais (`apt update`, `apt full-upgrade`)
- [ ] aplicar baseline de segurança (sshd + UFW com somente OpenSSH liberado)
- [x] validar conectividade do laptop para o host

## Infra
- [ ] criar estrutura inicial do repositório
- [ ] criar backlog técnico
- [ ] preparar Terraform base
- [ ] definir naming e ranges IP

## Plataforma
- [ ] instalar K3s single-node no mini PC
- [ ] validar serviço `k3s` ativo e habilitado no boot
- [ ] validar `kubectl get nodes` com 1 nó `Ready`
- [ ] validar pods do `kube-system` sem falhas persistentes
- [ ] confirmar Pod CIDR `10.42.0.0/16` e Service CIDR `10.43.0.0/16`
- [ ] criar namespaces base (`platform-system`, `apps`)
- [ ] preparar conectividade híbrida
- [ ] preparar fundação cloud