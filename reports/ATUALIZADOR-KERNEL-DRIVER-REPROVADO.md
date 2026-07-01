# Atualizador kernel/driver reprovado

Data: 2026-06-30T19:48:39-03:00

Status: reprovado e retirado de circulação.

Motivo: auditoria focada encontrou referências CachyOS/Cachy dentro de candidatos reais a atualizador, incluindo binários, fontes, desktop files e payload do Calamares.

Decisão canônica: não reaproveitar este atualizador. O próximo atualizador de kernel/driver deve ser refeito do zero.

Regra: não ativar repositórios CachyOS permanentes no pacman.conf e não instalar cachyos-keyring, cachyos-mirrorlist, linux-cachyos ou linux-cachyos-nvidia-open por meio deste componente antigo.

Quarentena: /media/mochafast/MochaArch-Interno/quarentena/atualizador-kernel-driver-cachyos-reprovado-20260630-194839
Relatório: /tmp/mocha-quarentena-atualizador-cachyos-reprovado-20260630-194839.txt
