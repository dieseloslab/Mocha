# MOCHA ARCH — AUDITORIA GERAL DO SISTEMA

- Timestamp: 20260528-123039
- Base de trabalho: /media/mochafast/MochaArch
- Diretório da auditoria: /media/mochafast/MochaArch/auditorias/auditoria-sistema-endeavour-kde-20260528-123039
- Modo: somente leitura
- Não toca XU
- Não instala
- Não remove
- Não edita

## uname

```
+ uname -a
Linux hal-systemproductname 7.0.10-arch1-1 #1 SMP PREEMPT_DYNAMIC Sat, 23 May 2026 14:21:20 +0000 x86_64 GNU/Linux

exit_code=0
```

## os-release e Endeavour/Arch

```bash
cat /etc/os-release 2>/dev/null || true; echo; hostnamectl 2>/dev/null || true

NAME="EndeavourOS"
PRETTY_NAME="EndeavourOS"
ID="endeavouros"
ID_LIKE="arch"
BUILD_ID=rolling
ANSI_COLOR="38;2;23;147;209"
HOME_URL="https://endeavouros.com"
DOCUMENTATION_URL="https://discovery.endeavouros.com"
SUPPORT_URL="https://forum.endeavouros.com"
BUG_REPORT_URL="https://forum.endeavouros.com/c/general-system/endeavouros-installation"
PRIVACY_POLICY_URL="https://endeavouros.com/privacy-policy-2"
LOGO="endeavouros"

 Static hostname: hal-systemproductname
       Icon name: computer-desktop
         Chassis: desktop 🖥️
      Machine ID: 09a044e993f7415a92dd2833d9afb1d2
         Boot ID: 92d9082fe0bc46a0b1156f043171c450
Operating System: EndeavourOS
          Kernel: Linux 7.0.10-arch1-1
    Architecture: x86-64
 Hardware Vendor: ASUS
  Hardware Model: PRIME A520M-E
    Hardware SKU: SKU
Hardware Version: System Version
Firmware Version: 3636
   Firmware Date: Sun 2026-01-04
    Firmware Age: 4month 3w 1d

exit_code=0
```

## kernel cmdline

```bash
cat /proc/cmdline 2>/dev/null || true

initrd=\09a044e993f7415a92dd2833d9afb1d2\7.0.10-arch1-1\initrd nvme_load=YES nowatchdog rw rootflags=subvol=/@ root=UUID=eaa807e8-e03e-4502-bca6-f7a49c93a6f3 systemd.machine_id=09a044e993f7415a92dd2833d9afb1d2

exit_code=0
```

## systemd-analyze

```bash
systemd-analyze 2>/dev/null || true; echo; systemd-analyze blame 2>/dev/null | head -40 || true; echo; systemd-analyze critical-chain 2>/dev/null || true

Startup finished in 17.633s (firmware) + 2.322s (loader) + 2.112s (kernel) + 3.709s (initrd) + 4.687s (userspace) = 30.465s 
graphical.target reached after 4.536s in userspace.

2.824s dev-disk-by\x2dpath-pci\x2d0000:02:00.1\x2data\x2d1.0\x2dpart-by\x2duuid-88e6aa16\x2d110c\x2d4b97\x2d9ffb\x2d85084c000198.device
2.824s dev-disk-by\x2dpartuuid-0106e9e4\x2db1ed\x2d4cc2\x2dbc33\x2debe3c9830b71.device
2.824s dev-disk-by\x2did-ata\x2dKINGSTON_SA400S37480G_50026B778431EE42\x2dpart1.device
2.824s dev-disk-by\x2dpath-pci\x2d0000:02:00.1\x2data\x2d1.0\x2dpart-by\x2dlabel-MOCHAFAST.device
2.824s dev-disk-by\x2dpath-pci\x2d0000:02:00.1\x2data\x2d1.0\x2dpart-by\x2dpartlabel-primary.device
2.824s dev-disk-by\x2dlabel-MOCHAFAST.device
2.824s dev-disk-by\x2dpartlabel-primary.device
2.824s dev-disk-by\x2did-wwn\x2d0x50026b778431ee42\x2dpart1.device
2.824s dev-disk-by\x2dpath-pci\x2d0000:02:00.1\x2data\x2d1.0\x2dpart-by\x2dpartuuid-0106e9e4\x2db1ed\x2d4cc2\x2dbc33\x2debe3c9830b71.device
2.824s dev-disk-by\x2dpath-pci\x2d0000:02:00.1\x2data\x2d1.0\x2dpart1.device
2.824s dev-sda1.device
2.824s dev-disk-by\x2dpath-pci\x2d0000:02:00.1\x2data\x2d1\x2dpart1.device
2.824s dev-disk-by\x2ddiskseq-1\x2dpart1.device
2.824s dev-disk-by\x2dpath-pci\x2d0000:02:00.1\x2data\x2d1.0\x2dpart-by\x2dpartnum-1.device
2.824s dev-disk-by\x2duuid-88e6aa16\x2d110c\x2d4b97\x2d9ffb\x2d85084c000198.device
2.824s sys-devices-pci0000:00-0000:00:02.1-0000:02:00.1-ata1-host0-target0:0:0-0:0:0:0-block-sda-sda1.device
2.807s sys-devices-LNXSYSTM:00-LNXSYBUS:00-MSFT0101:00-tpmrm-tpmrm0.device
2.807s dev-tpmrm0.device
2.768s dev-tpm0.device
2.768s sys-devices-LNXSYSTM:00-LNXSYBUS:00-MSFT0101:00-tpm-tpm0.device
2.762s sys-devices-pnp0-00:01-00:01:0-00:01:0.0-tty-ttyS0.device
2.762s dev-ttyS0.device
2.755s sys-devices-pci0000:00-0000:00:02.1-0000:02:00.1-ata1-host0-target0:0:0-0:0:0:0-block-sda.device
2.755s dev-sda.device
2.755s dev-disk-by\x2did-wwn\x2d0x50026b778431ee42.device
2.755s dev-disk-by\x2dpath-pci\x2d0000:02:00.1\x2data\x2d1.0.device
2.755s dev-disk-by\x2ddiskseq-1.device
2.755s dev-disk-by\x2dpath-pci\x2d0000:02:00.1\x2data\x2d1.device
2.755s dev-disk-by\x2did-ata\x2dKINGSTON_SA400S37480G_50026B778431EE42.device
2.755s sys-devices-platform-serial8250-serial8250:0-serial8250:0.2-tty-ttyS2.device
2.755s dev-ttyS2.device
2.754s dev-ttyS1.device
2.754s sys-devices-platform-serial8250-serial8250:0-serial8250:0.1-tty-ttyS1.device
2.753s dev-ttyS3.device
2.753s sys-devices-platform-serial8250-serial8250:0-serial8250:0.3-tty-ttyS3.device
2.736s sys-module-configfs.device
2.735s sys-module-fuse.device
2.729s dev-disk-by\x2dpath-pci\x2d0000:09:00.4\x2dusb\x2d0:1:1.0\x2dscsi\x2d0:0:0:0\x2dpart2.device
2.729s dev-disk-by\x2ddiskseq-3\x2dpart2.device
2.729s dev-disk-by\x2duuid-EA6C\x2d95B2.device

The time when unit became active or started is printed after the "@" character.
The time the unit took to start is printed after the "+" character.

graphical.target @4.536s
└─power-profiles-daemon.service @4.450s +85ms
  └─multi-user.target @4.447s
    └─systemd-user-sessions.service @4.425s +20ms
      └─network.target @4.423s
        └─NetworkManager.service @4.163s +259ms
          └─network-pre.target @4.162s
            └─firewalld.service @4.161s
              └─basic.target @4.144s
                └─dbus-broker.service @4.104s +27ms
                  └─dbus.socket @4.098s +44us
                    └─sysinit.target @4.094s
                      └─systemd-update-done.service @4.073s +20ms
                        └─ldconfig.service @3.094s +977ms
                          └─systemd-tmpfiles-setup.service @3.032s +61ms
                            └─local-fs.target @3.027s
                              └─home.mount @2.594s +432ms
                                └─systemd-fsck@dev-disk-by\x2duuid-8c380f6f\x2d1413\x2d415e\x2db9dd\x2d1142eca8f66f.service @1.887s +49ms
                                  └─dev-disk-by\x2duuid-8c380f6f\x2d1413\x2d415e\x2db9dd\x2d1142eca8f66f.device

exit_code=0
```

## CPU e governor

```bash

lscpu 2>/dev/null || true
echo
echo "Governors:"
for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do
  [ -r "$f" ] && echo "$f=$(cat "$f")"
done | sort -V | head -80
echo
echo "Drivers cpufreq:"
for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_driver; do
  [ -r "$f" ] && echo "$f=$(cat "$f")"
done | sort -u
echo
echo "Energy performance preference:"
for f in /sys/devices/system/cpu/cpu*/cpufreq/energy_performance_preference; do
  [ -r "$f" ] && echo "$f=$(cat "$f")"
done | sort -u
echo
if command -v powerprofilesctl >/dev/null 2>&1; then powerprofilesctl 2>/dev/null || true; fi


Arquitetura:                               x86_64
Modo(s) operacional da CPU:                32-bit, 64-bit
Tamanhos de endereço:                      48 bits physical, 48 bits virtual
Ordem dos bytes:                           Little Endian
CPU(s):                                    16
Lista de CPU(s) on-line:                   0-15
ID de fornecedor:                          AuthenticAMD
Nome do modelo:                            AMD Ryzen 7 5700G with Radeon Graphics
Família da CPU:                            25
Modelo:                                    80
Thread(s) per núcleo:                      2
Núcleo(s) por soquete:                     8
Soquete(s):                                1
Step:                                      0
Versão do micro-código:                    0xa500014
Aumento de frequência:                     habilitado
CPU(s) MHz de escala:                      77%
CPU MHz máx.:                              4673,8232
CPU MHz mín.:                              422,3340
BogoMIPS:                                  7599,87
Opções:                                    fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush mmx fxsr sse sse2 ht syscall nx mmxext fxsr_opt pdpe1gb rdtscp lm constant_tsc rep_good nopl xtopology nonstop_tsc cpuid extd_apicid aperfmperf rapl pni pclmulqdq monitor ssse3 fma cx16 sse4_1 sse4_2 x2apic movbe popcnt aes xsave avx f16c rdrand lahf_lm cmp_legacy svm extapic cr8_legacy abm sse4a misalignsse 3dnowprefetch osvw ibs skinit wdt tce topoext perfctr_core perfctr_nb bpext perfctr_llc mwaitx cpb cat_l3 cdp_l3 hw_pstate ssbd mba ibrs ibpb stibp vmmcall fsgsbase bmi1 avx2 smep bmi2 erms invpcid cqm rdt_a rdseed adx smap clflushopt clwb sha_ni xsaveopt xsavec xgetbv1 xsaves cqm_llc cqm_occup_llc cqm_mbm_total cqm_mbm_local user_shstk clzero irperf xsaveerptr rdpru wbnoinvd cppc arat npt lbrv svm_lock nrip_save tsc_scale vmcb_clean flushbyasid decodeassists pausefilter pfthreshold avic v_vmsave_vmload vgif v_spec_ctrl umip pku ospke vaes vpclmulqdq rdpid overflow_recov succor smca fsrm debug_swap
Virtualização:                             AMD-V
cache de L1d:                              256 KiB (8 instâncias)
cache de L1i:                              256 KiB (8 instâncias)
cache de L2:                               4 MiB (8 instâncias)
cache de L3:                               16 MiB (1 instância)
Nó(s) de NUMA:                             1
CPU(s) de nó0 NUMA:                        0-15
Vulnerabilidade Gather data sampling:      Not affected
Vulnerabilidade Ghostwrite:                Not affected
Vulnerabilidade Indirect target selection: Not affected
Vulnerabilidade Itlb multihit:             Not affected
Vulnerabilidade L1tf:                      Not affected
Vulnerabilidade Mds:                       Not affected
Vulnerabilidade Meltdown:                  Not affected
Vulnerabilidade Mmio stale data:           Not affected
Vulnerabilidade Old microcode:             Not affected
Vulnerabilidade Reg file data sampling:    Not affected
Vulnerabilidade Retbleed:                  Not affected
Vulnerabilidade Spec rstack overflow:      Mitigation; Safe RET
Vulnerabilidade Spec store bypass:         Mitigation; Speculative Store Bypass disabled via prctl
Vulnerabilidade Spectre v1:                Mitigation; usercopy/swapgs barriers and __user pointer sanitization
Vulnerabilidade Spectre v2:                Mitigation; Retpolines; IBPB conditional; IBRS_FW; STIBP always-on; RSB filling; PBRSB-eIBRS Not affected; BHI Not affected
Vulnerabilidade Srbds:                     Not affected
Vulnerabilidade Tsa:                       Mitigation; Clear CPU buffers
Vulnerabilidade Tsx async abort:           Not affected
Vulnerabilidade Vmscape:                   Mitigation; IBPB before exit to userspace

Governors:
/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor=powersave
/sys/devices/system/cpu/cpu1/cpufreq/scaling_governor=powersave
/sys/devices/system/cpu/cpu2/cpufreq/scaling_governor=powersave
/sys/devices/system/cpu/cpu3/cpufreq/scaling_governor=powersave
/sys/devices/system/cpu/cpu4/cpufreq/scaling_governor=powersave
/sys/devices/system/cpu/cpu5/cpufreq/scaling_governor=powersave
/sys/devices/system/cpu/cpu6/cpufreq/scaling_governor=powersave
/sys/devices/system/cpu/cpu7/cpufreq/scaling_governor=powersave
/sys/devices/system/cpu/cpu8/cpufreq/scaling_governor=powersave
/sys/devices/system/cpu/cpu9/cpufreq/scaling_governor=powersave
/sys/devices/system/cpu/cpu10/cpufreq/scaling_governor=powersave
/sys/devices/system/cpu/cpu11/cpufreq/scaling_governor=powersave
/sys/devices/system/cpu/cpu12/cpufreq/scaling_governor=powersave
/sys/devices/system/cpu/cpu13/cpufreq/scaling_governor=powersave
/sys/devices/system/cpu/cpu14/cpufreq/scaling_governor=powersave
/sys/devices/system/cpu/cpu15/cpufreq/scaling_governor=powersave

Drivers cpufreq:
/sys/devices/system/cpu/cpu0/cpufreq/scaling_driver=amd-pstate-epp
/sys/devices/system/cpu/cpu10/cpufreq/scaling_driver=amd-pstate-epp
/sys/devices/system/cpu/cpu11/cpufreq/scaling_driver=amd-pstate-epp
/sys/devices/system/cpu/cpu12/cpufreq/scaling_driver=amd-pstate-epp
/sys/devices/system/cpu/cpu13/cpufreq/scaling_driver=amd-pstate-epp
/sys/devices/system/cpu/cpu14/cpufreq/scaling_driver=amd-pstate-epp
/sys/devices/system/cpu/cpu15/cpufreq/scaling_driver=amd-pstate-epp
/sys/devices/system/cpu/cpu1/cpufreq/scaling_driver=amd-pstate-epp
/sys/devices/system/cpu/cpu2/cpufreq/scaling_driver=amd-pstate-epp
/sys/devices/system/cpu/cpu3/cpufreq/scaling_driver=amd-pstate-epp
/sys/devices/system/cpu/cpu4/cpufreq/scaling_driver=amd-pstate-epp
/sys/devices/system/cpu/cpu5/cpufreq/scaling_driver=amd-pstate-epp
/sys/devices/system/cpu/cpu6/cpufreq/scaling_driver=amd-pstate-epp
/sys/devices/system/cpu/cpu7/cpufreq/scaling_driver=amd-pstate-epp
/sys/devices/system/cpu/cpu8/cpufreq/scaling_driver=amd-pstate-epp
/sys/devices/system/cpu/cpu9/cpufreq/scaling_driver=amd-pstate-epp

Energy performance preference:
/sys/devices/system/cpu/cpu0/cpufreq/energy_performance_preference=balance_performance
/sys/devices/system/cpu/cpu10/cpufreq/energy_performance_preference=balance_performance
/sys/devices/system/cpu/cpu11/cpufreq/energy_performance_preference=balance_performance
/sys/devices/system/cpu/cpu12/cpufreq/energy_performance_preference=balance_performance
/sys/devices/system/cpu/cpu13/cpufreq/energy_performance_preference=balance_performance
/sys/devices/system/cpu/cpu14/cpufreq/energy_performance_preference=balance_performance
/sys/devices/system/cpu/cpu15/cpufreq/energy_performance_preference=balance_performance
/sys/devices/system/cpu/cpu1/cpufreq/energy_performance_preference=balance_performance
/sys/devices/system/cpu/cpu2/cpufreq/energy_performance_preference=balance_performance
/sys/devices/system/cpu/cpu3/cpufreq/energy_performance_preference=balance_performance
/sys/devices/system/cpu/cpu4/cpufreq/energy_performance_preference=balance_performance
/sys/devices/system/cpu/cpu5/cpufreq/energy_performance_preference=balance_performance
/sys/devices/system/cpu/cpu6/cpufreq/energy_performance_preference=balance_performance
/sys/devices/system/cpu/cpu7/cpufreq/energy_performance_preference=balance_performance
/sys/devices/system/cpu/cpu8/cpufreq/energy_performance_preference=balance_performance
/sys/devices/system/cpu/cpu9/cpufreq/energy_performance_preference=balance_performance

  performance:
    CpuDriver:	amd_pstate
    Degraded:   no

* balanced:
    CpuDriver:	amd_pstate
    PlatformDriver:	placeholder

  power-saver:
    CpuDriver:	amd_pstate
    PlatformDriver:	placeholder

exit_code=0
```

