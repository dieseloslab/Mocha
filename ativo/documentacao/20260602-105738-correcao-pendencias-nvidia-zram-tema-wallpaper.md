# MochaArch — correção de pendências NVIDIA / zram / tema / wallpaper

- Timestamp: 20260602-105738
- Log: /media/mochafast/MochaArch/ativo/relatorios/20260602-105738-corrigir-pendencias-nvidia-zram-tema-wallpaper-manual.log
- Ação: auditoria e correção dos pontos pendentes após montagem MochaArch.
- Mantido: FAST e VMSTORE persistentes, kernel Cachy comum como padrão, Wayland, UFW/GUFW, Cloudflare DNS-over-TLS, Steam/GameMode/MangoHud.
- Corrigido/verificado: parâmetros NVIDIA no GRUB, runtime NVIDIA, zram zstd com prioridade 32767, TuneD latency-performance, cpupower performance quando disponível, esquema MochaSolidCanonico, Plasma Style MochaPanelSolidCanonico quando presente, barra Win11/Mocha aprovada, wallpaper Mocha quando localizado.
- Observação: os parâmetros de GRUB entram no próximo boot.
- Regra: não remover programas; preservar swap física; manter zram com prioridade superior para uso normal.
