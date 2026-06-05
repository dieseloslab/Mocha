# MochaArch - TuneD Mocha latency V2 - 20260604-102732

## Correção
- Corrigido caminho do perfil customizado para /etc/tuned/profiles/mocha-latency-performance/tuned.conf.
- Isolada tentativa anterior em /etc/tuned/mocha-latency-performance, caso existisse.
- Criado perfil TuneD: mocha-latency-performance.
- O perfil herda latency-performance.
- vm.swappiness preservado em 180 para manter agressividade Mocha/ZRAM.
- vm.page-cluster preservado em 0.
- Não foi reduzido swappiness para 10.

## Validação
- TuneD aplicado; verify não retornou sucesso explícito, mas não acusou vm.swappiness.

## Preservado
- SDDM não alterado.
- GRUB/boot não alterados.
- Kernel/NVIDIA não alterados.
- Steam/wrapper/MangoHud não alterados.
- Tema/painel/wallpaper não alterados.
- Firewall não alterado.