## SMT, mitigations e timers

```bash

echo "SMT: $(cat /sys/devices/system/cpu/smt/active 2>/dev/null || echo indisponivel)"
echo "Mitigations:"
grep -H . /sys/devices/system/cpu/vulnerabilities/* 2>/dev/null || true
echo
timedatectl 2>/dev/null || true


SMT: 1
Mitigations:
/sys/devices/system/cpu/vulnerabilities/gather_data_sampling:Not affected
/sys/devices/system/cpu/vulnerabilities/ghostwrite:Not affected
/sys/devices/system/cpu/vulnerabilities/indirect_target_selection:Not affected
/sys/devices/system/cpu/vulnerabilities/itlb_multihit:Not affected
/sys/devices/system/cpu/vulnerabilities/l1tf:Not affected
/sys/devices/system/cpu/vulnerabilities/mds:Not affected
/sys/devices/system/cpu/vulnerabilities/meltdown:Not affected
/sys/devices/system/cpu/vulnerabilities/mmio_stale_data:Not affected
/sys/devices/system/cpu/vulnerabilities/old_microcode:Not affected
/sys/devices/system/cpu/vulnerabilities/reg_file_data_sampling:Not affected
/sys/devices/system/cpu/vulnerabilities/retbleed:Not affected
/sys/devices/system/cpu/vulnerabilities/spec_rstack_overflow:Mitigation: Safe RET
/sys/devices/system/cpu/vulnerabilities/spec_store_bypass:Mitigation: Speculative Store Bypass disabled via prctl
/sys/devices/system/cpu/vulnerabilities/spectre_v1:Mitigation: usercopy/swapgs barriers and __user pointer sanitization
/sys/devices/system/cpu/vulnerabilities/spectre_v2:Mitigation: Retpolines; IBPB: conditional; IBRS_FW; STIBP: always-on; RSB filling; PBRSB-eIBRS: Not affected; BHI: Not affected
/sys/devices/system/cpu/vulnerabilities/srbds:Not affected
/sys/devices/system/cpu/vulnerabilities/tsa:Mitigation: Clear CPU buffers
/sys/devices/system/cpu/vulnerabilities/tsx_async_abort:Not affected
/sys/devices/system/cpu/vulnerabilities/vmscape:Mitigation: IBPB before exit to userspace

               Local time: qui 2026-05-28 12:30:44 -03
           Universal time: qui 2026-05-28 15:30:44 UTC
                 RTC time: qui 2026-05-28 15:30:44
                Time zone: America/Sao_Paulo (-03, -0300)
System clock synchronized: yes
              NTP service: active
          RTC in local TZ: no

exit_code=0
```

## NVIDIA e módulos

```bash

if command -v nvidia-smi >/dev/null 2>&1; then
  nvidia-smi
else
  echo "nvidia-smi ausente"
fi
echo
echo "/proc/driver/nvidia/version:"
cat /proc/driver/nvidia/version 2>/dev/null || true
echo
echo "modinfo nvidia:"
modinfo nvidia 2>/dev/null | sed -n "1,80p" || true
echo
echo "nvidia_drm params:"
for p in modeset fbdev; do
  f="/sys/module/nvidia_drm/parameters/$p"
  [ -r "$f" ] && echo "$p=$(cat "$f")" || echo "$p=indisponivel"
done
echo
echo "GPU PCI:"
lspci -nnk 2>/dev/null | grep -A4 -Ei "vga|3d|display|nvidia|amd|intel" || true


Thu May 28 12:30:44 2026       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 595.71.05              Driver Version: 595.71.05      CUDA Version: 13.2     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 5060 Ti     Off |   00000000:01:00.0  On |                  N/A |
|  0%   38C    P8             11W /  180W |     656MiB /  16311MiB |      2%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A            1263      G   /usr/bin/ksecretd                         2MiB |
|    0   N/A  N/A            1326      G   /usr/bin/kwin_wayland                    12MiB |
|    0   N/A  N/A            1407      G   /usr/bin/Xwayland                         6MiB |
|    0   N/A  N/A            1442      G   /usr/bin/ksmserver                        2MiB |
|    0   N/A  N/A            1444      G   /usr/bin/kded6                            2MiB |
|    0   N/A  N/A            1518      G   /usr/bin/kaccess                          2MiB |
|    0   N/A  N/A            1519      G   ...it-kde-authentication-agent-1          2MiB |
|    0   N/A  N/A            1638      G   /usr/bin/kdeconnectd                      2MiB |
|    0   N/A  N/A            1742      G   /usr/bin/python                           2MiB |
|    0   N/A  N/A            1778      G   /usr/lib/xdg-desktop-portal-kde           2MiB |
|    0   N/A  N/A            9824      G   /usr/lib/firefox/firefox                158MiB |
|    0   N/A  N/A           15410      G   ...share/Steam/ubuntu12_32/steam          4MiB |
|    0   N/A  N/A           15608      G   ./steamwebhelper                         22MiB |
|    0   N/A  N/A           15637    C+G   ...am/ubuntu12_64/steamwebhelper          5MiB |
|    0   N/A  N/A           18833      G   /usr/bin/konsole                          2MiB |
|    0   N/A  N/A           21724      G   /usr/bin/plasmashell                     85MiB |
+-----------------------------------------------------------------------------------------+

/proc/driver/nvidia/version:
NVRM version: NVIDIA UNIX Open Kernel Module for x86_64  595.71.05  Release Build  (root@)  
GCC version:  gcc version 16.1.1 20260430 (GCC) 

modinfo nvidia:
filename:       /lib/modules/7.0.10-arch1-1/extramodules/nvidia.ko.zst
import_ns:      DMA_BUF
alias:          char-major-195-*
description:    NVIDIA core GPU kernel module
version:        595.71.05
supported:      external
license:        Dual MIT/GPL
firmware:       nvidia/595.71.05/gsp_tu10x.bin
firmware:       nvidia/595.71.05/gsp_ga10x.bin
softdep:        pre: ecdh_generic,ecdsa_generic
srcversion:     58D233B8E3F4A2973D73151
alias:          pci:v000010DEd*sv*sd*bc06sc80i00*
alias:          pci:v000010DEd*sv*sd*bc03sc02i00*
alias:          pci:v000010DEd*sv*sd*bc03sc00i00*
alias:          of:N*T*Cnvidia,tegra264-displayC*
alias:          of:N*T*Cnvidia,tegra264-display
alias:          of:N*T*Cnvidia,tegra234-displayC*
alias:          of:N*T*Cnvidia,tegra234-display
depends:        
name:           nvidia
retpoline:      Y
vermagic:       7.0.10-arch1-1 SMP preempt mod_unload 
parm:           NvSwitchRegDwords:NvSwitch regkey (charp)
parm:           NvSwitchBlacklist:NvSwitchBlacklist=uuid[,uuid...] (charp)
parm:           NVreg_ResmanDebugLevel:int
parm:           NVreg_RmLogonRC:int
parm:           NVreg_ModifyDeviceFiles:int
parm:           NVreg_DeviceFileUID:int
parm:           NVreg_DeviceFileGID:int
parm:           NVreg_DeviceFileMode:int
parm:           NVreg_InitializeSystemMemoryAllocations:int
parm:           NVreg_UsePageAttributeTable:int
parm:           NVreg_EnablePCIeGen3:int
parm:           NVreg_EnableMSI:int
parm:           NVreg_EnableStreamMemOPs:int
parm:           NVreg_RestrictProfilingToAdminUsers:int
parm:           NVreg_PreserveVideoMemoryAllocations:int
parm:           NVreg_EnableS0ixPowerManagement:int
parm:           NVreg_S0ixPowerManagementVideoMemoryThreshold:int
parm:           NVreg_DynamicPowerManagement:int
parm:           NVreg_DynamicPowerManagementVideoMemoryThreshold:int
parm:           NVreg_EnableGpuFirmware:int
parm:           NVreg_EnableGpuFirmwareLogs:int
parm:           NVreg_OpenRmEnableUnsupportedGpus:int
parm:           NVreg_EnableUserNUMAManagement:int
parm:           NVreg_MemoryPoolSize:int
parm:           NVreg_KMallocHeapMaxSize:int
parm:           NVreg_VMallocHeapMaxSize:int
parm:           NVreg_IgnoreMMIOCheck:int
parm:           NVreg_NvLinkDisable:int
parm:           NVreg_EnablePCIERelaxedOrderingMode:int
parm:           NVreg_RegisterPCIDriver:int
parm:           NVreg_RegisterPlatformDeviceDriver:int
parm:           NVreg_EnableResizableBar:int
parm:           NVreg_EnableDbgBreakpoint:int
parm:           NVreg_TegraGpuPgMask:int
parm:           NVreg_EnableNonblockingOpen:int
parm:           NVreg_ExcludeAllGpus:int
parm:           NVreg_GpuInitOnProbe:int
parm:           NVreg_CoherentGPUMemoryMode:charp
parm:           NVreg_RegistryDwords:charp
parm:           NVreg_RegistryDwordsPerDevice:charp
parm:           NVreg_RmMsg:charp
parm:           NVreg_GpuBlacklist:charp
parm:           NVreg_TemporaryFilePath:charp
parm:           NVreg_ExcludedGpus:charp
parm:           NVreg_DmaRemapPeerMmio:int
parm:           NVreg_RmNvlinkBandwidth:charp
parm:           NVreg_RmNvlinkBandwidthLinkCount:int
parm:           NVreg_ImexChannelCount:int
parm:           NVreg_CreateImexChannel0:int
parm:           NVreg_GrdmaPciTopoCheckOverride:int
parm:           NVreg_EnableSystemMemoryPools:int
parm:           NVreg_UseKernelSuspendNotifiers:int
parm:           rm_firmware_active:charp

nvidia_drm params:
modeset=indisponivel
fbdev=indisponivel

GPU PCI:
00:00.0 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD] Renoir/Cezanne Root Complex [1022:1630]
	Subsystem: ASUSTeK Computer Inc. Device [1043:8809]
00:00.2 IOMMU [0806]: Advanced Micro Devices, Inc. [AMD] Renoir/Cezanne IOMMU [1022:1631]
	Subsystem: ASUSTeK Computer Inc. Device [1043:8809]
00:01.0 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD] Renoir PCIe Dummy Host Bridge [1022:1632]
00:01.1 PCI bridge [0604]: Advanced Micro Devices, Inc. [AMD] Renoir PCIe GPP Bridge [1022:1633]
	Subsystem: ASUSTeK Computer Inc. Device [1043:8809]
	Kernel driver in use: pcieport
	Kernel modules: shpchp
00:02.0 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD] Renoir PCIe Dummy Host Bridge [1022:1632]
	DeviceName:  Onboard IGD
00:02.1 PCI bridge [0604]: Advanced Micro Devices, Inc. [AMD] Renoir/Cezanne PCIe GPP Bridge [1022:1634]
	Subsystem: ASUSTeK Computer Inc. Device [1043:8809]
	Kernel driver in use: pcieport
	Kernel modules: shpchp
00:02.2 PCI bridge [0604]: Advanced Micro Devices, Inc. [AMD] Renoir/Cezanne PCIe GPP Bridge [1022:1634]
	Subsystem: ASUSTeK Computer Inc. Device [1043:8809]
	Kernel driver in use: pcieport
	Kernel modules: shpchp
00:08.0 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD] Renoir PCIe Dummy Host Bridge [1022:1632]
00:08.1 PCI bridge [0604]: Advanced Micro Devices, Inc. [AMD] Renoir Internal PCIe GPP Bridge to Bus [1022:1635]
	Subsystem: ASUSTeK Computer Inc. Device [1043:8809]
	Kernel driver in use: pcieport
	Kernel modules: shpchp
00:14.0 SMBus [0c05]: Advanced Micro Devices, Inc. [AMD] FCH SMBus Controller [1022:790b] (rev 51)
	Subsystem: ASUSTeK Computer Inc. Device [1043:87e1]
	Kernel driver in use: piix4_smbus
	Kernel modules: i2c_piix4, sp5100_tco
00:14.3 ISA bridge [0601]: Advanced Micro Devices, Inc. [AMD] FCH LPC Bridge [1022:790e] (rev 51)
	Subsystem: ASUSTeK Computer Inc. Device [1043:87e1]
00:18.0 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD] Cezanne Data Fabric; Function 0 [1022:166a]
00:18.1 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD] Cezanne Data Fabric; Function 1 [1022:166b]
00:18.2 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD] Cezanne Data Fabric; Function 2 [1022:166c]
00:18.3 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD] Cezanne Data Fabric; Function 3 [1022:166d]
	Kernel driver in use: k10temp
	Kernel modules: k10temp
00:18.4 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD] Cezanne Data Fabric; Function 4 [1022:166e]
00:18.5 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD] Cezanne Data Fabric; Function 5 [1022:166f]
00:18.6 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD] Cezanne Data Fabric; Function 6 [1022:1670]
00:18.7 Host bridge [0600]: Advanced Micro Devices, Inc. [AMD] Cezanne Data Fabric; Function 7 [1022:1671]
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
	Kernel driver in use: xhci_hcd
	Kernel modules: xhci_pci
02:00.1 SATA controller [0106]: Advanced Micro Devices, Inc. [AMD] 500 Series Chipset SATA Controller [1022:43eb]
	Subsystem: ASMedia Technology Inc. ASM1062 Serial ATA Controller [1b21:1062]
	Kernel driver in use: ahci
	Kernel modules: ahci
02:00.2 PCI bridge [0604]: Advanced Micro Devices, Inc. [AMD] 500 Series Chipset Switch Upstream Port [1022:43e9]
	Subsystem: ASMedia Technology Inc. Device [1b21:0201]
	Kernel driver in use: pcieport
	Kernel modules: shpchp
03:00.0 PCI bridge [0604]: Advanced Micro Devices, Inc. [AMD] 500 Series Chipset Switch Downstream Port [1022:43ea]
	Subsystem: ASMedia Technology Inc. Device [1b21:3308]
	Kernel driver in use: pcieport
	Kernel modules: shpchp
03:01.0 PCI bridge [0604]: Advanced Micro Devices, Inc. [AMD] 500 Series Chipset Switch Downstream Port [1022:43ea]
	Subsystem: ASMedia Technology Inc. Device [1b21:3308]
	Kernel driver in use: pcieport
	Kernel modules: shpchp
03:02.0 PCI bridge [0604]: Advanced Micro Devices, Inc. [AMD] 500 Series Chipset Switch Downstream Port [1022:43ea]
	Subsystem: ASMedia Technology Inc. Device [1b21:3308]
	Kernel driver in use: pcieport
	Kernel modules: shpchp
03:03.0 PCI bridge [0604]: Advanced Micro Devices, Inc. [AMD] 500 Series Chipset Switch Downstream Port [1022:43ea]
	Subsystem: ASMedia Technology Inc. Device [1b21:3308]
	Kernel driver in use: pcieport
	Kernel modules: shpchp
04:00.0 Ethernet controller [0200]: Realtek Semiconductor Co., Ltd. RTL8111/8168/8211/8411 PCI Express Gigabit Ethernet Controller [10ec:8168] (rev 15)
--
09:00.0 Non-Essential Instrumentation [1300]: Advanced Micro Devices, Inc. [AMD] Zeppelin/Raven/Raven2 PCIe Dummy Function [1022:145a] (rev c8)
	Subsystem: ASUSTeK Computer Inc. Device [1043:8809]
09:00.1 Audio device [0403]: Advanced Micro Devices, Inc. [AMD/ATI] Renoir/Cezanne HDMI/DP Audio Controller [1002:1637]
	Subsystem: ASUSTeK Computer Inc. Device [1043:8809]
	Kernel driver in use: snd_hda_intel
	Kernel modules: snd_hda_intel
09:00.2 Encryption controller [1080]: Advanced Micro Devices, Inc. [AMD] Raven/Raven2/FireFlight/Renoir/Cezanne Platform Security Processor [1022:15df]
	Subsystem: ASUSTeK Computer Inc. Device [1043:8809]
	Kernel driver in use: ccp
	Kernel modules: ccp
09:00.3 USB controller [0c03]: Advanced Micro Devices, Inc. [AMD] Renoir/Cezanne USB 3.1 [1022:1639]
	Subsystem: ASUSTeK Computer Inc. Device [1043:87e1]
	Kernel driver in use: xhci_hcd
	Kernel modules: xhci_pci
09:00.4 USB controller [0c03]: Advanced Micro Devices, Inc. [AMD] Renoir/Cezanne USB 3.1 [1022:1639]
	Subsystem: ASUSTeK Computer Inc. Device [1043:87e1]
	Kernel driver in use: xhci_hcd
	Kernel modules: xhci_pci

exit_code=0
```

