## Auditoria automática do estado atual

Gerada em: 20260529-154304

Esta auditoria registra o estado real no momento da criação do manual. Ela não altera o sistema.

### Kernel atual

```text
Linux Mocha 7.0.10-arch1-1 #1 SMP PREEMPT_DYNAMIC Sat, 23 May 2026 14:21:20 +0000 x86_64 GNU/Linux
```

### Driver NVIDIA

```text
Fri May 29 15:43:04 2026       
+-----------------------------------------------------------------------------------------+
| NVIDIA-SMI 595.71.05              Driver Version: 595.71.05      CUDA Version: 13.2     |
+-----------------------------------------+------------------------+----------------------+
| GPU  Name                 Persistence-M | Bus-Id          Disp.A | Volatile Uncorr. ECC |
| Fan  Temp   Perf          Pwr:Usage/Cap |           Memory-Usage | GPU-Util  Compute M. |
|                                         |                        |               MIG M. |
|=========================================+========================+======================|
|   0  NVIDIA GeForce RTX 5060 Ti     On  |   00000000:01:00.0  On |                  N/A |
|  0%   37C    P8             11W /  180W |     843MiB /  16311MiB |      1%      Default |
|                                         |                        |                  N/A |
+-----------------------------------------+------------------------+----------------------+

+-----------------------------------------------------------------------------------------+
| Processes:                                                                              |
|  GPU   GI   CI              PID   Type   Process name                        GPU Memory |
|        ID   ID                                                               Usage      |
|=========================================================================================|
|    0   N/A  N/A             891      G   /usr/bin/ksecretd                         2MiB |
|    0   N/A  N/A             956      G   /usr/bin/kwin_wayland                    30MiB |
|    0   N/A  N/A            1039      G   /usr/bin/Xwayland                         2MiB |
|    0   N/A  N/A            1079      G   /usr/bin/ksmserver                        2MiB |
|    0   N/A  N/A            1081      G   /usr/bin/kded6                            2MiB |
|    0   N/A  N/A            1192      G   /usr/bin/kaccess                          2MiB |
|    0   N/A  N/A            1193      G   ...it-kde-authentication-agent-1          2MiB |
|    0   N/A  N/A            1288      G   /usr/bin/kdeconnectd                      2MiB |
|    0   N/A  N/A            1319      G   /usr/lib/firefox/firefox                243MiB |
|    0   N/A  N/A            1487      G   /usr/bin/akonadi_control                  2MiB |
|    0   N/A  N/A            1679      G   ...bin/akonadi_archivemail_agent          2MiB |
|    0   N/A  N/A            1682      G   ...konadi_followupreminder_agent          2MiB |
|    0   N/A  N/A            1686      G   .../akonadi_maildispatcher_agent          2MiB |
|    0   N/A  N/A            1687      G   .../bin/akonadi_mailfilter_agent          2MiB |
|    0   N/A  N/A            1688      G   /usr/bin/akonadi_mailmerge_agent          2MiB |
|    0   N/A  N/A            1689      G   /usr/bin/akonadi_migration_agent          2MiB |
|    0   N/A  N/A            1690      G   ...akonadi_newmailnotifier_agent          2MiB |
|    0   N/A  N/A            1691      G   /usr/bin/akonadi_sendlater_agent          2MiB |
|    0   N/A  N/A            1692      G   .../akonadi_unifiedmailbox_agent          2MiB |
|    0   N/A  N/A            2033      G   /usr/lib/DiscoverNotifier                 2MiB |
|    0   N/A  N/A            2042      G   /usr/bin/kalendarac                       2MiB |
|    0   N/A  N/A            2093      G   /usr/lib/xdg-desktop-portal-kde           2MiB |
|    0   N/A  N/A            2469      G   ...share/Steam/ubuntu12_32/steam          4MiB |
|    0   N/A  N/A            2676      G   ./steamwebhelper                         23MiB |
|    0   N/A  N/A            2705    C+G   ...am/ubuntu12_64/steamwebhelper          5MiB |
|    0   N/A  N/A            3236      G   ...asma-browser-integration-host          2MiB |
|    0   N/A  N/A            4133      G   /usr/bin/kwalletd6                        2MiB |
|    0   N/A  N/A            8656      G   /usr/bin/konsole                          2MiB |
|    0   N/A  N/A            8813      G   /usr/bin/dolphin                          2MiB |
|    0   N/A  N/A            9032      G   /usr/bin/plasmashell                     71MiB |
+-----------------------------------------------------------------------------------------+
```

