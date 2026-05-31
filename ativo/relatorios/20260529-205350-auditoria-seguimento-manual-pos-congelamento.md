
===== MOCHA ARCH - auditoria segura antes de seguir manual =====
Relatório: /media/mochafast/MochaArch/ativo/relatorios/20260529-205350-auditoria-seguimento-manual-pos-congelamento.md
Usuário real: hal
Data: 2026-05-29T20:53:50-03:00
Kernel atual: 7.0.10-zen1-1-zen
Host: Mocha

===== Obtendo sudo para leituras protegidas, se disponível =====

===== 1. Montagens obrigatórias =====
TARGET SOURCE         FSTYPE OPTIONS
/      /dev/nvme0n1p2 xfs    rw,noatime,inode64,logbufs=8,logbsize=32k,noquota
TARGET           SOURCE    FSTYPE OPTIONS
/media/mochafast systemd-1 autofs rw,relatime,fd=69,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=15563
/media/mochafast /dev/sda1 btrfs  rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvolid=5,subvol=/
TARGET         SOURCE    FSTYPE OPTIONS
/media/vmstore systemd-1 autofs rw,relatime,fd=71,pgrp=1,timeout=0,minproto=5,maxproto=5,direct,pipe_ino=17082
Sist. Arq.     Tipo   Tam. Usado Disp. Uso% Montado em
/dev/nvme0n1p2 xfs    913G   31G  882G   4% /
/dev/sda1      btrfs  448G  131G  281G  32% /media/mochafast
/dev/sdb1      xfs    1,9T  921G  942G  50% /media/vmstore

===== 2. Entradas relevantes do fstab =====
13:UUID=b81630a0-0756-45e4-9cb2-c7f16637a1c6 /media/vmstore xfs rw,noatime,nofail,x-systemd.automount,x-systemd.device-timeout=10,x-gvfs-show,x-gvfs-name=VMSTORE 0 0
14:UUID=88e6aa16-110c-4b97-9ffb-85084c000198 /media/mochafast btrfs rw,noatime,compress=zstd:3,nofail,x-systemd.automount,x-systemd.device-timeout=10,x-gvfs-show,x-gvfs-name=MochaFAST 0 0

Entradas duplicadas por ponto de montagem:
/media/mochafast => 1 entrada(s)
14: UUID=88e6aa16-110c-4b97-9ffb-85084c000198 /media/mochafast btrfs rw,noatime,compress=zstd:3,nofail,x-systemd.automount,x-systemd.device-timeout=10,x-gvfs-show,x-gvfs-name=MochaFAST 0 0
/media/vmstore => 1 entrada(s)
13: UUID=b81630a0-0756-45e4-9cb2-c7f16637a1c6 /media/vmstore xfs rw,noatime,nofail,x-systemd.automount,x-systemd.device-timeout=10,x-gvfs-show,x-gvfs-name=VMSTORE 0 0

===== 3. Kernel, boot e initramfs =====
Linux Mocha 7.0.10-zen1-1-zen #1 ZEN SMP PREEMPT_DYNAMIC Sat, 23 May 2026 14:45:01 +0000 x86_64 GNU/Linux

===== Pacotes de kernel/driver instalados =====
linux 7.0.10.arch1-1
linux-headers 7.0.10.arch1-1
linux-zen 7.0.10.zen1-1
linux-zen-headers 7.0.10.zen1-1
nvidia-open-dkms 595.71.05-2
nvidia-open-dkms 595.71.05-2
nvidia-utils 595.71.05-2
nvidia-settings 595.71.05-1
dkms 3.4.1-1
mkinitcpio 41-4

===== Arquivos principais em /boot =====
/boot/amd-ucode.img
/boot/initramfs-linux.img
/boot/initramfs-linux-zen.img
/boot/intel-ucode.img
/boot/vmlinuz-linux
/boot/vmlinuz-linux-zen

===== Entradas de boot detectáveis =====

BootCurrent: 0000
Timeout: 1 seconds
BootOrder: 0000,0013,0014
Boot0000* Arch	HD(1,GPT,63e923ae-be1f-4e03-a19c-65219f94c339,0x1000,0x400000)/\EFI\ARCH\GRUBX64.EFI
Boot0009  USB Entry for Windows To Go	UsbClass(ffff,ffff,255,255){0df5afdc-4026-47e4-818a-f34380953615}
Boot0013* UEFI OS	HD(2,MBR,0xdbf5b2d1,0x6fbcf30,0x10000)/\EFI\BOOT\BOOTX64.EFI0000424f
Boot0014* UEFI OS	HD(1,GPT,63e923ae-be1f-4e03-a19c-65219f94c339,0x1000,0x400000)/\EFI\BOOT\BOOTX64.EFI0000424f

===== GRUB default, se existir =====
3:GRUB_DEFAULT=0
4:GRUB_TIMEOUT=5
6:GRUB_CMDLINE_LINUX_DEFAULT="'quiet splash loglevel=3' nvidia_drm.modeset=1 nvidia_drm.fbdev=1 modprobe.blacklist=nouveau nouveau.modeset=0"
7:GRUB_CMDLINE_LINUX=""
17:GRUB_TIMEOUT_STYLE=menu
53:# setting 'GRUB_DEFAULT=saved' above.
57:#GRUB_DISABLE_SUBMENU=y

===== 4. Estado NVIDIA real =====

===== nvidia-smi =====
Fri May 29 20:53:56 2026       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 595.71.05              Driver Version: 595.71.05      CUDA Version: 13.2     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 5060 Ti     Off |   00000000:01:00.0  On |                  N/A |
|  0%   33C    P8             11W /  180W |     673MiB /  16311MiB |      5%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A             692      G   /usr/lib/Xorg                            15MiB |
|    0   N/A  N/A             791      G   /usr/bin/ksecretd                         2MiB |
|    0   N/A  N/A             827      G   /usr/bin/kwin_wayland                    22MiB |
|    0   N/A  N/A             917      G   /usr/bin/Xwayland                         3MiB |
|    0   N/A  N/A             961      G   /usr/bin/ksmserver                        2MiB |
|    0   N/A  N/A             963      G   /usr/bin/kded6                            2MiB |
|    0   N/A  N/A             997      G   /usr/bin/plasmashell                     63MiB |
|    0   N/A  N/A            1070      G   /usr/bin/kaccess                          2MiB |
|    0   N/A  N/A            1071      G   ...it-kde-authentication-agent-1          2MiB |
|    0   N/A  N/A            1175      G   /usr/bin/kdeconnectd                      2MiB |
|    0   N/A  N/A            1206      G   /usr/bin/akonadi_control                  2MiB |
|    0   N/A  N/A            1220      G   ...bin/akonadi_archivemail_agent          2MiB |
|    0   N/A  N/A            1223      G   ...konadi_followupreminder_agent          2MiB |
|    0   N/A  N/A            1227      G   .../akonadi_maildispatcher_agent          2MiB |
|    0   N/A  N/A            1228      G   .../bin/akonadi_mailfilter_agent          2MiB |
|    0   N/A  N/A            1229      G   /usr/bin/akonadi_mailmerge_agent          2MiB |
|    0   N/A  N/A            1230      G   /usr/bin/akonadi_migration_agent          2MiB |
|    0   N/A  N/A            1231      G   ...akonadi_newmailnotifier_agent          2MiB |
|    0   N/A  N/A            1232      G   /usr/bin/akonadi_sendlater_agent          2MiB |
|    0   N/A  N/A            1233      G   .../akonadi_unifiedmailbox_agent          2MiB |
|    0   N/A  N/A            1382      G   /usr/lib/DiscoverNotifier                 2MiB |
|    0   N/A  N/A            1383      G   /usr/bin/kalendarac                       2MiB |
|    0   N/A  N/A            1390      G   /usr/bin/kmix                             2MiB |
|    0   N/A  N/A            1449      G   /usr/lib/xdg-desktop-portal-kde           2MiB |
|    0   N/A  N/A            1499      G   /usr/lib/firefox/firefox                202MiB |
|    0   N/A  N/A            2137      G   /usr/bin/konsole                          2MiB |
+-----------------------------------------------------------------------------------------+

===== Módulos NVIDIA carregados =====
nvidia_drm            159744  97
drm_ttm_helper         20480  2 nvidia_drm
nvidia_uvm           2564096  0
nvidia_modeset       2203648  56 nvidia_drm
video                  81920  2 asus_wmi,nvidia_modeset
nvidia              16584704  1055 nvidia_uvm,nvidia_modeset

===== modinfo nvidia =====
filename:       /lib/modules/7.0.10-zen1-1-zen/updates/dkms/nvidia.ko.zst
version:        595.71.05
vermagic:       7.0.10-zen1-1-zen SMP preempt mod_unload 

===== DRM/KMS NVIDIA no kernel atual =====

===== Vulkan resumido, se disponível =====
==========
VULKANINFO
==========

Vulkan Instance Version: 1.4.350


Instance Extensions: count = 25
-------------------------------
VK_EXT_acquire_drm_display             : extension revision 1
VK_EXT_acquire_xlib_display            : extension revision 1
VK_EXT_debug_report                    : extension revision 10
VK_EXT_debug_utils                     : extension revision 2
VK_EXT_direct_mode_display             : extension revision 1
VK_EXT_display_surface_counter         : extension revision 1
VK_EXT_surface_maintenance1            : extension revision 1
VK_EXT_swapchain_colorspace            : extension revision 5
VK_KHR_device_group_creation           : extension revision 1
VK_KHR_display                         : extension revision 23
VK_KHR_external_fence_capabilities     : extension revision 1
VK_KHR_external_memory_capabilities    : extension revision 1
VK_KHR_external_semaphore_capabilities : extension revision 1
VK_KHR_get_display_properties2         : extension revision 1
VK_KHR_get_physical_device_properties2 : extension revision 2
VK_KHR_get_surface_capabilities2       : extension revision 1
VK_KHR_portability_enumeration         : extension revision 1
VK_KHR_surface                         : extension revision 25
VK_KHR_surface_maintenance1            : extension revision 1
VK_KHR_surface_protected_capabilities  : extension revision 1
VK_KHR_wayland_surface                 : extension revision 6
VK_KHR_xcb_surface                     : extension revision 6
VK_KHR_xlib_surface                    : extension revision 6
VK_LUNARG_direct_driver_loading        : extension revision 1
VK_NV_display_stereo                   : extension revision 1

Instance Layers: count = 2
--------------------------
VK_LAYER_NV_optimus NVIDIA Optimus layer      1.4.329  version 1
VK_LAYER_NV_present NVIDIA Presentation Layer 1.4.329  version 1

Devices:
========
GPU0:
	apiVersion         = 1.4.329
	driverVersion      = 595.71.5.0
	vendorID           = 0x10de
	deviceID           = 0x2d04
	deviceType         = PHYSICAL_DEVICE_TYPE_DISCRETE_GPU
	deviceName         = NVIDIA GeForce RTX 5060 Ti
	driverID           = DRIVER_ID_NVIDIA_PROPRIETARY
	driverName         = NVIDIA
	driverInfo         = 595.71.05
	conformanceVersion = 1.4.3.3
	deviceUUID         = 733d78c3-b037-1472-ec6b-944f533f70c0
	driverUUID         = eec1eba6-4484-5d12-ab32-1ef922507ba0

