# MochaArch - nota operacional de pacotes base - 20260604-101928

## Aplicado
- Instalação dos softwares padrão ausentes detectados na auditoria.
- Steam, GameMode, MangoHud, Vivaldi, Bitwarden, UFW/GUFW, BlueZ utils, TuneD, 7zip, zip e unzip.
- Wrapper canônico: /home/hal/.local/bin/mocha-steam-game-run
- Launch Option canônica da Steam: /home/hal/.local/bin/mocha-steam-game-run %command%
- Firewall: entrada negada, saída liberada, sem reset de regras existentes.
- DNS: systemd-resolved + Cloudflare DNS-over-TLS.

## JACK
- jack2 preservado; pipewire-jack não instalado para não remover jack2 sem ordem explícita

## Correção V3
- pipewire-jack não força remoção de jack2.
- configs MangoHud existentes recebem backup antes de substituição por symlink canônico.
- UFW não usa reset destrutivo.
- nenhum atalho Steam enganoso foi criado.

## Decisão sobre compactadores
- 7zip é o pacote canônico usado nesta montagem.
- p7zip é tratado como legado/substituído e não foi instalado como requisito canônico.
- zip e unzip continuam separados e foram instalados/confirmados.

## Itens preservados
- SDDM não foi alterado.
- GRUB/kernel não foram alterados.
- FAST/VMSTORE não foram refeitos.