### Pacotes de kernel, NVIDIA, Vulkan e Steam relevantes

```text
egl-wayland2 1.0.1-1
egl-wayland 4:1.1.21-1
gamemode 1.8.2-2
lib32-gamemode 1.8.2-1
lib32-nvidia-utils 595.71.05-1
lib32-vulkan-icd-loader 1.4.350.0-1
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
mangohud 0.8.3-2
nvidia-open-dkms 595.71.05-2
nvidia-settings 595.71.05-1
nvidia-utils 595.71.05-2
opencl-nvidia 595.71.05-2
steam 1.0.0.85-7
steam-devices 1.0.0.85-7
vulkan-icd-loader 1.4.350.0-1
vulkan-tools 1.4.350.0-1
```

### Login manager / display manager

```text
● plasmalogin.service - Plasma Login Manager
     Loaded: loaded (/usr/lib/systemd/system/plasmalogin.service; enabled; preset: disabled)
     Active: active (running) since Fri 2026-05-29 14:29:45 -03; 1h 13min ago
 Invocation: 7c16afbe746f47008acd42cd1d5dbc36
       Docs: man:plasmalogin(1)
             man:plasmalogin.conf(5)
   Main PID: 683 (plasmalogin)
      Tasks: 2 (limit: 18662)
     Memory: 16.8M (peak: 39.4M, swap: 560K, swap peak: 560K, zswap: 112.7K)
        CPU: 106ms
     CGroup: /system.slice/plasmalogin.service
             └─683 /usr/bin/plasmalogin

mai 29 14:29:52 Mocha plasmalogin-helper[865]: [PAM] returning.
mai 29 14:29:52 Mocha plasmalogin[683]: Authentication for user  "hal"  successful
mai 29 14:29:52 Mocha plasmalogin-helper[865]: pam_kwallet5(plasmalogin:setcred): pam_kwallet5: pam_sm_setcred
mai 29 14:29:52 Mocha plasmalogin-helper[865]: pam_unix(plasmalogin:session): session opened for user hal(uid=1000) by hal(uid=0)
mai 29 14:29:52 Mocha plasmalogin-helper[865]: pam_kwallet5(plasmalogin:session): pam_kwallet5: pam_sm_open_session
mai 29 14:29:52 Mocha plasmalogin-helper[865]: Starting Wayland user session: "/usr/share/plasmalogin/scripts/wayland-session" "/usr/lib/plasma-dbus-run-session-if-needed /usr/bin/startplasma-wayland"
mai 29 14:29:52 Mocha plasmalogin[683]: Session started true
mai 29 14:29:57 Mocha plasmalogin[683]: Greeter stopping...
mai 29 14:29:57 Mocha plasmalogin[683]: Auth: plasmalogin-helper exited with 255
mai 29 14:29:57 Mocha plasmalogin[683]: Greeter stopped. PLASMALOGIN::Auth::HelperExitStatus(255)

--- display-manager.service aponta para ---
/usr/lib/systemd/system/plasmalogin.service

--- units conhecidas ---
display-manager.service                      alias           -
plasmalogin.service                          enabled         disabled
plymouth-halt.service                        static          -
plymouth-kexec.service                       static          -
plymouth-poweroff.service                    static          -
plymouth-quit-wait.service                   static          -
plymouth-quit.service                        static          -
plymouth-read-write.service                  static          -
plymouth-reboot.service                      static          -
plymouth-start.service                       static          -
plymouth-switch-root-initramfs.service       static          -
plymouth-switch-root.service                 static          -
sddm.service                                 disabled        disabled
systemd-ask-password-plymouth.service        static          -
systemd-tmpfiles-setup-dev-early.service     static          -
systemd-tpm2-setup-early.service             static          -
```

### Sessão gráfica

```text
XDG_SESSION_TYPE=wayland
XDG_CURRENT_DESKTOP=KDE
Name=hal
Desktop=KDE
Type=wayland
```

### Montagens obrigatórias FAST e VMSTORE

