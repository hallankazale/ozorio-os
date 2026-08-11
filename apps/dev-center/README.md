# Central de Desenvolvimento

Aplicação modular do Ozorio OS para reunir ferramentas de desenvolvimento sem acoplar lógica ao desktop.

## MVP 0.1

- Projetos recentes
- Abrir terminal
- Abrir editor configurado
- Atalhos para Git, Python, Node.js e Java
- Estado de dependências instaladas
- Ações rápidas: novo projeto, importar, clonar e abrir

## Arquitetura prevista

A interface apenas orquestra comandos seguros e bem definidos. Instalação de pacotes e operações privilegiadas ficam em serviços/scripts separados com elevação explícita.