===== 5. DKMS e mkinitcpio =====

===== DKMS status =====
broadcom-wl/6.30.223.271, 7.0.10-arch1-1, x86_64: installed
broadcom-wl/6.30.223.271, 7.0.10-zen1-1-zen, x86_64: installed
nvidia/595.71.05, 7.0.10-arch1-1, x86_64: installed
nvidia/595.71.05, 7.0.10-zen1-1-zen, x86_64: installed

===== Presets mkinitcpio =====
total 20
drwxr-xr-x   2 root root   50 mai 29 20:31 .
drwxr-xr-x 107 root root 8192 mai 29 20:51 ..
-rw-r--r--   1 root root  588 mai 29 20:11 linux.preset
-rw-r--r--   1 root root  616 mai 29 20:31 linux-zen.preset

===== Últimos registros pacman sobre kernel/NVIDIA/DKMS/mkinitcpio =====
[2026-05-29T20:11:00-0300] [PACMAN] Running 'pacman -r /tmp/calamares-root-aaaaaaaa -Sy --noconfirm base sudo grub xterm mkinitcpio mkinitcpio-busybox mkinitcpio-nfs-utils cryptsetup device-mapper dhcpcd diffutils e2fsprogs inetutils jfsutils less linux linux-firmware logrotate lvm2 man-db man-pages mdadm nano netctl perl s-nail sysfsutils systemd-sysvcompat texinfo usbutils vi which xfsprogs f2fs-tools amd-ucode intel-ucode'
[2026-05-29T20:11:24-0300] [ALPM] installed util-linux (2.42.1-1)
[2026-05-29T20:11:27-0300] [ALPM] installed mkinitcpio-busybox (1.36.1-1)
[2026-05-29T20:11:27-0300] [ALPM] installed mkinitcpio (41-4)
[2026-05-29T20:11:27-0300] [ALPM] installed mkinitcpio-nfs-utils (0.3-8)
[2026-05-29T20:11:28-0300] [ALPM] installed linux (7.0.10.arch1-1)
[2026-05-29T20:11:28-0300] [ALPM] installed linux-firmware-nvidia (20260519-1)
[2026-05-29T20:11:30-0300] [ALPM-SCRIPTLET] Creating user 'alpm' (Arch Linux Package Management) with UID 970 and GID 970.
[2026-05-29T20:11:32-0300] [ALPM] running '90-mkinitcpio-install.hook'...
[2026-05-29T20:11:32-0300] [ALPM-SCRIPTLET] ==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
[2026-05-29T20:11:32-0300] [ALPM-SCRIPTLET] ==> Using default configuration file: '/etc/mkinitcpio.conf'
[2026-05-29T20:11:32-0300] [ALPM-SCRIPTLET]   -> -k /boot/vmlinuz-linux -g /boot/initramfs-linux.img
[2026-05-29T20:11:39-0300] [ALPM-SCRIPTLET] ==> Creating zstd-compressed initcpio image: '/boot/initramfs-linux.img'
[2026-05-29T20:12:31-0300] [PACMAN] Running 'pacman -S --noconfirm --noprogressbar broadcom-wl-dkms'
[2026-05-29T20:12:31-0300] [ALPM] installed dkms (3.4.1-1)
[2026-05-29T20:12:31-0300] [ALPM] installed broadcom-wl-dkms (6.30.223.271-47)
[2026-05-29T20:12:31-0300] [ALPM-SCRIPTLET] Unload and load kernel modules (wl is provided by broadcom-wl-dkms):
[2026-05-29T20:12:31-0300] [ALPM] running '70-dkms-install.hook'...
[2026-05-29T20:12:31-0300] [ALPM-SCRIPTLET] ==> dkms install --no-depmod broadcom-wl/6.30.223.271 -k 7.0.10-arch1-1
[2026-05-29T20:12:37-0300] [ALPM] running '90-mkinitcpio-install.hook'...
[2026-05-29T20:12:37-0300] [ALPM-SCRIPTLET] ==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
[2026-05-29T20:12:37-0300] [ALPM-SCRIPTLET] ==> Using default configuration file: '/etc/mkinitcpio.conf'
[2026-05-29T20:12:37-0300] [ALPM-SCRIPTLET]   -> -k /boot/vmlinuz-linux -g /boot/initramfs-linux.img
[2026-05-29T20:12:41-0300] [ALPM-SCRIPTLET] ==> Creating zstd-compressed initcpio image: '/boot/initramfs-linux.img'
[2026-05-29T20:12:54-0300] [ALPM] running '90-mkinitcpio-install.hook'...
[2026-05-29T20:12:54-0300] [ALPM-SCRIPTLET] ==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
[2026-05-29T20:12:54-0300] [ALPM-SCRIPTLET] ==> Using default configuration file: '/etc/mkinitcpio.conf'
[2026-05-29T20:12:54-0300] [ALPM-SCRIPTLET]   -> -k /boot/vmlinuz-linux -g /boot/initramfs-linux.img
[2026-05-29T20:12:58-0300] [ALPM-SCRIPTLET] ==> Creating zstd-compressed initcpio image: '/boot/initramfs-linux.img'
[2026-05-29T20:13:13-0300] [ALPM] running '90-mkinitcpio-install.hook'...
[2026-05-29T20:13:13-0300] [ALPM-SCRIPTLET] ==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
[2026-05-29T20:13:13-0300] [ALPM-SCRIPTLET] ==> Using default configuration file: '/etc/mkinitcpio.conf'
[2026-05-29T20:13:13-0300] [ALPM-SCRIPTLET]   -> -k /boot/vmlinuz-linux -g /boot/initramfs-linux.img
[2026-05-29T20:13:17-0300] [ALPM-SCRIPTLET] ==> Creating zstd-compressed initcpio image: '/boot/initramfs-linux.img'
[2026-05-29T20:13:20-0300] [ALPM] running '90-mkinitcpio-install.hook'...
[2026-05-29T20:13:20-0300] [ALPM-SCRIPTLET] ==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
[2026-05-29T20:13:20-0300] [ALPM-SCRIPTLET] ==> Using default configuration file: '/etc/mkinitcpio.conf'
[2026-05-29T20:13:20-0300] [ALPM-SCRIPTLET]   -> -k /boot/vmlinuz-linux -g /boot/initramfs-linux.img
[2026-05-29T20:13:24-0300] [ALPM-SCRIPTLET] ==> Creating zstd-compressed initcpio image: '/boot/initramfs-linux.img'
[2026-05-29T20:13:43-0300] [ALPM] running '90-mkinitcpio-install.hook'...
[2026-05-29T20:13:43-0300] [ALPM-SCRIPTLET] ==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
[2026-05-29T20:13:43-0300] [ALPM-SCRIPTLET] ==> Using default configuration file: '/etc/mkinitcpio.conf'
[2026-05-29T20:13:43-0300] [ALPM-SCRIPTLET]   -> -k /boot/vmlinuz-linux -g /boot/initramfs-linux.img
[2026-05-29T20:13:47-0300] [ALPM-SCRIPTLET] ==> Creating zstd-compressed initcpio image: '/boot/initramfs-linux.img'
[2026-05-29T20:14:29-0300] [ALPM] running '90-mkinitcpio-install.hook'...
[2026-05-29T20:14:29-0300] [ALPM-SCRIPTLET] ==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
[2026-05-29T20:14:29-0300] [ALPM-SCRIPTLET] ==> Using default configuration file: '/etc/mkinitcpio.conf'
[2026-05-29T20:14:29-0300] [ALPM-SCRIPTLET]   -> -k /boot/vmlinuz-linux -g /boot/initramfs-linux.img
[2026-05-29T20:14:33-0300] [ALPM-SCRIPTLET] ==> Creating zstd-compressed initcpio image: '/boot/initramfs-linux.img'
[2026-05-29T20:14:34-0300] [ALPM] running '90-mkinitcpio-install.hook'...
[2026-05-29T20:14:34-0300] [ALPM-SCRIPTLET] ==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
[2026-05-29T20:14:34-0300] [ALPM-SCRIPTLET] ==> Using default configuration file: '/etc/mkinitcpio.conf'
[2026-05-29T20:14:34-0300] [ALPM-SCRIPTLET]   -> -k /boot/vmlinuz-linux -g /boot/initramfs-linux.img
[2026-05-29T20:14:38-0300] [ALPM-SCRIPTLET] ==> Creating zstd-compressed initcpio image: '/boot/initramfs-linux.img'
[2026-05-29T20:14:50-0300] [ALPM] running '90-mkinitcpio-install.hook'...
[2026-05-29T20:14:50-0300] [ALPM-SCRIPTLET] ==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
[2026-05-29T20:14:50-0300] [ALPM-SCRIPTLET] ==> Using default configuration file: '/etc/mkinitcpio.conf'
[2026-05-29T20:14:50-0300] [ALPM-SCRIPTLET]   -> -k /boot/vmlinuz-linux -g /boot/initramfs-linux.img
[2026-05-29T20:14:53-0300] [ALPM-SCRIPTLET] ==> Creating zstd-compressed initcpio image: '/boot/initramfs-linux.img'
[2026-05-29T20:15:10-0300] [ALPM] running '90-mkinitcpio-install.hook'...
[2026-05-29T20:15:10-0300] [ALPM-SCRIPTLET] ==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
[2026-05-29T20:15:10-0300] [ALPM-SCRIPTLET] ==> Using default configuration file: '/etc/mkinitcpio.conf'
[2026-05-29T20:15:10-0300] [ALPM-SCRIPTLET]   -> -k /boot/vmlinuz-linux -g /boot/initramfs-linux.img
[2026-05-29T20:15:14-0300] [ALPM-SCRIPTLET] ==> Creating zstd-compressed initcpio image: '/boot/initramfs-linux.img'
[2026-05-29T20:15:22-0300] [PACMAN] Running 'pacman -S --noconfirm --noprogressbar nvidia'
[2026-05-29T20:15:22-0300] [PACMAN] Running 'pacman -S --noconfirm --noprogressbar nvidia-utils'
[2026-05-29T20:15:27-0300] [ALPM] installed nvidia-utils (595.71.05-2)
[2026-05-29T20:15:27-0300] [ALPM-SCRIPTLET] Creating group 'nvidia-persistenced' with GID 143.
[2026-05-29T20:15:27-0300] [ALPM-SCRIPTLET] Creating user 'nvidia-persistenced' (NVIDIA Persistence Daemon) with UID 143 and GID 143.
[2026-05-29T20:15:27-0300] [ALPM] running '90-mkinitcpio-install.hook'...
[2026-05-29T20:15:27-0300] [ALPM-SCRIPTLET] ==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
[2026-05-29T20:15:27-0300] [ALPM-SCRIPTLET] ==> Using default configuration file: '/etc/mkinitcpio.conf'
[2026-05-29T20:15:27-0300] [ALPM-SCRIPTLET]   -> -k /boot/vmlinuz-linux -g /boot/initramfs-linux.img
[2026-05-29T20:15:31-0300] [ALPM-SCRIPTLET] ==> Creating zstd-compressed initcpio image: '/boot/initramfs-linux.img'
[2026-05-29T20:15:32-0300] [PACMAN] Running 'pacman -S --noconfirm --noprogressbar nvidia-settings'
[2026-05-29T20:15:33-0300] [ALPM] installed nvidia-settings (595.71.05-1)
[2026-05-29T20:15:59-0300] [ALPM] running '90-mkinitcpio-install.hook'...
[2026-05-29T20:15:59-0300] [ALPM-SCRIPTLET] ==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
[2026-05-29T20:15:59-0300] [ALPM-SCRIPTLET] ==> Using default configuration file: '/etc/mkinitcpio.conf'
[2026-05-29T20:15:59-0300] [ALPM-SCRIPTLET]   -> -k /boot/vmlinuz-linux -g /boot/initramfs-linux.img
[2026-05-29T20:16:03-0300] [ALPM-SCRIPTLET] ==> Creating zstd-compressed initcpio image: '/boot/initramfs-linux.img'
[2026-05-29T20:29:03-0300] [PACMAN] Running 'pacman -S --needed linux-zen linux-zen-headers dkms nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings egl-wayland vulkan-icd-loader lib32-vulkan-icd-loader zram-generator tuned cpupower python'
[2026-05-29T20:29:16-0300] [ALPM] installed linux-zen (7.0.10.zen1-1)
[2026-05-29T20:29:17-0300] [ALPM] installed linux-zen-headers (7.0.10.zen1-1)
[2026-05-29T20:29:18-0300] [ALPM] installed nvidia-open-dkms (595.71.05-2)
[2026-05-29T20:29:19-0300] [ALPM] installed lib32-nvidia-utils (595.71.05-1)
[2026-05-29T20:29:21-0300] [ALPM] running '70-dkms-install.hook'...
[2026-05-29T20:29:21-0300] [ALPM-SCRIPTLET] ==> dkms install --no-depmod nvidia/595.71.05 -k 7.0.10-arch1-1
[2026-05-29T20:30:28-0300] [ALPM-SCRIPTLET] ==> dkms install --no-depmod broadcom-wl/6.30.223.271 -k 7.0.10-zen1-1-zen
[2026-05-29T20:30:31-0300] [ALPM-SCRIPTLET] ==> dkms install --no-depmod nvidia/595.71.05 -k 7.0.10-zen1-1-zen
[2026-05-29T20:31:41-0300] [ALPM] running '90-mkinitcpio-install.hook'...
[2026-05-29T20:31:42-0300] [ALPM-SCRIPTLET] ==> Building image from preset: /etc/mkinitcpio.d/linux.preset: 'default'
[2026-05-29T20:31:42-0300] [ALPM-SCRIPTLET] ==> Using default configuration file: '/etc/mkinitcpio.conf'
[2026-05-29T20:31:42-0300] [ALPM-SCRIPTLET]   -> -k /boot/vmlinuz-linux -g /boot/initramfs-linux.img
[2026-05-29T20:31:46-0300] [ALPM-SCRIPTLET] ==> Creating zstd-compressed initcpio image: '/boot/initramfs-linux.img'
[2026-05-29T20:31:47-0300] [ALPM-SCRIPTLET] ==> Building image from preset: /etc/mkinitcpio.d/linux-zen.preset: 'default'
[2026-05-29T20:31:47-0300] [ALPM-SCRIPTLET] ==> Using default configuration file: '/etc/mkinitcpio.conf'
[2026-05-29T20:31:47-0300] [ALPM-SCRIPTLET]   -> -k /boot/vmlinuz-linux-zen -g /boot/initramfs-linux-zen.img
[2026-05-29T20:31:52-0300] [ALPM-SCRIPTLET] ==> Creating zstd-compressed initcpio image: '/boot/initramfs-linux-zen.img'

