# Exposure Matrix

## Objetivo
Registrar quais serviços podem ser acessados, por quem e por qual caminho.

| Serviço | Ambiente | Tipo de acesso | Origem permitida | Observações |
|---|---|---|---|---|
| SSH host | local | privado | laptop/admin | chave obrigatória |
| Grafana | local | privado | operador | definir estratégia de autenticação |
| Loki | local | privado | operador/plataforma | acesso via gateway HTTP |
| Argo CD | local/cloud | privado | operador | detalhar no repo GitOps |