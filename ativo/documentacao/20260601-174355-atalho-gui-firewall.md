# MochaArch — atalho GUI do firewall

Timestamp: 20260601-174355

## O que foi criado

- Lançador: /home/hal/.local/bin/mocha-firewall-gui
- Atalho no menu: /home/hal/.local/share/applications/mocha-firewall-gui.desktop
- Atalho na Área de Trabalho: /home/hal/Área de trabalho/mocha-firewall-gui.desktop

## Nome visível

Mocha Firewall - Interface Gráfica

## Comportamento

O atalho tenta abrir, nesta ordem:

1. módulo de firewall encontrado via kcmshell6;
2. kcmshell6 kcm_firewall;
3. systemsettings kcm_firewall;
4. firewall-config, se instalado.

## Log

/media/mochafast/MochaArch/ativo/relatorios/20260601-174355-criar-atalho-gui-firewall.log
