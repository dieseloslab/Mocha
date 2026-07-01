# Mocha Updater RS - desenho inicial

Objetivo: substituir o updater antigo por ferramenta conservadora em Rust.

## Separação obrigatória

1. Atualização geral:
   - pacman
   - KDE
   - Flatpak
   - AUR, se futuramente permitido
   - Discover em perfil Flatpak-only, sem PackageKit Arch

2. Kernel/driver:
   - fluxo separado
   - requer fallback
   - requer benchmark
   - nunca converter Arch em CachyOS automaticamente

## Fases

### Fase 0 - inventário
Detecta CPU, instruções, GPU, kernel, driver, DKMS, repositórios, bootloader, rootfs e Flatpaks.

### Fase 1 - recomendação
Monta candidatos:
- kernel atual como baseline
- Arch linux-zen
- CachyOS default
- CachyOS BORE
- CachyOS LTS apenas como fallback/estabilidade
- driver NVIDIA casado conforme geração e kernel

### Fase 2 - benchmark
Cada candidato deve ser testado em reboot separado, com fallback garantido.

Métricas mínimas:
- boot ok
- sessão gráfica ok
- driver GPU carregado
- Vulkan ok
- MangoHud/GameMode/TuneD ok
- FPS médio
- 1% low
- frametime médio
- frametime p95/p99
- temperatura
- travamentos/erros journal

### Fase 3 - promoção
Só vira padrão se vencer baseline e não quebrar estabilidade.

## Regras de segurança

- dry-run por padrão
- nenhuma transação sem plano impresso
- snapshot/backup antes de kernel/driver
- manter kernel anterior
- manter entrada bootável anterior
- log obrigatório
- rollback explícito
