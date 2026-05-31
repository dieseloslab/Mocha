
## MOCHA ARCH — AUDITORIA GERAL PRE-FORMATACAO

Data: 20260529-195748
Modo: somente leitura, exceto criacao deste relatorio/checklist.
Base esperada: /media/mochafast/MochaArch
Ativo esperado: /media/mochafast/MochaArch/ativo
Relatorio: /media/mochafast/MochaArch/ativo/relatorios/20260529-195748-auditoria-geral-pre-formatacao-mochaarch.md
Checklist: /media/mochafast/MochaArch/ativo/relatorios/20260529-195748-checklist-pre-formatacao.tsv

Objetivo:
- conferir se a maquina atual esta reproduzivel;
- conferir se os manuais registram o que deu certo;
- conferir tema/cores/barra KDE;
- conferir kernel/driver/boot/energia/montagens;
- apontar o que escapou antes da formatacao.

### [01] Escopo, base ativa e montagens obrigatorias

[OK] Pasta base existe: /media/mochafast/MochaArch
[OK] Pasta ativa existe: /media/mochafast/MochaArch/ativo
[OK] FAST esta montado em /media/mochafast
[OK] VMSTORE esta montado em /media/vmstore

## findmnt

$ findmnt -no SOURCE,FSTYPE,OPTIONS,TARGET /media/mochafast
/dev/sda1 btrfs rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvolid=5,subvol=/ /media/mochafast

$ findmnt -no SOURCE,FSTYPE,OPTIONS,TARGET /media/vmstore
/dev/sdb1 xfs rw,noatime,inode64,logbufs=8,logbsize=32k,noquota /media/vmstore

[OK] FAST aparece como btrfs
[OK] VMSTORE aparece como xfs

## /etc/fstab — linhas relevantes

17:UUID=88e6aa16-110c-4b97-9ffb-85084c000198 /media/mochafast btrfs defaults,noatime,compress=zstd:3,ssd,discard=async,nofail,x-systemd.device-timeout=10s 0 0
18:UUID=b81630a0-0756-45e4-9cb2-c7f16637a1c6 /media/vmstore xfs defaults,noatime,nofail,x-systemd.device-timeout=10s 0 2
[OK] fstab contem referencia ao FAST/mochafast
[OK] fstab contem referencia ao VMSTORE/vmstore

### [02] Identidade do sistema, repositorios e pacotes instalados


## Sistema

$ uname -a
Linux Mocha 7.0.10-zen1-1-zen #1 ZEN SMP PREEMPT_DYNAMIC Sat, 23 May 2026 14:45:01 +0000 x86_64 GNU/Linux

NAME="Arch Linux"
PRETTY_NAME="Arch Linux"
ID=arch
BUILD_ID=rolling
ANSI_COLOR="38;2;23;147;209"
HOME_URL="https://archlinux.org/"
DOCUMENTATION_URL="https://wiki.archlinux.org/"
SUPPORT_URL="https://bbs.archlinux.org/"
BUG_REPORT_URL="https://gitlab.archlinux.org/groups/archlinux/-/issues"
PRIVACY_POLICY_URL="https://terms.archlinux.org/docs/privacy-policy/"
LOGO=archlinux-logo

## Pacman/repositorios

[OK] Lista completa de pacotes salva em: /media/mochafast/MochaArch/ativo/relatorios/20260529-195748-pacotes-instalados.txt
[OK] Lista de pacotes explicitos salva em: /media/mochafast/MochaArch/ativo/relatorios/20260529-195748-pacotes-explicitos.txt
$ pacman -Q pacman
pacman 7.1.0.r9.g54d9411-2

$ pacman-conf --repo-list
core
extra
multilib

$ pacman-conf CacheDir
/var/cache/pacman/pkg/


## /etc/pacman.conf — repos principais

9:[options]
43:SigLevel    = Required DatabaseOptional
77:[core]
78:Include = /etc/pacman.d/mirrorlist
83:[extra]
84:Include = /etc/pacman.d/mirrorlist
92:[multilib]
93:Include = /etc/pacman.d/mirrorlist

### [03] Kernel, headers, bootloader e entrada padrao


## Kernel atual

7.0.10-zen1-1-zen
[OK] Kernel atual e Zen: 7.0.10-zen1-1-zen

## Pacotes kernel/NVIDIA relevantes

egl-wayland 4:1.1.21-1
egl-wayland2 1.0.1-1
lib32-nvidia-utils 595.71.05-1
linux-api-headers 6.19-1
linux-atm 2.5.2-9
linux-firmware 20260519-1
linux-firmware-amdgpu 20260519-1
linux-firmware-atheros 20260519-1
linux-firmware-broadcom 20260519-1
linux-firmware-cirrus 20260519-1
linux-firmware-intel 20260519-1
linux-firmware-mediatek 20260519-1
linux-firmware-nvidia 20260519-1
linux-firmware-other 20260519-1
linux-firmware-radeon 20260519-1
linux-firmware-realtek 20260519-1
linux-firmware-whence 20260519-1
linux-headers 7.0.10.arch1-1
linux-zen 7.0.10.zen1-1
linux-zen-headers 7.0.10.zen1-1
nvidia-open-dkms 595.71.05-2
nvidia-settings 595.71.05-1
nvidia-utils 595.71.05-2
opencl-nvidia 595.71.05-2
vulkan-icd-loader 1.4.350.0-1
vulkan-tools 1.4.350.0-1
[OK] Pacote linux-zen instalado
[OK] Pacote linux-zen-headers instalado

## Bootloader detectado

$ bootctl status
Failed to read "/boot/efi/EFI/systemd": Permission denied
Failed to open '/boot/efi/loader/loader.conf': Permission denied
System:
      Firmware: n/a (n/a)
 Firmware Arch: x64
   Secure Boot: disabled
  TPM2 Support: yes
  Measured UKI: no
  Boot into FW: supported

Current Boot Loader:
       Product: GRUB 2.14
     Features: - Boot counting
               - Menu timeout control
               - One-shot menu timeout control
               - Default entry control
               - One-shot entry control
               - Support for XBOOTLDR partition
               - Support for passing random seed to OS
               - Load drop-in drivers
               - Support Type #1 sort-key field
               - Support @saved pseudo-entry
               - Support Type #1 devicetree field
               - Enroll SecureBoot keys
               - Retain SHIM protocols
               - Menu can be disabled
               - Multi-Profile UKIs are supported
               - Loader reports network boot URL
               - Support Type #1 uki field
               - Support Type #1 uki-url field
               - Loader reports active TPM2 PCR banks
     Partition: /dev/disk/by-partuuid/63e923ae-be1f-4e03-a19c-65219f94c339
 Default Entry: 9fb12cce3c9f4d0faa59ef1767d38042-7.0.10-zen1-1-zen.conf