## Vulkan/OpenGL resumo

```bash

if command -v vulkaninfo >/dev/null 2>&1; then
  timeout 20 vulkaninfo --summary 2>/dev/null || timeout 20 vulkaninfo 2>/dev/null | sed -n "1,160p" || true
else
  echo "vulkaninfo ausente"
fi
echo
if command -v glxinfo >/dev/null 2>&1; then
  glxinfo -B 2>/dev/null || true
else
  echo "glxinfo ausente"
fi


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

Instance Layers: count = 6
--------------------------
VK_LAYER_NV_optimus               NVIDIA Optimus layer         1.4.329  version 1
VK_LAYER_NV_present               NVIDIA Presentation Layer    1.4.329  version 1
VK_LAYER_VALVE_steam_fossilize_32 Steam Pipeline Caching Layer 1.3.207  version 1
VK_LAYER_VALVE_steam_fossilize_64 Steam Pipeline Caching Layer 1.3.207  version 1
VK_LAYER_VALVE_steam_overlay_32   Steam Overlay Layer          1.3.207  version 1
VK_LAYER_VALVE_steam_overlay_64   Steam Overlay Layer          1.3.207  version 1

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

name of display: :0
display: :0  screen: 0
direct rendering: Yes
Memory info (GL_NVX_gpu_memory_info):
    Dedicated video memory: 16311 MB
    Total available memory: 16311 MB
    Currently available dedicated video memory: 15179 MB
OpenGL vendor string: NVIDIA Corporation
OpenGL renderer string: NVIDIA GeForce RTX 5060 Ti/PCIe/SSE2
OpenGL core profile version string: 4.6.0 NVIDIA 595.71.05
OpenGL core profile shading language version string: 4.60 NVIDIA
OpenGL core profile context flags: (none)
OpenGL core profile profile mask: core profile

OpenGL version string: 4.6.0 NVIDIA 595.71.05
OpenGL shading language version string: 4.60 NVIDIA
OpenGL context flags: (none)
OpenGL profile mask: (none)

OpenGL ES profile version string: OpenGL ES 3.2 NVIDIA 595.71.05
OpenGL ES profile shading language version string: OpenGL ES GLSL ES 3.20


exit_code=0
```

## Memória e swap

```bash

free -h
echo
swapon --show --bytes 2>/dev/null || true
echo
zramctl 2>/dev/null || true
echo
grep -H . /sys/block/zram*/comp_algorithm /sys/block/zram*/disksize /sys/block/zram*/mm_stat 2>/dev/null || true


               total       usada       livre    compart.  buff/cache  disponível
Mem.:           15Gi       4,0Gi       1,5Gi        94Mi        10Gi        11Gi
Swap:           16Gi       1,9Gi        15Gi

NAME           TYPE             SIZE       USED PRIO
/dev/nvme0n1p3 partition 18209861632 2006536192   -1



exit_code=0
```

## Sysctls de desempenho comparáveis

```bash

keys=(
  vm.swappiness
  vm.vfs_cache_pressure
  vm.page-cluster
  vm.dirty_background_bytes
  vm.dirty_bytes
  vm.dirty_ratio
  vm.dirty_background_ratio
  vm.max_map_count
  kernel.sched_autogroup_enabled
  kernel.nmi_watchdog
  kernel.sched_cfs_bandwidth_slice_us
  fs.file-max
)
for k in "${keys[@]}"; do
  printf "%-38s %s\n" "$k" "$(sysctl -n "$k" 2>/dev/null || echo indisponivel)"
done
echo
echo "Transparent Huge Pages:"
grep -H . /sys/kernel/mm/transparent_hugepage/enabled /sys/kernel/mm/transparent_hugepage/defrag 2>/dev/null || true


vm.swappiness                          60
vm.vfs_cache_pressure                  100
vm.page-cluster                        3
vm.dirty_background_bytes              0
vm.dirty_bytes                         0
vm.dirty_ratio                         20
vm.dirty_background_ratio              10
vm.max_map_count                       1048576
kernel.sched_autogroup_enabled         1
kernel.nmi_watchdog                    0
kernel.sched_cfs_bandwidth_slice_us    5000
fs.file-max                            9223372036854775807

Transparent Huge Pages:
/sys/kernel/mm/transparent_hugepage/enabled:[always] madvise never
/sys/kernel/mm/transparent_hugepage/defrag:always defer defer+madvise [madvise] never

exit_code=0
```

## lsblk e montagens

```bash

lsblk -e7 -o NAME,PATH,SIZE,TYPE,FSTYPE,FSVER,LABEL,UUID,MOUNTPOINTS,MODEL,ROTA,DISC-GRAN,DISC-MAX,SCHED 2>/dev/null || lsblk -f
echo
findmnt -R / /home /media/vmstore /media/mochafast 2>/dev/null || true
echo
df -hT / /home /media/vmstore /media/mochafast 2>/dev/null || true


NAME        PATH             SIZE TYPE FSTYPE FSVER LABEL     UUID                                 MOUNTPOINTS      MODEL                 ROTA DISC-GRAN DISC-MAX SCHED
sda         /dev/sda       447,1G disk                                                                              KINGSTON SA400S37480G    0      512B       2G mq-deadline
└─sda1      /dev/sda1      447,1G part btrfs        MOCHAFAST 88e6aa16-110c-4b97-9ffb-85084c000198 /media/mochafast                          0      512B       2G mq-deadline
sdb         /dev/sdb         1,8T disk                                                                              WDC WD20PURZ-85GU6Y0     1        0B       0B mq-deadline
└─sdb1      /dev/sdb1        1,8T part xfs          vmstore   b81630a0-0756-45e4-9cb2-c7f16637a1c6 /media/vmstore                            1        0B       0B mq-deadline
sdc         /dev/sdc        55,9G disk                                                                              KINGSTON SV300S37A60G    1        0B       0B mq-deadline
├─sdc1      /dev/sdc1       55,9G part exfat  1.0   Ventoy    5D8D-2429                                                                      1        0B       0B mq-deadline
└─sdc2      /dev/sdc2         32M part vfat   FAT16 VTOYEFI   EA6C-95B2                                                                      1        0B       0B mq-deadline
nvme0n1     /dev/nvme0n1   931,5G disk                                                                              KINGSTON SNV2S1000G      0      512B       2T none
├─nvme0n1p1 /dev/nvme0n1p1   229G part btrfs                  eaa807e8-e03e-4502-bca6-f7a49c93a6f3 /var/log                                  0      512B       2T none
│                                                                                                  /var/cache                                                     
│                                                                                                  /                                                              
├─nvme0n1p2 /dev/nvme0n1p2 683,6G part xfs                    8c380f6f-1413-415e-b9dd-1142eca8f66f /home                                     0      512B       2T none
├─nvme0n1p3 /dev/nvme0n1p3    17G part swap   1     swap      f2e048d4-adfc-4326-803a-674c796acd84 [SWAP]                                    0      512B       2T none
└─nvme0n1p4 /dev/nvme0n1p4     2G part vfat   FAT32           CA6A-C99C                            /efi                                      0      512B       2T none


Sist. Arq.     Tipo   Tam. Usado Disp. Uso% Montado em
/dev/nvme0n1p1 btrfs  229G  7,7G  220G   4% /
/dev/nvme0n1p2 xfs    684G  138G  546G  21% /home
/dev/sdb1      xfs    1,9T  921G  942G  50% /media/vmstore
/dev/sda1      btrfs  448G  131G  281G  32% /media/mochafast

exit_code=0
```

## fstab: /etc/fstab

```
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a device; this may
# be used with UUID= as a more robust way to name devices that works even if
# disks are added and removed. See fstab(5).
#
# <file system>             <mount point>  <type>  <options>  <dump>  <pass>
UUID=CA6A-C99C                            /efi           vfat    fmask=0137,dmask=0027 0 2
UUID=eaa807e8-e03e-4502-bca6-f7a49c93a6f3 /              btrfs   subvol=/@,noatime,compress=zstd 0 0
UUID=eaa807e8-e03e-4502-bca6-f7a49c93a6f3 /var/cache     btrfs   subvol=/@cache,noatime,compress=zstd 0 0
UUID=eaa807e8-e03e-4502-bca6-f7a49c93a6f3 /var/log       btrfs   subvol=/@log,noatime,compress=zstd 0 0
UUID=8c380f6f-1413-415e-b9dd-1142eca8f66f /home          xfs     noatime    0 2
tmpfs                                     /tmp           tmpfs   defaults,noatime,mode=1777 0 0

# MOCHA Endeavour stock mounts — 20260528-113003
UUID=88e6aa16-110c-4b97-9ffb-85084c000198 /media/mochafast btrfs defaults,nofail,x-gvfs-show,x-gvfs-name=MochaFAST 0 0
UUID=b81630a0-0756-45e4-9cb2-c7f16637a1c6 /media/vmstore xfs defaults,nofail,x-gvfs-show,x-gvfs-name=MochaVMSTORE 0 0
```

## Schedulers por bloco

```bash

for q in /sys/block/*/queue/scheduler; do
  [ -r "$q" ] && echo "$q=$(cat "$q")"
done | sort
echo
systemctl is-enabled fstrim.timer 2>/dev/null || true
systemctl status fstrim.timer --no-pager 2>/dev/null | sed -n "1,80p" || true


/sys/block/nvme0n1/queue/scheduler=[none] mq-deadline kyber bfq 
/sys/block/sda/queue/scheduler=none [mq-deadline] kyber bfq 
/sys/block/sdb/queue/scheduler=none [mq-deadline] kyber bfq 
/sys/block/sdc/queue/scheduler=none [mq-deadline] kyber bfq 

enabled
● fstrim.timer - Discard unused filesystem blocks once a week
     Loaded: loaded (/usr/lib/systemd/system/fstrim.timer; enabled; preset: disabled)
     Active: active (waiting) since Thu 2026-05-28 11:14:30 -03; 1h 16min ago
 Invocation: 858b26b860e24509925f4c4f06543d32
    Trigger: Mon 2026-06-01 00:17:27 -03; 3 days left
   Triggers: ● fstrim.service
       Docs: man:fstrim

mai 28 11:14:30 hal-systemproductname systemd[1]: Started Discard unused filesystem blocks once a week.

exit_code=0
```

