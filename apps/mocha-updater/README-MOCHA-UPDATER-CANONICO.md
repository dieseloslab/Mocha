# Mocha Updater canônico

Interface aprovada/canônica: frontend Qt/Python.

Caminhos canônicos:
- App fonte: /media/mochafast/MochaArch/apps/mocha-updater
- Frontend: /media/mochafast/MochaArch/apps/mocha-updater/frontend/mocha-updater-qt.py
- Backend: /media/mochafast/MochaArch/apps/mocha-updater/scripts/mocha-updater-action-v1.sh
- Executável: /usr/local/bin/mocha-updater
- Menu Sistema/KDE: /usr/share/applications/mocha-updater.desktop
- Atalho de teste no Desktop do usuário: ~/Desktop/mocha-updater.desktop

Regras:
- Não substituir por kdialog, prompt, menu textual, whiptail, zenity ou interface Rust/egui simples.
- A tela principal deve mostrar cards, botões e fluxo gráfico para usuário comum.
- Logs brutos ficam separados em Detalhes técnicos.
- A interface deve seguir pt/en/fr/es, com fallback para inglês.
- Atualização geral não deve trocar kernel nem driver NVIDIA.
- Kernel/driver ficam em área separada e exigem ação explícita.
- Conjunto recomendado atual: linux-lqx + linux-lqx-headers + nvidia-open-dkms quando houver NVIDIA.
- CachyOS fica como histórico/fallback auditável, não como padrão estável do Mocha.
- O atualizador não deve fazer scan/limpeza de VMSTORE/FAST como parte do fluxo principal.
