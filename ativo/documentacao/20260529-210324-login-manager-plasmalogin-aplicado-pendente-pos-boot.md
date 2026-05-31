# Mocha Arch - Login Manager - Plasma Login Manager

Data: 20260529-210324

Estado: aplicado; pendente de validação após reboot/login.

O que foi feito:
- Validado que /media/mochafast e /media/vmstore estavam montados.
- Validado/instalado o pacote plasma-login-manager pelo pacman.
- Validada a presença de /usr/lib/systemd/system/plasmalogin.service.
- Validada a presença de /usr/bin/startplasma-login-wayland.
- Executado systemd-sysusers e systemd-tmpfiles para o plasmalogin.
- Desativados apenas serviços antigos de display manager que estivessem habilitados, sem parar a sessão atual.
- Ativado plasmalogin.service com systemctl enable --force para substituir display-manager.service.

O que NÃO foi feito:
- Não foi alterado teclado.
- Não foi alterado localectl.
- Não foi alterado /etc/vconsole.conf.
- Não foi removido SDDM nem qualquer outro pacote.
- Não foi usado X11 como fallback.
- Não foi reiniciado o login manager durante a sessão atual.

Validação final antes do reboot:
- display-manager.service -> /usr/lib/systemd/system/plasmalogin.service
- plasmalogin.service is-enabled -> enabled
- default target -> graphical.target

Arquivos gerados:
- Log: /media/mochafast/MochaArch/ativo/logs/20260529-210324-login-manager-plasmalogin.log
- Auditoria: /media/mochafast/MochaArch/ativo/relatorios/20260529-210324-login-manager-plasmalogin-auditoria.txt
- Script de verificação pós-boot: /media/mochafast/MochaArch/ativo/scripts/20260529-210324-mocha-verificar-plasmalogin-pos-boot.sh
