# Phase 08 - AI Lab GCP Foundation

## Objetivo
Provisionar a infraestrutura base do `ai-lab` na GCP, mantendo a solução simples, reutilizável e preparada para receber o K3s em uma etapa posterior.

## Escopo desta entrega
- VPC dedicada para o `ai-lab`
- subnet principal parametrizável
- firewall restritivo para SSH administrativo
- reserva de IP público estático
- VM base parametrizável por tipo de máquina e modelo de provisionamento
- disco adicional para dados do futuro cluster
- service account dedicada da VM
- documentação arquitetural e operacional corrigida

## Fora do escopo
- instalação do K3s
- bootstrap do Argo CD no `ai-lab`
- kubeconfig do `ai-lab`
- VPN, NAT ou conectividade privada híbrida
- escolhas finais de GPU nativa e automações associadas

## Entry point Terraform
- `terraform/clusters/ai-lab/foundation`

## Módulos reutilizáveis criados
- `terraform/modules/network-vpc`
- `terraform/modules/compute-vm`

## Parâmetros principais
- `project_id`
- `region`
- `zone`
- `name_prefix`
- `subnet_cidr`
- `admin_source_ranges`
- `machine_type`
- `instance_provisioning_model`
- `boot_disk_size_gb`
- `data_disk_size_gb`

## Defaults iniciais
- região: `us-central1`
- zona: `us-central1-a`
- subnet: `10.60.0.0/24`
- machine type: `e2-standard-4`
- provisioning model: `SPOT`

## Validação mínima
1. `terraform -chdir=terraform/clusters/ai-lab/foundation init -backend=false`
2. `terraform -chdir=terraform/clusters/ai-lab/foundation validate`
3. revisar `terraform/clusters/ai-lab/foundation/terraform.tfvars`
4. substituir `project_id` e `admin_source_ranges` pelos valores reais antes do primeiro `plan`

## Resultado esperado
- base cloud pronta para a futura instalação do K3s
- baixa quantidade de parâmetros para recriar o ambiente com outro sizing
- separação clara entre fundação cloud e bootstrap Kubernetes

## Tentativas recentes e status atual

### Objetivo tentado
- migrar a VM base para `n1-standard-8`
- usar apenas boot disk de `150 GB`
- remover o disco adicional de `200 GB`
- anexar `1 x nvidia-tesla-t4`
- restringir SSH e acesso ao Ollama ao egress publico do homelab

### Validacoes confirmadas
- quota regional de `NVIDIA_T4_GPUS` encontrada nas regioes tentadas
- egress publico do cluster `homelab` confirmado como `177.76.206.120`
- o mesmo NAT publico atende tanto o laptop admin quanto o cluster homelab

### Regioes e zonas tentadas
- `us-central1-a`: sem capacidade para `n1-standard-8 + 1 x T4`
- `us-central1-b`: sem capacidade para `n1-standard-8 + 1 x T4`
- `us-central1-c`: sem capacidade para `n1-standard-8 + 1 x T4`
- `us-central1-f`: sem capacidade para `n1-standard-8 + 1 x T4`
- `us-east1-b`: combinacao rejeitada na criacao com a configuracao solicitada
- `us-east1-c`: sem capacidade para `n1-standard-8 + 1 x T4`
- `us-east1-d`: sem capacidade para `n1-standard-8 + 1 x T4`
- `us-east4-b`: sem capacidade para `n1-standard-8 + 1 x T4`
- `europe-west1-b`: sem capacidade para `n1-standard-8 + 1 x T4`
- `europe-west1-c`: sem capacidade para `n1-standard-8 + 1 x T4`
- `europe-west1-d`: sem capacidade para `n1-standard-8 + 1 x T4`

### Resultado operacional
- a foundation foi destruida ao final das tentativas para evitar custos recorrentes
- ultimo `terraform destroy` removeu `11` recursos remanescentes
- o estado Terraform da foundation ficou vazio apos o rollback
- o arquivo de configuracao permaneceu com o ultimo alvo tentado para facilitar nova iteracao

### Implicacao para a proxima evolucao
- o bloqueio observado foi de capacidade real do Compute Engine, nao de quota nem de sintaxe do Terraform
- a proxima retomada deve considerar pelo menos uma destas alternativas:
	- restaurar a VM sem GPU
	- trocar a combinacao de maquina e GPU
	- tentar outra regiao apenas apos validar disponibilidade mais provavel do shape desejado