```text
/media/mochafast: MONTADO
TARGET           SOURCE    FSTYPE OPTIONS
/media/mochafast /dev/sda1 btrfs  rw,noatime,compress=zstd:3,ssd,discard=async,space_cache=v2,subvolid=5,subvol=/

/media/vmstore: MONTADO
TARGET         SOURCE    FSTYPE OPTIONS
/media/vmstore /dev/sdb1 xfs    rw,noatime,inode64,logbufs=8,logbsize=32k,noquota

--- /etc/fstab: entradas relevantes ---
17:UUID=88e6aa16-110c-4b97-9ffb-85084c000198 /media/mochafast btrfs defaults,noatime,compress=zstd:3,ssd,discard=async,nofail,x-systemd.device-timeout=10s 0 0
18:UUID=b81630a0-0756-45e4-9cb2-c7f16637a1c6 /media/vmstore xfs defaults,noatime,nofail,x-systemd.device-timeout=10s 0 2
```

### Energia, CPU, GPU e agressividade

```text
--- powerprofilesctl ---
powerprofilesctl não encontrado.

--- tuned ---
Current active profile: latency-performance
enabled
active

--- governor CPU ---
/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu1/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu2/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu3/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu4/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu5/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu6/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu7/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu8/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu9/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu10/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu11/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu12/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu13/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu14/cpufreq/scaling_governor:performance
/sys/devices/system/cpu/cpu15/cpufreq/scaling_governor:performance

--- NVIDIA power/persistence ---

==============NVSMI LOG==============

Timestamp                                              : Fri May 29 15:43:05 2026
Driver Version                                         : 595.71.05
CUDA Version                                           : 13.2

Attached GPUs                                          : 1
GPU 00000000:01:00.0
    GPU Power Readings
        Average Power Draw                             : 11.67 W
        Instantaneous Power Draw                       : 10.85 W
        Current Power Limit                            : 180.00 W
        Requested Power Limit                          : 180.00 W
        Default Power Limit                            : 180.00 W
        Min Power Limit                                : 150.00 W
        Max Power Limit                                : 180.00 W
    Power Samples
        Duration                                       : 2.36 sec
        Number of Samples                              : 119
        Max                                            : 16.48 W
        Min                                            : 10.43 W
        Avg                                            : 11.93 W
    GPU Memory Power Readings 
        Average Power Draw                             : N/A
        Instantaneous Power Draw                       : N/A
    Module Power Readings
        Average Power Draw                             : N/A
        Instantaneous Power Draw                       : N/A
        Current Power Limit                            : N/A
        Requested Power Limit                          : N/A
        Default Power Limit                            : N/A
        Min Power Limit                                : N/A
        Max Power Limit                                : N/A
    EDPp Multiplier                                    : N/A

disabled
inactive
```

### Correção Bluetooth e volume duplicados

