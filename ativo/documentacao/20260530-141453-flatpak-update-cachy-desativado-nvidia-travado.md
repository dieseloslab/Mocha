# MOCHA — Flatpak atualizado, CachyOS desativado e NVIDIA travado

Data: 2026-05-30T14:15:02-03:00

## O que foi feito

- Atualizados somente os runtimes Flatpak relevantes do Discover: org.freedesktop.Platform 25.08 e org.gnome.Platform 50.
- Confirmado que a origem desses runtimes é Flathub.
- Comentado o bloco de repositórios CachyOS V3 em /etc/pacman.conf para evitar contaminação futura.
- Adicionado IgnorePkg para linux-cachyos-bore-lto, linux-cachyos-bore-lto-nvidia-open, nvidia-utils e lib32-nvidia-utils.
- Atualizado apenas o banco do pacman com pacman -Sy; nenhum pacote pacman foi atualizado.

## Regra operacional

- Discover pode ser usado para Flatpak/Flathub, mas não para atualização geral de pacotes do sistema enquanto kernel/NVIDIA Cachy estiverem pinados.
- Atualizações de kernel/NVIDIA devem ser feitas manualmente, em par casado, com auditoria antes.

## Log

/media/mochafast/MochaArch/ativo/relatorios/20260530-141453-flatpak-update-cachy-desativado-nvidia-travado.log
