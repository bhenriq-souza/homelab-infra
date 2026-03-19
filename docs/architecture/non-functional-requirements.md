# Non-Functional Requirements

## Operação
- o laboratório deve ser operável por uma pessoa
- troubleshooting deve ser simples
- documentação mínima é obrigatória

## Segurança
- acesso administrativo por SSH com chave
- segredos não devem ser versionados em texto puro
- princípio do menor privilégio sempre que possível

## Performance
- priorizar baixo consumo de recursos no host local
- manter a stack inicial enxuta
- evitar componentes desnecessariamente pesados nas primeiras fases

## Evolução
- permitir expansão incremental
- evitar acoplamento entre repositórios
- preservar clareza de responsabilidade por camada

## Agentic development
- tarefas devem ser pequenas
- contexto deve estar documentado
- decisões estruturais devem ser explícitas