```text
--- /home/hal/.config/autostart/blueman.desktop ---
[Desktop Entry]
Name[be]=Аплет Blueman
Name[da]=Blueman-panelprogram
Name[de]=Blueman Applet
Name[el]=Εφαρμογή blueman
Name[en_GB]=Blueman Applet
Name[es]=Miniaplicación Blueman
Name[et]=Blueman rakend
Name[eu]=Blueman trepeta
Name[fi]=Blueman-sovelma
Name[fr]=Applet Blueman
Name[ga]=Feidhmchláirín Blueman
Name[he]=יישומון Blueman
Name[hr]=Blueman aplet
Name[hu]=Blueman kisalkalmazás
Name[is]=Blueman-smáforrit
Name[it]=Blueman Applet
Name[ja]=Bluetooth アプレット
Name[ko]=Blueman 애플릿
Name[mr]=ब्लूमॅन ॲपलेट
Name[ms]=Aplet Blueman
Name[nb]=Blueman-panelprogram
Name[nl]=Blueman-werkbalkhulpje
Name[pl]=Aplet Blueman
Name[pt_BR]=Miniaplicativo Blueman
Name[pt]=Applet Blueman
Name[ro]=Miniaplicație Blueman
Name[ru]=Апплет Blueman
Name[sk]=Aplet bluetooth
Name[sl]=Blueman Applet
Name[sv]=Blueman panelprogram
Name[ta]=ப்ளூமேன் ஆப்லெட்
Name[tr]=Blueman Uygulaması
Name[uk]=Аплет Blueman
Name[zh_CN]=Blueman 小程序
Name[zh_TW]=Blueman 小程式
Name[oc]=Applet Blueman
Name=Blueman Applet
Comment[ast]=Alministrador Bluetooth Blueman
Comment[be]=Blueman - кіраўнік Bluetooth
Comment[ca]=Gestor de Bluetooth Blueman
Comment[da]=Blueman Bluetooth-håndtering
Comment[de]=Blueman Bluetooth Manager
Comment[el]=Διαχειριστής bluetooth του blueman
Comment[en_GB]=Blueman Bluetooth Manager
Comment[es]=Gestor de conexiones Bluetooth Blueman
Comment[et]=Bluetoothi haldur Blueman
Comment[eu]=Blueman Bluetooth kudeatzailea
Comment[fi]=Blueman bluetooth-hallinta
Comment[fr]=Gestionnaire Bluetooth Blueman
Comment[ga]=Bainisteoir Bluetooth Blueman
Comment[he]=Blueman - מנהל בלוטות׳
Comment[hr]=Blueman Bluetooth upravitelj
Comment[hu]=Blueman Bluetooth-kezelő
Comment[is]=Blueman Bluetooth-umsýsla
Comment[it]=Blueman Gestore Bluetooth
Comment[ja]=Blueman Bluetooth マネージャー
Comment[ko]=Blueman 블루투스 관리자
Comment[lt]=Blueman „Bluetooth“ tvarkytuvė
Comment[nb]=Blueman Blåtannsbehandler

--- /home/hal/.config/autostart/kmix_autostart.desktop ---
[Desktop Entry]
Exec=kmix --keepvisibility
X-DocPath=kmix/index.html
OnlyShowIn=KDE;
Type=Application
X-KDE-autostart-after=panel
X-KDE-autostart-after=pulseaudio
X-KDE-StartupNotify=false
X-DBUS-StartupType=Unique
X-KDE-autostart-condition=kmixrc:Global:AutoStart:true
Icon=kmix
GenericName=Sound Mixer
GenericName[ar]=مازج الصوت
GenericName[bg]=Звуков миксер
GenericName[bs]=Mikser zvuka
GenericName[ca]=Mesclador de so
GenericName[ca@valencia]=Mesclador de so
GenericName[cs]=Směšovač zvuku
GenericName[da]=Lydmikser
GenericName[de]=Lautstärkeregler
GenericName[el]=Μείκτης ήχου
GenericName[en_GB]=Sound Mixer
GenericName[eo]=Sonmiksilo
GenericName[es]=Mezclador de sonido
GenericName[et]=Helimikser
GenericName[eu]=Soinua nahaslea
GenericName[fi]=Äänimikseri
GenericName[fr]=Console de mixage
GenericName[ga]=Meascthóir Fuaime
GenericName[gl]=Mesturador de son
GenericName[he]=מערבל שמע
GenericName[hu]=Hangkeverő
GenericName[ia]=Miscitor de sono
GenericName[id]=Mixer Suara
GenericName[is]=Hljóðblandari
GenericName[it]=Mixer audio
GenericName[ja]=サウンドミキサー
GenericName[ka]=ხმის მიქსერი
GenericName[kk]=Дыбыс микшері
GenericName[km]=កម្មវិធី​លាយ​សំលេង
GenericName[ko]=소리 믹서
GenericName[lt]=Garsų maišiklis
GenericName[lv]=Skaņas mikseris
GenericName[mr]=आवाज मिक्सर
GenericName[nb]=Lydmikser
GenericName[nds]=Klangmischer
GenericName[nl]=Geluidsmixer
GenericName[nn]=Lydmiksar
GenericName[pa]=ਸਾਊਡ ਮਿਕਸਰ
GenericName[pl]=Mikser dźwięku
GenericName[pt]=Mistura de Áudio
GenericName[pt_BR]=Mixer de som
GenericName[ro]=Mixer de sunet
GenericName[ru]=Звуковой микшер
GenericName[sa]=ध्वनिमिश्रकः
GenericName[se]=Jietnamixer
GenericName[sk]=Zvukový mixér
GenericName[sl]=Mešalnik zvoka
GenericName[sr]=Звучна миксета
GenericName[sr@ijekavian]=Звучна миксета

--- /etc/skel/.config/autostart/blueman.desktop ---
[Desktop Entry]
Type=Application
Name=blueman.desktop
Comment=Mocha KDE: disabled because KDE/Bluedevil already provides Bluetooth in the system tray
Exec=blueman-applet
OnlyShowIn=KDE;
Hidden=true

--- /etc/skel/.config/autostart/kmix_autostart.desktop ---
[Desktop Entry]
Type=Application
Name=kmix_autostart.desktop
Comment=Mocha KDE: disabled because Plasma volume applet already provides volume control in the system tray
Exec=kmix --keepvisibility
OnlyShowIn=KDE;
Hidden=true

```