===== 6. Logs do boot anterior e alertas do congelamento =====

===== Erros do boot anterior =====
mai 29 20:41:55 Mocha kmix[1924]: no mix devices and not dynamic
mai 29 20:41:55 Mocha kmix[1924]: no mix devices and not dynamic
mai 29 20:41:55 Mocha kmix[1924]: No such icon "audio-card-pci"
mai 29 20:41:55 Mocha kmix[1924]: No such icon "audio-card-pci"
mai 29 20:41:55 Mocha kmix[1924]: No such icon "audio-card-pci"
mai 29 20:41:55 Mocha pulseaudio[934]: Failed to open connection to session manager: None of the authentication protocols specified are supported
mai 29 20:41:55 Mocha pulseaudio[934]: Failed to load module "module-x11-xsmp" (argument: "display=:1 xauthority=/run/user/1000/xauth_aKnthR session_manager=local/Mocha:@/tmp/.ICE-unix/960,unix/Mocha:/tmp/.ICE-unix/960"): initialization failed.
mai 29 20:41:55 Mocha systemd[735]: app-pulseaudio@autostart.service: Failed with result 'exit-code'.
mai 29 20:41:55 Mocha kwin_wayland[808]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.kwin'")
mai 29 20:41:55 Mocha ksmserver[960]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.ksmserver'")
mai 29 20:41:55 Mocha kactivitymanagerd[1018]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.ActivityManager'")
mai 29 20:41:55 Mocha kded6[962]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.kded6'")
mai 29 20:41:55 Mocha xembedsniproxy[1074]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.xembedsniproxy'")
mai 29 20:41:55 Mocha gmenudbusmenuproxy[1069]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.gmenudbusmenuproxy'")
mai 29 20:41:55 Mocha polkit-kde-authentication-agent-1[1071]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: Unable to open /proc/1071/root")
mai 29 20:41:55 Mocha akonadi_control[1202]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_control'")
mai 29 20:41:55 Mocha akonadi_migration_agent[1226]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_migration_agent'")
mai 29 20:41:55 Mocha akonadi_followupreminder_agent[1219]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_followupreminder_agent'")
mai 29 20:41:55 Mocha akonadi_maildispatcher_agent[1223]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_maildispatcher_agent'")
mai 29 20:41:55 Mocha akonadi_newmailnotifier_agent[1227]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_newmailnotifier_agent'")
mai 29 20:41:55 Mocha akonadi_mailmerge_agent[1225]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_mailmerge_agent'")
mai 29 20:41:55 Mocha akonadi_sendlater_agent[1228]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_sendlater_agent'")
mai 29 20:41:55 Mocha akonadi_archivemail_agent[1216]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_archivemail_agent'")
mai 29 20:41:55 Mocha akonadi_unifiedmailbox_agent[1229]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_unifiedmailbox_agent'")
mai 29 20:41:55 Mocha akonadi_mailfilter_agent[1224]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_mailfilter_agent'")
mai 29 20:41:55 Mocha org_kde_powerdevil[1072]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.org_kde_powerdevil'")
mai 29 20:41:55 Mocha kclockd[1888]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.kclockd'")
mai 29 20:41:55 Mocha kdeconnectd[1176]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: Connection already associated with an application ID")
mai 29 20:41:55 Mocha polkit-kde-authentication-agent-1[1071]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: Unable to open /proc/1071/root")
mai 29 20:41:55 Mocha kaccess[1070]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: Connection already associated with an application ID")
mai 29 20:41:55 Mocha gmenudbusmenuproxy[1069]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.gmenudbusmenuproxy'")
mai 29 20:41:55 Mocha kactivitymanagerd[1018]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.ActivityManager'")
mai 29 20:41:55 Mocha ksmserver[960]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.ksmserver'")
mai 29 20:41:55 Mocha ksecretd[771]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: Connection already associated with an application ID")
mai 29 20:41:55 Mocha kded6[962]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.kded6'")
mai 29 20:41:55 Mocha kmix[1924]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: Connection already associated with an application ID")
mai 29 20:41:55 Mocha plasmashell[995]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: Connection already associated with an application ID")
mai 29 20:41:55 Mocha kwin_wayland[808]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.kwin'")
mai 29 20:41:55 Mocha DiscoverNotifier[1915]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: Connection already associated with an application ID")
mai 29 20:41:55 Mocha kclockd[1888]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.kclockd'")
mai 29 20:41:55 Mocha akonadi_followupreminder_agent[1219]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_followupreminder_agent'")
mai 29 20:41:55 Mocha akonadi_unifiedmailbox_agent[1229]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_unifiedmailbox_agent'")
mai 29 20:41:55 Mocha akonadi_sendlater_agent[1228]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_sendlater_agent'")
mai 29 20:41:55 Mocha akonadi_migration_agent[1226]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_migration_agent'")
mai 29 20:41:55 Mocha akonadi_newmailnotifier_agent[1227]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_newmailnotifier_agent'")
mai 29 20:41:55 Mocha org_kde_powerdevil[1072]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: Connection already associated with an application ID")
mai 29 20:41:55 Mocha xembedsniproxy[1074]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.xembedsniproxy'")
mai 29 20:41:55 Mocha xdg-desktop-portal-kde[1960]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: Connection already associated with an application ID")
mai 29 20:41:55 Mocha akonadi_mailmerge_agent[1225]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_mailmerge_agent'")
mai 29 20:41:55 Mocha akonadi_control[1202]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_control'")
mai 29 20:41:55 Mocha akonadi_maildispatcher_agent[1223]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_maildispatcher_agent'")
mai 29 20:41:55 Mocha akonadi_mailfilter_agent[1224]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_mailfilter_agent'")
mai 29 20:41:55 Mocha akonadi_archivemail_agent[1216]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.akonadi_archivemail_agent'")
mai 29 20:41:55 Mocha akonadi_control[1202]: Agent instance (agentInstanceAccountId)  "akonadi_birthdays_resource"  has no agent account interface.
mai 29 20:41:55 Mocha akonadi_control[1202]: Agent instance (agentInstanceAccountId)  "akonadi_sendlater_agent"  has no agent account interface.
mai 29 20:41:55 Mocha akonadi_control[1202]: Agent instance (agentInstanceAccountId)  "akonadi_followupreminder_agent"  has no agent account interface.
mai 29 20:41:55 Mocha akonadi_control[1202]: Agent instance (agentInstanceAccountId)  "akonadi_archivemail_agent"  has no agent account interface.
mai 29 20:41:55 Mocha akonadi_control[1202]: Agent instance (agentInstanceAccountId)  "akonadi_contacts_resource_0"  has no agent account interface.
mai 29 20:41:55 Mocha akonadi_control[1202]: Agent instance (agentInstanceAccountId)  "akonadi_indexing_agent"  has no agent account interface.
mai 29 20:41:55 Mocha akonadi_control[1202]: Agent instance (agentInstanceAccountId)  "akonadi_unifiedmailbox_agent"  has no agent account interface.
mai 29 20:41:55 Mocha akonadi_control[1202]: Agent instance (agentInstanceAccountId)  "akonadi_maildispatcher_agent"  has no agent account interface.
mai 29 20:41:55 Mocha akonadi_control[1202]: Agent instance (agentInstanceAccountId)  "akonadi_maildir_resource_0"  has no agent account interface.
mai 29 20:41:55 Mocha akonadi_control[1202]: Agent instance (agentInstanceAccountId)  "akonadi_mailfilter_agent"  has no agent account interface.
mai 29 20:41:55 Mocha akonadi_control[1202]: Agent instance (agentInstanceAccountId)  "akonadi_mailmerge_agent"  has no agent account interface.
mai 29 20:41:55 Mocha akonadi_control[1202]: Agent instance (agentInstanceAccountId)  "akonadi_ical_resource_0"  has no agent account interface.
mai 29 20:41:55 Mocha akonadi_control[1202]: Agent instance (agentInstanceAccountId)  "akonadi_migration_agent"  has no agent account interface.
mai 29 20:41:55 Mocha akonadi_control[1202]: Agent instance (agentInstanceAccountId)  "akonadi_newmailnotifier_agent"  has no agent account interface.
mai 29 20:41:55 Mocha kalendarac[1916]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.kalendarac'")
mai 29 20:41:55 Mocha kalendarac[1916]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.kalendarac'")
mai 29 20:41:57 Mocha systemsettings[2023]: Failed to connect to Bolt manager DBus interface: 
mai 29 20:41:57 Mocha systemsettings[2023]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: Connection already associated with an application ID")
mai 29 20:42:13 Mocha kded6[962]: "Did not receive a reply. Possible causes include: the remote application did not send a reply, the message bus security policy blocked the reply, the reply timeout expired, or the network connection was broken."
mai 29 20:43:32 Mocha plasmashell[995]: qrc:/qt/qml/plasma/applet/org/kde/plasma/taskmanager/ToolTipDelegate.qml:63: TypeError: Cannot read property 'containsMouse' of null
mai 29 20:43:33 Mocha plasmashell[995]: error creating screencast "Não foi possível encontrar a janela de id {35a2ea96-1bd8-49cf-bebe-5ce7d5439534}"
mai 29 20:49:32 Mocha plasmashell[995]: The cached device pixel ratio value was stale on window update.  Please file a QTBUG which explains how to reproduce.
mai 29 20:51:03 Mocha systemd[1]: cpupower.service: Main process exited, code=killed, status=15/TERM
mai 29 20:51:03 Mocha systemd[1]: cpupower.service: Failed with result 'signal'.
mai 29 20:51:20 Mocha sddm-helper[728]: Signal received: SIGTERM
mai 29 20:51:20 Mocha sddm[686]: Authentication error: SDDM::Auth::ERROR_INTERNAL "Process crashed"
mai 29 20:51:20 Mocha sddm[686]: Auth: sddm-helper (--socket /tmp/sddm-auth-cbc72e99-60c8-4555-a25e-aa17b1fa8441 --id 1 --start /usr/lib/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland --user hal) crashed (exit code 1)
mai 29 20:51:20 Mocha sddm[686]: Authentication error: SDDM::Auth::ERROR_INTERNAL "Process crashed"
mai 29 20:51:20 Mocha sddm[686]: Auth: sddm-helper exited with 1
mai 29 20:51:20 Mocha sddm[686]: Signal received: SIGTERM
mai 29 20:51:20 Mocha plasmashell[995]: "QLocalSocket: Remote closed" "/run/user/1000/akonadi/akonadiserver-cmd.socket"
mai 29 20:51:20 Mocha plasmashell[995]: "QLocalSocket: Conexão remota encerrada" "/run/user/1000/akonadi/akonadiserver-cmd.socket"
mai 29 20:51:20 Mocha pulseaudio[934]: PulseAudio information vanished from X11!
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.534587] (dw_watch_display_connections) Time since last return from sleep = 571888242445 ns = 571888 ms
mai 29 20:51:20 Mocha systemd[1]: sys-devices-pci0000:00-0000:00:01.1-0000:01:00.1-sound-card0-controlC0.device: Failed to enqueue SYSTEMD_WANTS job, ignoring: Transaction for sound.target/start is destructive (reboot.target has 'start' job queued, but 'stop' is included in transaction).
mai 29 20:51:20 Mocha systemd[1]: sys-devices-pci0000:00-0000:00:08.1-0000:09:00.1-sound-card1-controlC1.device: Failed to enqueue SYSTEMD_WANTS job, ignoring: Transaction for sound.target/start is destructive (systemd-reboot.service has 'start' job queued, but 'stop' is included in transaction).
mai 29 20:51:20 Mocha systemd[1]: sys-devices-virtual-misc-rfkill.device: Failed to enqueue SYSTEMD_WANTS job, ignoring: Transaction for systemd-rfkill.socket/start is destructive (reboot.target has 'start' job queued, but 'stop' is included in transaction).
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.540163] Open failed for /dev/i2c-3, errno=EACCES(-13): Permissão negada in file i2c_bus_core.c near line 433
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.540174] Traced function stack 0x7fa17c0008b0 for current thread [  1849]
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.540180]    dw_watch_display_connections
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.540184]    invoke_process_screen_change_event
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.540188]    process_screen_change_event
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.540192]    i2c_edid_exists
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.540195]    i2c_open_bus
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.540199]    i2c_open_bus_basic
mai 29 20:51:20 Mocha kded6[962]: context kaput
mai 29 20:51:20 Mocha kded6[962]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo"
mai 29 20:51:20 Mocha kded6[962]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor"
mai 29 20:51:20 Mocha kded6[962]: Playing audio notification failed: IO error
mai 29 20:51:20 Mocha systemd[735]: sys-devices-pci0000:00-0000:00:01.1-0000:01:00.1-sound-card0-controlC0.device: Failed to enqueue SYSTEMD_USER_WANTS job, ignoring: Transaction for sound.target/start is destructive (shutdown.target has 'start' job queued, but 'stop' is included in transaction).
mai 29 20:51:20 Mocha systemd[735]: sys-devices-pci0000:00-0000:00:08.1-0000:09:00.1-sound-card1-controlC1.device: Failed to enqueue SYSTEMD_USER_WANTS job, ignoring: Transaction for sound.target/start is destructive (systemd-exit.service has 'start' job queued, but 'stop' is included in transaction).
mai 29 20:51:20 Mocha dbus-broker-launch[614]: Activation request for 'org.bluez' failed.
mai 29 20:51:20 Mocha kwin_wayland[808]: PipeWire remote error:  connection error
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.561769] open() EACCES failure, recently resumed from sleep: false
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.561777] User ACL is not RW
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.564362] Current user not in group i2c
mai 29 20:51:20 Mocha dbus-broker-launch[614]: Activation request for 'org.freedesktop.UDisks2' failed.
mai 29 20:51:20 Mocha kded6[962]: Failed enumerating UDisks2 objects: "org.freedesktop.DBus.Error.NameHasNoOwner" "\n" "Could not activate remote peer 'org.freedesktop.UDisks2': activation request failed: unit is invalid"
mai 29 20:51:20 Mocha dbus-broker-launch[614]: Activation request for 'org.freedesktop.UDisks2' failed.
mai 29 20:51:20 Mocha kded6[962]: Failed enumerating UDisks2 objects: "org.freedesktop.DBus.Error.NameHasNoOwner" "\n" "Could not activate remote peer 'org.freedesktop.UDisks2': activation request failed: unit is invalid"
mai 29 20:51:20 Mocha dbus-broker-launch[614]: Activation request for 'org.freedesktop.UDisks2' failed.
mai 29 20:51:20 Mocha kded6[962]: Failed enumerating UDisks2 objects: "org.freedesktop.DBus.Error.NameHasNoOwner" "\n" "Could not activate remote peer 'org.freedesktop.UDisks2': activation request failed: unit is invalid"
mai 29 20:51:20 Mocha dbus-broker-launch[614]: Activation request for 'org.freedesktop.UDisks2' failed.
mai 29 20:51:20 Mocha kded6[962]: Failed enumerating UDisks2 objects: "org.freedesktop.DBus.Error.NameHasNoOwner" "\n" "Could not activate remote peer 'org.freedesktop.UDisks2': activation request failed: unit is invalid"
mai 29 20:51:20 Mocha kded6[962]: PendingCall Error: "Could not activate remote peer 'org.bluez': activation request failed: unit is invalid"
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.664470] Open failed for /dev/i2c-3, errno=EACCES(-13): Permissão negada in file i2c_bus_core.c near line 433
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.664486] open() failed with 1 EACCES errors, total retry ms = 100
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.664946] Open failed for /dev/i2c-4, errno=EACCES(-13): Permissão negada in file i2c_bus_core.c near line 433
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.664956] Traced function stack 0x7fa17c0008b0 for current thread [  1849]
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.664962]    dw_watch_display_connections
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.664966]    invoke_process_screen_change_event
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.664969]    process_screen_change_event
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.664972]    i2c_edid_exists
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.664975]    i2c_open_bus
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.664978]    i2c_open_bus_basic
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.672592] open() EACCES failure, recently resumed from sleep: false
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.672598] User ACL is not RW
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.673861] Current user not in group i2c
mai 29 20:51:20 Mocha plasmashell[995]: Socket error occurred: "QLocalSocket: Remote closed"
mai 29 20:51:20 Mocha plasmashell[995]: Socket error occurred: "QLocalSocket: Conexão remota encerrada"
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: context kaput
mai 29 20:51:20 Mocha plasmashell[995]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo"
mai 29 20:51:20 Mocha plasmashell[995]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor"
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.773951] Open failed for /dev/i2c-4, errno=EACCES(-13): Permissão negada in file i2c_bus_core.c near line 433
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.773964] open() failed with 1 EACCES errors, total retry ms = 100
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.774387] Open failed for /dev/i2c-5, errno=EACCES(-13): Permissão negada in file i2c_bus_core.c near line 433
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.774394] Traced function stack 0x7fa17c0008b0 for current thread [  1849]
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.774399]    dw_watch_display_connections
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.774402]    invoke_process_screen_change_event
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.774405]    process_screen_change_event
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.774408]    i2c_edid_exists
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.774410]    i2c_open_bus
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.774413]    i2c_open_bus_basic
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.781911] open() EACCES failure, recently resumed from sleep: false
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.781917] User ACL is not RW
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.783261] Current user not in group i2c
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.883369] Open failed for /dev/i2c-5, errno=EACCES(-13): Permissão negada in file i2c_bus_core.c near line 433
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.883383] open() failed with 1 EACCES errors, total retry ms = 100
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.883789] Open failed for /dev/i2c-6, errno=EACCES(-13): Permissão negada in file i2c_bus_core.c near line 433
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.883795] Traced function stack 0x7fa17c0008b0 for current thread [  1849]
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.883800]    dw_watch_display_connections
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.883803]    invoke_process_screen_change_event
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.883806]    process_screen_change_event
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.883809]    i2c_edid_exists
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.883811]    i2c_open_bus
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.883814]    i2c_open_bus_basic
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.891638] open() EACCES failure, recently resumed from sleep: false
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.891644] User ACL is not RW
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.893092] Current user not in group i2c
mai 29 20:51:21 Mocha dbus-broker-launch[614]: Activation request for 'org.freedesktop.nm_dispatcher' failed.
mai 29 20:51:22 Mocha kernel: watchdog: watchdog0: watchdog did not stop!

