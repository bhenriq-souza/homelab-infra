# Hybrid Connectivity

## Objetivo
Definir a evolucao da conectividade entre o ambiente on-prem e a GCP sem antecipar implementacoes desta etapa.

## Estado atual (fase em execucao)
- conectividade apenas LAN local
- acesso administrativo do laptop ao mini PC via SSH
- sem VPN, sem tunel e sem conectividade privada com cloud
- foco em estabilidade operacional local

## Plano evolutivo por fases

### Fase futura 1 - conectividade privada simples (admin/testes)
Objetivo arquitetural:
- habilitar comunicacao privada basica entre on-prem e cloud para administracao e testes controlados

Escopo esperado:
- fluxos administrativos e de validacao tecnica entre ambientes
- baixa complexidade operacional no inicio

Resultado esperado:
- operacao remota basica entre ambientes sem exposicao publica desnecessaria

### Fase futura 2 - conectividade hibrida tipo site-to-site
Objetivo arquitetural:
- evoluir para um modelo mais completo de conectividade continua entre as redes

Escopo esperado:
- rotas entre blocos on-prem e cloud com governanca de trafego
- base para operacao recorrente entre ambientes

Resultado esperado:
- topologia hibrida mais previsivel, proxima de um cenario site-to-site

## Principio importante
- fleet (gestao de clusters) nao substitui conectividade de rede
- mesmo com fleet, comunicacao entre redes depende de desenho de conectividade, rotas e politicas

## Dependencias
- LAN local estavel e documentada (mini PC com DHCP reservado e SSH funcional)
- definicao futura de CIDRs de cluster local e cloud sem sobreposicao
- definicao do modelo de resolucao de nomes (DNS) para trafego hibrido
- criterios de exposicao de servicos administrativos e aplicacionais

## Decisoes pendentes
- qual modelo de conectividade privada sera adotado na fase futura 1
- quando evoluir da fase futura 1 para fase futura 2
- quais servicos exigirao somente acesso privado e quais poderao ter exposicao controlada
- estrategia final de DNS para recursos hibridos

## Cuidados de arquitetura e operacao
- CIDR: evitar qualquer sobreposicao entre LAN, cluster local e rede cloud
- rotas: garantir que o caminho entre redes seja explicito, previsivel e auditavel
- DNS: separar resolucao administrativa interna de nomes publicos quando necessario
- exposicao de servicos: priorizar acesso privado para administracao e publicar apenas o estritamente necessario

## Fora de escopo desta etapa
- implementacao de VPN/site-to-site
- provisionamento cloud real
- Terraform e automacao de infraestrutura
- implantacao de K3s e topologias de cluster