# Current Focus

## Objetivo atual
Encerrar formalmente o bootstrap inicial do cluster local K3s no mini PC e preparar a transição para a próxima fase.

## Escopo
- consolidar evidências finais da execução do K3s single-node
- manter checklist aderente ao estado real concluído da etapa de bootstrap
- explicitar que pendências remanescentes são de fases posteriores (híbrido/cloud)

## Resultado esperado
- histórico de execução da fase 03 completo e rastreável
- bootstrap K3s sem pendências técnicas imediatas
- backlog pronto para mudança de foco de fase

## Fora de escopo
- observabilidade
- Argo CD
- Terraform
- conectividade híbrida implementada
- instalação de aplicações no cluster

## Critérios de aceite
- evidências do cluster `Ready` registradas na documentação
- kubeconfig remoto validado e registrado
- serviço `k3s` habilitado no boot e namespaces base criados documentados