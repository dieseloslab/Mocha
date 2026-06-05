# MochaArch - DNS e TuneD - 20260604-102418

## Corrigido
- NetworkManager configurado para não aceitar DNS automático por DHCP nas conexões ativas.
- systemd-resolved mantido como resolvedor.
- Cloudflare DNS-over-TLS mantido como DNS global.
- /etc/resolv.conf apontando para /run/systemd/resolve/stub-resolv.conf.
- TuneD reiniciado e perfil de baixa latência reaplicado.

## Validação
- DNS do roteador 192.168.100.1 não deve aparecer mais nas linhas de DNS ativo.
- TuneD reaplicado; verify ainda indicou divergência. Ver relatório para detalhes.

## Preservado
- SDDM não alterado.
- GRUB/boot não alterados.
- Kernel/NVIDIA não alterados.
- Steam/wrapper/MangoHud não alterados.
- Tema/painel/wallpaper não alterados.