## Pacman versão e repositórios habilitados

```bash

pacman --version 2>/dev/null | sed -n "1,20p" || true
echo
echo "Repos habilitados em /etc/pacman.conf:"
awk "
  /^[[:space:]]*\\[[^]]+\\]/ {
    repo=\$0
    gsub(/[[:space:]]/, \"\", repo)
    print repo
  }
" /etc/pacman.conf 2>/dev/null || true
echo
echo "Trecho multilib:"
grep -n -A4 -B4 "multilib" /etc/pacman.conf 2>/dev/null || true



 .--.                  Pacman v7.1.0 - libalpm v16.0.1
/ _.-' .-.  .-.  .-.   Copyright (C) 2006-2025 Pacman Development Team
\  '-. '-'  '-'  '-'   Copyright (C) 2002-2006 Judd Vinet
 '--'
                       Este programa pode ser redistribuído livremente
                       sob os termos da Licença Pública Geral GNU.


Repos habilitados em /etc/pacman.conf:
[options]
[endeavouros]
[core]
[extra]
[multilib]

Trecho multilib:
88-[extra]
89-Include = /etc/pacman.d/mirrorlist
90-
91-# If you want to run 32 bit applications on your x86_64 system,
92:# enable the multilib repositories as required here.
93-
94:#[multilib-testing]
95-#Include = /etc/pacman.d/mirrorlist
96-
97:[multilib]
98-Include = /etc/pacman.d/mirrorlist
99-
100-# An example of a custom package repository.  See the pacman manpage for
101-# tips on creating your own repositories.

exit_code=0
```

## Pacotes críticos de jogos/performance

```bash

pkgs=(
  linux linux-zen linux-lts linux-cachyos linux-cachyos-bore linux-cachyos-bore-lto
  nvidia nvidia-open nvidia-dkms nvidia-utils lib32-nvidia-utils
  mesa lib32-mesa vulkan-icd-loader lib32-vulkan-icd-loader vulkan-tools
  steam mangohud lib32-mangohud gamemode lib32-gamemode tuned irqbalance
  gamescope vkbasalt lib32-vkbasalt flatpak
  plasma-desktop kwin sddm
  amd-ucode intel-ucode
)
for p in "${pkgs[@]}"; do
  pacman -Q "$p" 2>/dev/null || true
done


linux 7.0.10.arch1-1
nvidia-open 595.71.05-12
nvidia-utils 595.71.05-2
lib32-nvidia-utils 595.71.05-1
mesa 1:26.1.1-2
lib32-mesa 1:26.1.1-1
vulkan-icd-loader 1.4.350.0-1
lib32-vulkan-icd-loader 1.4.350.0-1
vulkan-tools 1.4.350.0-1
steam 1.0.0.85-7
flatpak 1:1.16.6-1
plasma-desktop 6.6.5-1
kwin 6.6.5-2
amd-ucode 20260519-1

exit_code=0
```

## Contagem de pacotes

```bash

echo "Pacotes nativos explícitos: $(pacman -Qqe 2>/dev/null | wc -l || echo 0)"
echo "Pacotes AUR/foreign:        $(pacman -Qqm 2>/dev/null | wc -l || echo 0)"
echo
echo "Primeiros AUR/foreign:"
pacman -Qqm 2>/dev/null | head -80 || true


Pacotes nativos explícitos: 214
Pacotes AUR/foreign:        0

Primeiros AUR/foreign:

exit_code=0
```

## Serviços principais

```bash

services=(
  NetworkManager.service
  bluetooth.service
  sddm.service
  display-manager.service
  tuned.service
  gamemoded.service
  irqbalance.service
  power-profiles-daemon.service
  systemd-oomd.service
  fstrim.timer
)
for s in "${services[@]}"; do
  printf "%-32s enabled=%-12s active=%s\n" "$s" "$(systemctl is-enabled "$s" 2>/dev/null || echo n/a)" "$(systemctl is-active "$s" 2>/dev/null || echo n/a)"
done
echo
if command -v tuned-adm >/dev/null 2>&1; then tuned-adm active 2>/dev/null || true; fi
if command -v gamemoded >/dev/null 2>&1; then gamemoded -s 2>/dev/null || true; fi


NetworkManager.service           enabled=enabled      active=active
bluetooth.service                enabled=enabled      active=active
sddm.service                     enabled=not-found
n/a active=inactive
n/a
display-manager.service          enabled=alias        active=active
tuned.service                    enabled=not-found
n/a active=inactive
n/a
gamemoded.service                enabled=not-found
n/a active=inactive
n/a
irqbalance.service               enabled=not-found
n/a active=inactive
n/a
power-profiles-daemon.service    enabled=enabled      active=active
systemd-oomd.service             enabled=disabled
n/a active=inactive
n/a
fstrim.timer                     enabled=enabled      active=active


exit_code=0
```

## Sessão gráfica

```bash

echo "XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-indisponivel}"
echo "XDG_CURRENT_DESKTOP=${XDG_CURRENT_DESKTOP:-indisponivel}"
echo "DESKTOP_SESSION=${DESKTOP_SESSION:-indisponivel}"
echo "KDE_FULL_SESSION=${KDE_FULL_SESSION:-indisponivel}"
echo
plasmashell --version 2>/dev/null || true
kwin_wayland --version 2>/dev/null || kwin_x11 --version 2>/dev/null || true
qdbus6 org.kde.KWin /KWin supportInformation 2>/dev/null | sed -n "1,220p" || true


XDG_SESSION_TYPE=wayland
XDG_CURRENT_DESKTOP=KDE
DESKTOP_SESSION=/usr/share/wayland-sessions/plasma.desktop
KDE_FULL_SESSION=true

plasmashell 6.6.5
kwin 6.6.5
Informação de suporte do KWin:
A seguinte informação deve ser usada ao pedir suporte, p.ex., no https://discuss.kde.org.
Ela fornece informações sobre a instância atualmente em execução, quais as opções usadas,
qual o driver de OpenGL e os efeitos em execução.
Envie a informação fornecida após este texto introdutório para um serviço de área de transferência
remoto, como o https://paste.kde.org, em vez de colar o texto nos tópicos de suporte.

==========================

Version
=======
KWin version: 6.6.5
Qt Version: 6.11.1
Qt compile version: 6.11.1
XCB compile version: 1.17.0

Operation Mode: Wayland

Build Options
=============
KWIN_BUILD_DECORATIONS: yes
KWIN_BUILD_TABBOX: yes
KWIN_BUILD_ACTIVITIES: yes
HAVE_X11_XCB: yes

X11
===
Vendor: The X.Org Foundation
Vendor Release: 12401011
Protocol Version/Revision: 11/0
SHAPE: yes; Version: 0x11
RANDR: yes; Version: 0x14
Composite: yes; Version: 0x4
RENDER: yes; Version: 0xb
XFIXES: yes; Version: 0x50
SYNC: yes; Version: 0x31
RES: yes; Version: 0x12

Decoration
==========
Plugin: org.kde.breeze
Theme: Breeze
Plugin recommends border size: None
onAllDesktopsAvailable: false
alphaChannelSupported: true
closeOnDoubleClickOnMenu: false
alwaysShowExcludeFromCapture: false
decorationButtonsLeft: 0, 2, 12
decorationButtonsRight: 6, 3, 4, 5
borderSize: 0
gridUnit: 10
font: Noto Sans,10,-1,0,400,0,0,0,0,0,0,0,0,0,0,1,,0,0
smallSpacing: 2
largeSpacing: 10

LogicalOutput backend
==============
Name: DRM
Atomic Mode Setting on GPU 0: true

Cursor
======
themeName: breeze_cursors
themeSize: 24

Options
=======
focusPolicy: ClickToFocus
xwaylandCrashPolicy: 1
xwaylandMaxCrashCount: 3
nextFocusPrefersMouse: false
clickRaise: true
autoRaise: false
autoRaiseInterval: 0
delayFocusInterval: 0
separateScreenFocus: true
placement: 5
activationDesktopPolicy: SwitchToOtherDesktop
focusPolicyIsReasonable: true
borderSnapZone: 10
windowSnapZone: 10
centerSnapZone: 0
snapOnlyWhenOverlapping: false
edgeBarrier: 100
cornerBarrier: 1
rollOverDesktops: false
focusStealingPreventionLevel: 1
operationTitlebarDblClick: 5000
operationMaxButtonLeftClick: 5000
operationMaxButtonMiddleClick: 5013
operationMaxButtonRightClick: 5012
commandActiveTitlebar1: MouseRaise
commandActiveTitlebar2: MouseNothing
commandActiveTitlebar3: MouseOperationsMenu
commandInactiveTitlebar1: MouseActivateAndRaise
commandInactiveTitlebar2: MouseNothing
commandInactiveTitlebar3: MouseOperationsMenu
commandWindow1: MouseActivateRaiseOnReleaseAndPassClick
commandWindow2: MouseActivateAndPassClick
commandWindow3: MouseActivateAndPassClick
commandWindowWheel: MouseNothing
commandAll1: MouseUnrestrictedMove
commandAll2: MouseToggleRaiseAndLower
commandAll3: MouseUnrestrictedResize
keyCmdAllModKey: 16777250
doubleClickBorderToMaximize: true
condensedTitle: false
electricBorderMaximize: true
electricBorderTiling: true
electricBorderAllScreenCorner: true
electricBorderCornerRatio: 0.25
borderlessMaximizedWindows: false
killPingTimeout: 5000
compositingMode: 1
allowTearing: true
interactiveWindowMoveEnabled: true
pictureInPictureHomeCorner: BottomRightCorner
pictureInPictureMargin: 20
overlayVirtualKeyboardOnWindows: false

Screen Edges
============
desktopSwitching: false
desktopSwitchingMovingClients: false
cursorPushBackDistance: 1x1
actionTopLeft: 0
actionTop: 0
actionTopRight: 0
actionRight: 0
actionBottomRight: 0
actionBottom: 0
actionBottomLeft: 0
actionLeft: 0

Screens
=======
Number of Screens: 1

Screen 0:
---------
Name: HDMI-A-1
Enabled: 1
Geometry: 0,0,1920x1080
Physical size: 160x90mm
Scale: 1
Refresh Rate: 60000
Adaptive Sync: incapable

Compositing
===========
Compositing is active
Compositing Type: OpenGL
OpenGL vendor string: NVIDIA Corporation
OpenGL renderer string: NVIDIA GeForce RTX 5060 Ti/PCIe/SSE2
OpenGL version string: 3.1.0 NVIDIA 595.71.05
OpenGL platform interface: EGL
OpenGL shading language version string: 1.40 NVIDIA via Cg compiler
Driver: NVIDIA
Driver version: 595.71.5
GPU class: Unknown
OpenGL version: 3.1
GLSL version: 1.40
X server version: 1.24.1
Linux kernel version: 7.0.10
Direct rendering: Requires strict binding: no
Virtual Machine:  no
OpenGL 2 Shaders are used

Loaded Effects:
---------------
shakecursor
outputlocator
colorpicker
zoom
screenedge
blur
sessionquit
logout
login
slidingpopups
windowaperture
slide
squash
scale
maximize
fullscreen
frozenapp
fadingpopups
dimscreen
dialogparent
windowview
tileseditor
overview
highlightwindow
blendchanges
startupfeedback
systembell
screentransform
kscreen

Currently Active Effects:
-------------------------
blur
scale
fadingpopups

Effect Settings:
----------------
shakecursor:

outputlocator:

colorpicker:

zoom:
zoomFactor: 1.2
mousePointer: 0
mouseTracking: 0
focusDelay: 350
moveFactor: 20

exit_code=0
```

## KWin config do usuário: /home/hal/.config/kwinrc

```
[Desktops]
Id_1=703b62be-7c5a-44b3-a99c-9f31c8d0a8a3
Number=1
Rows=1

[Tiling][703b62be-7c5a-44b3-a99c-9f31c8d0a8a3][fa9cd5a2-674b-4a0b-8a9a-0d1eb805e2d8]
padding=4
tiles={"layoutDirection":"horizontal","tiles":[{"width":0.25},{"width":0.5},{"width":0.25}]}

[Xwayland]
Scale=1
```

## Plasma panel config do usuário: /home/hal/.config/plasma-org.kde.plasma.desktop-appletsrc