===== Kernel log do boot anterior =====
mai 29 20:41:35 Mocha kernel: rust_binder: Loaded Rust Binder.
mai 29 20:41:35 Mocha kernel: sd 6:0:0:0: [sdc] Optimal transfer size 33553920 bytes not a multiple of preferred minimum block size (4096 bytes)
mai 29 20:41:35 Mocha kernel: nvidia: loading out-of-tree module taints kernel.
mai 29 20:41:35 Mocha systemd-journald[384]: File /var/log/journal/4da79a7861734df58d6f08f5f3b954b1/system.journal corrupted or uncleanly shut down, renaming and replacing.
mai 29 20:41:36 Mocha kernel: 
mai 29 20:41:36 Mocha kernel: NVRM: loading NVIDIA UNIX Open Kernel Module for x86_64  595.71.05  Release Build  (root@Mocha)  
mai 29 20:41:37 Mocha kernel: asus_wmi: failed to register LPS0 sleep handler in asus-wmi
mai 29 20:41:45 Mocha systemd-journald[384]: File /var/log/journal/4da79a7861734df58d6f08f5f3b954b1/user-1000.journal corrupted or uncleanly shut down, renaming and replacing.
mai 29 20:41:46 Mocha kernel: nvme nvme0: using unchecked data buffer
mai 29 20:41:46 Mocha kernel: block nvme0n1: No UUID available providing old NGUID
mai 29 20:51:22 Mocha kernel: watchdog: watchdog0: watchdog did not stop!

