# MochaArch — estado kernel/NVIDIA

Data: 2026-06-07 15:34:08 -03

## Estado confirmado

- Kernel em execução: 7.0.11-1-cachyos
- Kernel Mocha/CachyOS esperado: 7.0.11-1-cachyos
- Driver NVIDIA em execução: 610.43.02
- Repositório CachyOS ativo no cliente: não
- Driver usado no sistema: nvidia-open-dkms
- Ação recomendada: não instalar nada agora; testar jogos no estado atual

## Pacotes instalados

linux 7.0.11.arch1-1
linux-headers 7.0.11.arch1-1
linux-cachyos 7.0.11-1
linux-cachyos-headers 7.0.11-1
nvidia-utils 610.43.02-2
lib32-nvidia-utils 610.43.02-1
nvidia-open-dkms 610.43.02-2

## Repositórios ativos

9:[options]
77:[core]
83:[extra]
92:[multilib]

## NVIDIA

Sun Jun  7 15:34:09 2026       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 610.43.02              KMD Version: 610.43.02     CUDA UMD Version: 13.3     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 5060 Ti     Off |   00000000:01:00.0  On |                  N/A |
|  0%   36C    P8             10W /  180W |     947MiB /  16311MiB |      0%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A             957      G   /usr/bin/ksecretd                         2MiB |
|    0   N/A  N/A            1027      G   /usr/bin/kwin_wayland                    20MiB |
|    0   N/A  N/A            1114      G   /usr/bin/Xwayland                         2MiB |
|    0   N/A  N/A            1151      G   /usr/bin/ksmserver                        2MiB |
|    0   N/A  N/A            1153      G   /usr/bin/kded6                            2MiB |
|    0   N/A  N/A            1226      G   /usr/bin/kaccess                          2MiB |
|    0   N/A  N/A            1237      G   ...it-kde-authentication-agent-1          2MiB |
|    0   N/A  N/A            1366      G   /usr/bin/kdeconnectd                      2MiB |
|    0   N/A  N/A            1496      G   /usr/lib/xdg-desktop-portal-kde           2MiB |
|    0   N/A  N/A            1508      G   /usr/lib/firefox/firefox                331MiB |
|    0   N/A  N/A            2029      G   ...asma-browser-integration-host          2MiB |
|    0   N/A  N/A            4402      G   ...lib/drkonqi-coredump-launcher          2MiB |
|    0   N/A  N/A           32556      G   /usr/bin/plasmashell                    104MiB |
|    0   N/A  N/A           32868      G   /usr/bin/dolphin                          2MiB |
|    0   N/A  N/A           33630      G   ...share/Steam/ubuntu12_32/steam          4MiB |
|    0   N/A  N/A           33829      G   ./steamwebhelper                         22MiB |
|    0   N/A  N/A           33864    C+G   ...am/ubuntu12_64/steamwebhelper          5MiB |
|    0   N/A  N/A           35927      G   /usr/bin/konsole                          2MiB |
+-----------------------------------------------------------------------------------------+

## GRUB

3:GRUB_DEFAULT=0
66:GRUB_SAVEDEFAULT=false
