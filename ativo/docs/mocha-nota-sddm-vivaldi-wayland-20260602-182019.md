# MochaArch - SDDM Mocha e Vivaldi Wayland

Data: 20260602-182019

## SDDM

Problema encontrado:
- O arquivo de recuperação `/etc/sddm.conf.d/zz-mocha-sddm-wayland-recovery.conf` estava sobrescrevendo o tema Mocha com `Current=breeze`.
- O arquivo Mocha anterior declarava `Current=mocha-login`, mas perdia por precedência lexicográfica.

Correção aplicada:
- Criado arquivo final de maior precedência:
  - `/etc/sddm.conf.d/zzzz-mocha-sddm-login-wayland-final.conf`
- Tema efetivo:
  - `Current=mocha-login`
- Wayland preservado:
  - `DisplayServer=wayland`
- Wallpaper aplicado no tema Mocha:
  - `/usr/share/sddm/themes/mocha-login/mocha-login-wallpaper-current.png`

Regra Mocha:
- O login SDDM deve permanecer em Wayland.
- O tema de login deve permanecer sincronizado com o visual/papel de parede Mocha.
- Não usar X11 como fallback.

## Vivaldi

Problema encontrado:
- O log indicou incompatibilidade entre Vivaldi/Chromium em Wayland e Vulkan:
  - `--ozone-platform=wayland is not compatible with Vulkan`
- Também houve erro VAAPI/libva.
- O navegador gerou coredumps de renderer com SIGILL e SIGSEGV.

Correção aplicada:
- Criado lançador:
  - `/home/hal/.local/share/applications/mocha-vivaldi-wayland-stable.desktop`
- Wrapper:
  - `/home/hal/.local/bin/mocha-vivaldi-wayland-stable`
- Wayland preservado.
- Vulkan e VAAPI desativados no Vivaldi.
- X11 não foi usado.