===== Erros do boot atual =====
mai 29 20:51:45 Mocha kernel: 
mai 29 20:51:47 Mocha bluetoothd[624]: Failed to set default system config for hci0
mai 29 20:52:03 Mocha org_kde_powerdevil[1072]: [  1072][  6.898934] Time since library initialized:   6.898934 seconds
mai 29 20:52:03 Mocha org_kde_powerdevil[1072]: [  1072][  6.898938] Extra delay starting dw_start_watch_displays: 0 millisec
mai 29 20:52:03 Mocha pulseaudio[934]: Failed to open connection to session manager: None of the authentication protocols specified are supported
mai 29 20:52:03 Mocha pulseaudio[934]: Failed to load module "module-x11-xsmp" (argument: "display=:1 xauthority=/run/user/1000/xauth_GplKfI session_manager=local/Mocha:@/tmp/.ICE-unix/961,unix/Mocha:/tmp/.ICE-unix/961"): initialization failed.

===== Ocorrências NVIDIA/Xid/freeze/hang/oops =====
mai 29 20:41:35 Mocha kernel: NMI watchdog: Enabled. Permanently consumes one hw-PMU counter.
mai 29 20:41:35 Mocha kernel: ACPI: bus type drm_connector registered
mai 29 20:41:35 Mocha kernel: simple-framebuffer simple-framebuffer.0: [drm] Registered 1 planes with drm panic
mai 29 20:41:35 Mocha kernel: [drm] Initialized simpledrm 1.0.0 for simple-framebuffer.0 on minor 0
mai 29 20:41:35 Mocha kernel: simple-framebuffer simple-framebuffer.0: [drm] fb0: simpledrmdrmfb frame buffer device
mai 29 20:41:35 Mocha systemd[1]: Load Kernel Module drm skipped, unmet condition check ConditionKernelModuleLoaded=!drm
mai 29 20:41:35 Mocha kernel: nvidia: loading out-of-tree module taints kernel.
mai 29 20:41:35 Mocha kernel: nvidia: module verification failed: signature and/or required key missing - tainting kernel
mai 29 20:41:36 Mocha kernel: nvidia-nvlink: Nvlink Core is being initialized, major device number 237
mai 29 20:41:36 Mocha kernel: nvidia 0000:01:00.0: vgaarb: VGA decodes changed: olddecodes=io+mem,decodes=none:owns=none
mai 29 20:41:36 Mocha kernel: NVRM: loading NVIDIA UNIX Open Kernel Module for x86_64  595.71.05  Release Build  (root@Mocha)  
mai 29 20:41:36 Mocha systemd-modules-load[385]: Inserted module 'nvidia_uvm'
mai 29 20:41:37 Mocha systemd-timesyncd[448]: Network configuration changed, trying to establish connection.
mai 29 20:41:37 Mocha kernel: sp5100_tco: SP5100/SB800 TCO WatchDog Timer Driver
mai 29 20:41:37 Mocha kernel: sp5100-tco sp5100-tco: Using 0xfeb00000 for watchdog MMIO address
mai 29 20:41:37 Mocha systemd-fsck[540]: *** Filesystem was changed ***
mai 29 20:41:37 Mocha systemd-fsck[540]: Writing changes.
mai 29 20:41:37 Mocha systemd-timesyncd[448]: Network configuration changed, trying to establish connection.
mai 29 20:41:37 Mocha kernel: nvidia-modeset: Loading NVIDIA UNIX Open Kernel Mode Setting Driver for x86_64  595.71.05  Release Build  (root@Mocha)  
mai 29 20:41:37 Mocha kernel: r8169 0000:04:00.0 eth0: RTL8168h/8111h, c8:7f:54:63:3e:0e, XID 541, IRQ 78
mai 29 20:41:37 Mocha kernel: [drm] [nvidia-drm] [GPU ID 0x00000100] Loading driver
mai 29 20:41:37 Mocha kernel: input: HDA NVidia HDMI/DP,pcm=3 as /devices/pci0000:00/0000:00:01.1/0000:01:00.1/sound/card0/input28
mai 29 20:41:37 Mocha kernel: input: HDA NVidia HDMI/DP,pcm=7 as /devices/pci0000:00/0000:00:01.1/0000:01:00.1/sound/card0/input29
mai 29 20:41:37 Mocha kernel: input: HDA NVidia HDMI/DP,pcm=8 as /devices/pci0000:00/0000:00:01.1/0000:01:00.1/sound/card0/input30
mai 29 20:41:37 Mocha kernel: input: HDA NVidia HDMI/DP,pcm=9 as /devices/pci0000:00/0000:00:01.1/0000:01:00.1/sound/card0/input31
mai 29 20:41:38 Mocha systemd-timesyncd[448]: Network configuration changed, trying to establish connection.
mai 29 20:41:38 Mocha systemd-timesyncd[448]: Network configuration changed, trying to establish connection.
mai 29 20:41:38 Mocha systemd-timesyncd[448]: Network configuration changed, trying to establish connection.
mai 29 20:41:38 Mocha systemd-timesyncd[448]: Network configuration changed, trying to establish connection.
mai 29 20:41:38 Mocha systemd-timesyncd[448]: Network configuration changed, trying to establish connection.
mai 29 20:41:38 Mocha systemd-timesyncd[448]: Network configuration changed, trying to establish connection.
mai 29 20:41:38 Mocha kernel: [drm] Initialized nvidia-drm 0.0.0 for 0000:01:00.0 on minor 1
mai 29 20:41:38 Mocha kernel: nvidia 0000:01:00.0: vgaarb: deactivate vga console
mai 29 20:41:38 Mocha kernel: fbcon: nvidia-drmdrmfb (fb0) is primary device
mai 29 20:41:38 Mocha kernel: nvidia 0000:01:00.0: [drm] fb0: nvidia-drmdrmfb frame buffer device
mai 29 20:41:39 Mocha alsactl[619]: Found hardware: "HDA-Intel" "Nvidia GPU ad HDMI/DP" "HDA:10de00ad,10de0000,00100100" "0x10de" "0x0000"
mai 29 20:41:39 Mocha NetworkManager[618]: <info>  [1780098099.2084] hostname: static hostname changed from (none) to "Mocha"
mai 29 20:41:39 Mocha NetworkManager[618]: <info>  [1780098099.2371] device (lo): state change: unmanaged -> unavailable (reason 'connection-assumed', managed-type: 'external')
mai 29 20:41:39 Mocha NetworkManager[618]: <info>  [1780098099.2374] device (lo): state change: unavailable -> disconnected (reason 'connection-assumed', managed-type: 'external')
mai 29 20:41:39 Mocha NetworkManager[618]: <info>  [1780098099.2391] device (enp4s0): state change: unmanaged -> unavailable (reason 'managed', managed-type: 'external')
mai 29 20:41:39 Mocha NetworkManager[618]: <info>  [1780098099.4007] device (lo): state change: disconnected -> prepare (reason 'none', managed-type: 'external')
mai 29 20:41:39 Mocha NetworkManager[618]: <info>  [1780098099.4009] device (lo): state change: prepare -> config (reason 'none', managed-type: 'external')
mai 29 20:41:39 Mocha NetworkManager[618]: <info>  [1780098099.4010] device (lo): state change: config -> ip-config (reason 'none', managed-type: 'external')
mai 29 20:41:39 Mocha NetworkManager[618]: <info>  [1780098099.4013] device (lo): state change: ip-config -> ip-check (reason 'none', managed-type: 'external')
mai 29 20:41:39 Mocha NetworkManager[618]: <info>  [1780098099.4021] device (lo): state change: ip-check -> secondaries (reason 'none', managed-type: 'external')
mai 29 20:41:39 Mocha NetworkManager[618]: <info>  [1780098099.4022] device (lo): state change: secondaries -> activated (reason 'none', managed-type: 'external')
mai 29 20:41:42 Mocha NetworkManager[618]: <info>  [1780098102.0563] device (enp4s0): state change: unavailable -> disconnected (reason 'carrier-changed', managed-type: 'full')
mai 29 20:41:42 Mocha NetworkManager[618]: <info>  [1780098102.0569] device (enp4s0): state change: disconnected -> prepare (reason 'none', managed-type: 'full')
mai 29 20:41:42 Mocha NetworkManager[618]: <info>  [1780098102.0574] device (enp4s0): state change: prepare -> config (reason 'none', managed-type: 'full')
mai 29 20:41:42 Mocha NetworkManager[618]: <info>  [1780098102.0579] device (enp4s0): state change: config -> ip-config (reason 'none', managed-type: 'full')
mai 29 20:41:43 Mocha NetworkManager[618]: <info>  [1780098103.8389] dhcp6 (enp4s0): state changed new lease
mai 29 20:41:45 Mocha NetworkManager[618]: <info>  [1780098105.5522] device (enp4s0): state change: ip-config -> ip-check (reason 'none', managed-type: 'full')
mai 29 20:41:45 Mocha NetworkManager[618]: <info>  [1780098105.5529] device (enp4s0): state change: ip-check -> secondaries (reason 'none', managed-type: 'full')
mai 29 20:41:45 Mocha NetworkManager[618]: <info>  [1780098105.5530] device (enp4s0): state change: secondaries -> activated (reason 'none', managed-type: 'full')
mai 29 20:41:46 Mocha NetworkManager[618]: <info>  [1780098106.2206] dhcp4 (enp4s0): state changed new lease, address=192.168.100.2, acd pending
mai 29 20:41:46 Mocha kwin_wayland[808]: Failed to gain real time thread priority (See CAP_SYS_NICE in the capabilities(7) man page). error: Operation not permitted
mai 29 20:41:46 Mocha kwin_wayland[808]: No backend specified, automatically choosing drm
mai 29 20:41:46 Mocha NetworkManager[618]: <info>  [1780098106.4018] dhcp4 (enp4s0): state changed new lease, address=192.168.100.2
mai 29 20:41:46 Mocha kwin_wayland[808]: Failed to gain real time thread priority (See CAP_SYS_NICE in the capabilities(7) man page). error: Operação não permitida
mai 29 20:41:46 Mocha kwin_wayland[808]: XKB: /usr/share/X11/locale/pt_BR.UTF-8/Compose:13:28: this compose sequence already exists; overriding
mai 29 20:41:46 Mocha kwin_wayland[808]: XKB: /usr/share/X11/locale/pt_BR.UTF-8/Compose:14:28: this compose sequence already exists; overriding
mai 29 20:41:46 Mocha kwin_wayland[808]: XKB: /usr/share/X11/locale/pt_BR.UTF-8/Compose:16:34: this compose sequence already exists; overriding
mai 29 20:41:46 Mocha kwin_wayland[808]: XKB: /usr/share/X11/locale/pt_BR.UTF-8/Compose:17:34: this compose sequence already exists; overriding
mai 29 20:41:46 Mocha kwin_wayland[808]: XKB: /usr/share/X11/locale/pt_BR.UTF-8/Compose:19:39: a sequence already exists which is a prefix of this sequence; overriding
mai 29 20:41:46 Mocha kwin_wayland[808]: Failed to gain real time thread priority (See CAP_SYS_NICE in the capabilities(7) man page). error: Operação não permitida
mai 29 20:41:47 Mocha kwin_wayland_wrapper[923]: The XKEYBOARD keymap compiler (xkbcomp) reports:
mai 29 20:41:47 Mocha kwin_wayland_wrapper[923]: > Warning:          Multiple symbols for level 1/group 1 on key <FK23>
mai 29 20:41:47 Mocha kwin_wayland_wrapper[923]: >                   Using F23, ignoring XF86TouchpadOff
mai 29 20:41:47 Mocha kwin_wayland_wrapper[923]: > Warning:          Symbol map for key <FK23> redefined
mai 29 20:41:47 Mocha kwin_wayland_wrapper[923]: >                   Using last definition for conflicting fields
mai 29 20:41:47 Mocha kwin_wayland_wrapper[923]: > Warning:          Symbol map for key <FK24> redefined
mai 29 20:41:47 Mocha kwin_wayland_wrapper[923]: >                   Using last definition for conflicting fields
mai 29 20:41:47 Mocha kwin_wayland_wrapper[923]: Errors from xkbcomp are not fatal to the X server
mai 29 20:41:47 Mocha kwin_wayland_wrapper[930]: The XKEYBOARD keymap compiler (xkbcomp) reports:
mai 29 20:41:47 Mocha kwin_wayland_wrapper[930]: > Warning:          Unsupported maximum keycode 709, clipping.
mai 29 20:41:47 Mocha kwin_wayland_wrapper[930]: >                   X11 cannot support keycodes above 255.
mai 29 20:41:47 Mocha kwin_wayland_wrapper[930]: > Warning:          Virtual modifier Hyper multiply defined
mai 29 20:41:47 Mocha kwin_wayland_wrapper[930]: >                   Using 0, ignoring 0
mai 29 20:41:47 Mocha kwin_wayland_wrapper[930]: > Warning:          Virtual modifier ScrollLock multiply defined
mai 29 20:41:47 Mocha kwin_wayland_wrapper[930]: >                   Using 0, ignoring 0
mai 29 20:41:47 Mocha kwin_wayland_wrapper[930]: Errors from xkbcomp are not fatal to the X server
mai 29 20:41:47 Mocha plasmashell[995]: Could not find required file "mainscript" for package "/usr/share/plasma/plasmoids/org.kde.plasma.icontasks/" should be QList("ui/main.qml")
mai 29 20:41:48 Mocha plasmashell[995]: Member visible of the object PlasmaQuick::Dialog overrides a member of the base object. Consider renaming it or adding final or override specifier
mai 29 20:41:48 Mocha plasmashell[995]: Member enabled of the object DeclarativeDropArea overrides a member of the base object. Consider renaming it or adding final or override specifier
mai 29 20:41:49 Mocha plasmashell[995]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor"
mai 29 20:41:51 Mocha akonadi_control[1202]: Connecting to deprecated signal QDBusConnectionInterface::serviceOwnerChanged(QString,QString,QString)
mai 29 20:41:51 Mocha akonadiserver[1207]: Connecting to deprecated signal QDBusConnectionInterface::serviceOwnerChanged(QString,QString,QString)
mai 29 20:41:51 Mocha akonadiserver[1207]: Subscriber Akonadi::Server::NotificationSubscriber(0x7f26e8002200) identified as "AgentBaseChangeRecorder - 94731784083136"
mai 29 20:41:51 Mocha akonadiserver[1207]: Subscriber Akonadi::Server::NotificationSubscriber(0x7f26e80399b0) identified as "AgentBaseChangeRecorder - 94731500188096"
mai 29 20:41:51 Mocha akonadiserver[1207]: Subscriber Akonadi::Server::NotificationSubscriber(0x7f26e803ac40) identified as "AgentBaseChangeRecorder - 94636293126272"
mai 29 20:41:51 Mocha akonadiserver[1207]: Subscriber Akonadi::Server::NotificationSubscriber(0x7f26e803c340) identified as "AgentBaseChangeRecorder - 94355009816752"
mai 29 20:41:51 Mocha akonadiserver[1207]: Subscriber Akonadi::Server::NotificationSubscriber(0x7f26e803dc10) identified as "UnifiedMailboxChangeRecorder - 140735981589792"
mai 29 20:41:51 Mocha akonadiserver[1207]: Subscriber Akonadi::Server::NotificationSubscriber(0x7f26e805f4d0) identified as "AgentBaseChangeRecorder - 94059609011312"
mai 29 20:41:51 Mocha akonadiserver[1207]: Subscriber Akonadi::Server::NotificationSubscriber(0x7f26e80ae9c0) identified as "AgentBaseChangeRecorder - 94105598549056"
mai 29 20:41:51 Mocha akonadiserver[1207]: Subscriber Akonadi::Server::NotificationSubscriber(0x7f26e80aa5b0) identified as "AgentBaseChangeRecorder - 94175118203824"
mai 29 20:41:51 Mocha akonadiserver[1207]: Subscriber Akonadi::Server::NotificationSubscriber(0x7f26e80abb10) identified as "AgentBaseChangeRecorder - 94204304308176"
mai 29 20:41:51 Mocha akonadiserver[1207]: Subscriber Akonadi::Server::NotificationSubscriber(0x7f26e80d56a0) identified as "AgentBaseChangeRecorder - 94284476237440"
mai 29 20:41:51 Mocha akonadiserver[1207]: Subscriber Akonadi::Server::NotificationSubscriber(0x7f26e80d6d90) identified as "AgentBaseChangeRecorder - 94615721095888"
mai 29 20:41:51 Mocha akonadiserver[1207]: Subscriber Akonadi::Server::NotificationSubscriber(0x7f26e80f86c0) identified as "AgentBaseChangeRecorder - 94096055988288"
mai 29 20:41:51 Mocha akonadiserver[1207]: Subscriber Akonadi::Server::NotificationSubscriber(0x7f26e80fb330) identified as "AgentBaseChangeRecorder - 93850084883104"
mai 29 20:41:51 Mocha akonadiserver[1207]: Subscriber Akonadi::Server::NotificationSubscriber(0x7f26e811e660) identified as "AgentBaseChangeRecorder - 93828677722560"
mai 29 20:41:51 Mocha akonadiserver[1207]: Subscriber Akonadi::Server::NotificationSubscriber(0x7f26e8185d20) identified as "AgentBaseChangeRecorder - 94196827152416"
mai 29 20:41:51 Mocha plasmashell[995]: endResetModel called on Akonadi::ContactsTreeModel(0x55a45f88d700) without calling beginResetModel first
mai 29 20:41:51 Mocha plasmashell[995]: endResetModel called on Akonadi::ContactsFilterProxyModel(0x7f47dc0390e0) without calling beginResetModel first
mai 29 20:41:51 Mocha plasmashell[995]: endResetModel called on KDescendantsProxyModel(0x7f47dc0391d0) without calling beginResetModel first
mai 29 20:41:51 Mocha plasmashell[995]: endResetModel called on Akonadi::EntityMimeTypeFilterModel(0x55a45f891b60) without calling beginResetModel first
mai 29 20:41:51 Mocha plasmashell[995]: endResetModel called on ContactsModel(0x55a45f87e5c0) without calling beginResetModel first
mai 29 20:41:51 Mocha plasmashell[995]: endResetModel called on KSortFilterProxyModel(0x55a45f87d960) without calling beginResetModel first
mai 29 20:41:51 Mocha plasmashell[995]: "QLocalSocket: Conexão remota encerrada" "/run/user/1000/akonadi/akonadiserver-ntf.socket"
mai 29 20:41:51 Mocha plasmashell[995]: qrc:/qt/qml/plasma/applet/org/kde/plasma/taskmanager/ToolTipDelegate.qml:63: TypeError: Cannot read property 'containsMouse' of null
mai 29 20:41:54 Mocha org_kde_powerdevil[1072]: Watching for DPMS state changes unimplemented
mai 29 20:41:54 Mocha org_kde_powerdevil[1072]: [  1072] Watching for DPMS state changes unimplemented
mai 29 20:41:54 Mocha org_kde_powerdevil[1072]: [  1072] Watching for display connection changes, resolved watch mode = Watch_Mode_Udev, poll loop interval = 500 millisec
mai 29 20:41:54 Mocha systemd[1]: Created slice Slice /system/dbus-:1.2-org.kde.powerdevil.discretegpuhelper.
mai 29 20:41:54 Mocha systemd[1]: Started dbus-:1.2-org.kde.powerdevil.discretegpuhelper@0.service.
mai 29 20:41:55 Mocha kwin_wayland[808]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.kwin'")
mai 29 20:41:55 Mocha plasmashell[995]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: Connection already associated with an application ID")
mai 29 20:41:55 Mocha kwin_wayland[808]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.kwin'")
mai 29 20:42:04 Mocha systemd[1]: dbus-:1.2-org.kde.powerdevil.discretegpuhelper@0.service: Deactivated successfully.
mai 29 20:43:32 Mocha plasmashell[995]: qrc:/qt/qml/plasma/applet/org/kde/plasma/taskmanager/ToolTipDelegate.qml:63: TypeError: Cannot read property 'containsMouse' of null
mai 29 20:43:33 Mocha plasmashell[995]: error creating screencast "Não foi possível encontrar a janela de id {35a2ea96-1bd8-49cf-bebe-5ce7d5439534}"
mai 29 20:49:32 Mocha plasmashell[995]: The cached device pixel ratio value was stale on window update.  Please file a QTBUG which explains how to reproduce.
mai 29 20:51:02 Mocha sudo[3598]:      hal : TTY=pts/2 ; PWD=/home/hal ; USER=root ; COMMAND=/usr/bin/tee /etc/modprobe.d/mocha-nvidia-wayland.conf
mai 29 20:51:03 Mocha kernel: zram0: detected capacity change from 0 to 32313344
mai 29 20:51:04 Mocha kernel: zram0: detected capacity change from 32313344 to 0
mai 29 20:51:04 Mocha kernel: zram0: detected capacity change from 0 to 32313344
mai 29 20:51:20 Mocha systemd[1]: Removed slice Slice /system/dbus-:1.2-org.kde.powerdevil.discretegpuhelper.
mai 29 20:51:20 Mocha plasmashell[995]: "QLocalSocket: Remote closed" "/run/user/1000/akonadi/akonadiserver-cmd.socket"
mai 29 20:51:20 Mocha plasmashell[995]: "QLocalSocket: Conexão remota encerrada" "/run/user/1000/akonadi/akonadiserver-cmd.socket"
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.534535]    prop_subsystem:  drm
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.534535]    prop_action:     change
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.534535]    syspath:         /sys/devices/pci0000:00/0000:00:01.1/0000:01:00.0/drm/card1
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.540184]    invoke_process_screen_change_event
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.540188]    process_screen_change_event
mai 29 20:51:20 Mocha kwin_wayland[808]: PipeWire remote error:  connection error
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.664966]    invoke_process_screen_change_event
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.664969]    process_screen_change_event
mai 29 20:51:20 Mocha plasmashell[995]: Socket error occurred: "QLocalSocket: Remote closed"
mai 29 20:51:20 Mocha plasmashell[995]: Socket error occurred: "QLocalSocket: Conexão remota encerrada"
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: context kaput
mai 29 20:51:20 Mocha plasmashell[995]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo"
mai 29 20:51:20 Mocha plasmashell[995]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor"
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.774402]    invoke_process_screen_change_event
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.774405]    process_screen_change_event
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha plasmashell[995]: PipeWire remote error:  -32 connection error
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.883803]    invoke_process_screen_change_event
mai 29 20:51:20 Mocha org_kde_powerdevil[1072]: [  1849][572.883806]    process_screen_change_event
mai 29 20:51:21 Mocha plasmashell[995]: warning: queue 0x55a45a4ffbe0 destroyed while proxies still attached:
mai 29 20:51:21 Mocha plasmashell[995]:   wl_callback#196 still attached
mai 29 20:51:21 Mocha systemd[735]: plasma-plasmashell.service: Consumed 5.243s CPU time over 9min 32.924s wall clock time, 480.6M memory peak.
mai 29 20:51:21 Mocha systemd[735]: plasma-kwin_wayland.service: Consumed 34.521s CPU time over 9min 34.488s wall clock time, 310.3M memory peak.
mai 29 20:51:21 Mocha NetworkManager[618]: <info>  [1780098681.3760] dhcp4 (enp4s0): state changed no lease
mai 29 20:51:21 Mocha NetworkManager[618]: <info>  [1780098681.3761] dhcp6 (enp4s0): state changed no lease
mai 29 20:51:21 Mocha kernel: zram0: detected capacity change from 32313344 to 0
mai 29 20:51:22 Mocha systemd[1]: Using hardware watchdog /dev/watchdog0: 'SP5100 TCO timer', version 0.
mai 29 20:51:22 Mocha systemd[1]: Watchdog running with a hardware timeout of 10min.
mai 29 20:51:22 Mocha kernel: watchdog: watchdog0: watchdog did not stop!
mai 29 20:51:22 Mocha systemd-shutdown[1]: Using hardware watchdog /dev/watchdog0: 'SP5100 TCO timer', version 0.
mai 29 20:51:22 Mocha systemd-shutdown[1]: Watchdog running with a hardware timeout of 10min.