```
[ActionPlugins][0]
RightButton;NoModifier=org.kde.contextmenu

[ActionPlugins][1]
RightButton;NoModifier=org.kde.contextmenu

[Containments][1]
ItemGeometries-1422x800=
ItemGeometries-1920x1080=
ItemGeometriesHorizontal=
activityId=27fbf93b-d728-40f7-9fc3-99c5ea95e922
formfactor=0
immutability=1
lastScreen=0
location=0
plugin=org.kde.plasma.folder
wallpaperplugin=org.kde.image

[Containments][2]
activityId=
formfactor=2
immutability=1
lastScreen=0
location=4
plugin=org.kde.panel
wallpaperplugin=org.kde.image

[Containments][2][Applets][21]
immutability=1
plugin=org.kde.plasma.digitalclock

[Containments][2][Applets][21][Configuration]
popupHeight=400
popupWidth=560

[Containments][2][Applets][21][Configuration][Appearance]
fontWeight=400

[Containments][2][Applets][22]
immutability=1
plugin=org.kde.plasma.showdesktop

[Containments][2][Applets][3]
immutability=1
plugin=org.kde.plasma.kickoff

[Containments][2][Applets][3][Configuration]
popupHeight=509
popupWidth=629

[Containments][2][Applets][3][Configuration][General]
favoritesPortedToKAstats=true

[Containments][2][Applets][3][Configuration][Shortcuts]
global=Alt+F1

[Containments][2][Applets][4]
immutability=1
plugin=org.kde.plasma.pager

[Containments][2][Applets][5]
immutability=1
plugin=org.kde.plasma.icontasks

[Containments][2][Applets][5][Configuration][General]
groupingStrategy=1
launchers=preferred://filemanager,applications:org.kde.konsole.desktop,preferred://browser
showOnlyCurrentDesktop=false
showOnlyCurrentScreen=false

[Containments][2][Applets][6]
immutability=1
plugin=org.kde.plasma.marginsseparator

[Containments][2][Applets][7]
activityId=
formfactor=0
immutability=1
lastScreen=-1
location=0
plugin=org.kde.plasma.systemtray
popupHeight=432
popupWidth=432
wallpaperplugin=org.kde.image

[Containments][2][Applets][7][Applets][10]
immutability=1
plugin=org.kde.plasma.clipboard

[Containments][2][Applets][7][Applets][11]
immutability=1
plugin=org.kde.plasma.devicenotifier

[Containments][2][Applets][7][Applets][12]
immutability=1
plugin=org.kde.plasma.manage-inputmethod

[Containments][2][Applets][7][Applets][13]
immutability=1
plugin=org.kde.plasma.notifications

[Containments][2][Applets][7][Applets][14]
immutability=1
plugin=org.kde.plasma.keyboardindicator

[Containments][2][Applets][7][Applets][15]
immutability=1
plugin=org.kde.plasma.weather

[Containments][2][Applets][7][Applets][16]
immutability=1
plugin=org.kde.kscreen

[Containments][2][Applets][7][Applets][17]
immutability=1
plugin=org.kde.plasma.keyboardlayout

[Containments][2][Applets][7][Applets][18]
immutability=1
plugin=org.kde.plasma.networkmanagement

[Containments][2][Applets][7][Applets][19]
immutability=1
plugin=org.kde.plasma.volume

[Containments][2][Applets][7][Applets][19][Configuration][General]
migrated=true

[Containments][2][Applets][7][Applets][20]
immutability=1
plugin=org.kde.plasma.printmanager

[Containments][2][Applets][7][Applets][23]
immutability=1
plugin=org.kde.plasma.brightness

[Containments][2][Applets][7][Applets][24]
immutability=1
plugin=org.kde.plasma.battery

[Containments][2][Applets][7][Applets][25]
immutability=1
plugin=org.kde.plasma.bluetooth

[Containments][2][Applets][7][Applets][8]
immutability=1
plugin=org.kde.kdeconnect

[Containments][2][Applets][7][Applets][9]
immutability=1
plugin=org.kde.plasma.cameraindicator

[Containments][2][Applets][7][ConfigDialog]
DialogHeight=630
DialogWidth=810

[Containments][2][Applets][7][General]
extraItems=org.kde.kdeconnect,org.kde.plasma.cameraindicator,org.kde.plasma.clipboard,org.kde.plasma.devicenotifier,org.kde.plasma.manage-inputmethod,org.kde.plasma.mediacontroller,org.kde.plasma.notifications,org.kde.plasma.keyboardindicator,org.kde.plasma.weather,org.kde.kscreen,org.kde.plasma.battery,org.kde.plasma.brightness,org.kde.plasma.keyboardlayout,org.kde.plasma.networkmanagement,org.kde.plasma.volume,org.kde.plasma.printmanager,org.kde.plasma.bluetooth
knownItems=org.kde.kdeconnect,org.kde.plasma.bluetooth,org.kde.plasma.cameraindicator,org.kde.plasma.clipboard,org.kde.plasma.devicenotifier,org.kde.plasma.manage-inputmethod,org.kde.plasma.mediacontroller,org.kde.plasma.notifications,org.kde.plasma.keyboardindicator,org.kde.plasma.weather,org.kde.kscreen,org.kde.plasma.battery,org.kde.plasma.brightness,org.kde.plasma.keyboardlayout,org.kde.plasma.networkmanagement,org.kde.plasma.volume,org.kde.plasma.printmanager
shownItems=org.kde.plasma.bluetooth

[Containments][2][General]
AppletOrder=4;23;3;5;24;6;7;21;22

[ScreenMapping]
itemsOnDisabledScreens=
screenMapping=desktop:/steam.desktop,0,27fbf93b-d728-40f7-9fc3-99c5ea95e922

[Containments][2][Applets][23]
immutability=1
plugin=org.kde.plasma.panelspacer

[Containments][2][Applets][23][Configuration][General]
expanding=true
length=0

[Containments][2][Applets][24]
immutability=1
plugin=org.kde.plasma.panelspacer

[Containments][2][Applets][24][Configuration][General]
expanding=true
length=0
```

## KDE globals do usuário: /home/hal/.config/kdeglobals

```
[ColorEffects:Disabled]
ChangeSelectionColor=
Color=56,56,56
ColorAmount=0
ColorEffect=0
ContrastAmount=0.65
ContrastEffect=1
Enable=
IntensityAmount=0.1
IntensityEffect=2

[ColorEffects:Inactive]
ChangeSelectionColor=true
Color=112,111,110
ColorAmount=0.025
ColorEffect=2
ContrastAmount=0.1
ContrastEffect=2
Enable=false
IntensityAmount=0
IntensityEffect=0

[Colors:Button]
BackgroundAlternate=114,90,174
BackgroundNormal=41,44,48
DecorationFocus=146,110,228
DecorationHover=146,110,228
ForegroundActive=146,110,228
ForegroundInactive=161,169,177
ForegroundLink=209,199,242
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[Colors:Complementary]
BackgroundAlternate=30,87,116
BackgroundNormal=32,35,38
DecorationFocus=146,110,228
DecorationHover=146,110,228
ForegroundActive=146,110,228
ForegroundInactive=161,169,177
ForegroundLink=209,199,242
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[Colors:Header]
BackgroundAlternate=32,35,38
BackgroundNormal=41,44,48
DecorationFocus=146,110,228
DecorationHover=146,110,228
ForegroundActive=146,110,228
ForegroundInactive=161,169,177
ForegroundLink=209,199,242
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[Colors:Header][Inactive]
BackgroundAlternate=41,44,48
BackgroundNormal=32,35,38
DecorationFocus=61,174,233
DecorationHover=61,174,233
ForegroundActive=61,174,233
ForegroundInactive=161,169,177
ForegroundLink=29,153,243
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[Colors:Selection]
BackgroundAlternate=108,83,166
BackgroundNormal=108,83,166
DecorationFocus=146,110,228
DecorationHover=146,110,228
ForegroundActive=146,110,228
ForegroundInactive=255,255,255
ForegroundLink=118,54,221
ForegroundNegative=176,55,69
ForegroundNeutral=198,92,0
ForegroundNormal=255,255,255
ForegroundPositive=23,104,57
ForegroundVisited=155,89,182

[Colors:Tooltip]
BackgroundAlternate=32,35,38
BackgroundNormal=41,44,48
DecorationFocus=146,110,228
DecorationHover=146,110,228
ForegroundActive=146,110,228
ForegroundInactive=161,169,177
ForegroundLink=209,199,242
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[Colors:View]
BackgroundAlternate=29,31,34
BackgroundNormal=20,22,24
DecorationFocus=146,110,228
DecorationHover=146,110,228
ForegroundActive=146,110,228
ForegroundInactive=161,169,177
ForegroundLink=146,110,228
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[Colors:Window]
BackgroundAlternate=41,44,48
BackgroundNormal=32,35,38
DecorationFocus=146,110,228
DecorationHover=146,110,228
ForegroundActive=146,110,228
ForegroundInactive=161,169,177
ForegroundLink=209,199,242
ForegroundNegative=218,68,83
ForegroundNeutral=246,116,0
ForegroundNormal=252,252,252
ForegroundPositive=39,174,96
ForegroundVisited=155,89,182

[General]
ColorSchemeHash=2c3f86428c11011a7c64ee1e7f47c274d498ff10

[KDE]
LookAndFeelPackage=org.kde.breezedark.desktop
contrast=4
frameContrast=0.2

[KShortcutsDialog Settings]
Dialog Size=600,480

[WM]
activeBackground=39,44,49
activeBlend=252,252,252
activeForeground=252,252,252
inactiveBackground=32,36,40
inactiveBlend=161,169,177
inactiveForeground=161,169,177
```

## Steam/MangoHud/GameMode arquivos do usuário

```bash

echo "Steam:"
command -v steam 2>/dev/null || true
pacman -Q steam 2>/dev/null || true
echo
echo "MangoHud:"
command -v mangohud 2>/dev/null || true
pacman -Q mangohud lib32-mangohud 2>/dev/null || true
ls -la "$HOME/.config/MangoHud" 2>/dev/null || true
echo
echo "Wrappers ~/.local/bin:"
ls -la "$HOME/.local/bin" 2>/dev/null | grep -Ei "mocha|steam|game|mango|onlyoffice" || true
echo
echo "Wrapper mocha-steam-game-run:"
sed -n "1,220p" "$HOME/.local/bin/mocha-steam-game-run" 2>/dev/null || true
echo
echo "Desktop entries Mocha/Steam:"
grep -RIl "mocha\\|Steam\\|MangoHud" "$HOME/.local/share/applications" /usr/share/applications 2>/dev/null | head -80 || true


Steam:
/usr/bin/steam
steam 1.0.0.85-7

MangoHud:

Wrappers ~/.local/bin:

Wrapper mocha-steam-game-run:

Desktop entries Mocha/Steam:
/home/hal/.local/share/applications/Sniper Elite Resistance.desktop
/usr/share/applications/steam.desktop

exit_code=0
```

## Flatpak

```bash

if command -v flatpak >/dev/null 2>&1; then
  flatpak remotes --columns=name,url 2>/dev/null || true
  echo
  flatpak list --app 2>/dev/null || true
else
  echo "flatpak ausente"
fi


flathub	https://dl.flathub.org/repo/


exit_code=0
```

## pacman.conf: /etc/pacman.conf

```
#
# /etc/pacman.conf
#
# See the pacman.conf(5) manpage for option and repository directives

#
# GENERAL OPTIONS
#
[options]
# The following paths are commented out with their default values listed.
# If you wish to use different paths, uncomment and update the paths.
#RootDir     = /
#DBPath      = /var/lib/pacman/
#CacheDir    = /var/cache/pacman/pkg/
#LogFile     = /var/log/pacman.log
#GPGDir      = /etc/pacman.d/gnupg/
#HookDir     = /etc/pacman.d/hooks/
HoldPkg     = pacman glibc dracut kernel-install-for-dracut eos-dracut
#XferCommand = /usr/bin/curl -L -C - -f -o %o %u
#XferCommand = /usr/bin/wget --passive-ftp -c -O %o %u
#CleanMethod = KeepInstalled
Architecture = auto

# Pacman won't upgrade packages listed in IgnorePkg and members of IgnoreGroup
#IgnorePkg   =
#IgnoreGroup =

#NoUpgrade   =
#NoExtract   =

# Misc options
#UseSyslog
Color
ILoveCandy
#NoProgressBar
#CheckSpace
VerbosePkgLists
ParallelDownloads = 5
DownloadUser = alpm
#DisableSandbox

# By default, pacman accepts packages signed by keys that its local keyring
# trusts (see pacman-key and its man page), as well as unsigned packages.
SigLevel    = Required DatabaseOptional
LocalFileSigLevel = Optional
#RemoteFileSigLevel = Required

# NOTE: You must run `pacman-key --init` before first using pacman; the local
# keyring can then be populated with the keys of all official Arch Linux
# packagers with `pacman-key --populate archlinux`.

#
# REPOSITORIES
#   - can be defined here or included from another file
#   - pacman will search repositories in the order defined here
#   - local/custom mirrors can be added here or in separate files
#   - repositories listed first will take precedence when packages
#     have identical names, regardless of version number
#   - URLs will have $repo replaced by the name of the current repo
#   - URLs will have $arch replaced by the name of the architecture
#
# Repository entries are of the format:
#       [repo-name]
#       Server = ServerName
#       Include = IncludePath
#
# The header [repo-name] is crucial - it must be present and
# uncommented to enable the repo.
#

# The testing repositories are disabled by default. To enable, uncomment the
# repo name header and Include lines. You can add preferred servers immediately
# after the header, and they will be used before the default mirrors.

[endeavouros]
SigLevel = PackageRequired
Include = /etc/pacman.d/endeavouros-mirrorlist

#[core-testing]
#Include = /etc/pacman.d/mirrorlist

[core]
Include = /etc/pacman.d/mirrorlist

#[extra-testing]
#Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

# If you want to run 32 bit applications on your x86_64 system,
# enable the multilib repositories as required here.

#[multilib-testing]
#Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist

# An example of a custom package repository.  See the pacman manpage for
# tips on creating your own repositories.
#[custom]
#SigLevel = Optional TrustAll
#Server = file:///home/custompkgs
```

## makepkg.conf: /etc/makepkg.conf

