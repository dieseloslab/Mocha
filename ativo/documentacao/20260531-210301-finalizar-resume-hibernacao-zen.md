# MochaArch — finalizar resume/hibernação no kernel Zen

Data: 20260531-210301

## Estado corrigido

- Kernel atual: `7.0.10-zen1-1-zen`
- Preset regenerado: `linux-zen`
- Swap física: `/dev/nvme0n1p3`
- Parâmetro aplicado: `resume=UUID=c55827ce-1ead-4561-84c9-435612a8862b`
- GRUB regenerado: `/boot/grub/grub.cfg`

## Observação

O preset CachyOS não foi regenerado neste reparo porque ele está com módulos NVIDIA ausentes/incompatíveis. A correção foi limitada ao kernel Zen atualmente em uso.

## Backups

\`/media/mochafast/MochaArch/ativo/relatorios/20260531-210301-backups-finalizar-resume-hibernacao-zen\`

## Log

\`/media/mochafast/MochaArch/ativo/relatorios/20260531-210301-finalizar-resume-hibernacao-zen.log\`

## Validação após reiniciar

Rodar: `cat /proc/cmdline; cat /sys/power/resume; swapon --show; journalctl -b -p warning..alert --no-pager | grep -Ei "resume|hibernate|hibernation|swap" || true`