===== 7. Energia, desempenho e agressividade aplicada =====

===== TuneD ativo =====
Current active profile: latency-performance

===== cpupower frequency-info =====
analisando o CPU 15:
  driver: amd-pstate-epp
  CPUs que rodam na mesma frequência de hardware: 15
  CPUs que precisam ter suas frequências coordenadas por software: 15
  energy performance preference: performance
  limites do hardware: 422 MHz - 4.67 GHz
  reguladores do cpufreq disponíveis: performance powersave
  política de frequência atual deve estar entre 2.39 GHz e 4.67 GHz.
                  O regulador "performance" deve decidir qual velocidade usar
                  dentro desse limite.
  current CPU frequency: Unable to call hardware
  current CPU frequency: 4.55 GHz (asserted by call to kernel)
  boost state support:
    Supported: yes
    Active: yes
  amd-pstate limits:
    Highest Performance: 166. Maximum Frequency: 4.67 GHz.
    Nominal Performance: 135. Nominal Frequency: 3.80 GHz.
    Lowest Non-linear Performance: 85. Lowest Non-linear Frequency: 2.39 GHz.
    Lowest Performance: 15. Lowest Frequency: 400 MHz.
    Preferred Core Support: 1. Preferred Core Ranking: 166.

===== Governors atuais =====
/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor: performance
/sys/devices/system/cpu/cpu10/cpufreq/scaling_governor: performance
/sys/devices/system/cpu/cpu11/cpufreq/scaling_governor: performance
/sys/devices/system/cpu/cpu12/cpufreq/scaling_governor: performance
/sys/devices/system/cpu/cpu13/cpufreq/scaling_governor: performance
/sys/devices/system/cpu/cpu14/cpufreq/scaling_governor: performance
/sys/devices/system/cpu/cpu15/cpufreq/scaling_governor: performance
/sys/devices/system/cpu/cpu1/cpufreq/scaling_governor: performance
/sys/devices/system/cpu/cpu2/cpufreq/scaling_governor: performance
/sys/devices/system/cpu/cpu3/cpufreq/scaling_governor: performance
/sys/devices/system/cpu/cpu4/cpufreq/scaling_governor: performance
/sys/devices/system/cpu/cpu5/cpufreq/scaling_governor: performance
/sys/devices/system/cpu/cpu6/cpufreq/scaling_governor: performance
/sys/devices/system/cpu/cpu7/cpufreq/scaling_governor: performance
/sys/devices/system/cpu/cpu8/cpufreq/scaling_governor: performance
/sys/devices/system/cpu/cpu9/cpufreq/scaling_governor: performance

