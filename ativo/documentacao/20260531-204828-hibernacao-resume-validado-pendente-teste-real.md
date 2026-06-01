# MochaArch — hibernação com resume configurado

Timestamp: 20260531-204828

Estado registrado:
- Suspensão: funcionando.
- Hibernação: correção aplicada, ainda pendente de teste real após reboot.

Correção validada:
- GRUB contém resume=UUID=c55827ce-1ead-4561-84c9-435612a8862b.
- mkinitcpio.conf contém hook resume.
- GRUB foi regenerado com sudo.
- linux-zen continua presente no grub.cfg.

Não marcar como aprovado até testar systemctl hibernate e retornar corretamente à sessão.
