# Secrets Strategy

## Objetivo
Definir como segredos serão tratados sem exposição indevida no repositório.

## Regras
- nunca commitar segredos reais
- usar arquivos de exemplo para variáveis
- documentar origem e destino dos segredos
- manter distinção entre segredo de infra e segredo de aplicação

## Tipos de segredo
- credenciais GCP
- tokens de CI
- credenciais de acesso administrativo
- segredos do app