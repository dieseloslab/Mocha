# MochaArch — estado pós-manual

- Timestamp: 20260602-100554
- Manual lido: /media/mochafast/MochaArch/ativo/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md
- Kernel/driver NVIDIA: tratados como já corretos; este script apenas auditou, não alterou.
- Login manager: SDDM habilitado como display-manager padrão para o próximo boot.
- SDDM Wayland: /etc/sddm.conf.d/10-mocha-wayland.conf com DisplayServer=wayland.
- FAST: /media/mochafast
- VMSTORE: /media/vmstore
- Base ativa: /media/mochafast/MochaArch/ativo
- Repositórios Cachy: desativados se estavam ativos, por serem temporários.
- Firewall: firewalld ativado.
- DNS: systemd-resolved com Cloudflare DNS-over-TLS.
- Flatpak/Flathub: configurado quando flatpak está disponível.
- MangoHud: configuração Mocha criada.
- Wrapper Steam canônico: /home/hal/.local/bin/mocha-steam-game-run %command%
- Bluetooth/volume duplicados: blueman-applet e kmix desativados no autostart, sem remover pacotes.
- Log: /media/mochafast/MochaArch/ativo/relatorios/20260602-100554-seguir-manual-pos-kernel-driver-com-login-manager.log
