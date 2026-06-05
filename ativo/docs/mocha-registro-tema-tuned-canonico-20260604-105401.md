# Registro canônico — Tema Mocha KDE e TuneD

- Data: 20260604-105401
- Manual alvo: /media/mochafast/MochaArch/ativo/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md
- Relatório da atualização: /media/mochafast/MochaArch/auditorias/mocha-atualiza-manual-tema-tuned-20260604-105401.log
- Estado bruto auditado: /media/mochafast/MochaArch/auditorias/mocha-estado-tema-tuned-20260604-105401

## Tema KDE/Plasma Mocha aprovado

- Estado aprovado pelo usuário: as cores agora estão Mocha.
- Sessão real auditada: XDG_SESSION_TYPE=wayland; DESKTOP_SESSION=plasma; KDE_SESSION_VERSION=6.
- ColorScheme ativo: MochaDark.
- Plasma theme ativo: MochaPanelSolidCanonico.
- LookAndFeelPackage preservado: org.kde.breezedark.desktop.
- Wallpaper ativo: file:///media/mochafast/MochaArch/ativo/assets/branding/wallpaper/05fdb8fa-73e8-4d9b-a75e-6e1686f8e3ed.png.
- Diretório do tema Plasma: /home/hal/.local/share/plasma/desktoptheme/MochaPanelSolidCanonico.
- Arquivo de cores: /home/hal/.local/share/color-schemes/MochaDark.colors.

### Regra operacional do tema

- Não basta gravar ColorScheme no kdeglobals.
- Para painel e menu assumirem Mocha, o tema Plasma precisa ter SVGZ reais corrigidos.
- Arquivos críticos incluem panel-background.svgz, dialogs/background.svgz, widgets/background.svgz, tooltip.svgz, viewitem.svgz, listitem.svgz, tasks.svgz, button.svgz, lineedit.svgz e frame.svgz, incluindo variantes opaque, solid e translucent quando existirem.
- Depois de alterar SVGZ, limpar cache KSVG/Plasma do tema, especialmente ~/.cache/ksvg-elements e ~/.cache/plasma_theme_MochaPanelSolidCanonico.kcache.
- Reiniciar apenas plasmashell é suficiente. Não reiniciar máquina por dedução.
- Não tocar em SDDM, GRUB, boot, kernel, firewall, Steam ou painel quando a tarefa for somente corrigir cor do tema.

### Paleta Mocha registrada

- Fundo profundo: #171412.
- Fundo janela: #1f201f.
- Fundo painel: #2f2924.
- Fundo popup/menu: #28231f.
- Fundo botão: #322a24.
- Borda: #5c4638.
- Accent/foco: #c98758.
- Hover: #d99e68.
- Accent claro: #f4be82.
- Texto normal: #ece2d7.
- Texto discreto: #aea296.

## TuneD/agressividade

- tuned.service enabled: enabled.
- tuned.service active: active.
- Perfil ativo detectado: mocha-latency-performance.
- Configuração do perfil detectada: /etc/tuned/profiles/mocha-latency-performance/tuned.conf.
- tuned-adm verify: Verification succeeded, current system settings match the preset profile. See TuneD log file ('/var/log/tuned/tuned.log') for details. .
- vm.swappiness atual: 180.
- vm.page-cluster atual: 0.
- vm.max_map_count atual: 16777216.
- zram0 comp_algorithm atual: lzo-rle lzo lz4 lz4hc [zstd] deflate 842 .
- swap atual: /dev/nvme0n1p3 partition 17G 0B -1 /dev/zram0 partition 15,4G 0B 32767.

### Regra operacional do TuneD

- Registrar e preservar o perfil Mocha real ativo antes de mexer.
- Perfil Mocha deve ser autônomo quando a correção aprovada assim tiver sido aplicada; não deixar dependência quebrada de perfil base inexistente.
- Se houver zram e swap em disco, zram deve ficar com prioridade máxima e compressão zstd; swap em disco é aceitável apenas como escape com prioridade baixa.
- O TuneD deve ser validado com tuned-adm active e tuned-adm verify antes de considerar a etapa concluída.
- Divergência restante aceitável só pode ser registrada se for explicitamente aprovada; caso contrário, corrigir ou isolar a tentativa.

## Arquivos auditados

- /media/mochafast/MochaArch/auditorias/mocha-estado-tema-tuned-20260604-105401/kde-plasma.txt
- /media/mochafast/MochaArch/auditorias/mocha-estado-tema-tuned-20260604-105401/tema-arquivos.txt
- /media/mochafast/MochaArch/auditorias/mocha-estado-tema-tuned-20260604-105401/tuned-agressividade.txt
- /media/mochafast/MochaArch/auditorias/mocha-estado-tema-tuned-20260604-105401/tuned-verify.txt
