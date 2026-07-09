# GameMode OC NVIDIA — payload de instalacao

Status: payload interno sincronizado a partir do runtime local atual.

Nome historico do diretorio:
- gamemode-oc-nvidia-nvml

Regra operacional:
- OC NVIDIA existe somente durante GameMode.
- Nao aplicar OC NVIDIA permanente solto.
- Nao substituir helper, hooks ou configuracao por equivalente improvisado.
- Nao reinstalar no runtime sem auditoria previa.
- Nao canonizar alteracao nova em manual sem teste real e aprovacao explicita.

Arquivos runtime que este payload instala:
- /etc/mocha/nvidia-game-oc.conf
- /etc/sudoers.d/mocha-nvidia-oc-root-helper
- /usr/local/lib/mocha/mocha-nvidia-oc-root-helper
- /usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system
- /usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system

Integracao esperada em /etc/gamemode.ini:
- start=/usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system
- end=/usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system

Validacao obrigatoria:
- /etc/gamemode.ini deve apontar start/end para os hooks authority-system.
- /etc/sudoers.d/mocha-nvidia-oc-root-helper deve passar em visudo -cf.
- offsets devem ativar apenas durante GameMode e reverter ao final.
- validar em jogo real antes de documentar nova mudanca como canonica.

Aplicacao:
- executar ./mocha-aplica-gamemode-oc-nvidia-nvml.sh somente quando a auditoria indicar que o runtime precisa ser reimplantado.
