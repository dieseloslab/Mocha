# MochaArch — hibernação com zram prioritário e swap física

Timestamp: 20260531-214202

## Decisão técnica

- A prioridade alta do zram foi preservada.
- O zram continua sendo o swap preferencial para uso normal.
- A swap física escolhida para hibernação é: /dev/nvme0n1p3
- UUID usado em resume=: c55827ce-1ead-4561-84c9-435612a8862b
- Não foi configurado resume para zram.

## Alterações feitas

- /etc/default/grub recebeu resume=UUID=c55827ce-1ead-4561-84c9-435612a8862b em GRUB_CMDLINE_LINUX_DEFAULT.
- noresume, resume= antigo e resume_offset= antigo foram removidos das linhas de cmdline do GRUB.
- /etc/mkinitcpio.conf ficou com hook resume antes de filesystems.
- initramfs foi regenerado.
- /boot/grub/grub.cfg foi regenerado.
- systemd recebeu /etc/systemd/sleep.conf.d/90-mocha-hibernate.conf.
- Se suportado pelo driver, NVIDIA recebeu NVreg_PreserveVideoMemoryAllocations=1 e NVreg_TemporaryFilePath=/var/tmp.
- Serviços NVIDIA de suspend/hibernate/resume foram habilitados quando existentes.

## Próximo teste

Após reiniciar, testar:

    systemctl hibernate

Se o boot normal mostrar apenas "PM: Image not found" sem tentativa anterior de hibernação, isso é ruído normal: significa que não havia imagem de hibernação gravada na swap.
