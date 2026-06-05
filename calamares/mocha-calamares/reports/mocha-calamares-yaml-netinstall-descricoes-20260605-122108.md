# Mocha Calamares - correção YAML do netinstall

Data: 20260605-122108

Correção aplicada:
- Corrigidos campos name e description em netinstall.yaml/packagechooser.conf para escalares YAML entre aspas.
- Causa corrigida: descrição com dois-pontos em texto livre quebrava o parser YAML.
- netinstall.yaml validado com PyYAML.
- netinstall.yaml validado semanticamente.
- KDE Plasma + SDDM permanecem como interface inicial única.
- XWayland permanece apenas como compatibilidade para jogos/aplicativos.
- Nenhum desktop concorrente foi adicionado.

Arquivos verificados:
- etc/calamares/netinstall.yaml
- etc/calamares/modules/netinstall.conf
- etc/calamares/modules/packagechooser.conf
- etc/calamares/modules/packages.conf

Backup:
/media/mochafast/MochaArch/calamares/mocha-calamares/backups/yaml-descricoes-20260605-122108