===== ZRAM =====
NAME       ALGORITHM DISKSIZE DATA COMPR TOTAL STREAMS MOUNTPOINT
/dev/zram0 zstd         15,4G   4K   64B   20K         [SWAP]
NAME           TYPE       SIZE USED  PRIO
/dev/zram0     partition 15,4G   0B 32767
/dev/nvme0n1p3 partition   17G   0B    -1

===== Sysctl Mocha relevantes =====
vm.swappiness = 80
vm.vfs_cache_pressure = 50
vm.page-cluster = 0
vm.dirty_background_bytes = 67108864
vm.dirty_bytes = 268435456
vm.max_map_count = 16777216
kernel.sched_autogroup_enabled = 0

===== THP =====
always [madvise] never

===== 8. Pacotes Mocha relevantes =====

===== Pacotes gráficos/jogos/sistema =====
plasma-workspace 6.6.5-2
plasma-desktop 6.6.5-1
sddm 0.21.0-7
bluedevil 1:6.6.5-1
blueman 2.4.6-2
kmix 26.04.1-1
pipewire 1:1.6.6-1
wireplumber 0.5.14-1
tuned 2.27.0-1
cpupower 7.0.10-1
flatpak 1:1.16.6-1
discover 6.6.5-1

===== 9. Autostarts redundantes já corrigidos =====

/home/hal/.config/autostart/blueman.desktop
ausente

/home/hal/.config/autostart/kmix_autostart.desktop
ausente

/etc/skel/.config/autostart/blueman.desktop
ausente

/etc/skel/.config/autostart/kmix_autostart.desktop
ausente

===== 10. Barra KDE, esquema de cores e Plasma Style =====
Appletsrc atual existe: /home/hal/.config/plasma-org.kde.plasma.desktop-appletsrc
Assinaturas de painel/barra:
30:plugin=org.kde.plasma.digitalclock
41:plugin=org.kde.plasma.showdesktop
45:plugin=org.kde.plasma.kickoff
60:plugin=org.kde.plasma.icontasks
75:plugin=org.kde.plasma.systemtray

===== Tema KDE atualmente configurado =====
/home/hal/.config/kdeglobals:136:ColorSchemeHash=2c3f86428c11011a7c64ee1e7f47c274d498ff10
/home/hal/.config/kdeglobals:139:LookAndFeelPackage=org.kde.breezedark.desktop

