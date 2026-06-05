# MochaArch — Login SDDM com wallpaper do desktop

Timestamp: 20260602-175323

## Regra permanente

O login SDDM do MochaArch deve usar o mesmo papel de parede/visual aplicado no desktop Plasma.

Se o SDDM cair no visual antigo/padrão, a correção canônica é:

- manter SDDM em Wayland;
- definir explicitamente `Current=mocha-login`;
- criar/atualizar `/usr/share/sddm/themes/mocha-login`;
- copiar o wallpaper atual do Plasma para o tema;
- apontar `theme.conf.user` para esse wallpaper;
- evitar configs duplicadas em `/etc/sddm.conf.d`.

## Estado aplicado

- Tema SDDM: `mocha-login`
- Wallpaper usado: `/media/mochafast/MochaArch/ativo/assets/branding/wallpaper/mocha-wallpaper-kdePCan-20260529-1634032.png`
- Cópia no tema: `/usr/share/sddm/themes/mocha-login/mocha-login-wallpaper-20260602-175323png.png`
- Config canônica: `/etc/sddm.conf.d/99-mocha-login-wallpaper-wayland.conf`
- Backup das configs antigas: `/etc/sddm.conf.d/mocha-backup-login-wallpaper-20260602-175323`

## Observação

Esta regra não altera kernel, GRUB, NVIDIA nem entrada de boot.
