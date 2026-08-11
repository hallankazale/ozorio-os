# Arquitetura do Ozorio OS 0.1

## Objetivo

Criar uma distribuição Linux leve, modular e reproduzível, com identidade visual própria e foco em computadores antigos.

## Camadas

1. **Base do sistema**
   - Debian/Q4OS como base de referência
   - Kernel e drivers mantidos pela distribuição base

2. **Desktop**
   - Ambiente leve
   - Tema inspirado no Windows 7, sem copiar marcas ou ícones proprietários
   - Branding Ozorio em splash, login, menu e atalhos

3. **Aplicações próprias**
   - Central de Desenvolvimento
   - Central de Hacker

4. **Pacotes opcionais**
   - Ferramentas pesadas de desenvolvimento e segurança instaladas sob demanda

5. **Build**
   - Scripts versionados
   - Saída reproduzível para geração de ISO

## Metas de desempenho

- Priorizar baixo consumo de RAM em repouso
- Evitar serviços desnecessários na inicialização
- Carregar ferramentas pesadas apenas quando solicitadas

## Segurança

- Ferramentas de segurança destinadas a laboratório, CTFs e ambientes autorizados
- Nenhuma credencial ou segredo deve ser armazenado no repositório
- Scripts devem falhar de forma segura e validar dependências

## Estratégia de testes

- ShellCheck nos scripts
- Testes de sintaxe
- Validação de arquivos esperados no rootfs
- Testes manuais de boot, rede, áudio, vídeo e instalador