```
#!/hint/bash
# shellcheck disable=2034

#
# /etc/makepkg.conf
#

#########################################################################
# SOURCE ACQUISITION
#########################################################################
#
#-- The download utilities that makepkg should use to acquire sources
#  Format: 'protocol::agent'
DLAGENTS=('file::/usr/bin/curl -qgC - -o %o %u'
          'ftp::/usr/bin/curl -qgfC - --ftp-pasv --retry 3 --retry-delay 3 -o %o %u'
          'http::/usr/bin/curl -qgb "" -fLC - --retry 3 --retry-delay 3 -o %o %u'
          'https::/usr/bin/curl -qgb "" -fLC - --retry 3 --retry-delay 3 -o %o %u'
          'rsync::/usr/bin/rsync --no-motd -z %u %o'
          'scp::/usr/bin/scp -C %u %o')

# Other common tools:
# /usr/bin/snarf
# /usr/bin/lftpget -c
# /usr/bin/wget

#-- The package required by makepkg to download VCS sources
#  Format: 'protocol::package'
VCSCLIENTS=('bzr::breezy'
            'fossil::fossil'
            'git::git'
            'hg::mercurial'
            'svn::subversion')

#########################################################################
# ARCHITECTURE, COMPILE FLAGS
#########################################################################
#
CARCH="x86_64"
CHOST="x86_64-pc-linux-gnu"

#-- Compiler and Linker Flags
#CPPFLAGS=""
CFLAGS="-march=x86-64 -mtune=generic -O2 -pipe -fno-plt -fexceptions \
        -Wp,-D_FORTIFY_SOURCE=3 -Wformat -Werror=format-security \
        -fstack-clash-protection -fcf-protection \
        -fno-omit-frame-pointer -mno-omit-leaf-frame-pointer"
CXXFLAGS="$CFLAGS -Wp,-D_GLIBCXX_ASSERTIONS"
LDFLAGS="-Wl,-O1 -Wl,--sort-common -Wl,--as-needed -Wl,-z,relro -Wl,-z,now \
         -Wl,-z,pack-relative-relocs"
LTOFLAGS="-flto=auto"
#-- Make Flags: change this for DistCC/SMP systems
#MAKEFLAGS="-j2"
#-- Debugging flags
DEBUG_CFLAGS="-g"
DEBUG_CXXFLAGS="$DEBUG_CFLAGS"

#########################################################################
# BUILD ENVIRONMENT
#########################################################################
#
# Makepkg defaults: BUILDENV=(!distcc !color !ccache check !sign)
#  A negated environment option will do the opposite of the comments below.
#
#-- distcc:   Use the Distributed C/C++/ObjC compiler
#-- color:    Colorize output messages
#-- ccache:   Use ccache to cache compilation
#-- check:    Run the check() function if present in the PKGBUILD
#-- sign:     Generate PGP signature file
#
BUILDENV=(!distcc color !ccache check !sign)
#
#-- If using DistCC, your MAKEFLAGS will also need modification. In addition,
#-- specify a space-delimited list of hosts running in the DistCC cluster.
#DISTCC_HOSTS=""
#
#-- Specify a directory for package building.
#BUILDDIR=/tmp/makepkg

#########################################################################
# GLOBAL PACKAGE OPTIONS
#   These are default values for the options=() settings
#########################################################################
#
# Makepkg defaults: OPTIONS=(!strip docs libtool staticlibs emptydirs !zipman !purge !debug !lto !autodeps)
#  A negated option will do the opposite of the comments below.
#
#-- strip:      Strip symbols from binaries/libraries
#-- docs:       Save doc directories specified by DOC_DIRS
#-- libtool:    Leave libtool (.la) files in packages
#-- staticlibs: Leave static library (.a) files in packages
#-- emptydirs:  Leave empty directories in packages
#-- zipman:     Compress manual (man and info) pages in MAN_DIRS with gzip
#-- purge:      Remove files specified by PURGE_TARGETS
#-- debug:      Add debugging flags as specified in DEBUG_* variables
#-- lto:        Add compile flags for building with link time optimization
#-- autodeps:   Automatically add depends/provides
#
OPTIONS=(strip docs !libtool !staticlibs emptydirs zipman purge !debug !lto !autodeps)

#-- File integrity checks to use. Valid: md5, sha1, sha224, sha256, sha384, sha512, b2
INTEGRITY_CHECK=(sha256)
#-- Options to be used when stripping binaries. See `man strip' for details.
STRIP_BINARIES="--strip-all"
#-- Options to be used when stripping shared libraries. See `man strip' for details.
STRIP_SHARED="--strip-unneeded"
#-- Options to be used when stripping static libraries. See `man strip' for details.
STRIP_STATIC="--strip-debug"
#-- Manual (man and info) directories to compress (if zipman is specified)
MAN_DIRS=({usr{,/local}{,/share},opt/*}/{man,info})
#-- Doc directories to remove (if !docs is specified)
DOC_DIRS=(usr/{,local/}{,share/}{doc,gtk-doc} opt/*/{doc,gtk-doc})
#-- Files to be removed from all packages (if purge is specified)
PURGE_TARGETS=(usr/{,share}/info/dir .packlist *.pod)
#-- Directory to store source code in for debug packages
DBGSRCDIR="/usr/src/debug"
#-- Prefix and directories for library autodeps
LIB_DIRS=('lib:usr/lib' 'lib32:usr/lib32')

#########################################################################
# PACKAGE OUTPUT
#########################################################################
#
# Default: put built package and cached source in build directory
#
#-- Destination: specify a fixed directory where all packages will be placed
#PKGDEST=/home/packages
#-- Source cache: specify a fixed directory where source files will be cached
#SRCDEST=/home/sources
#-- Source packages: specify a fixed directory where all src packages will be placed
#SRCPKGDEST=/home/srcpackages
#-- Log files: specify a fixed directory where all log files will be placed
#LOGDEST=/home/makepkglogs
#-- Packager: name/email of the person or organization building packages
#PACKAGER="John Doe <john@doe.com>"
#-- Specify a key to use for package signing
#GPGKEY=""

#########################################################################
# COMPRESSION DEFAULTS
#########################################################################
#
COMPRESSGZ=(gzip -c -f -n)
COMPRESSBZ2=(bzip2 -c -f)
COMPRESSXZ=(xz -c -z -)
COMPRESSZST=(zstd -c -T0 -)
COMPRESSLRZ=(lrzip -q)
COMPRESSLZO=(lzop -q)
COMPRESSZ=(compress -c -f)
COMPRESSLZ4=(lz4 -q)
COMPRESSLZ=(lzip -c -f)

#########################################################################
# EXTENSION DEFAULTS
#########################################################################
#
PKGEXT='.pkg.tar.zst'
SRCEXT='.src.tar.gz'

#########################################################################
# OTHER
#########################################################################
#
#-- Command used to run pacman as root, instead of trying sudo and su
#PACMAN_AUTH=()
# vim: set ft=sh ts=2 sw=2 et:
```

## mkinitcpio.conf: /etc/mkinitcpio.conf

```
não legível: /etc/mkinitcpio.conf
```

## grub default: /etc/default/grub

```
não legível: /etc/default/grub
```

## systemd boot entries

```bash

ls -la /boot/loader/entries 2>/dev/null || true
for f in /boot/loader/entries/*.conf; do
  [ -r "$f" ] || continue
  echo
  echo "### $f"
  sed -n "1,180p" "$f"
done



exit_code=0
```

## modprobe.d e sysctl.d

```bash

echo "modprobe.d:"
for f in /etc/modprobe.d/*.conf; do
  [ -r "$f" ] || continue
  echo
  echo "### $f"
  sed -n "1,180p" "$f"
done
echo
echo "sysctl.d:"
for f in /etc/sysctl.d/*.conf /usr/lib/sysctl.d/*.conf; do
  [ -r "$f" ] || continue
  case "$f" in
    *99-sysctl.conf|*99-mocha*|*90-*|*10-*|*00-*|/etc/sysctl.d/*)
      echo
      echo "### $f"
      sed -n "1,180p" "$f"
      ;;
  esac
done


modprobe.d:

### /etc/modprobe.d/firewalld-sysctls.conf
install nf_conntrack /usr/bin/modprobe --ignore-install nf_conntrack $CMDLINE_OPTS && /sbin/sysctl --quiet --pattern 'net[.]netfilter[.]nf_conntrack.*' --system

sysctl.d:

### /usr/lib/sysctl.d/10-arch.conf
# Raise inotify resource limits
# https://bugs.archlinux.org/task/47830
fs.inotify.max_user_instances = 1024
fs.inotify.max_user_watches = 524288

# Increase the default vm.max_map_count value
# https://archlinux.org/news/increasing-the-default-vmmax_map_count-value/
vm.max_map_count = 1048576

# Shorten the default TCP keepalive time
# https://rfc.archlinux.page/0051-tcp-keepalive/
net.ipv4.tcp_keepalive_time = 120

exit_code=0
```

## Rede/DNS

```bash

ip -brief addr 2>/dev/null || true
echo
resolvectl status 2>/dev/null | sed -n "1,220p" || true
echo
nmcli general status 2>/dev/null || true
nmcli connection show --active 2>/dev/null || true


lo               UNKNOWN        127.0.0.1/8 ::1/128 
enp4s0           UP             192.168.100.2/24 2804:d51:568d:d300:fdc7:d5a2:2604:3569/64 fe80::2ff7:4f15:7f90:69dd/64 


STATE      CONNECTIVITY  WIFI-HW  WIFI        WWAN-HW  WWAN        METERED          
conectado  completa      missing  habilitado  missing  habilitado  não (adivinhado) 
NAME               UUID                                  TYPE      DEVICE 
Conexão cabeada 1  c158f0c1-4867-3b1d-ad89-a641605ae4e7  ethernet  enp4s0 
lo                 8f2ce74f-7030-46d9-8f8f-b552e649945c  loopback  lo     

exit_code=0
```

## Erros críticos do boot atual

```bash

journalctl -b -p warning..alert --no-pager 2>/dev/null | tail -250 || true


mai 28 11:21:45 hal-systemproductname kde-open[9819]: Not passing environment variable "BASH_FUNC_eos_yad_WARN%%" to systemd because its name contains illegal characters
mai 28 11:21:45 hal-systemproductname kde-open[9819]: Not passing environment variable "BASH_FUNC_eos_yad__detectDE%%" to systemd because its name contains illegal characters
mai 28 11:21:45 hal-systemproductname kde-open[9819]: Not passing environment variable "BASH_FUNC_eos_yad_check_internet_connection%%" to systemd because its name contains illegal characters
mai 28 11:21:45 hal-systemproductname kde-open[9819]: Not passing environment variable "BASH_FUNC_eos_yad_nothing_todo%%" to systemd because its name contains illegal characters
mai 28 11:21:45 hal-systemproductname kde-open[9819]: Not passing environment variable "BASH_FUNC_eos_yad_problem%%" to systemd because its name contains illegal characters
mai 28 11:21:45 hal-systemproductname kde-open[9819]: Not passing environment variable "BASH_FUNC_eos_yad_terminal%%" to systemd because its name contains illegal characters
mai 28 11:21:45 hal-systemproductname kde-open[9819]: Not passing environment variable "BASH_FUNC_ethernet_toggle_r8168_r8169%%" to systemd because its name contains illegal characters
mai 28 11:21:45 hal-systemproductname kde-open[9819]: Not passing environment variable "BASH_FUNC_w_WARN%%" to systemd because its name contains illegal characters
mai 28 11:21:45 hal-systemproductname kde-open[9819]: Not passing environment variable "BASH_FUNC_yad_ChangeDisplayManager%%" to systemd because its name contains illegal characters
mai 28 11:21:45 hal-systemproductname kde-open[9819]: Not passing environment variable "BASH_FUNC_yad_GetCurrentDM%%" to systemd because its name contains illegal characters
mai 28 11:21:45 hal-systemproductname kde-open[9819]: Not passing environment variable "BASH_FUNC_yad_Install%%" to systemd because its name contains illegal characters
mai 28 11:23:28 hal-systemproductname systemsettings[10973]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: Connection already associated with an application ID")
mai 28 11:23:58 hal-systemproductname org_kde_powerdevil[1520]: org.kde.powerdevil.chargethresholdhelper.getconservationmode failed "Battery conservation mode is not supported"
mai 28 11:23:58 hal-systemproductname org_kde_powerdevil[1520]: org.kde.powerdevil.chargethresholdhelper.getconservationmode failed "Battery conservation mode is not supported"
mai 28 11:24:16 hal-systemproductname org_kde_powerdevil[1520]: org.kde.powerdevil.chargethresholdhelper.getthreshold failed "Charge thresholds are not supported by the kernel for this hardware"
mai 28 11:31:03 hal-systemproductname systemsettings[11685]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: Connection already associated with an application ID")
mai 28 11:31:27 hal-systemproductname baloo_file_extractor[11897]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.baloo'")
mai 28 11:32:51 hal-systemproductname org_kde_powerdevil[1520]: [  1712][1091.069537] (dw_watch_display_connections) Time since last return from sleep = 1091012433337 ns = 1091012 ms
mai 28 11:32:51 hal-systemproductname kwin_wayland[1326]: Failed to open /dev/dri/renderD128 device (No such device)
mai 28 11:32:51 hal-systemproductname kwin_wayland[1326]: Failed to open drm device /dev/dri/renderD128
mai 28 11:32:51 hal-systemproductname kwin_wayland[1326]: Failed to open drm device 
mai 28 11:32:51 hal-systemproductname kwin_wayland[1326]: Failed to open drm device 
mai 28 11:32:51 hal-systemproductname kwin_wayland[1326]: Failed to open drm device 
mai 28 11:32:51 hal-systemproductname kwin_wayland[1326]: Failed to open drm device 
mai 28 11:32:51 hal-systemproductname org_kde_powerdevil[1520]: [  1712][1091.488573] (dw_watch_display_connections) Time since last return from sleep = 1091431469965 ns = 1091431 ms
mai 28 11:32:51 hal-systemproductname org_kde_powerdevil[1520]: [  1712][1091.763146] (dw_watch_display_connections) Time since last return from sleep = 1091706043088 ns = 1091706 ms
mai 28 11:32:51 hal-systemproductname org_kde_powerdevil[1520]: [  1712][1092.034006] (dw_watch_display_connections) Time since last return from sleep = 1091976903463 ns = 1091977 ms
mai 28 11:32:52 hal-systemproductname org_kde_powerdevil[1520]: [  1712][1092.302918] (dw_watch_display_connections) Time since last return from sleep = 1092245815275 ns = 1092246 ms
mai 28 11:32:52 hal-systemproductname org_kde_powerdevil[1520]: [  1712][1092.570003] (dw_watch_display_connections) Time since last return from sleep = 1092512899900 ns = 1092513 ms
mai 28 11:32:52 hal-systemproductname org_kde_powerdevil[1520]: [  1712][1092.838972] (dw_watch_display_connections) Time since last return from sleep = 1092781868783 ns = 1092782 ms
mai 28 11:32:53 hal-systemproductname org_kde_powerdevil[1520]: [  1712][1093.106946] (dw_watch_display_connections) Time since last return from sleep = 1093049843155 ns = 1093050 ms
mai 28 11:32:53 hal-systemproductname org_kde_powerdevil[1520]: [  1712][1093.383650] (dw_watch_display_connections) Time since last return from sleep = 1093326547649 ns = 1093327 ms
mai 28 11:32:53 hal-systemproductname org_kde_powerdevil[1520]: [  1712][1093.651866] (dw_watch_display_connections) Time since last return from sleep = 1093594763263 ns = 1093595 ms
mai 28 11:32:53 hal-systemproductname org_kde_powerdevil[1520]: [  1712][1093.920258] (dw_watch_display_connections) Time since last return from sleep = 1093863154746 ns = 1093863 ms
mai 28 11:32:54 hal-systemproductname org_kde_powerdevil[1520]: [  1712][1094.188112] (dw_watch_display_connections) Time since last return from sleep = 1094131008721 ns = 1094131 ms
mai 28 11:32:54 hal-systemproductname org_kde_powerdevil[1520]: [  1712][1094.456925] (dw_watch_display_connections) Time since last return from sleep = 1094399821467 ns = 1094400 ms
mai 28 11:33:38 hal-systemproductname baloo_file_extractor[12708]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.baloo'")
mai 28 11:33:58 hal-systemproductname baloo_file_extractor[12900]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.baloo'")
mai 28 11:34:17 hal-systemproductname plasmashell[1461]: Failed to find service for Unity Launcher "gldriverquery.desktop"
mai 28 11:34:17 hal-systemproductname plasmashell[1461]: Failed to find service for Unity Launcher "gldriverquery.desktop"
mai 28 11:35:46 hal-systemproductname plasmashell[1461]: Failed to find service for Unity Launcher "gldriverquery.desktop"
mai 28 11:35:46 hal-systemproductname plasmashell[1461]: Failed to find service for Unity Launcher "gldriverquery.desktop"
mai 28 11:38:05 hal-systemproductname dolphin[16411]: Unknown class  ""  in session saved data!
mai 28 11:39:46 hal-systemproductname baloo_file_extractor[16577]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: App info not found for 'org.kde.baloo'")
mai 28 11:44:30 hal-systemproductname plasmashell[1461]: This plugin does not support setting window opacity
mai 28 11:44:32 hal-systemproductname plasmashell[17102]: Could not find required file "mainscript" for package "/usr/share/plasma/plasmoids/org.kde.plasma.icontasks/" should be QList("ui/main.qml")
mai 28 11:44:32 hal-systemproductname plasmashell[17102]: Member visible of the object PlasmaQuick::Dialog overrides a member of the base object. Consider renaming it or adding final or override specifier
mai 28 11:44:32 hal-systemproductname plasmashell[17102]: Member enabled of the object DeclarativeDropArea overrides a member of the base object. Consider renaming it or adding final or override specifier
mai 28 11:44:33 hal-systemproductname plasmashell[17102]: Entry is not valid "org.kde.kontact.desktop" 0x55d542c8ad60
mai 28 11:44:33 hal-systemproductname plasmashell[17102]: Entry is not valid "org.kde.discover.desktop" 0x55d542c8ad60
mai 28 11:44:33 hal-systemproductname plasmashell[17102]: Entry is not valid "org.kde.kontact.desktop" 0x55d542c8ad60
mai 28 11:44:33 hal-systemproductname plasmashell[17102]: Entry is not valid "org.kde.discover.desktop" 0x55d542c8ad60
mai 28 11:44:33 hal-systemproductname plasmashell[17102]: Final member StackingOrder is overridden in class QQmlDMAbstractItemModelData. The override won't be used.
mai 28 11:44:34 hal-systemproductname plasmashell[17102]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor"
mai 28 11:45:32 hal-systemproductname systemd[1251]: dbus-:1.2-org.kde.KSplash@1.service: Failed with result 'exit-code'.
mai 28 11:46:55 hal-systemproductname kwin_wayland[1326]: Member visible of the object PlasmaQuick::Dialog overrides a member of the base object. Consider renaming it or adding final or override specifier
mai 28 11:46:55 hal-systemproductname kwin_wayland[1326]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: Unable to open /proc/1326/root")
mai 28 11:47:18 hal-systemproductname plasmashell[17535]: Could not find required file "mainscript" for package "/usr/share/plasma/plasmoids/org.kde.plasma.icontasks/" should be QList("ui/main.qml")
mai 28 11:47:18 hal-systemproductname plasmashell[17535]: Member visible of the object PlasmaQuick::Dialog overrides a member of the base object. Consider renaming it or adding final or override specifier
mai 28 11:47:18 hal-systemproductname plasmashell[17535]: Member enabled of the object DeclarativeDropArea overrides a member of the base object. Consider renaming it or adding final or override specifier
mai 28 11:47:19 hal-systemproductname plasmashell[17535]: Entry is not valid "org.kde.kontact.desktop" 0x560f06b5ab30
mai 28 11:47:19 hal-systemproductname plasmashell[17535]: Entry is not valid "org.kde.discover.desktop" 0x560f06b5ab30
mai 28 11:47:19 hal-systemproductname plasmashell[17535]: Entry is not valid "org.kde.kontact.desktop" 0x560f06b5ab30
mai 28 11:47:19 hal-systemproductname plasmashell[17535]: Entry is not valid "org.kde.discover.desktop" 0x560f06b5ab30
mai 28 11:47:19 hal-systemproductname plasmashell[17535]: Final member StackingOrder is overridden in class QQmlDMAbstractItemModelData. The override won't be used.
mai 28 11:47:20 hal-systemproductname plasmashell[17535]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor"
mai 28 11:48:18 hal-systemproductname systemd[1251]: dbus-:1.2-org.kde.KSplash@2.service: Failed with result 'exit-code'.
mai 28 11:53:42 hal-systemproductname plasmashell[18000]: Could not find required file "mainscript" for package "/usr/share/plasma/plasmoids/org.kde.plasma.icontasks/" should be QList("ui/main.qml")
mai 28 11:53:42 hal-systemproductname plasmashell[18000]: Member visible of the object PlasmaQuick::Dialog overrides a member of the base object. Consider renaming it or adding final or override specifier
mai 28 11:53:42 hal-systemproductname plasmashell[18000]: Member enabled of the object DeclarativeDropArea overrides a member of the base object. Consider renaming it or adding final or override specifier
mai 28 11:53:42 hal-systemproductname plasmashell[18000]: Entry is not valid "org.kde.kontact.desktop" 0x561143198a60
mai 28 11:53:42 hal-systemproductname plasmashell[18000]: Entry is not valid "org.kde.discover.desktop" 0x561143198a60
mai 28 11:53:42 hal-systemproductname plasmashell[18000]: Entry is not valid "org.kde.kontact.desktop" 0x561143198a60
mai 28 11:53:42 hal-systemproductname plasmashell[18000]: Entry is not valid "org.kde.discover.desktop" 0x561143198a60
mai 28 11:53:42 hal-systemproductname plasmashell[18000]: Final member StackingOrder is overridden in class QQmlDMAbstractItemModelData. The override won't be used.
mai 28 11:53:43 hal-systemproductname plasmashell[18000]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor"
mai 28 11:54:42 hal-systemproductname systemd[1251]: dbus-:1.2-org.kde.KSplash@3.service: Failed with result 'exit-code'.
mai 28 11:54:57 hal-systemproductname steam[12700]: pressure-vessel-wrap[18208]: Internal error: _srt_architecture_read_elf: assertion 'error == NULL || *error == NULL' failed
mai 28 11:54:57 hal-systemproductname steam[12700]: pressure-vessel-wrap[18208]: W: Unable to determine architecture of runtime's ldconfig: Unable to acquire exclusive lock on .ref: file is busy
mai 28 11:57:30 hal-systemproductname systemsettings[18894]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: Connection already associated with an application ID")
mai 28 11:57:51 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml:25:1: QML ConfigGeneral: Created graphical object was not placed in the graphics scene.
mai 28 11:57:51 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_disabledStatusNotifiersDefault
mai 28 11:57:51 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_extraItemsDefault
mai 28 11:57:51 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_hiddenItemsDefault
mai 28 11:57:51 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_iconSpacingDefault
mai 28 11:57:51 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_knownItems
mai 28 11:57:51 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_knownItemsDefault
mai 28 11:57:51 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_pin
mai 28 11:57:51 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_pinDefault
mai 28 11:57:51 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_scaleIconsToFitDefault
mai 28 11:57:51 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_showAllItemsDefault
mai 28 11:57:51 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_shownItemsDefault
mai 28 12:01:04 hal-systemproductname systemsettings[19017]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: Connection already associated with an application ID")
mai 28 12:01:32 hal-systemproductname systemsettings[19053]: Failed to register with host portal QDBusError("org.freedesktop.portal.Error.Failed", "Could not register app ID: Connection already associated with an application ID")
mai 28 12:01:57 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml:25:1: QML ConfigGeneral: Created graphical object was not placed in the graphics scene.
mai 28 12:01:57 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_disabledStatusNotifiersDefault
mai 28 12:01:57 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_extraItemsDefault
mai 28 12:01:57 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_hiddenItemsDefault
mai 28 12:01:57 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_iconSpacingDefault
mai 28 12:01:57 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_knownItems
mai 28 12:01:57 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_knownItemsDefault
mai 28 12:01:57 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_pin
mai 28 12:01:57 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_pinDefault
mai 28 12:01:57 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_scaleIconsToFitDefault
mai 28 12:01:57 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_showAllItemsDefault
mai 28 12:01:57 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/systemtray/ConfigGeneral.qml: Setting initial properties failed: ConfigGeneral does not have a property called cfg_shownItemsDefault
mai 28 12:03:34 hal-systemproductname bluetoothd[19258]: Failed to set default system config for hci0
mai 28 12:03:34 hal-systemproductname wireplumber[1387]: spa.bluez5: RegisterApplication() failed: org.freedesktop.DBus.Error.NoReply
mai 28 12:03:34 hal-systemproductname wireplumber[1387]: spa.bluez5: Using legacy bluez5 API for A2DP - only SBC will be supported. Please upgrade bluez5.
mai 28 12:03:34 hal-systemproductname bluetoothd[19284]: Failed to set default system config for hci0
mai 28 12:03:34 hal-systemproductname bluetoothd[19284]: Failed to set privacy: Rejected (0x0b)
mai 28 12:03:34 hal-systemproductname systemd-coredump[19288]: Process 1387 (wireplumber) of user 1000 dumped core.
                                                               
                                                               Stack trace of thread 1387:
                                                               #0  0x00007f5eea09a29c n/a (libc.so.6 + 0x9a29c)
                                                               #1  0x00007f5eea03e7d0 raise (libc.so.6 + 0x3e7d0)
                                                               #2  0x00007f5eea025681 abort (libc.so.6 + 0x25681)
                                                               #3  0x00007f5ee97bb064 n/a (libdbus-1.so.3 + 0xe064)
                                                               #4  0x00007f5ee97e4e50 _dbus_warn_check_failed (libdbus-1.so.3 + 0x37e50)
                                                               #5  0x00007f5ee97d2a12 dbus_message_new_method_call (libdbus-1.so.3 + 0x25a12)
                                                               #6  0x00007f5ecf379142 n/a (libspa-bluez5.so + 0x75142)
                                                               #7  0x00007f5ecf3796fd n/a (libspa-bluez5.so + 0x756fd)
                                                               #8  0x00007f5ee97c2698 n/a (libdbus-1.so.3 + 0x15698)
                                                               #9  0x00007f5ee97c6f1e dbus_connection_dispatch (libdbus-1.so.3 + 0x19f1e)
                                                               #10 0x00007f5eea6af1a7 n/a (libspa-dbus.so + 0x11a7)
                                                               #11 0x00007f5ee9b329a6 n/a (libspa-support.so + 0x69a6)
                                                               #12 0x00007f5eea61ee0c n/a (libwireplumber-0.5.so.0 + 0x19e0c)
                                                               #13 0x00007f5eea4a0bfd n/a (libglib-2.0.so.0 + 0x61bfd)
                                                               #14 0x00007f5eea4a2e57 n/a (libglib-2.0.so.0 + 0x63e57)
                                                               #15 0x00007f5eea4a31a7 g_main_loop_run (libglib-2.0.so.0 + 0x641a7)
                                                               #16 0x0000555fc138751f n/a (/usr/bin/wireplumber + 0x251f)
                                                               #17 0x00007f5eea027741 n/a (libc.so.6 + 0x27741)
                                                               #18 0x00007f5eea027879 __libc_start_main (libc.so.6 + 0x27879)
                                                               #19 0x0000555fc1387945 n/a (/usr/bin/wireplumber + 0x2945)
                                                               
                                                               Stack trace of thread 1391:
                                                               #0  0x00007f5eea0a0a52 n/a (libc.so.6 + 0xa0a52)
                                                               #1  0x00007f5eea094abc n/a (libc.so.6 + 0x94abc)
                                                               #2  0x00007f5eea094b04 n/a (libc.so.6 + 0x94b04)
                                                               #3  0x00007f5eea10fff6 ppoll (libc.so.6 + 0x10fff6)
                                                               #4  0x00007f5eea4a2edf n/a (libglib-2.0.so.0 + 0x63edf)
                                                               #5  0x00007f5eea4a2fe5 g_main_context_iteration (libglib-2.0.so.0 + 0x63fe5)
                                                               #6  0x00007f5eea4a3032 n/a (libglib-2.0.so.0 + 0x64032)
                                                               #7  0x00007f5eea4d9ad4 n/a (libglib-2.0.so.0 + 0x9aad4)
                                                               #8  0x00007f5eea0981b9 n/a (libc.so.6 + 0x981b9)
                                                               #9  0x00007f5eea11d21c n/a (libc.so.6 + 0x11d21c)
                                                               
                                                               Stack trace of thread 1390:
                                                               #0  0x00007f5eea0a0a52 n/a (libc.so.6 + 0xa0a52)
                                                               #1  0x00007f5eea094abc n/a (libc.so.6 + 0x94abc)
                                                               #2  0x00007f5eea094b04 n/a (libc.so.6 + 0x94b04)
                                                               #3  0x00007f5eea11d4f5 epoll_wait (libc.so.6 + 0x11d4f5)
                                                               #4  0x00007f5ee9b49729 n/a (libspa-support.so + 0x1d729)
                                                               #5  0x00007f5ee9b328e9 n/a (libspa-support.so + 0x68e9)
                                                               #6  0x00007f5eea3fd201 n/a (libpipewire-0.3.so.0 + 0x8e201)
                                                               #7  0x00007f5eea0981b9 n/a (libc.so.6 + 0x981b9)
                                                               #8  0x00007f5eea11d21c n/a (libc.so.6 + 0x11d21c)
                                                               
                                                               Stack trace of thread 1397:
                                                               #0  0x00007f5eea0a0a52 n/a (libc.so.6 + 0xa0a52)
                                                               #1  0x00007f5eea094abc n/a (libc.so.6 + 0x94abc)
                                                               #2  0x00007f5eea094b04 n/a (libc.so.6 + 0x94b04)
                                                               #3  0x00007f5eea11d4f5 epoll_wait (libc.so.6 + 0x11d4f5)
                                                               #4  0x00007f5ee9b49729 n/a (libspa-support.so + 0x1d729)
                                                               #5  0x00007f5ee9b328e9 n/a (libspa-support.so + 0x68e9)
                                                               #6  0x00007f5eea3946d1 n/a (libpipewire-0.3.so.0 + 0x256d1)
                                                               #7  0x00007f5eea0981b9 n/a (libc.so.6 + 0x981b9)
                                                               #8  0x00007f5eea11d21c n/a (libc.so.6 + 0x11d21c)
                                                               
                                                               Stack trace of thread 1392:
                                                               #0  0x00007f5eea11af9d syscall (libc.so.6 + 0x11af9d)
                                                               #1  0x00007f5eea4d00de g_cond_wait (libglib-2.0.so.0 + 0x910de)
                                                               #2  0x00007f5eea46554d n/a (libglib-2.0.so.0 + 0x2654d)
                                                               #3  0x00007f5eea4d9fd7 n/a (libglib-2.0.so.0 + 0x9afd7)
                                                               #4  0x00007f5eea4d9ad4 n/a (libglib-2.0.so.0 + 0x9aad4)
                                                               #5  0x00007f5eea0981b9 n/a (libc.so.6 + 0x981b9)
                                                               #6  0x00007f5eea11d21c n/a (libc.so.6 + 0x11d21c)
                                                               
                                                               Stack trace of thread 1395:
                                                               #0  0x00007f5eea0a0a52 n/a (libc.so.6 + 0xa0a52)
                                                               #1  0x00007f5eea094abc n/a (libc.so.6 + 0x94abc)
                                                               #2  0x00007f5eea094b04 n/a (libc.so.6 + 0x94b04)
                                                               #3  0x00007f5eea10fff6 ppoll (libc.so.6 + 0x10fff6)
                                                               #4  0x00007f5eea4a2edf n/a (libglib-2.0.so.0 + 0x63edf)
                                                               #5  0x00007f5eea4a31a7 g_main_loop_run (libglib-2.0.so.0 + 0x641a7)
                                                               #6  0x00007f5ee9f39974 n/a (libgio-2.0.so.0 + 0x127974)
                                                               #7  0x00007f5eea4d9ad4 n/a (libglib-2.0.so.0 + 0x9aad4)
                                                               #8  0x00007f5eea0981b9 n/a (libc.so.6 + 0x981b9)
                                                               #9  0x00007f5eea11d21c n/a (libc.so.6 + 0x11d21c)
                                                               ELF object binary architecture: AMD x86-64
mai 28 12:03:34 hal-systemproductname systemd[1251]: wireplumber.service: Main process exited, code=dumped, status=6/ABRT
mai 28 12:03:34 hal-systemproductname systemd[1251]: wireplumber.service: Failed with result 'core-dump'.
mai 28 12:03:34 hal-systemproductname kded6[1444]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo"
mai 28 12:03:34 hal-systemproductname kded6[1444]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor"
mai 28 12:03:34 hal-systemproductname kded6[1444]: No object for name "@DEFAULT_SINK@"
mai 28 12:03:34 hal-systemproductname kded6[1444]: No object for name "@DEFAULT_SOURCE@"
mai 28 12:03:34 hal-systemproductname plasmashell[18000]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo"
mai 28 12:03:34 hal-systemproductname plasmashell[18000]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor"
mai 28 12:03:34 hal-systemproductname plasmashell[18000]: qrc:/qt/qml/plasma/applet/org/kde/plasma/volume/main.qml:102: TypeError: Cannot read property 'description' of undefined
mai 28 12:03:34 hal-systemproductname kded6[1444]: No object for name "@DEFAULT_SINK@"
mai 28 12:03:34 hal-systemproductname kded6[1444]: No object for name "@DEFAULT_SOURCE@"
mai 28 12:03:34 hal-systemproductname plasmashell[18000]: No object for name "@DEFAULT_SINK@"
mai 28 12:03:34 hal-systemproductname plasmashell[18000]: No object for name "@DEFAULT_SOURCE@"
mai 28 12:03:34 hal-systemproductname plasmashell[18000]: No object for name "@DEFAULT_SINK@"
mai 28 12:03:34 hal-systemproductname plasmashell[18000]: No object for name "@DEFAULT_SOURCE@"
mai 28 12:03:35 hal-systemproductname kded6[1444]: No object for name "@DEFAULT_SOURCE@"
mai 28 12:03:35 hal-systemproductname plasmashell[18000]: No object for name "@DEFAULT_SOURCE@"
mai 28 12:03:35 hal-systemproductname kded6[1444]: No object for name "auto_null"
mai 28 12:03:35 hal-systemproductname kded6[1444]: No object for name "@DEFAULT_SOURCE@"
mai 28 12:03:35 hal-systemproductname kded6[1444]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo"
mai 28 12:03:35 hal-systemproductname kded6[1444]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor"
mai 28 12:03:35 hal-systemproductname kded6[1444]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor"
mai 28 12:03:35 hal-systemproductname plasmashell[18000]: No object for name "auto_null"
mai 28 12:03:35 hal-systemproductname plasmashell[18000]: No object for name "@DEFAULT_SOURCE@"
mai 28 12:03:35 hal-systemproductname plasmashell[18000]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo"
mai 28 12:03:35 hal-systemproductname plasmashell[18000]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor"
mai 28 12:03:35 hal-systemproductname plasmashell[18000]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor"
mai 28 12:04:18 hal-systemproductname kded6[1444]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor"
mai 28 12:04:18 hal-systemproductname kded6[1444]: No object for name "bluez_input.0C:ED:E7:FF:AB:9D"
mai 28 12:04:18 hal-systemproductname plasmashell[18000]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor"
mai 28 12:04:18 hal-systemproductname plasmashell[18000]: No object for name "bluez_input.0C:ED:E7:FF:AB:9D"
mai 28 12:05:05 hal-systemproductname plasmashell[18000]: Final member StackingOrder is overridden in class QQmlDMAbstractItemModelData. The override won't be used.
mai 28 12:07:13 hal-systemproductname plasmashell[18000]: pa_ext_stream_restore_write failed
mai 28 12:11:08 hal-systemproductname kernel: umip_printk: 9 callbacks suppressed
mai 28 12:19:32 hal-systemproductname kernel: umip_printk: 11 callbacks suppressed
mai 28 12:21:58 hal-systemproductname kernel: umip_printk: 15 callbacks suppressed
mai 28 12:22:11 hal-systemproductname plasmashell[18000]: pa_ext_stream_restore_write failed
mai 28 12:22:11 hal-systemproductname kwin_wayland[1326]: XCB error: 3 (BadWindow), sequence: 15076, resource id: 98566237, major code: 129 (SHAPE), minor code: 6 (Input)
mai 28 12:24:04 hal-systemproductname systemd[1251]: app-plasmashell@50de621c981d47f2b183bd86feb01263.service: Main process exited, code=killed, status=14/ALRM
mai 28 12:24:04 hal-systemproductname systemd[1251]: app-plasmashell@50de621c981d47f2b183bd86feb01263.service: Failed with result 'signal'.
mai 28 12:24:05 hal-systemproductname plasmashell[21724]: Could not find required file "mainscript" for package "/usr/share/plasma/plasmoids/org.kde.plasma.icontasks/" should be QList("ui/main.qml")
mai 28 12:24:05 hal-systemproductname plasmashell[21724]: Member visible of the object PlasmaQuick::Dialog overrides a member of the base object. Consider renaming it or adding final or override specifier
mai 28 12:24:05 hal-systemproductname plasmashell[21724]: Member enabled of the object DeclarativeDropArea overrides a member of the base object. Consider renaming it or adding final or override specifier
mai 28 12:24:06 hal-systemproductname plasmashell[21724]: Entry is not valid "org.kde.kontact.desktop" 0x55febd723bb0
mai 28 12:24:06 hal-systemproductname plasmashell[21724]: Entry is not valid "org.kde.discover.desktop" 0x55febd723bb0
mai 28 12:24:06 hal-systemproductname plasmashell[21724]: Entry is not valid "org.kde.kontact.desktop" 0x55febd723bb0
mai 28 12:24:06 hal-systemproductname plasmashell[21724]: Entry is not valid "org.kde.discover.desktop" 0x55febd723bb0
mai 28 12:24:06 hal-systemproductname plasmashell[21724]: Final member StackingOrder is overridden in class QQmlDMAbstractItemModelData. The override won't be used.
mai 28 12:25:05 hal-systemproductname systemd[1251]: dbus-:1.2-org.kde.KSplash@4.service: Failed with result 'exit-code'.
mai 28 12:28:52 hal-systemproductname bluetoothd[19284]: src/profile.c:ext_io_disconnected() Unable to get io data for Hands-Free Voice gateway: getpeername: Transport endpoint is not connected (107)
mai 28 12:28:52 hal-systemproductname plasmashell[21724]: No object for name "bluez_input.0C:ED:E7:FF:AB:9D"
mai 28 12:28:52 hal-systemproductname kded6[1444]: No object for name "bluez_input.0C:ED:E7:FF:AB:9D"
mai 28 12:28:52 hal-systemproductname kded6[1444]: No object for name "bluez_output.0C_ED_E7_FF_AB_9D.1"
mai 28 12:28:52 hal-systemproductname kded6[1444]: No object for name "bluez_input.0C:ED:E7:FF:AB:9D"
mai 28 12:28:52 hal-systemproductname plasmashell[21724]: No object for name "bluez_output.0C_ED_E7_FF_AB_9D.1"
mai 28 12:28:52 hal-systemproductname plasmashell[21724]: No object for name "bluez_input.0C:ED:E7:FF:AB:9D"
mai 28 12:28:52 hal-systemproductname kded6[1444]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor"
mai 28 12:28:52 hal-systemproductname kded6[1444]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor"
mai 28 12:28:52 hal-systemproductname plasmashell[21724]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor"
mai 28 12:28:52 hal-systemproductname plasmashell[21724]: No object for name "alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor"

exit_code=0
```

## Falhas systemd

```bash

systemctl --failed --no-pager 2>/dev/null || true


  UNIT LOAD ACTIVE SUB DESCRIPTION

0 loaded units listed.

exit_code=0
```

## Resumo bruto

```bash

echo "Data: $(date -Is)"
echo "Kernel: $(uname -r)"
echo "Sistema: $(grep -E "^(NAME|VERSION|ID|PRETTY_NAME)=" /etc/os-release 2>/dev/null | tr "\n" " ")"
echo
echo "CPU governor único:"
for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor; do [ -r "$f" ] && cat "$f"; done | sort -u
echo
echo "Driver cpufreq único:"
for f in /sys/devices/system/cpu/cpu*/cpufreq/scaling_driver; do [ -r "$f" ] && cat "$f"; done | sort -u
echo
echo "NVIDIA:"
nvidia-smi --query-gpu=driver_version,name,pstate,power.draw,power.limit --format=csv,noheader 2>/dev/null || true
echo
echo "Swappiness: $(sysctl -n vm.swappiness 2>/dev/null || echo n/a)"
echo "VFS cache pressure: $(sysctl -n vm.vfs_cache_pressure 2>/dev/null || echo n/a)"
echo "Page cluster: $(sysctl -n vm.page-cluster 2>/dev/null || echo n/a)"
echo "Max map count: $(sysctl -n vm.max_map_count 2>/dev/null || echo n/a)"
echo "Autogroup: $(sysctl -n kernel.sched_autogroup_enabled 2>/dev/null || echo n/a)"
echo "THP enabled: $(cat /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null || echo n/a)"
echo "THP defrag: $(cat /sys/kernel/mm/transparent_hugepage/defrag 2>/dev/null || echo n/a)"
echo
echo "Swap:"
swapon --show 2>/dev/null || true
echo
echo "TuneD: $(systemctl is-active tuned.service 2>/dev/null || echo n/a) / $(command -v tuned-adm >/dev/null 2>&1 && tuned-adm active 2>/dev/null || echo sem-tuned)"
echo "GameMode: $(systemctl is-active gamemoded.service 2>/dev/null || echo n/a)"
echo "Power profiles: $(command -v powerprofilesctl >/dev/null 2>&1 && powerprofilesctl get 2>/dev/null || echo n/a)"
echo "Multilib habilitado:"
awk "/^\\[multilib\\]/{print \"sim\"; found=1} END{if(!found) print \"nao-ou-comentado\"}" /etc/pacman.conf 2>/dev/null


Data: 2026-05-28T12:30:48-03:00
Kernel: 7.0.10-arch1-1
Sistema: NAME="EndeavourOS" PRETTY_NAME="EndeavourOS" ID="endeavouros" 

CPU governor único:
powersave

Driver cpufreq único:
amd-pstate-epp

NVIDIA:
595.71.05, NVIDIA GeForce RTX 5060 Ti, P0, 16.26 W, 180.00 W

Swappiness: 60
VFS cache pressure: 100
Page cluster: 3
Max map count: 1048576
Autogroup: 1
THP enabled: [always] madvise never
THP defrag: always defer defer+madvise [madvise] never

Swap:
NAME           TYPE      SIZE USED PRIO
/dev/nvme0n1p3 partition  17G 1,9G   -1

TuneD: inactive
n/a / sem-tuned
GameMode: inactive
n/a
Power profiles: balanced
Multilib habilitado:
sim

exit_code=0
```
MOCHA ARCH — DIAGNÓSTICO COMPARATIVO PRELIMINAR — 20260528-123039

Sistema auditado: Endeavour/Arch KDE atual
Kernel: 7.0.10-arch1-1
NVIDIA: 595.71.05, NVIDIA GeForce RTX 5060 Ti
CPU governor: powersave 
CPU scaling driver: amd-pstate-epp 
Power profile: balanced
TuneD active: inactive
n/a
 tuned ausente
GameMode active: inactive
n/a
Multilib: sim
MangoHud: ausente ou parcial
GameMode pacotes: ausente ou parcial

Memória/sysctl:
  vm.swappiness=60
  vm.vfs_cache_pressure=100
  vm.page-cluster=3
  vm.max_map_count=1048576
  kernel.sched_autogroup_enabled=1
  kernel.nmi_watchdog=0
  zram devices=0
  THP enabled=[always] madvise never
  THP defrag=always defer defer+madvise [madvise] never

Leitura inicial para comparação:
- Kernel parece Arch padrão: tende a ser mais conservador que CachyOS/Garuda agressivo.
- TuneD não está ativo: pode explicar parte da diferença contra sistemas mais agressivos.
- Governor não parece performance/schedutil: possível perda de responsividade/FPS.
- power-profiles-daemon está em balanced: pode reduzir boost e resposta.
- ZRAM não detectado: Manjaro/CachyOS/Garuda podem estar levando vantagem se usam zram/zswap agressivo.
- sched_autogroup não está desativado; na receita Mocha canônica ele fica 0.
- vm.page-cluster não está 0; na receita Mocha canônica ele fica 0.
- vm.max_map_count difere da receita Mocha canônica velha/fallback: esperado 16777216.
- THP não está em madvise; comparar com a receita Mocha usada nos melhores testes.

Conclusão provisória:
- Este arquivo ainda não decide sozinho se Endeavour é pior que Manjaro.
- Ele separa os pontos comparáveis para bater contra Manjaro/CachyOS/Garuda/Bazzite/NixOS.
- O próximo passo é rodar auditoria equivalente no Manjaro ou colar o resumo deste relatório para análise linha a linha.

## Arquivos gerados

- Relatório completo: /media/mochafast/MochaArch/auditorias/auditoria-sistema-endeavour-kde-20260528-123039/RELATORIO-AUDITORIA-SISTEMA-20260528-123039.md
- Diagnóstico comparativo: /media/mochafast/MochaArch/auditorias/auditoria-sistema-endeavour-kde-20260528-123039/DIAGNOSTICO-COMPARATIVO-20260528-123039.txt
- Pacotes nativos: /media/mochafast/MochaArch/auditorias/auditoria-sistema-endeavour-kde-20260528-123039/pacman-pacotes-nativos-20260528-123039.txt
- Pacotes AUR/foreign: /media/mochafast/MochaArch/auditorias/auditoria-sistema-endeavour-kde-20260528-123039/pacman-pacotes-aur-foreign-20260528-123039.txt
- Serviços systemd: /media/mochafast/MochaArch/auditorias/auditoria-sistema-endeavour-kde-20260528-123039/systemd-servicos-20260528-123039.txt

