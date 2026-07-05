# GameMode OC NVIDIA NVML — pacote canonico

Estado: substitui o modelo antigo de OC por sessao grafica.
Regra: OC NVIDIA existe somente durante GameMode.
Metodo: helper root NVML chamado pelos hooks authority-system.

Arquivos runtime canonicos:
- /etc/mocha/nvidia-game-oc.conf
- /etc/sudoers.d/mocha-nvidia-oc-root-helper
- /usr/local/lib/mocha/mocha-nvidia-oc-root-helper
- /usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system
- /usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system

Aplicacao:
- executar ./mocha-aplica-gamemode-oc-nvidia-nvml.sh

Validacao:
- /etc/gamemode.ini deve apontar start/end para os hooks authority-system.
- sudoers deve validar com visudo -cf.
- offsets devem ativar apenas durante GameMode e reverter ao final.