===== Arquivos KDE ativos no MochaArch =====
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/ime.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/input.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/kalarm.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/kdeconnect.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/keyboard.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/kget.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/kgpg.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/kleopatra.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/klipper.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/kmail.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/konversation.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/konv_message.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/kopete.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/korgac.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/kpackagekit.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/kruler.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/kteatime.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/ktorrent.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/kup.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/list.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/mail.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/media.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/mobile.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/network.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/notification.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/osd.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/phone.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/plasmavault_error.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/plasmavault.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/preferences.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/printer.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/quassel.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/search.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/slc.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/software.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/start.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/system.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/touchpad.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/user.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/video-card.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/video.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/view.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/vlc.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/wallet.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/window.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/yakuake.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/icons/zoom.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/opaque/dialogs/background.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/opaque/widgets/panel-background.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/opaque/widgets/tooltip.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/plasmarc
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/solid/dialogs/background.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/solid/widgets/background.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/solid/widgets/panel-background.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/solid/widgets/tooltip.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/translucent/dialogs/background.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/translucent/widgets/background.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/translucent/widgets/panel-background.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/translucent/widgets/tooltip.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/actionbutton.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/action-overlays.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/analog_meter.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/arrows.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/background.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/bar_meter_horizontal.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/bar_meter_vertical.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/branding.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/busywidget.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/button.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/calendar.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/checkmarks.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/clock.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/configuration-icons.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/containment-controls.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/dragger.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/frame.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/glowbar.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/lineedit.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/line.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/listitem.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/margins-highlight.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/media-delegate.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/menubaritem.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/monitor.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/notes.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/pager.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/picker.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/plasmoidheading.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/plot-background.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/radiobutton.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/scrollbar.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/scrollwidget.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/slider.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/switch.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/tabbar.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/tasks.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/toolbar.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/tooltip.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/translucentbackground.svgz
2026-05-12 17:04  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/viewitem.svgz
2026-05-12 17:49  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/weather/wind-arrows.svgz
2026-05-12 17:49  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/timer.svgz
2026-05-28 22:54  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
2026-05-28 22:56  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt
2026-05-29 15:33  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh
2026-05-29 15:43  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/MANUAL-BARRA-WIN11-MOCHA-APROVADA.md
2026-05-29 17:56  /media/mochafast/MochaArch/ativo/kde/busca-esquema-cores-20260529-175611/20260529-175611-arquivos-com-hex-ranqueados.tsv
2026-05-29 17:56  /media/mochafast/MochaArch/ativo/kde/busca-esquema-cores-20260529-175611/20260529-175611-busca-esquema-cores-kde.log
2026-05-29 17:56  /media/mochafast/MochaArch/ativo/kde/busca-esquema-cores-20260529-175611/20260529-175611-candidatos-arquivos.txt
2026-05-29 17:58  /media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/MochaDark.colors
2026-05-29 17:58  /media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/MochaKDE.colors
2026-05-29 17:58  /media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/MochaSolidCanonico.colors
2026-05-29 17:58  /media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/Mocha-Windows11.colors
2026-05-29 18:03  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/metadata.json
2026-05-29 18:03  /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico/widgets/panel-background.svgz
2026-05-29 19:52  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-atual
2026-05-29 19:52  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-atual-20260529-200013
2026-05-29 20:00  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-200013-mocha-reaplicar-barra-aprovada-atual.sh
2026-05-29 20:00  /media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/20260529-200013-TABELA-CORES-MOCHA-SOLID-CANONICO.md
2026-05-29 20:00  /media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/TABELA-CORES-MOCHA-SOLID-CANONICO.md

===== 11. Manual e documentação ativa =====

===== Documentos Markdown recentes no ativo =====
2026-05-28 22:56  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt
2026-05-29 15:01  /media/mochafast/MochaArch/ativo/documentacao/20260529-150104-login-plasma-manager-esquema-aprovado.md
2026-05-29 15:24  /media/mochafast/MochaArch/ativo/auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/LEIA-ME.txt
2026-05-29 15:24  /media/mochafast/MochaArch/ativo/auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/plasma-applets-volume-bluetooth-systemtray.txt
2026-05-29 15:24  /media/mochafast/MochaArch/ativo/auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/resumo-auditoria.txt
2026-05-29 15:24  /media/mochafast/MochaArch/ativo/documentacao/20260529-152416-baseline-superior-endeavour-steam-overlay-kde.md
2026-05-29 15:27  /media/mochafast/MochaArch/ativo/documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md
2026-05-29 15:29  /media/mochafast/MochaArch/ativo/documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md
2026-05-29 15:29  /media/mochafast/MochaArch/ativo/passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md
2026-05-29 15:43  /media/mochafast/MochaArch/ativo/documentacao/20260529-154304-MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md
2026-05-29 15:43  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/MANUAL-BARRA-WIN11-MOCHA-APROVADA.md
2026-05-29 15:43  /media/mochafast/MochaArch/ativo/logs/20260529-154304-auditoria-estado-atual-para-manual.md
2026-05-29 15:43  /media/mochafast/MochaArch/ativo/logs/20260529-154304-evidencias-extraidas-para-manual.md
2026-05-29 15:44  /media/mochafast/MochaArch/ativo/documentacao/20260529-154451-wrapper-steam-auditoria-e-implantacao.md
2026-05-29 15:46  /media/mochafast/MochaArch/ativo/documentacao/20260529-154612-wrapper-steam-corrigido-falso-positivo.md
2026-05-29 16:13  /media/mochafast/MochaArch/ativo/documentacao/20260529-161327-auditoria-gamemode-on-off.md
2026-05-29 16:26  /media/mochafast/MochaArch/ativo/auditorias/20260529-162618-auditoria-tema-kde-deuterocanonico-wallpaper.md
2026-05-29 16:28  /media/mochafast/MochaArch/ativo/auditorias/20260529-162826-fast-tema-kde-esquema-cores-wallpaper.md
2026-05-29 16:34  /media/mochafast/MochaArch/ativo/auditorias/20260529-163403-aplicar-wallpaper-kdePCan.md
2026-05-29 16:34  /media/mochafast/MochaArch/ativo/documentacao/20260529-163403-wallpaper-kdePCan-aplicado.md
2026-05-29 16:46  /media/mochafast/MochaArch/ativo/auditorias/20260529-164631-fast-procura-esquema-cores-tema-recente.md
2026-05-29 17:24  /media/mochafast/MochaArch/ativo/documentacao/20260529-172415-steam-launcher-mangohud-padrao-telemetria.md
2026-05-29 17:29  /media/mochafast/MochaArch/ativo/telemetria/20260529-172426-steam-2169200-mangohud-mocha-gamemode/resumo-final.md
2026-05-29 17:31  /media/mochafast/MochaArch/ativo/documentacao/20260529-173139-steam-telemetria-ruim-nao-usar.md
2026-05-29 17:31  /media/mochafast/MochaArch/ativo/steam-launcher-telemetria/linha-steam-atual-segura-20260529-173139.txt
2026-05-29 17:33  /media/mochafast/MochaArch/ativo/documentacao/20260529-173325-coletor-externo-leve-jogo.md
2026-05-29 17:47  /media/mochafast/MochaArch/ativo/auditorias/20260529-171302-fast-arquivos-com-cores-hex.md
2026-05-29 17:56  /media/mochafast/MochaArch/ativo/kde/busca-esquema-cores-20260529-175611/20260529-175611-candidatos-arquivos.txt
2026-05-29 17:58  /media/mochafast/MochaArch/ativo/documentacao/20260529-175841-esquema-cores-kde-mocha-solid-canonico-aplicado.md
2026-05-29 18:01  /media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt
2026-05-29 18:01  /media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-resumo-barra-plasma-cores.md
2026-05-29 18:03  /media/mochafast/MochaArch/ativo/documentacao/20260529-180309-plasma-style-barra-mocha-aplicado.md
2026-05-29 18:27  /media/mochafast/MochaArch/ativo/documentacao/20260529-182750-zen-default-grub-seguro.md
2026-05-29 19:57  /media/mochafast/MochaArch/ativo/relatorios/20260529-195748-auditoria-geral-pre-formatacao-mochaarch.md
2026-05-29 19:57  /media/mochafast/MochaArch/ativo/relatorios/20260529-195748-hashes-arquivos-criticos.txt
2026-05-29 19:57  /media/mochafast/MochaArch/ativo/relatorios/20260529-195748-nomes-scripts.txt
2026-05-29 19:57  /media/mochafast/MochaArch/ativo/relatorios/20260529-195748-pacotes-explicitos.txt
2026-05-29 19:57  /media/mochafast/MochaArch/ativo/relatorios/20260529-195748-pacotes-instalados.txt
2026-05-29 20:00  /media/mochafast/MochaArch/ativo/documentacao/20260529-200013-pendencias-auditoria-pre-formatacao-corrigidas.md
2026-05-29 20:00  /media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/20260529-200013-TABELA-CORES-MOCHA-SOLID-CANONICO.md
2026-05-29 20:00  /media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/TABELA-CORES-MOCHA-SOLID-CANONICO.md
2026-05-29 20:00  /media/mochafast/MochaArch/ativo/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md
2026-05-29 20:00  /media/mochafast/MochaArch/ativo/relatorios/20260529-200013-auditoria-corrigida-cobertura-manuais.md
2026-05-29 20:47  /media/mochafast/MochaArch/ativo/logs/20260529-204737-auditoria-congelamento-pos-freeze.txt
2026-05-29 20:51  /media/mochafast/MochaArch/ativo/documentacao/manual-montagem-mochaarch.md
2026-05-29 20:53  /media/mochafast/MochaArch/ativo/relatorios/20260529-205350-auditoria-seguimento-manual-pos-congelamento.md

===== Possíveis manuais de montagem =====
2026-05-29 15:29  /media/mochafast/MochaArch/ativo/documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md
2026-05-29 15:29  /media/mochafast/MochaArch/ativo/passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md
2026-05-29 15:43  /media/mochafast/MochaArch/ativo/documentacao/20260529-154304-MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md
2026-05-29 15:43  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/MANUAL-BARRA-WIN11-MOCHA-APROVADA.md
2026-05-29 15:43  /media/mochafast/MochaArch/ativo/logs/20260529-154304-auditoria-estado-atual-para-manual.md
2026-05-29 15:43  /media/mochafast/MochaArch/ativo/logs/20260529-154304-criar-manual-vivo-definitivo-mocha-arch-kde.log
2026-05-29 15:43  /media/mochafast/MochaArch/ativo/logs/20260529-154304-evidencias-extraidas-para-manual.md
2026-05-29 15:43  /media/mochafast/MochaArch/ativo/scripts/20260529-154304-mocha-adicionar-entrada-aprovada-ao-manual.sh
2026-05-29 15:43  /media/mochafast/MochaArch/ativo/scripts/mocha-adicionar-entrada-aprovada-ao-manual.sh
2026-05-29 20:00  /media/mochafast/MochaArch/ativo/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md
2026-05-29 20:37  /media/mochafast/MochaArch/ativo/scripts/20260529-203750-montar-fast-vm-ler-manual.sh
2026-05-29 20:43  /media/mochafast/MochaArch/ativo/scripts/20260529-204336-atualizar-manual-ler.sh
2026-05-29 20:51  /media/mochafast/MochaArch/ativo/documentacao/manual-montagem-mochaarch.md
2026-05-29 20:53  /media/mochafast/MochaArch/ativo/relatorios/20260529-205350-auditoria-seguimento-manual-pos-congelamento.md

===== 12. Wrapper Steam Mocha, sem contaminar baseline =====
Wrapper não encontrado em /home/hal/.local/bin/mocha-steam-game-run

===== 13. Flatpak/Steam/MangoHud =====

===== Flatpak remotes =====
flathub	Flathub	https://dl.flathub.org/repo/	-	-	-	1	system	Central repository of Flatpak applications	Central repository of Flatpak applications	https://flathub.org/	https://dl.flathub.org/repo/logo.svg

===== Steam detectável =====

===== MangoHud configs =====

===== 14. Resumo objetivo =====
Relatório salvo em:
/media/mochafast/MochaArch/ativo/relatorios/20260529-205350-auditoria-seguimento-manual-pos-congelamento.md

Cole a saída inteira ou pelo menos o bloco final com erros/avisos.
Depois disso, o próximo comando deve ser de correção específica, não de tentativa às cegas.
