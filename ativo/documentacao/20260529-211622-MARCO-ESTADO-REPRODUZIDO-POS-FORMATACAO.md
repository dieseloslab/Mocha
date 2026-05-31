# MARCO - Estado Mocha Arch/KDE reproduzido pós-formatação

Data: 20260529-211622

Status informado pelo usuário:

- Aparentemente está tudo perfeito.
- O estado da máquina foi reproduzido como estava antes da formatação.
- Ainda falta testar jogos.

Estado técnico observado:

- Kernel: 7.0.10-zen1-1-zen
- Sessão: wayland
- Desktop: KDE
- Login manager: /usr/lib/systemd/system/plasmalogin.service
- NVIDIA: NVIDIA GeForce RTX 5060 Ti, 595.71.05
- TuneD: Current active profile: latency-performance 
- CPU governor: performance
- ColorScheme KDE: MochaSolidCanonico
- Plasma Style: MochaPanelSolidCanonico
- zram: /dev/zram0     partition 15,4G 32767

Itens já reproduzidos/validados no fluxo:

- FAST e VMSTORE montados e persistentes.
- Login manager corrigido para caminho Plasma/KDE.
- Sessão Wayland preservada.
- Kernel Zen ativo.
- NVIDIA open funcional.
- Receita de agressividade/performance ativa.
- TuneD em latency-performance.
- CPU em governor performance.
- zram ativa.
- Duplicidade de Bluetooth e volume corrigida via autostart Hidden=true para blueman-applet e kmix.
- Tema Mocha aplicado.
- Wallpaper Mocha aplicado.
- Barra Mocha/Win11 aprovada aplicada.

Pendência:

- Testar jogos antes de tratar este estado como desempenho aprovado/canonizado.

Regra para próximos passos:

- Não mexer na base reproduzida antes dos testes.
- Testar jogos primeiro sem Launch Options, preservando o baseline que funcionou bem anteriormente.
- Não reintroduzir wrapper, MangoHud forçado, vkbasalt, gamescope ou MANGOHUD_DLSYM sem teste separado.
- Documentar cada jogo/teste com FPS, fluidez, imagem, som e eventuais travamentos.
