# ADR-0005: Host ai-lab on GCP and Defer K3s Install

## Status
Accepted

## Context
O discovery e o pricing do ai-lab foram concluídos.

O experimento inicial com um cluster K3s do `ai-lab` rodando localmente em Ubuntu sobre WSL no laptop administrador ajudou a validar a estrutura GitOps multi-cluster, mas divergiu da direção arquitetural final.

O objetivo consolidado agora é preparar primeiro a infraestrutura base na GCP, mantendo a solução simples, reutilizável e de baixo acoplamento, para só depois instalar o K3s nessa base.

Também ficou decidido que esta etapa não deve aprofundar especializações para máquinas com GPU nativa nem introduzir complexidade de rede prematura, como VPN ou NAT dedicados.

## Decision
- hospedar o `ai-lab` na GCP
- destruir e descontinuar o cluster K3s provisório criado no laptop administrador
- entregar nesta fase apenas a fundação cloud necessária para receber o futuro cluster
- manter a infraestrutura como código parametrizável por poucos inputs principais, como projeto, região, zona, prefixos, CIDR e tipo de máquina
- adiar o bootstrap do Argo CD e a criação do kubeconfig do `ai-lab` até a fase em que o K3s for instalado
- manter a árvore GitOps `clusters/ai-lab` como scaffold preparado para a etapa futura, sem tratá-la como cluster ativo agora
- não aprofundar automações específicas para GPU nesta entrega

## Consequences
### Positivas
- alinha a implementação com a direção arquitetural final
- reduz retrabalho operacional e divergência entre documentação e ambiente real
- mantém a base pronta para evolução incremental até o futuro K3s
- simplifica a topologia inicial da cloud com IP público restritivo e sem VPN/NAT nesta fase
- melhora o reaproveitamento do Terraform ao separar fundação cloud de bootstrap Kubernetes

### Negativas
- o `ai-lab` não fica imediatamente reconciliado por Argo CD nesta entrega
- a instalação do K3s e o bootstrap GitOps passam a depender de uma etapa posterior
- parte da documentação operacional antiga do experimento local precisa ser removida ou reescrita

## Alternatives Considered
- manter o `ai-lab` no laptop administrador como caminho final
- instalar o K3s na GCP já nesta mesma entrega
- avançar desde já em automações específicas para GPU nativa