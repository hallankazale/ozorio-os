# Build da ISO Live — Ozorio OS 0.1

## Objetivo
Gerar uma ISO Live BIOS/amd64 para validar o Ozorio OS em PCs antigos antes da instalação em disco.

## Host recomendado
Use Debian/Ubuntu/Q4OS 64-bit com pelo menos 20 GB livres. O build exige privilégios de root para `debootstrap`, `chroot` e mounts temporários.

## Dependências no host

```bash
sudo apt update
sudo apt install -y debootstrap rsync squashfs-tools xorriso isolinux syslinux-common
```

## Fluxo

```bash
git clone https://github.com/hallankazale/ozorio-os.git
cd ozorio-os
sudo ./scripts/build-rootfs.sh
sudo ./scripts/build-live-iso.sh
```

A saída esperada será:

```text
build/output/ozorio-os-0.1-amd64.iso
build/output/ozorio-os-0.1-amd64.iso.sha256
```

## Boot
A v0.1 prioriza BIOS legado porque o primeiro hardware-alvo é um PC antigo. O menu oferece modo normal e modo seguro de vídeo (`nomodeset`). UEFI será adicionado em etapa posterior.

## Segurança
- O build falha se não for executado como root.
- Mounts temporários possuem rotina de limpeza via `trap`.
- Ferramentas de segurança ofensiva não são incluídas no perfil Live base.
- Pacotes pesados permanecem opcionais.

## Validação mínima
1. Validar SHA256 da ISO.
2. Gravar em pendrive com ferramenta confiável.
3. Iniciar em modo Live sem instalar no disco.
4. Confirmar vídeo, áudio, Ethernet/Wi-Fi, teclado ABNT2 e desligamento.
5. Medir RAM em repouso.
6. Abrir navegador e executar um smoke test de rede.

## Próximas etapas
- Branding Ozorio Aurora.
- Tela de login e menu estilo Windows 7 sem copiar marcas proprietárias.
- UEFI.
- Central de Desenvolvimento.
- Central de Hacker com ferramentas instaláveis sob demanda para laboratório autorizado/CTF.