### Barra Win11/Mocha aprovada

```text
2026-05-28 22:54  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
2026-05-28 22:56  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt
2026-05-29 15:33  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh

--- assinaturas do appletsrc aprovado ---
30:plugin=org.kde.plasma.digitalclock
45:plugin=org.kde.plasma.kickoff
63:plugin=org.kde.plasma.icontasks
78:plugin=org.kde.plasma.systemtray
155:AppletOrder=4;6;23;3;5;24;7;21;22
163:plugin=org.kde.plasma.panelspacer
166:expanding=true
170:plugin=org.kde.plasma.panelspacer
173:expanding=true
```

### Scripts e documentos principais no ativo

```text
2026-05-28 22:56  1159 bytes  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt
2026-05-29 15:01  1754 bytes  /media/mochafast/MochaArch/ativo/documentacao/20260529-150104-login-plasma-manager-esquema-aprovado.md
2026-05-29 15:01  2068 bytes  /media/mochafast/MochaArch/ativo/scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh
2026-05-29 15:01  2068 bytes  /media/mochafast/MochaArch/ativo/scripts/mocha-aplicar-login-plasma-manager.sh
2026-05-29 15:24  10321 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/resumo-auditoria.txt
2026-05-29 15:24  1070 bytes  /media/mochafast/MochaArch/ativo/documentacao/20260529-152416-baseline-superior-endeavour-steam-overlay-kde.md
2026-05-29 15:24  4616 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/plasma-applets-volume-bluetooth-systemtray.txt
2026-05-29 15:24  624 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/LEIA-ME.txt
2026-05-29 15:25  3401 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152529-corrigir-blueman-auditar-volume/execucao.log
2026-05-29 15:27  1108 bytes  /media/mochafast/MochaArch/ativo/scripts/20260529-152700-mocha-desativar-kmix-volume-duplicado.sh
2026-05-29 15:27  1389 bytes  /media/mochafast/MochaArch/ativo/documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md
2026-05-29 15:27  7077 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log
2026-05-29 15:29  1624 bytes  /media/mochafast/MochaArch/ativo/documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md
2026-05-29 15:29  1624 bytes  /media/mochafast/MochaArch/ativo/passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md
2026-05-29 15:29  2541 bytes  /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh
2026-05-29 15:29  3810 bytes  /media/mochafast/MochaArch/ativo/auditorias/20260529-152907-canonizar-barra-sem-duplicidade/execucao.log
2026-05-29 15:30  3891 bytes  /media/mochafast/MochaArch/ativo/logs/20260529-153031-aplicar-barra-kde-mocha-aprovada.log
2026-05-29 15:32  824 bytes  /media/mochafast/MochaArch/ativo/logs/20260529-153249-aplicar-barra-win11-aprovada-pasta-certa.log
2026-05-29 15:33  2039 bytes  /media/mochafast/MochaArch/ativo/logs/20260529-153335-aplicar-appletsrc-barra-win11-aprovada.log
2026-05-29 15:33  2985 bytes  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh
2026-05-29 15:33  835 bytes  /media/mochafast/MochaArch/ativo/logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log
2026-05-29 15:43  17941 bytes  /media/mochafast/MochaArch/ativo/logs/20260529-154304-auditoria-estado-atual-para-manual.md
2026-05-29 15:43  203 bytes  /media/mochafast/MochaArch/ativo/logs/20260529-154304-criar-manual-vivo-definitivo-mocha-arch-kde.log
```