Random Seed:
 System Token: set
       Exists: Can't access /boot/efi/loader/random-seed (Permission denied)

Available Boot Loaders on ESP:
          ESP: /boot/efi (/dev/disk/by-partuuid/63e923ae-be1f-4e03-a19c-65219f94c339)
         File: (can't access /boot/efi: Permission denied)

Boot Loaders Listed in EFI Variables:
        Title: Arch
           ID: 0x0000
       Status: active, boot-order
    Partition: /dev/disk/by-partuuid/63e923ae-be1f-4e03-a19c-65219f94c339
         File: `-/boot/efi//EFI/ARCH/GRUBX64.EFI

        Title: UEFI OS
           ID: 0x0014
       Status: active, boot-order
    Partition: /dev/disk/by-partuuid/63e923ae-be1f-4e03-a19c-65219f94c339
         File: `-/boot/efi//EFI/BOOT/BOOTX64.EFI


$ bootctl list
Failed to open '/boot/efi/loader/loader.conf': Permission denied


## /etc/default/grub

3:GRUB_DEFAULT=0
4:GRUB_TIMEOUT=8
6:GRUB_CMDLINE_LINUX_DEFAULT="quiet splash loglevel=3 nvidia_drm.modeset=1"
7:GRUB_CMDLINE_LINUX=""
17:GRUB_TIMEOUT_STYLE=menu
53:# setting 'GRUB_DEFAULT=saved' above.
57:#GRUB_DISABLE_SUBMENU=y
[OK] /etc/default/grub contem indicio de default salvo/Zen

### [04] NVIDIA, Wayland e login grafico


## NVIDIA

$ nvidia-smi
Fri May 29 19:57:49 2026       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 595.71.05              Driver Version: 595.71.05      CUDA Version: 13.2     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 5060 Ti     On  |   00000000:01:00.0  On |                  N/A |
|  0%   30C    P5             19W /  180W |     648MiB /  16311MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A             914      G   /usr/bin/ksecretd                         2MiB |
|    0   N/A  N/A             980      G   /usr/bin/kwin_wayland                    22MiB |
|    0   N/A  N/A            1062      G   /usr/bin/Xwayland                         3MiB |
|    0   N/A  N/A            1101      G   /usr/bin/ksmserver                        2MiB |
|    0   N/A  N/A            1103      G   /usr/bin/kded6                            2MiB |
|    0   N/A  N/A            1131      G   /usr/bin/plasmashell                     68MiB |
|    0   N/A  N/A            1218      G   /usr/bin/kaccess                          2MiB |
|    0   N/A  N/A            1219      G   ...it-kde-authentication-agent-1          2MiB |
|    0   N/A  N/A            1301      G   /usr/bin/kdeconnectd                      2MiB |
|    0   N/A  N/A            1334      G   /usr/bin/akonadi_control                  2MiB |
|    0   N/A  N/A            1348      G   ...bin/akonadi_archivemail_agent          2MiB |
|    0   N/A  N/A            1351      G   ...konadi_followupreminder_agent          2MiB |
|    0   N/A  N/A            1355      G   .../akonadi_maildispatcher_agent          2MiB |
|    0   N/A  N/A            1356      G   .../bin/akonadi_mailfilter_agent          2MiB |
|    0   N/A  N/A            1357      G   /usr/bin/akonadi_mailmerge_agent          2MiB |
|    0   N/A  N/A            1358      G   /usr/bin/akonadi_migration_agent          2MiB |
|    0   N/A  N/A            1359      G   ...akonadi_newmailnotifier_agent          2MiB |
|    0   N/A  N/A            1360      G   /usr/bin/akonadi_sendlater_agent          2MiB |
|    0   N/A  N/A            1361      G   .../akonadi_unifiedmailbox_agent          2MiB |
|    0   N/A  N/A            1516      G   /usr/lib/DiscoverNotifier                 2MiB |
|    0   N/A  N/A            1517      G   /usr/bin/kalendarac                       2MiB |
|    0   N/A  N/A            1537      G   /usr/lib/firefox/firefox                218MiB |
|    0   N/A  N/A            1590      G   /usr/lib/xdg-desktop-portal-kde           2MiB |
|    0   N/A  N/A            2425      G   /usr/bin/konsole                          2MiB |
+-----------------------------------------------------------------------------------------+

[OK] nvidia-smi respondeu; driver NVIDIA funcional no momento
Resumo GPU:
NVIDIA GeForce RTX 5060 Ti, 595.71.05, P5, 18.38 W, 180.00 W, 705 MHz, 810 MHz

## Modulos NVIDIA carregados

nvidia_drm            159744  88
nvidia_uvm           2564096  0
nvidia_modeset       2203648  51 nvidia_drm
nvidia              16584704  967 nvidia_uvm,nvidia_modeset
[OK] Modulo NVIDIA carregado

## lspci video

01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GB206 [GeForce RTX 5060 Ti] [10de:2d04] (rev a1)
	Subsystem: Micro-Star International Co., Ltd. [MSI] Device [1462:5351]
	Kernel driver in use: nvidia
	Kernel modules: nouveau, nvidia_drm, nvidia
01:00.1 Audio device [0403]: NVIDIA Corporation GB206 High Definition Audio Controller [10de:22eb] (rev a1)
	Subsystem: NVIDIA Corporation Device [10de:0000]
	Kernel driver in use: snd_hda_intel
	Kernel modules: snd_hda_intel
02:00.0 USB controller [0c03]: Advanced Micro Devices, Inc. [AMD] A520 Series Chipset USB 3.1 XHCI Controller [1022:43ec]
	Subsystem: ASMedia Technology Inc. Device [1b21:1142]

## Sessao atual

XDG_SESSION_TYPE=wayland
XDG_CURRENT_DESKTOP=KDE
[OK] Sessao atual e Wayland
$ loginctl show-session 2 -p Type -p Desktop -p Name -p State
Name=hal
Desktop=KDE
Type=wayland
State=active


## Display manager

$ systemctl status display-manager --no-pager
* plasmalogin.service - Plasma Login Manager
     Loaded: loaded (/usr/lib/systemd/system/plasmalogin.service; enabled; preset: disabled)
     Active: active (running) since Fri 2026-05-29 19:52:20 -03; 5min ago
 Invocation: b4e6415916494ef09f71674560ec99a6
       Docs: man:plasmalogin(1)
             man:plasmalogin.conf(5)
    Process: 718 ExecStartPre=udevadm settle --timeout=10 (code=exited, status=0/SUCCESS)
   Main PID: 720 (plasmalogin)
      Tasks: 2 (limit: 18657)
     Memory: 20.4M (peak: 39.9M)
        CPU: 180ms
     CGroup: /system.slice/plasmalogin.service
             `-720 /usr/bin/plasmalogin

May 29 19:52:35 Mocha plasmalogin-helper[890]: [PAM] returning.
May 29 19:52:35 Mocha plasmalogin[720]: Authentication for user  "hal"  successful
May 29 19:52:35 Mocha plasmalogin-helper[890]: pam_kwallet5(plasmalogin:setcred): pam_kwallet5: pam_sm_setcred
May 29 19:52:35 Mocha plasmalogin-helper[890]: pam_unix(plasmalogin:session): session opened for user hal(uid=1000) by hal(uid=0)
May 29 19:52:35 Mocha plasmalogin-helper[890]: pam_kwallet5(plasmalogin:session): pam_kwallet5: pam_sm_open_session
May 29 19:52:35 Mocha plasmalogin-helper[890]: Starting Wayland user session: "/usr/share/plasmalogin/scripts/wayland-session" "/usr/lib/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland"
May 29 19:52:35 Mocha plasmalogin[720]: Session started true
May 29 19:52:40 Mocha plasmalogin[720]: Greeter stopping...
May 29 19:52:40 Mocha plasmalogin[720]: Auth: plasmalogin-helper exited with 255
May 29 19:52:40 Mocha plasmalogin[720]: Greeter stopped. PLASMALOGIN::Auth::HelperExitStatus(255)

$ systemctl is-enabled sddm
disabled

display-manager.service -> /usr/lib/systemd/system/plasmalogin.service

## SDDM/Wayland configs relevantes

/etc/sddm.conf:2:Session=plasma
/usr/lib/sddm/sddm.conf.d/default.conf:6:Session=
/usr/lib/sddm/sddm.conf.d/default.conf:14:# Valid values are: x11, x11-user, wayland. Wayland support is experimental
/usr/lib/sddm/sddm.conf.d/default.conf:15:DisplayServer=x11
/usr/lib/sddm/sddm.conf.d/default.conf:18:GreeterEnvironment=
/usr/lib/sddm/sddm.conf.d/default.conf:85:RememberLastSession=true
/usr/lib/sddm/sddm.conf.d/default.conf:91:ReuseSession=true
/usr/lib/sddm/sddm.conf.d/default.conf:94:[Wayland]
/usr/lib/sddm/sddm.conf.d/default.conf:95:# Path of the Wayland compositor to execute when starting the greeter
/usr/lib/sddm/sddm.conf.d/default.conf:96:CompositorCommand=weston --shell=kiosk
/usr/lib/sddm/sddm.conf.d/default.conf:102:SessionCommand=/usr/share/sddm/scripts/wayland-session
/usr/lib/sddm/sddm.conf.d/default.conf:104:# Comma-separated list of directories containing available Wayland sessions
/usr/lib/sddm/sddm.conf.d/default.conf:105:SessionDir=/usr/local/share/wayland-sessions,/usr/share/wayland-sessions
/usr/lib/sddm/sddm.conf.d/default.conf:108:SessionLogFile=.local/share/sddm/wayland-session.log
/usr/lib/sddm/sddm.conf.d/default.conf:111:[X11]
/usr/lib/sddm/sddm.conf.d/default.conf:128:SessionCommand=/usr/share/sddm/scripts/Xsession
/usr/lib/sddm/sddm.conf.d/default.conf:131:SessionDir=/usr/local/share/xsessions,/usr/share/xsessions
/usr/lib/sddm/sddm.conf.d/default.conf:134:SessionLogFile=.local/share/sddm/xorg-session.log

### [05] Receita de agressividade, CPU/GPU, TuneD, zram e sysctl


## CPU governor

Governors detectados: performance 
[OK] CPU governor inclui performance
$ cpupower frequency-info
analyzing CPU 0:
  driver: amd-pstate-epp
  CPUs which run at the same hardware frequency: 0
  CPUs which need to have their frequency coordinated by software: 0
  energy performance preference: performance
  hardware limits: 422 MHz - 4.67 GHz
  available cpufreq governors: performance powersave
  current policy: frequency should be within 2.39 GHz and 4.67 GHz.
                  The governor "performance" may decide which speed to use
                  within this range.
  current CPU frequency: Unable to call hardware
  current CPU frequency: 3.88 GHz (asserted by call to kernel)
  boost state support:
    Supported: yes
    Active: yes
  amd-pstate limits:
    Highest Performance: 166. Maximum Frequency: 4.67 GHz.
    Nominal Performance: 135. Nominal Frequency: 3.80 GHz.
    Lowest Non-linear Performance: 85. Lowest Non-linear Frequency: 2.39 GHz.
    Lowest Performance: 15. Lowest Frequency: 400 MHz.
    Preferred Core Support: 1. Preferred Core Ranking: 191.


## TuneD

$ tuned-adm active
Current active profile: latency-performance

[OK] TuneD responde com perfil ativo
$ systemctl is-enabled tuned
enabled

$ systemctl is-active tuned
active


## Power profiles


## GameMode

$ gamemoded -s
gamemode is inactive


## Sysctl atual

vm.swappiness = 80
vm.vfs_cache_pressure = 50
vm.page-cluster = 0
vm.dirty_background_bytes = 67108864
vm.dirty_bytes = 268435456
vm.max_map_count = 16777216
kernel.sched_autogroup_enabled = 0
kernel.nmi_watchdog = 0

## THP

always [madvise] never
[OK] THP esta em madvise

## zram/swap

$ zramctl
NAME       ALGORITHM DISKSIZE DATA COMPR TOTAL STREAMS MOUNTPOINT
/dev/zram0 zstd         15.4G   4K   64B   20K         [SWAP]

$ swapon --show
NAME       TYPE       SIZE USED  PRIO
/swapfile  file       512M   0B    -1
/dev/zram0 partition 15.4G   0B 32767


## Arquivos de agressividade em /etc

/etc/sysctl.d/99-mocha-agressividade.conf:3:vm.swappiness = 80
/etc/sysctl.d/99-mocha-agressividade.conf:4:vm.vfs_cache_pressure = 50
/etc/sysctl.d/99-mocha-agressividade.conf:5:vm.page-cluster = 0
/etc/sysctl.d/99-mocha-agressividade.conf:6:vm.dirty_background_bytes = 67108864
/etc/sysctl.d/99-mocha-agressividade.conf:7:vm.dirty_bytes = 268435456
/etc/sysctl.d/99-mocha-agressividade.conf:8:vm.max_map_count = 16777216
/etc/sysctl.d/99-mocha-agressividade.conf:9:kernel.sched_autogroup_enabled = 0
/etc/tmpfiles.d/mocha-thp.conf:2:w /sys/kernel/mm/transparent_hugepage/enabled - - - - madvise
/etc/systemd/zram-generator.conf:1:# Mocha Arch — zram canônico velho
/etc/systemd/zram-generator.conf:2:[zram0]
/etc/systemd/zram-generator.conf:3:zram-size = ram
/etc/systemd/system/mocha-nvidia-max-performance.service:2:Description=Mocha NVIDIA maximum performance baseline
/etc/systemd/system/mocha-nvidia-max-performance.service:8:ExecStart=/usr/local/sbin/mocha-nvidia-max-performance
/etc/systemd/system/multi-user.target.wants/mocha-nvidia-max-performance.service:2:Description=Mocha NVIDIA maximum performance baseline
/etc/systemd/system/multi-user.target.wants/mocha-nvidia-max-performance.service:8:ExecStart=/usr/local/sbin/mocha-nvidia-max-performance

### [06] Steam, wrapper, MangoHud e linha base sem Launch Options


## Pacotes jogos

gamemode 1.8.2-2
lib32-gamemode 1.8.2-1
lib32-mangohud 0.8.3-1
lib32-vulkan-icd-loader 1.4.350.0-1
mangohud 0.8.3-2
steam 1.0.0.85-7
steam-devices 1.0.0.85-7
vulkan-icd-loader 1.4.350.0-1
vulkan-tools 1.4.350.0-1
[OK] Wrapper existe: /home/hal/.local/bin/mocha-steam-game-run

Trechos sensiveis do wrapper:
10:  "MANGOHUD_"'DLSYM' \
19:export DXVK_LOG_LEVEL="${DXVK_LOG_LEVEL:-none}"
21:MANGOHUD_CONF_USER="${HOME}/.config/MangoHud/Mocha-MangoHud-FPS-Comparacao.conf"
22:MANGOHUD_CONF_SYSTEM="/etc/mocha/mangohud/MangoHud.conf"
26:if command -v gamemoderun >/dev/null 2>&1; then
27:  cmd=( gamemoderun "${cmd[@]}" )
31:  export MANGOHUD=1
33:  if [ -f "$MANGOHUD_CONF_USER" ]; then
34:    export MANGOHUD_CONFIGFILE="$MANGOHUD_CONF_USER"
35:  elif [ -f "$MANGOHUD_CONF_SYSTEM" ]; then
36:    export MANGOHUD_CONFIGFILE="$MANGOHUD_CONF_SYSTEM"
[OK] Wrapper nao contem MANGOHUD_DLSYM
[FALTA] Wrapper contem vkbasalt/gamescope; isso nao deve entrar no wrapper canonico

## MangoHud configs

2026-05-29 14:23 /home/hal/.config/MangoHud/Mocha-MangoHud-FPS-Comparacao.conf

### [07] KDE, esquema de cores, Plasma Style e tabela de cores


## Estado KDE atual

ColorScheme atual: indisponivel
Plasma Style atual: MochaPanelSolidCanonico
[ATENCAO] ColorScheme atual nao e MochaSolidCanonico: indisponivel
[OK] Plasma Style atual e MochaPanelSolidCanonico

## Arquivos .colors no usuario e no ativo

2026-05-12 17:06 /usr/share/color-schemes/Oxygen.colors
2026-05-12 17:06 /usr/share/color-schemes/OxygenCold.colors
2026-05-12 17:08 /usr/share/color-schemes/BreezeClassic.colors
2026-05-12 17:08 /usr/share/color-schemes/BreezeDark.colors
2026-05-12 17:08 /usr/share/color-schemes/BreezeLight.colors
2026-05-29 17:58 /home/hal/.local/share/color-schemes/Mocha-Windows11.colors
2026-05-29 17:58 /home/hal/.local/share/color-schemes/MochaDark.colors
2026-05-29 17:58 /home/hal/.local/share/color-schemes/MochaKDE.colors
2026-05-29 17:58 /home/hal/.local/share/color-schemes/MochaSolidCanonico.colors
2026-05-29 17:58 /media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/Mocha-Windows11.colors
2026-05-29 17:58 /media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/MochaDark.colors
2026-05-29 17:58 /media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/MochaKDE.colors
2026-05-29 17:58 /media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/MochaSolidCanonico.colors
[OK] MochaSolidCanonico.colors existe no usuario
[OK] MochaSolidCanonico.colors existe no ativo: /media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/MochaSolidCanonico.colors
[OK] MochaSolidCanonico do usuario bate com a copia do ativo

## Plasma Style MochaPanelSolidCanonico

/home/hal/.local/share/plasma/desktoptheme/MochaPanelSolidCanonico
/media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico
[OK] MochaPanelSolidCanonico existe no usuario

## Tabela/hexadecimais de cores no ativo

/media/mochafast/MochaArch/ativo/documentacao/20260529-180309-plasma-style-barra-mocha-aplicado.md:23:- HEX aplicado na barra: `#4f463e`
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:19:     pagecolor="#ffffff"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:20:     bordercolor="#4f463e"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:29:     inkscape:deskcolor="#d1d1d1"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:50:                color:#4f463e;
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:51:                stop-color:#4f463e;
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:54:                color:#eff0f1;
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:55:                stop-color:#eff0f1;
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:195:     style="color:#eff0f1;fill:currentColor;fill-opacity:1;stroke:none;stop-color:#eff0f1"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:204:     style="fill:#800080;fill-opacity:1;stroke:none;stroke-width:1.1547"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:217:     style="fill:#800080;fill-opacity:1;stroke:none;stroke-width:1.1547" />
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:224:     style="fill:#800080;fill-opacity:1;stroke:none;stroke-width:1.1547" />
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:226:     style="fill:#800080;fill-opacity:1;stroke:none;stroke-width:1.1547"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:235:     style="fill:#ff6600"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:366:     style="fill:#ff00ff;stroke-width:0.999996"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:373:     style="fill:#ff00ff;stroke-width:0.999996"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:380:     style="fill:#ff00ff;stroke-width:0.999996"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:387:     style="fill:#ff00ff;stroke-width:0.999996"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:394:     style="fill:#00ff00"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:401:     style="fill:#00ff00"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:408:     style="fill:#00ff00"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:415:     style="fill:#00ff00"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:466:     style="fill:#ffff00;stroke-width:2;stroke-linecap:round"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:476:       style="opacity:0.00100002;fill:#000000;fill-opacity:0.00392157"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:498:       style="opacity:0.00100002;fill:#000000;fill-opacity:0.00392157;fill-rule:evenodd"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:509:       style="opacity:0.00100002;fill:#000000;fill-opacity:0.00392157;fill-rule:evenodd"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:534:       style="opacity:0.00100002;fill:#000000;fill-opacity:0.00392157;fill-rule:evenodd"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:545:       style="opacity:0.00100002;fill:#000000;fill-opacity:0.00392157;fill-rule:evenodd"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:560:     style="fill:#ff00ff"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:567:     style="fill:#ff00ff"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:574:     style="fill:#ff00ff"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:581:     style="fill:#ff00ff"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:588:     style="fill:#00ff00"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:595:     style="fill:#00ff00"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:602:     style="fill:#00ff00"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:609:     style="fill:#00ff00"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:619:       style="opacity:0.00100002;fill:#000000;fill-opacity:0.00392157"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:634:       style="opacity:0.00100002;fill:#000000;fill-opacity:0.00392157"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:648:       style="opacity:0.00100002;fill:#000000;fill-opacity:0.00392157"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:671:     style="font-stretch:condensed;font-size:1.25217px;font-family:Impact;-inkscape-font-specification:'Impact Condensed';text-align:start;text-anchor:start;fill:#ff0000;stroke:#000000;stroke-width:5.72866;stroke-linecap:round"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:679:       style="font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;font-size:1.25217px;font-family:'Noto Sans';-inkscape-font-specification:'Noto Sans';text-align:start;text-anchor:start;fill:#000000;stroke:none;stroke-width:5.72866">The corners of the mask are 1px  smaller because they</tspan><tspan
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:683:       style="font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;font-size:1.25217px;font-family:'Noto Sans';-inkscape-font-specification:'Noto Sans';text-align:start;text-anchor:start;fill:#000000;stroke:none;stroke-width:5.72866"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:688:       style="font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;font-size:1.25217px;font-family:'Noto Sans';-inkscape-font-specification:'Noto Sans';text-align:start;text-anchor:start;fill:#000000;stroke:none;stroke-width:5.72866"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:693:       style="font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;font-size:1.25217px;font-family:'Noto Sans';-inkscape-font-specification:'Noto Sans';text-align:start;text-anchor:start;fill:#000000;stroke:none;stroke-width:5.72866"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-mocha.svg:698:       style="font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;font-size:1.25217px;font-family:'Noto Sans';-inkscape-font-specification:'Noto Sans';text-align:start;text-anchor:start;fill:#000000;stroke:none;stroke-width:5.72866"
/media/mochafast/MochaArch/ativo/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md:5215:- Cor aplicada na barra: `#4f463e`
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:19:     pagecolor="#ffffff"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:20:     bordercolor="#111111"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:29:     inkscape:deskcolor="#d1d1d1"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:50:                color:#232629;
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:51:                stop-color:#232629;
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:54:                color:#eff0f1;
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:55:                stop-color:#eff0f1;
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:195:     style="color:#eff0f1;fill:currentColor;fill-opacity:1;stroke:none;stop-color:#eff0f1"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:204:     style="fill:#800080;fill-opacity:1;stroke:none;stroke-width:1.1547"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:217:     style="fill:#800080;fill-opacity:1;stroke:none;stroke-width:1.1547" />
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:224:     style="fill:#800080;fill-opacity:1;stroke:none;stroke-width:1.1547" />
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:226:     style="fill:#800080;fill-opacity:1;stroke:none;stroke-width:1.1547"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:235:     style="fill:#ff6600"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:366:     style="fill:#ff00ff;stroke-width:0.999996"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:373:     style="fill:#ff00ff;stroke-width:0.999996"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:380:     style="fill:#ff00ff;stroke-width:0.999996"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:387:     style="fill:#ff00ff;stroke-width:0.999996"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:394:     style="fill:#00ff00"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:401:     style="fill:#00ff00"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:408:     style="fill:#00ff00"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:415:     style="fill:#00ff00"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:466:     style="fill:#ffff00;stroke-width:2;stroke-linecap:round"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:476:       style="opacity:0.00100002;fill:#000000;fill-opacity:0.00392157"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:498:       style="opacity:0.00100002;fill:#000000;fill-opacity:0.00392157;fill-rule:evenodd"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:509:       style="opacity:0.00100002;fill:#000000;fill-opacity:0.00392157;fill-rule:evenodd"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:534:       style="opacity:0.00100002;fill:#000000;fill-opacity:0.00392157;fill-rule:evenodd"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:545:       style="opacity:0.00100002;fill:#000000;fill-opacity:0.00392157;fill-rule:evenodd"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:560:     style="fill:#ff00ff"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:567:     style="fill:#ff00ff"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:574:     style="fill:#ff00ff"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:581:     style="fill:#ff00ff"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:588:     style="fill:#00ff00"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:595:     style="fill:#00ff00"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:602:     style="fill:#00ff00"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:609:     style="fill:#00ff00"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:619:       style="opacity:0.00100002;fill:#000000;fill-opacity:0.00392157"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:634:       style="opacity:0.00100002;fill:#000000;fill-opacity:0.00392157"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:648:       style="opacity:0.00100002;fill:#000000;fill-opacity:0.00392157"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:671:     style="font-stretch:condensed;font-size:1.25217px;font-family:Impact;-inkscape-font-specification:'Impact Condensed';text-align:start;text-anchor:start;fill:#ff0000;stroke:#000000;stroke-width:5.72866;stroke-linecap:round"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:679:       style="font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;font-size:1.25217px;font-family:'Noto Sans';-inkscape-font-specification:'Noto Sans';text-align:start;text-anchor:start;fill:#000000;stroke:none;stroke-width:5.72866">The corners of the mask are 1px  smaller because they</tspan><tspan
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:683:       style="font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;font-size:1.25217px;font-family:'Noto Sans';-inkscape-font-specification:'Noto Sans';text-align:start;text-anchor:start;fill:#000000;stroke:none;stroke-width:5.72866"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:688:       style="font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;font-size:1.25217px;font-family:'Noto Sans';-inkscape-font-specification:'Noto Sans';text-align:start;text-anchor:start;fill:#000000;stroke:none;stroke-width:5.72866"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:693:       style="font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;font-size:1.25217px;font-family:'Noto Sans';-inkscape-font-specification:'Noto Sans';text-align:start;text-anchor:start;fill:#000000;stroke:none;stroke-width:5.72866"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/panel-background-original.svg:698:       style="font-style:normal;font-variant:normal;font-weight:normal;font-stretch:normal;font-size:1.25217px;font-family:'Noto Sans';-inkscape-font-specification:'Noto Sans';text-align:start;text-anchor:start;fill:#000000;stroke:none;stroke-width:5.72866"
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/20260529-180309-plasma-style-barra-mocha.log:13:HEX aplicado na barra: #4f463e
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/20260529-180309-plasma-style-barra-mocha.log:25:     14 #000000
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/20260529-180309-plasma-style-barra-mocha.log:26:      1 #111111
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/20260529-180309-plasma-style-barra-mocha.log:27:      2 #232629
/media/mochafast/MochaArch/ativo/auditorias/20260529-180309-plasma-style-barra-mocha/20260529-180309-plasma-style-barra-mocha.log:30:      3 #4f463e
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:1:#000000
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:2:#00ff00
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:3:#111111
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:4:#232629
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:5:#d1d1d1
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:6:#eff0f1
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:7:#ff0000
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:8:#ff00ff
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:9:#ff6600
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:10:#ffff00
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:11:#ffffff
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:27:#27ae60
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:28:#31363b
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:29:#3daee9
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:30:#93cee9
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:31:#c90303
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:32:#da4453
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:33:#eff0f1
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:34:#fcfcfc
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:35:#ffffff
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:42:#000000
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:43:#232629
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:44:#3daee9
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:45:#93cee9
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:46:#d1d1d1
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:47:#eff0f1
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:48:#ffffff
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:53:#000000
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:54:#0000ff
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:55:#232629
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:56:#31363b
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:57:#3daee9
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:58:#666666
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:59:#818b96
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:60:#98a1a9
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:61:#9c0000
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:62:#bd0000
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:63:#db0000
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:64:#e2e2e2
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:65:#eff0f1
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:66:#f00000
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:67:#f0f0f0
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:68:#f67400
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:69:#ff4747
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:70:#ffffff
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:92:#31363b
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:93:#3daee9
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:94:#93cee9
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:95:#c90303
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:96:#eff0f1
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:97:#fcfcfc
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:98:#ffffff
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:103:#000000
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:104:#008000
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:105:#111314
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:106:#1E92FF
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:107:#1a1c1e
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:108:#232629
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:109:#3DAEE6
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:110:#666666
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:111:#7B7C7E
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:112:#919191
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:113:#EFF0F1
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:114:#FCFCFC
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:115:#ff00ff
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:128:#111111
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:129:#232629
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:130:#3daee9
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:131:#d1d1d1
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:132:#eff0f1
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:133:#ff2a2a
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:134:#ffffff
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:143:#111111
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:144:#232629
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:145:#3daee9
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:146:#d1d1d1
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:147:#eff0f1
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:148:#ff2a2a
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:149:#ffffff
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:158:#666666
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:159:#ffffff
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:162:#0000ff
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:163:#31363b
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:164:#3daee9
/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-cores-svg-painel.txt:165:#93cee9
[ATENCAO] Nao confirmei tabela hexadecimal dentro do MochaSolidCanonico ativo

### [08] Barra KDE estilo Windows 11 / Mocha


## Arquivos da barra

Atual: /home/hal/.config/plasma-org.kde.plasma.desktop-appletsrc
Aprovado esperado: /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617

[OK] Arquivo aprovado da barra existe no caminho correto
[OK] Arquivo atual do Plasma appletsrc existe
panelspacer no arquivo atual: 2
[OK] Barra atual contem pelo menos dois panelspacers
[ATENCAO] Appletsrc atual difere do arquivo aprovado; pode ser ajuste posterior ou divergencia

## Scripts/arquivos aprovados da barra

2026-05-28 22:54 /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
2026-05-28 22:56 /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt
2026-05-29 15:33 /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh
2026-05-29 15:43 /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/MANUAL-BARRA-WIN11-MOCHA-APROVADA.md
[OK] Ha script reutilizavel na pasta aprovada da barra

### [09] Bluetooth e volume duplicados


## Autostart usuario


Arquivo: /home/hal/.config/autostart/blueman.desktop
38:Name=Blueman Applet
78:Exec=blueman-applet
83:Hidden=true
[OK] blueman.desktop esta oculto no autostart do usuario

Arquivo: /home/hal/.config/autostart/kmix_autostart.desktop
2:Exec=kmix --keepvisibility
12:GenericName=Sound Mixer
69:Name=KMix
128:Hidden=true
[OK] kmix_autostart.desktop esta oculto no autostart do usuario

## Autostart /etc/skel


Arquivo: /etc/skel/.config/autostart/blueman.desktop
3:Name=blueman.desktop
5:Exec=blueman-applet
7:Hidden=true
[OK] blueman.desktop esta oculto em /etc/skel

Arquivo: /etc/skel/.config/autostart/kmix_autostart.desktop
3:Name=kmix_autostart.desktop
5:Exec=kmix --keepvisibility
7:Hidden=true
[OK] kmix_autostart.desktop esta oculto em /etc/skel

## Pacotes/servicos Bluetooth/volume

bluedevil 1:6.6.5-1
blueman 2.4.6-2
bluez 5.86-6
bluez-libs 5.86-6
bluez-qt 6.26.0-1
bluez-tools 0.2.0-6
kmix 26.04.1-1
pipewire 1:1.6.6-1
pipewire-session-manager 1:1.6.6-1
plasma-pa 6.6.5-1
pulseaudio 17.0+r98+gb096704c0-1
pulseaudio-alsa 1:1.2.12-5
pulseaudio-bluetooth 17.0+r98+gb096704c0-1
pulseaudio-equalizer 17.0+r98+gb096704c0-1
pulseaudio-jack 17.0+r98+gb096704c0-1
pulseaudio-lirc 17.0+r98+gb096704c0-1
pulseaudio-qt 1.8.1-1
pulseaudio-zeroconf 17.0+r98+gb096704c0-1
wireplumber 0.5.14-1
$ systemctl is-enabled bluetooth
enabled

$ systemctl is-active bluetooth
active


### [10] Flatpak, Flathub, Discover e programas que nao devem entrar por padrao


## Flatpak

$ flatpak remotes --columns=name,url,options
flathub	https://dl.flathub.org/repo/	system

[OK] Flathub esta configurado

## Discover/loja

discover 6.6.5-1
flatpak 1:1.16.6-1
flatpak-kcm 6.6.5-1
xdg-desktop-portal 1.20.4-1
xdg-desktop-portal-gtk 1.15.3-1
xdg-desktop-portal-kde 6.6.5-1

## Chrome/Bitwarden

[OK] google-chrome nao aparece instalado via pacman
[OK] Bitwarden nao aparece instalado via pacman

### [11] Manuais, documentacao e cobertura da receita atual


## Manuais encontrados

2026-05-29 19:57|/media/mochafast/MochaArch/ativo/relatorios/20260529-195748-auditoria-geral-pre-formatacao-mochaarch.md
2026-05-29 18:27|/media/mochafast/MochaArch/ativo/documentacao/20260529-182750-zen-default-grub-seguro.md
2026-05-29 18:03|/media/mochafast/MochaArch/ativo/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md
2026-05-29 18:03|/media/mochafast/MochaArch/ativo/documentacao/20260529-180309-plasma-style-barra-mocha-aplicado.md
2026-05-29 18:01|/media/mochafast/MochaArch/ativo/auditorias/20260529-180130-auditoria-barra-plasma-cores/20260529-180130-resumo-barra-plasma-cores.md
2026-05-29 17:58|/media/mochafast/MochaArch/ativo/documentacao/20260529-175841-esquema-cores-kde-mocha-solid-canonico-aplicado.md
2026-05-29 17:47|/media/mochafast/MochaArch/ativo/auditorias/20260529-171302-fast-arquivos-com-cores-hex.md
2026-05-29 17:33|/media/mochafast/MochaArch/ativo/documentacao/20260529-173325-coletor-externo-leve-jogo.md
2026-05-29 17:31|/media/mochafast/MochaArch/ativo/documentacao/20260529-173139-steam-telemetria-ruim-nao-usar.md
2026-05-29 17:29|/media/mochafast/MochaArch/ativo/telemetria/20260529-172426-steam-2169200-mangohud-mocha-gamemode/resumo-final.md
2026-05-29 17:24|/media/mochafast/MochaArch/ativo/documentacao/20260529-172415-steam-launcher-mangohud-padrao-telemetria.md
2026-05-29 16:46|/media/mochafast/MochaArch/ativo/auditorias/20260529-164631-fast-procura-esquema-cores-tema-recente.md
2026-05-29 16:34|/media/mochafast/MochaArch/ativo/documentacao/20260529-163403-wallpaper-kdePCan-aplicado.md
2026-05-29 16:34|/media/mochafast/MochaArch/ativo/auditorias/20260529-163403-aplicar-wallpaper-kdePCan.md
2026-05-29 16:28|/media/mochafast/MochaArch/ativo/auditorias/20260529-162826-fast-tema-kde-esquema-cores-wallpaper.md
2026-05-29 16:26|/media/mochafast/MochaArch/ativo/auditorias/20260529-162618-auditoria-tema-kde-deuterocanonico-wallpaper.md
2026-05-29 16:13|/media/mochafast/MochaArch/ativo/documentacao/20260529-161327-auditoria-gamemode-on-off.md
2026-05-29 15:46|/media/mochafast/MochaArch/ativo/documentacao/20260529-154612-wrapper-steam-corrigido-falso-positivo.md
2026-05-29 15:44|/media/mochafast/MochaArch/ativo/documentacao/20260529-154451-wrapper-steam-auditoria-e-implantacao.md
2026-05-29 15:43|/media/mochafast/MochaArch/ativo/logs/20260529-154304-criar-manual-vivo-definitivo-mocha-arch-kde.log
2026-05-29 15:43|/media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/MANUAL-BARRA-WIN11-MOCHA-APROVADA.md
2026-05-29 15:43|/media/mochafast/MochaArch/ativo/documentacao/20260529-154304-MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md
2026-05-29 15:43|/media/mochafast/MochaArch/ativo/scripts/mocha-adicionar-entrada-aprovada-ao-manual.sh
2026-05-29 15:43|/media/mochafast/MochaArch/ativo/scripts/20260529-154304-mocha-adicionar-entrada-aprovada-ao-manual.sh
2026-05-29 15:43|/media/mochafast/MochaArch/ativo/logs/20260529-154304-evidencias-extraidas-para-manual.md
2026-05-29 15:43|/media/mochafast/MochaArch/ativo/logs/20260529-154304-auditoria-estado-atual-para-manual.md
2026-05-29 15:29|/media/mochafast/MochaArch/ativo/passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md
2026-05-29 15:29|/media/mochafast/MochaArch/ativo/documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md
2026-05-29 15:27|/media/mochafast/MochaArch/ativo/documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md
2026-05-29 15:24|/media/mochafast/MochaArch/ativo/documentacao/20260529-152416-baseline-superior-endeavour-steam-overlay-kde.md
2026-05-29 15:01|/media/mochafast/MochaArch/ativo/documentacao/20260529-150104-login-plasma-manager-esquema-aprovado.md
[OK] Foram encontrados 31 arquivos candidatos a manual/documentacao
[OK] Manual principal candidato: /media/mochafast/MochaArch/ativo/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md

## Cobertura minima esperada nos manuais

bash: line 84: ${#MANUAL_PATHS[@]:-0}: bad substitution

### [12] Scripts reutilizaveis aprovados e sintaxe shell


## Scripts no ativo

2026-05-29 15:01 /media/mochafast/MochaArch/ativo/scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh
2026-05-29 15:01 /media/mochafast/MochaArch/ativo/scripts/mocha-aplicar-login-plasma-manager.sh
2026-05-29 15:27 /media/mochafast/MochaArch/ativo/scripts/20260529-152700-mocha-desativar-kmix-volume-duplicado.sh
2026-05-29 15:29 /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh
2026-05-29 15:43 /media/mochafast/MochaArch/ativo/scripts/20260529-154304-mocha-adicionar-entrada-aprovada-ao-manual.sh
2026-05-29 15:43 /media/mochafast/MochaArch/ativo/scripts/mocha-adicionar-entrada-aprovada-ao-manual.sh
2026-05-29 15:46 /media/mochafast/MochaArch/ativo/scripts/20260529-154612-mocha-instalar-wrapper-steam-limpo-corrigido.sh
2026-05-29 16:34 /media/mochafast/MochaArch/ativo/scripts/20260529-163403-mocha-aplicar-wallpaper-kdePCan.sh
2026-05-29 18:03 /media/mochafast/MochaArch/ativo/scripts/20260529-180309-reaplicar-plasma-style-barra-mocha.sh

## bash -n nos scripts .sh do ativo

[OK] sintaxe: /media/mochafast/MochaArch/ativo/scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh
[OK] sintaxe: /media/mochafast/MochaArch/ativo/scripts/mocha-aplicar-login-plasma-manager.sh
[OK] sintaxe: /media/mochafast/MochaArch/ativo/scripts/20260529-152700-mocha-desativar-kmix-volume-duplicado.sh
[OK] sintaxe: /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh
[OK] sintaxe: /media/mochafast/MochaArch/ativo/scripts/mocha-adicionar-entrada-aprovada-ao-manual.sh
[OK] sintaxe: /media/mochafast/MochaArch/ativo/scripts/20260529-154304-mocha-adicionar-entrada-aprovada-ao-manual.sh
[OK] sintaxe: /media/mochafast/MochaArch/ativo/scripts/20260529-154612-mocha-instalar-wrapper-steam-limpo-corrigido.sh
[OK] sintaxe: /media/mochafast/MochaArch/ativo/scripts/20260529-163403-mocha-aplicar-wallpaper-kdePCan.sh
[OK] sintaxe: /media/mochafast/MochaArch/ativo/scripts/20260529-180309-reaplicar-plasma-style-barra-mocha.sh
[OK] Todos os scripts .sh encontrados passaram em bash -n

## Scripts esperados por assunto

[OK] Ha arquivo/script relacionado a: kernel/zen
[ATENCAO] Nao encontrei arquivo/script claramente relacionado a: nvidia
[OK] Ha arquivo/script relacionado a: montagem FAST/VM
[OK] Ha arquivo/script relacionado a: barra Win11
[OK] Ha arquivo/script relacionado a: bluetooth/volume duplicado
[ATENCAO] Nao encontrei arquivo/script claramente relacionado a: energia/agressividade
[OK] Ha arquivo/script relacionado a: manual/documentacao

### [13] Hashes de arquivos criticos para reproducao

dd772480f6f3a6c19704e1e56c3e51f90e4f09972a5b7b6a428d84796938bad4  /home/hal/.config/plasma-org.kde.plasma.desktop-appletsrc
fa9810ed17507011b44dcdbdd7a66d006414c671460f67687767d208cee3818d  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
67e1e7a134245d45ad104b214fc19451892f30b782c40b426fe7541d69c541ae  /home/hal/.local/share/color-schemes/MochaSolidCanonico.colors
67e1e7a134245d45ad104b214fc19451892f30b782c40b426fe7541d69c541ae  /media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/MochaSolidCanonico.colors
c5769f634504c39abc259d21006dcb15d98e6099c9e203cb78da74180d321458  /home/hal/.config/plasmarc
ae3ac72886b4348c91106bde9074461c0278b3b2ef1c738e5c3af534c159c98b  /home/hal/.config/kdeglobals
3da9cca7c858a29bd8da2cb273ca588a756827c66220a9c3573895115dd9abb5  /home/hal/.config/autostart/blueman.desktop
e54faf05e81fb7d2db9741c281e7107945e6e40703e13a75808166fca1808271  /home/hal/.config/autostart/kmix_autostart.desktop
72e899cbcf80112637b5b9a933ddcdb3d2086b1859da8c9d78d47c283eaf8dee  /etc/skel/.config/autostart/blueman.desktop
6af41312274e9fcc3241190a2f47214942a05cda4e1e09ef773bf857906d864c  /etc/skel/.config/autostart/kmix_autostart.desktop
c69fa4c32b94fbcc5b6c867f22377446b5482688c3d8df72a3908ed436d26089  /etc/fstab
40a184ed5765843dc6879be208f6ccb17936fa2bf146b11ed19967bcf088a67e  /etc/default/grub
[OK] Hashes salvos em: /media/mochafast/MochaArch/ativo/relatorios/20260529-195748-hashes-arquivos-criticos.txt

### [14] Resumo final


## RESUMO FINAL

OK: 47
ATENCAO: 5
FALTA: 1

Relatorio completo:
/media/mochafast/MochaArch/ativo/relatorios/20260529-195748-auditoria-geral-pre-formatacao-mochaarch.md

Checklist:
/media/mochafast/MochaArch/ativo/relatorios/20260529-195748-checklist-pre-formatacao.tsv

Lista de manuais:
/media/mochafast/MochaArch/ativo/relatorios/20260529-195748-manuais-encontrados.tsv

Pacotes instalados:
/media/mochafast/MochaArch/ativo/relatorios/20260529-195748-pacotes-instalados.txt

Pacotes explicitos:
/media/mochafast/MochaArch/ativo/relatorios/20260529-195748-pacotes-explicitos.txt

Hashes:
/media/mochafast/MochaArch/ativo/relatorios/20260529-195748-hashes-arquivos-criticos.txt

FALTAS CRITICAS:
 - Wrapper contem vkbasalt/gamescope; isso nao deve entrar no wrapper canonico

ATENCOES/PENDENCIAS:
 - ColorScheme atual nao e MochaSolidCanonico: indisponivel
 - Nao confirmei tabela hexadecimal dentro do MochaSolidCanonico ativo
 - Appletsrc atual difere do arquivo aprovado; pode ser ajuste posterior ou divergencia
 - Nao encontrei arquivo/script claramente relacionado a: nvidia
 - Nao encontrei arquivo/script claramente relacionado a: energia/agressividade

Resultado: ha pendencias acima. Corrigir/documentar antes de usar isto como receita de reproducao.

FIM DA AUDITORIA: 20260529-195748
