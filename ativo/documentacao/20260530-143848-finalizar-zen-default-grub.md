# Mocha Arch - finalização do rollback para linux-zen

Timestamp: 20260530-143848
Objetivo: finalizar o GRUB para iniciar pelo linux-zen como padrão e validar NVIDIA DKMS no Zen.
Kernel Zen detectado: 7.0.10-zen1-1-zen
Entrada GRUB salva: Arch Linux, with Linux linux-zen
Driver: nvidia-open-dkms + nvidia-utils/lib32-nvidia-utils.
Observação: o kernel Cachy permanece instalado, mas não deve ser usado como padrão neste teste.
Log: /media/mochafast/MochaArch/ativo/relatorios/20260530-143848-finalizar-zen-default-grub.log

Validação após reboot:
uname -r
nvidia-smi
dkms status | grep -i nvidia || true
lsmod | grep -E '^nvidia|^nvidia_drm|^nvidia_modeset|^nvidia_uvm' || true
