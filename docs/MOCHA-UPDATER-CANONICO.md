# Mocha Updater canônico

Estado canônico atual:
- Frontend Qt/Python aprovado.
- Visual com cards, botões e aba separada de Detalhes técnicos.
- Idiomas suportados: português, inglês, francês e espanhol; outros locales caem para inglês.
- Atualização geral conserva kernel e driver NVIDIA.
- Guia Kernel / Driver usa explicitamente o conjunto recomendado LQX/DKMS.
- Kernel recomendado: linux-lqx.
- Headers recomendados: linux-lqx-headers.
- Driver NVIDIA recomendado: nvidia-open-dkms com nvidia-utils e lib32-nvidia-utils.
- CachyOS permanece como histórico/fallback auditável e não deve ser apresentado como padrão estável.

Caminhos:
- App fonte: /media/mochafast/MochaArch/apps/mocha-updater
- Frontend: /media/mochafast/MochaArch/apps/mocha-updater/frontend/mocha-updater-qt.py
- Backend: /media/mochafast/MochaArch/apps/mocha-updater/scripts/mocha-updater-action-v1.sh
- Script de validação/manutenção: /media/mochafast/MochaArch/scripts/mocha-updater-lqx-dkms-canonico-v2.sh
- Executável: /usr/local/bin/mocha-updater
- Menu Sistema/KDE: /usr/share/applications/mocha-updater.desktop
- Atalho de teste no Desktop: ~/Desktop/mocha-updater.desktop

Proibições:
- Não voltar para Rust/egui simples reprovado.
- Não voltar para kdialog, zenity, whiptail, prompt ou menu textual como interface principal.
- Não mostrar log bruto na tela principal.
- Não acoplar scan/limpeza de VMSTORE/FAST no fluxo de update.
- Não reinstaurar CachyOS como padrão silencioso do Mocha Updater.

Fluxo:
- Sistema: update geral com kernel/NVIDIA ignorados.
- Kernel / Driver: diagnóstico e instalação explícita do conjunto LQX/DKMS.
- Rollback: reinstala o conjunto recomendado LQX/DKMS.
- Detalhes técnicos: relatório bruto separado da tela principal.
