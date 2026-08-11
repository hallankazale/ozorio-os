# Ozorio OS

Ozorio OS é uma distribuição Linux leve, com visual inspirado no Windows 7, voltada para computadores antigos e para um fluxo moderno de desenvolvimento.

## Visão

- Base Linux estável e leve
- Interface familiar, com identidade própria Ozorio
- Gradientes em roxo, azul-marinho e verde
- Central de Desenvolvimento integrada
- Central de Hacker voltada a laboratório, CTFs e ambientes autorizados
- Foco em baixo consumo de RAM

## Meta da versão 0.1

1. Inicializar a base do sistema
2. Aplicar branding Ozorio
3. Criar a Central de Desenvolvimento
4. Criar a Central de Hacker
5. Gerar uma ISO bootável
6. Validar rede, áudio, vídeo e desempenho em hardware antigo

## Estrutura

```text
ozorio-os/
├── apps/
│   ├── dev-center/
│   └── hacker-center/
├── branding/
├── configs/
│   ├── desktop/
│   └── system/
├── docs/
├── packages/
│   ├── development/
│   └── security/
├── scripts/
└── tests/
```

## Princípios

- Leve por padrão
- Ferramentas pesadas opcionais
- Configuração reproduzível
- Separação entre sistema, interface e ferramentas
- Segurança e testes desde o início

## Status

Projeto iniciado. Próximo passo: arquitetura da versão 0.1 e scripts de preparação/build.
