## Evidências extraídas dos documentos, scripts e logs do MochaArch

Estas evidências foram extraídas automaticamente de `documentacao`, `scripts`, `logs` e `kde`, ignorando `backups`, `quarentena` e caminhos com `XU`.

### Driver de vídeo NVIDIA

#### Fonte: `logs/20260529-154304-auditoria-estado-atual-para-manual.md`

Pontuação de relevância: 6

Linhas aproximadas 3-42:

```text
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
```

Linhas aproximadas 57-103:

```text
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

```

#### Fonte: `auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/resumo-auditoria.txt`

Pontuação de relevância: 2

Linhas aproximadas 38-75:

```text
linux 7.0.10.arch1-1
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
pipewire 1:1.6.6-1
pipewire-session-manager 1:1.6.6-1
plasma5support 6.6.5-1
plasma-activities 6.6.5-1
plasma-activities-stats 6.6.5-1
plasma-browser-integration 6.6.5-1
plasma-camera 26.04.1-1
plasma-desktop 6.6.5-1
plasma-disks 6.6.5-1
plasma-firewall 6.6.5-1
plasma-integration 6.6.5-2
plasma-keyboard 6.6.5-1
plasma-login-manager 6.6.5-1
plasma-nm 6.6.5-1
plasma-pa 6.6.5-1
plasma-sdk 6.6.5-1
plasma-systemmonitor 6.6.5-1
plasma-thunderbolt 6.6.5-1
```

#### Fonte: `passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md`

Pontuação de relevância: 1

Linhas aproximadas 46-68:

```text
## Regra canônica

Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md`

Pontuação de relevância: 1

Linhas aproximadas 46-68:

```text
## Regra canônica

Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md`

Pontuação de relevância: 1

Linhas aproximadas 33-61:

```text
e encerrado o processo:

`kmix`

## O que não foi alterado

- Nenhum pacote foi removido.
- PipeWire não foi alterado.
- PulseAudio não foi alterado.
- Plasma volume applet foi preservado.
- Kernel, NVIDIA, Steam, MangoHud, GameMode e ajustes de performance não foram alterados.
- Bluetooth funcional foi preservado.
- O override anterior do Blueman foi preservado.

## Resultado esperado

- Ficar apenas um controle de volume na barra.
- Ficar apenas o Bluetooth do KDE/Bluedevil na barra.
- Desempenho e conectividade permanecem intactos.

## Reversão manual, se algum dia for necessário

Remover o override local:

```bash
rm -f "/home/hal/.config/autostart/kmix_autostart.desktop"
```

Depois encerrar sessão e entrar de novo.
```

#### Fonte: `documentacao/20260529-152416-baseline-superior-endeavour-steam-overlay-kde.md`

Pontuação de relevância: 1

Linhas aproximadas 20-30:

```text

## Decisão operacional

Este estado deve ser tratado como baseline positivo atual antes de qualquer alteração visual ou de painel.

Próximo passo seguro:

1. Auditar a configuração real do Plasma/KDE.
2. Identificar se a duplicidade vem de applets independentes, system tray, serviços auxiliares ou widgets fixados.
3. Corrigir somente o item duplicado identificado.
4. Não mexer em kernel, driver NVIDIA, Steam, agressividade/performance, Bluetooth funcional ou baseline de desempenho.
```

#### Fonte: `kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt`

Pontuação de relevância: 1

Linhas aproximadas 20-30:

```text
- Snapshot aprovado:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
- Script reutilizável:
  /media/mochafast/MochaArch/scripts/mocha-kde-barra-win11-aprovada-20260528-225617.sh
- Log desta gravação:
  /home/hal/mocha-salvar-barra-win11-aprovada-20260528-225617.log

Observação:
- Não depende de X11.
- Não instala pacotes.
- Não mexe em kernel, NVIDIA, boot, Steam ou receita de performance.
```

### Kernel/base funcional

#### Fonte: `logs/20260529-154304-auditoria-estado-atual-para-manual.md`

Pontuação de relevância: 2

Linhas aproximadas 1-25:

```text
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
```

Linhas aproximadas 57-85:

```text
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
```

Linhas aproximadas 131-159:

```text

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
```

#### Fonte: `kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt`

Pontuação de relevância: 2

Linhas aproximadas 20-30:

```text
- Snapshot aprovado:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
- Script reutilizável:
  /media/mochafast/MochaArch/scripts/mocha-kde-barra-win11-aprovada-20260528-225617.sh
- Log desta gravação:
  /home/hal/mocha-salvar-barra-win11-aprovada-20260528-225617.log

Observação:
- Não depende de X11.
- Não instala pacotes.
- Não mexe em kernel, NVIDIA, boot, Steam ou receita de performance.
```

#### Fonte: `passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md`

Pontuação de relevância: 1

Linhas aproximadas 46-68:

```text
## Regra canônica

Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md`

Pontuação de relevância: 1

Linhas aproximadas 46-68:

```text
## Regra canônica

Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md`

Pontuação de relevância: 1

Linhas aproximadas 33-61:

```text
e encerrado o processo:

`kmix`

## O que não foi alterado

- Nenhum pacote foi removido.
- PipeWire não foi alterado.
- PulseAudio não foi alterado.
- Plasma volume applet foi preservado.
- Kernel, NVIDIA, Steam, MangoHud, GameMode e ajustes de performance não foram alterados.
- Bluetooth funcional foi preservado.
- O override anterior do Blueman foi preservado.

## Resultado esperado

- Ficar apenas um controle de volume na barra.
- Ficar apenas o Bluetooth do KDE/Bluedevil na barra.
- Desempenho e conectividade permanecem intactos.

## Reversão manual, se algum dia for necessário

Remover o override local:

```bash
rm -f "/home/hal/.config/autostart/kmix_autostart.desktop"
```

Depois encerrar sessão e entrar de novo.
```

#### Fonte: `auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/resumo-auditoria.txt`

Pontuação de relevância: 1

Linhas aproximadas 1-22:

```text
### DATA
sex 29 mai 2026 15:24:16 -03

### KERNEL
Linux Mocha 7.0.10-arch1-1 #1 SMP PREEMPT_DYNAMIC Sat, 23 May 2026 14:21:20 +0000 x86_64 GNU/Linux

### PACOTES RELEVANTES
bluedevil 1:6.6.5-1
bluez 5.86-6
bluez-libs 5.86-6
bluez-qt 6.26.0-1
bluez-tools 0.2.0-6
gamemode 1.8.2-2
kdebugsettings 26.04.1-1
kdeclarative 6.26.0-1
kde-cli-tools 6.6.5-1
kdeconnect 26.04.1-1
kdecoration 6.6.5-1
kded 6.26.0-1
kde-dev-scripts 26.04.1-1
kde-dev-utils 26.04.1-1
kdeedu-data 26.04.1-1
```

#### Fonte: `documentacao/20260529-152416-baseline-superior-endeavour-steam-overlay-kde.md`

Pontuação de relevância: 1

Linhas aproximadas 20-30:

```text

## Decisão operacional

Este estado deve ser tratado como baseline positivo atual antes de qualquer alteração visual ou de painel.

Próximo passo seguro:

1. Auditar a configuração real do Plasma/KDE.
2. Identificar se a duplicidade vem de applets independentes, system tray, serviços auxiliares ou widgets fixados.
3. Corrigir somente o item duplicado identificado.
4. Não mexer em kernel, driver NVIDIA, Steam, agressividade/performance, Bluetooth funcional ou baseline de desempenho.
```

#### Fonte: `scripts/mocha-aplicar-login-plasma-manager.sh`

Pontuação de relevância: 1

Linhas aproximadas 2-30:

```bash
set -Eeuo pipefail

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

SUDO="/run/wrappers/bin/sudo"
[[ -x "$SUDO" ]] || SUDO="$(command -v sudo)"

echo "== MOCHA ARCH — aplicar login Plasma Manager =="
echo "Modo: troca display manager para plasma-login.service se existir."
echo "Não remove pacotes. Não toca XU. Não altera bootloader. Não configura X11."
echo

echo "== Auditoria antes da alteração =="
echo "-- display-manager.service --"
systemctl status display-manager.service --no-pager || true
echo
echo "-- estados relevantes --"
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || echo "plasma-login enabled: indisponível"
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || echo "plasma-login active: indisponível"
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || echo "sddm enabled: indisponível"
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || echo "sddm active: indisponível"
echo

if ! systemctl list-unit-files --no-pager | awk '{print $1}' | grep -qx 'plasma-login.service'; then
  echo "ERRO: plasma-login.service não existe neste sistema."
  echo "Abortando sem alterar nada."
  exit 1
fi
```

#### Fonte: `scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh`

Pontuação de relevância: 1

Linhas aproximadas 2-30:

```bash
set -Eeuo pipefail

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

SUDO="/run/wrappers/bin/sudo"
[[ -x "$SUDO" ]] || SUDO="$(command -v sudo)"

echo "== MOCHA ARCH — aplicar login Plasma Manager =="
echo "Modo: troca display manager para plasma-login.service se existir."
echo "Não remove pacotes. Não toca XU. Não altera bootloader. Não configura X11."
echo

echo "== Auditoria antes da alteração =="
echo "-- display-manager.service --"
systemctl status display-manager.service --no-pager || true
echo
echo "-- estados relevantes --"
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || echo "plasma-login enabled: indisponível"
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || echo "plasma-login active: indisponível"
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || echo "sddm enabled: indisponível"
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || echo "sddm active: indisponível"
echo

if ! systemctl list-unit-files --no-pager | awk '{print $1}' | grep -qx 'plasma-login.service'; then
  echo "ERRO: plasma-login.service não existe neste sistema."
  echo "Abortando sem alterar nada."
  exit 1
fi
```

#### Fonte: `documentacao/20260529-150104-login-plasma-manager-esquema-aprovado.md`

Pontuação de relevância: 1

Linhas aproximadas 1-41:

```text
# Mocha Arch — esquema de login aprovado

Registro gerado em: `20260529-150104`

## Mounts persistentes corrigidos

- FAST: `UUID=88e6aa16-110c-4b97-9ffb-85084c000198` em `/media/mochafast`, tipo `btrfs`, label `MOCHAFAST`
- VMSTORE: `UUID=b81630a0-0756-45e4-9cb2-c7f16637a1c6` em `/media/vmstore`, tipo `xfs`, label `vmstore`
- O script não formatou, não particionou, não removeu pacote, não alterou bootloader e não mexeu em XU.
- No `/etc/fstab`, foram substituídas somente entradas cujo mountpoint era exatamente `/media/mochafast` ou `/media/vmstore`.

## Estado aprovado observado do login

- Gerenciador de login desejado para esta fase: `plasma-login.service`
- Sessão alvo: KDE Plasma em Wayland
- X11 não é fallback neste projeto, salvo ordem explícita posterior.
- Link atual de `display-manager.service`: `/usr/lib/systemd/system/plasmalogin.service`
- Unidade carregada pelo systemd: `/usr/lib/systemd/system/plasmalogin.service`
- Estado de `plasma-login.service`: enabled=`not-found`, active=`inactive`
- Estado de `sddm.service`: enabled=`disabled`, active=`inactive`
- Sessão atual detectada: Type=`wayland`, Desktop=`KDE`

## Regra operacional

1. Usar `plasma-login.service` como display manager quando disponível.
2. Desabilitar `sddm.service` para evitar conflito com login manager antigo.
3. Não usar X11/Xorg como fallback.
4. Não remover pacotes.
5. Não tocar na pasta XU.
6. Não apagar entradas de boot.
7. Antes de editar configuração, auditar o estado real.

## Script salvo

Script reutilizável:

`/media/mochafast/MochaArch/ativo/scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh`

Atalho estável atualizado:

`/media/mochafast/MochaArch/ativo/scripts/mocha-aplicar-login-plasma-manager.sh`
```

### Login manager / Wayland

#### Fonte: `logs/20260529-154304-auditoria-estado-atual-para-manual.md`

Pontuação de relevância: 6

Linhas aproximadas 25-54:

```text
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
```

Linhas aproximadas 60-127:

```text
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
```

#### Fonte: `documentacao/20260529-150104-login-plasma-manager-esquema-aprovado.md`

Pontuação de relevância: 6

Linhas aproximadas 4-41:

```text

## Mounts persistentes corrigidos

- FAST: `UUID=88e6aa16-110c-4b97-9ffb-85084c000198` em `/media/mochafast`, tipo `btrfs`, label `MOCHAFAST`
- VMSTORE: `UUID=b81630a0-0756-45e4-9cb2-c7f16637a1c6` em `/media/vmstore`, tipo `xfs`, label `vmstore`
- O script não formatou, não particionou, não removeu pacote, não alterou bootloader e não mexeu em XU.
- No `/etc/fstab`, foram substituídas somente entradas cujo mountpoint era exatamente `/media/mochafast` ou `/media/vmstore`.

## Estado aprovado observado do login

- Gerenciador de login desejado para esta fase: `plasma-login.service`
- Sessão alvo: KDE Plasma em Wayland
- X11 não é fallback neste projeto, salvo ordem explícita posterior.
- Link atual de `display-manager.service`: `/usr/lib/systemd/system/plasmalogin.service`
- Unidade carregada pelo systemd: `/usr/lib/systemd/system/plasmalogin.service`
- Estado de `plasma-login.service`: enabled=`not-found`, active=`inactive`
- Estado de `sddm.service`: enabled=`disabled`, active=`inactive`
- Sessão atual detectada: Type=`wayland`, Desktop=`KDE`

## Regra operacional

1. Usar `plasma-login.service` como display manager quando disponível.
2. Desabilitar `sddm.service` para evitar conflito com login manager antigo.
3. Não usar X11/Xorg como fallback.
4. Não remover pacotes.
5. Não tocar na pasta XU.
6. Não apagar entradas de boot.
7. Antes de editar configuração, auditar o estado real.

## Script salvo

Script reutilizável:

`/media/mochafast/MochaArch/ativo/scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh`

Atalho estável atualizado:

`/media/mochafast/MochaArch/ativo/scripts/mocha-aplicar-login-plasma-manager.sh`
```

#### Fonte: `scripts/mocha-aplicar-login-plasma-manager.sh`

Pontuação de relevância: 3

Linhas aproximadas 1-44:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

SUDO="/run/wrappers/bin/sudo"
[[ -x "$SUDO" ]] || SUDO="$(command -v sudo)"

echo "== MOCHA ARCH — aplicar login Plasma Manager =="
echo "Modo: troca display manager para plasma-login.service se existir."
echo "Não remove pacotes. Não toca XU. Não altera bootloader. Não configura X11."
echo

echo "== Auditoria antes da alteração =="
echo "-- display-manager.service --"
systemctl status display-manager.service --no-pager || true
echo
echo "-- estados relevantes --"
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || echo "plasma-login enabled: indisponível"
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || echo "plasma-login active: indisponível"
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || echo "sddm enabled: indisponível"
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || echo "sddm active: indisponível"
echo

if ! systemctl list-unit-files --no-pager | awk '{print $1}' | grep -qx 'plasma-login.service'; then
  echo "ERRO: plasma-login.service não existe neste sistema."
  echo "Abortando sem alterar nada."
  exit 1
fi

echo "== Aplicando esquema aprovado =="
"$SUDO" systemctl disable --now sddm.service 2>/dev/null || true
"$SUDO" systemctl enable plasma-login.service
"$SUDO" systemctl set-default graphical.target

echo
echo "== Verificação depois da alteração =="
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || true
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || true
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || true
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || true
echo
echo "Concluído. Reinicie apenas quando quiser testar o login pelo plasma-login."
```

#### Fonte: `scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh`

Pontuação de relevância: 3

Linhas aproximadas 1-44:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

SUDO="/run/wrappers/bin/sudo"
[[ -x "$SUDO" ]] || SUDO="$(command -v sudo)"

echo "== MOCHA ARCH — aplicar login Plasma Manager =="
echo "Modo: troca display manager para plasma-login.service se existir."
echo "Não remove pacotes. Não toca XU. Não altera bootloader. Não configura X11."
echo

echo "== Auditoria antes da alteração =="
echo "-- display-manager.service --"
systemctl status display-manager.service --no-pager || true
echo
echo "-- estados relevantes --"
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || echo "plasma-login enabled: indisponível"
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || echo "plasma-login active: indisponível"
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || echo "sddm enabled: indisponível"
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || echo "sddm active: indisponível"
echo

if ! systemctl list-unit-files --no-pager | awk '{print $1}' | grep -qx 'plasma-login.service'; then
  echo "ERRO: plasma-login.service não existe neste sistema."
  echo "Abortando sem alterar nada."
  exit 1
fi

echo "== Aplicando esquema aprovado =="
"$SUDO" systemctl disable --now sddm.service 2>/dev/null || true
"$SUDO" systemctl enable plasma-login.service
"$SUDO" systemctl set-default graphical.target

echo
echo "== Verificação depois da alteração =="
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || true
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || true
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || true
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || true
echo
echo "Concluído. Reinicie apenas quando quiser testar o login pelo plasma-login."
```

#### Fonte: `auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/resumo-auditoria.txt`

Pontuação de relevância: 2

Linhas aproximadas 60-88:

```text
plasma5support 6.6.5-1
plasma-activities 6.6.5-1
plasma-activities-stats 6.6.5-1
plasma-browser-integration 6.6.5-1
plasma-camera 26.04.1-1
plasma-desktop 6.6.5-1
plasma-disks 6.6.5-1
plasma-firewall 6.6.5-1
plasma-integration 6.6.5-2
plasma-keyboard 6.6.5-1
plasma-login-manager 6.6.5-1
plasma-nm 6.6.5-1
plasma-pa 6.6.5-1
plasma-sdk 6.6.5-1
plasma-systemmonitor 6.6.5-1
plasma-thunderbolt 6.6.5-1
plasmatube 26.04.1-2
plasma-vault 6.6.5-1
plasma-welcome 6.6.5-1
plasma-workspace 6.6.5-2
plasma-workspace-wallpapers 6.6.5-1
steam 1.0.0.85-7
steam-devices 1.0.0.85-7
wireplumber 0.5.14-1

### SERVIÇOS DO SISTEMA RELACIONADOS
● bluetooth.service - Bluetooth service
     Loaded: loaded (/usr/lib/systemd/system/bluetooth.service; enabled; preset: disabled)
     Active: active (running) since Fri 2026-05-29 14:29:45 -03; 54min ago
```

Linhas aproximadas 114-182:

```text
sys-subsystem-bluetooth-devices-hci0:1.device                                                                           loaded active plugged   /sys/subsystem/bluetooth/devices/hci0:1
app-blueman@autostart.service                                                                                           loaded active running   Blueman Applet
app-org.kde.bluedevilwizard@2c6d514fa32d417ea2e56bae877bd717.service                                                    loaded failed failed    Adicionar dispositivo Bluetooth - Adicionar dispositivo Bluetooth
app-pulseaudio@autostart.service                                                                                        loaded failed failed    PulseAudio Sound System
pipewire.service                                                                                                        loaded active running   PipeWire Multimedia Service
plasma-gmenudbusmenuproxy.service                                                                                       loaded active running   Proxies GTK DBus menus to a Plasma readable format
plasma-kaccess.service                                                                                                  loaded active running   KAccess
plasma-kactivitymanagerd.service                                                                                        loaded active running   KActivityManager Activity manager Service
plasma-kded6.service                                                                                                    loaded active running   KDE Daemon 6
plasma-ksmserver.service                                                                                                loaded active running   KDE Session Management Server
plasma-kwin_wayland.service                                                                                             loaded active running   KDE Wayland Compositor
plasma-plasmashell.service                                                                                              loaded active running   KDE Plasma Workspace
plasma-polkit-agent.service                                                                                             loaded active running   KDE PolicyKit Authentication Agent
plasma-powerdevil.service                                                                                               loaded active running   Powerdevil
plasma-xdg-desktop-portal-kde.service                                                                                   loaded active running   Xdg Desktop Portal For KDE
plasma-xembedsniproxy.service                                                                                           loaded active running   Handle legacy xembed system tray icons
pulseaudio.service                                                                                                      loaded active running   Sound Service
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth
plasma-core.target                                                                                                      loaded active active    KDE Plasma Workspace Core
plasma-workspace-wayland.target                                                                                         loaded active active    plasma-workspace-wayland.target
plasma-workspace.target                                                                                                 loaded active active    KDE Plasma Workspace

### ÁUDIO
String do servidor: /run/user/1000/pulse/native
Versão do protocolo da biblioteca: 35
Versão do protocolo do servidor: 35
É local: sim
Índice do cliente: 39
Tamanho de fragmento: 65472
Nome do usuário: hal
Nome da máquina: Mocha
Nome do servidor: pulseaudio
Versão do servidor: 17.0-98-gb096
Especificação padrão de amostragem: s16le 2ch 44100Hz
Mapa de canais padrão: front-left,front-right
Destino padrão: bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink
Fonte padrão: bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink.monitor
Cookie: ed82:a34c

2	alsa_output.pci-0000_01_00.1.hdmi-stereo	module-alsa-card.c	s16le 2ch 44100Hz	SUSPENDED
3	bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink	module-bluez5-device.c	s16le 2ch 44100Hz	SUSPENDED

2	alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor	module-alsa-card.c	s16le 2ch 44100Hz	SUSPENDED
3	bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink.monitor	module-bluez5-device.c	s16le 2ch 44100Hz	SUSPENDED

PipeWire 'pipewire-0' [1.6.6, hal@Mocha, cookie:1187326163]
 └─ Clients:
        32. kwin_wayland                        [1.6.6, hal@Mocha, pid:956]
        33. WirePlumber                         [1.6.6, hal@Mocha, pid:1015]
        41. WirePlumber [export]                [1.6.6, hal@Mocha, pid:1015]
        42. plasmashell                         [1.6.6, hal@Mocha, pid:1114]
        43. xdg-desktop-portal                  [1.6.6, hal@Mocha, pid:964]
        47. wpctl                               [1.6.6, hal@Mocha, pid:8278]

Audio
 ├─ Devices:
 │  
 ├─ Sinks:
 │  
 ├─ Sources:
 │  
 ├─ Filters:
 │  
 └─ Streams:

Video
```

### Montagem FAST e VMSTORE

#### Fonte: `documentacao/20260529-150104-login-plasma-manager-esquema-aprovado.md`

Pontuação de relevância: 5

Linhas aproximadas 1-41:

```text
# Mocha Arch — esquema de login aprovado

Registro gerado em: `20260529-150104`

## Mounts persistentes corrigidos

- FAST: `UUID=88e6aa16-110c-4b97-9ffb-85084c000198` em `/media/mochafast`, tipo `btrfs`, label `MOCHAFAST`
- VMSTORE: `UUID=b81630a0-0756-45e4-9cb2-c7f16637a1c6` em `/media/vmstore`, tipo `xfs`, label `vmstore`
- O script não formatou, não particionou, não removeu pacote, não alterou bootloader e não mexeu em XU.
- No `/etc/fstab`, foram substituídas somente entradas cujo mountpoint era exatamente `/media/mochafast` ou `/media/vmstore`.

## Estado aprovado observado do login

- Gerenciador de login desejado para esta fase: `plasma-login.service`
- Sessão alvo: KDE Plasma em Wayland
- X11 não é fallback neste projeto, salvo ordem explícita posterior.
- Link atual de `display-manager.service`: `/usr/lib/systemd/system/plasmalogin.service`
- Unidade carregada pelo systemd: `/usr/lib/systemd/system/plasmalogin.service`
- Estado de `plasma-login.service`: enabled=`not-found`, active=`inactive`
- Estado de `sddm.service`: enabled=`disabled`, active=`inactive`
- Sessão atual detectada: Type=`wayland`, Desktop=`KDE`

## Regra operacional

1. Usar `plasma-login.service` como display manager quando disponível.
2. Desabilitar `sddm.service` para evitar conflito com login manager antigo.
3. Não usar X11/Xorg como fallback.
4. Não remover pacotes.
5. Não tocar na pasta XU.
6. Não apagar entradas de boot.
7. Antes de editar configuração, auditar o estado real.

## Script salvo

Script reutilizável:

`/media/mochafast/MochaArch/ativo/scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh`

Atalho estável atualizado:

`/media/mochafast/MochaArch/ativo/scripts/mocha-aplicar-login-plasma-manager.sh`
```

#### Fonte: `logs/20260529-154304-auditoria-estado-atual-para-manual.md`

Pontuação de relevância: 4

Linhas aproximadas 151-192:

```text
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
```

#### Fonte: `kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh`

Pontuação de relevância: 2

Linhas aproximadas 1-41:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

echo "== MOCHA ARCH/KDE — restaurar barra Win11/Mocha aprovada =="

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

TS="$(date +%Y%m%d-%H%M%S)"
BASE="/media/mochafast/MochaArch"
TARGET="$BASE/ativo/kde/barra-win11-aprovada"
APPROVED="$TARGET/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617"
CFG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
BACKUP_DIR="$BASE/ativo/backups/plasma-barra"
LOG_DIR="$BASE/ativo/logs"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

LOG="$LOG_DIR/${TS}-restaurar-barra-win11-mocha-aprovada.log"
exec > >(tee -a "$LOG") 2>&1

if ! mountpoint -q /media/mochafast; then
  echo "ERRO: /media/mochafast não está montado."
  exit 1
fi

if [ ! -f "$APPROVED" ]; then
  echo "ERRO: appletsrc aprovado não encontrado:"
  echo "  $APPROVED"
  exit 1
fi

if [ ! -f "$CFG" ]; then
  echo "ERRO: appletsrc atual não encontrado:"
  echo "  $CFG"
  exit 1
fi

if ! grep -q 'plugin=org.kde.plasma.panelspacer' "$APPROVED"; then
  echo "ERRO: arquivo aprovado sem panelspacer. Abortando."
  exit 1
```

#### Fonte: `logs/20260529-154304-criar-manual-vivo-definitivo-mocha-arch-kde.log`

Pontuação de relevância: 1

Linhas aproximadas 1-12:

```text
== Preflight ==
FAST montado: OK
Pasta ativa: /media/mochafast/MochaArch/ativo

== Backup do manual anterior, se existir ==
Nenhum manual anterior com nome fixo.

== Gerando auditoria do estado atual ==
Auditoria salva:
  /media/mochafast/MochaArch/ativo/logs/20260529-154304-auditoria-estado-atual-para-manual.md

== Extraindo evidências e comandos salvos por tema ==
```

#### Fonte: `logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log`

Pontuação de relevância: 1

Linhas aproximadas 1-22:

```text
Backup salvo em:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
Parando Plasma Shell...
Aplicando appletsrc aprovado...
Reiniciando Plasma Shell...

Validação:
18:plugin=org.kde.plasma.digitalclock
33:plugin=org.kde.plasma.panelspacer
36:expanding=true
40:plugin=org.kde.plasma.panelspacer
43:expanding=true
47:plugin=org.kde.plasma.kickoff
65:plugin=org.kde.plasma.icontasks
80:plugin=org.kde.plasma.systemtray
161:AppletOrder=4;6;23;3;5;24;7;21;22

Barra Win11/Mocha aprovada restaurada.
Log:
  /media/mochafast/MochaArch/ativo/logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log
Backup:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
```

#### Fonte: `logs/20260529-153335-aplicar-appletsrc-barra-win11-aprovada.log`

Pontuação de relevância: 1

Linhas aproximadas 1-57:

```text
== Preflight ==
FAST montado: OK
Pasta aprovada: OK
Arquivo aprovado: OK
Config atual: OK

== Auditoria do arquivo aprovado ==
Arquivo:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617

Assinaturas esperadas:
30:plugin=org.kde.plasma.digitalclock
45:plugin=org.kde.plasma.kickoff
63:plugin=org.kde.plasma.icontasks
78:plugin=org.kde.plasma.systemtray
155:AppletOrder=4;6;23;3;5;24;7;21;22
163:plugin=org.kde.plasma.panelspacer
166:expanding=true
170:plugin=org.kde.plasma.panelspacer
173:expanding=true

Assinatura da barra aprovada validada.

== Criando script reutilizável na pasta aprovada ==
Script reutilizável criado:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh

== Executando restauração da barra aprovada ==
== MOCHA ARCH/KDE — restaurar barra Win11/Mocha aprovada ==
Backup salvo em:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
Parando Plasma Shell...
Aplicando appletsrc aprovado...
Reiniciando Plasma Shell...

Validação:
18:plugin=org.kde.plasma.digitalclock
33:plugin=org.kde.plasma.panelspacer
36:expanding=true
40:plugin=org.kde.plasma.panelspacer
43:expanding=true
47:plugin=org.kde.plasma.kickoff
65:plugin=org.kde.plasma.icontasks
80:plugin=org.kde.plasma.systemtray
161:AppletOrder=4;6;23;3;5;24;7;21;22

Barra Win11/Mocha aprovada restaurada.
Log:
  /media/mochafast/MochaArch/ativo/logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log
Backup:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11

== Finalizado ==
Log principal:
  /media/mochafast/MochaArch/ativo/logs/20260529-153335-aplicar-appletsrc-barra-win11-aprovada.log
Script salvo para uso futuro:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh
```

#### Fonte: `logs/20260529-153249-aplicar-barra-win11-aprovada-pasta-certa.log`

Pontuação de relevância: 1

Linhas aproximadas 1-16:

```text
== Preflight ==
FAST montado: OK
Pasta aprovada encontrada: OK
Configuração Plasma encontrada: OK

== Conteúdo da pasta aprovada ==
2026-05-28 22:54  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
2026-05-28 22:56  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt

== Procurando script aprovado dentro da pasta correta ==
ERRO: não achei script .sh/.bash aprovado dentro de:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada

Arquivos encontrados:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
```

#### Fonte: `logs/20260529-153031-aplicar-barra-kde-mocha-aprovada.log`

Pontuação de relevância: 1

Linhas aproximadas 1-26:

```text
== Preflight ==
FAST montado: OK
Pasta de scripts: /media/mochafast/MochaArch/ativo/scripts
Config Plasma: /home/hal/.config/plasma-org.kde.plasma.desktop-appletsrc

== Procurando script aprovado da barra Mocha/KDE ==
Script escolhido:
  /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh

== Auditoria curta do script antes de executar ==
--- começo do script ---
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"

SUDO="sudo"
if [ -x /run/wrappers/bin/sudo ]; then
  SUDO="/run/wrappers/bin/sudo"
fi

apply_hidden_desktop_user() {
  local name="$1"
  local exec_line="$2"
  local comment="$3"
  local target="$HOME/.config/autostart/$name"
```

Linhas aproximadas 109-134:

```text
systemctl --user stop app-kmix@autostart.service 2>/dev/null || true
pkill -x blueman-applet 2>/dev/null || true
pkill -x kmix 2>/dev/null || true

echo "Mocha KDE: autostarts redundantes de Blueman e KMix desativados."
echo "Bluetooth fica com KDE/Bluedevil. Volume fica com Plasma Volume."
--- fim da auditoria curta ---

== Backup da configuração atual do Plasma ==
Backup salvo em:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153031-plasma-org.kde.plasma.desktop-appletsrc.antes-barra-mocha
Mantendo no máximo 2 backups recentes desta configuração...

== Executando script documentado/aprovado da barra ==
Mocha KDE: autostarts redundantes de Blueman e KMix desativados.
Bluetooth fica com KDE/Bluedevil. Volume fica com Plasma Volume.

== Reiniciando Plasma Shell para refletir a barra, se necessário ==

== Finalizado ==
Barra Mocha aplicada usando:
  /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh
Log:
  /media/mochafast/MochaArch/ativo/logs/20260529-153031-aplicar-barra-kde-mocha-aprovada.log
Backup:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153031-plasma-org.kde.plasma.desktop-appletsrc.antes-barra-mocha
```

#### Fonte: `auditorias/20260529-152907-canonizar-barra-sem-duplicidade/execucao.log`

Pontuação de relevância: 1

Linhas aproximadas 40-60:

```text
app-org.kde.bluedevilwizard@2c6d514fa32d417ea2e56bae877bd717.service                                                    loaded failed failed    Adicionar dispositivo Bluetooth - Adicionar dispositivo Bluetooth
app-pulseaudio@autostart.service                                                                                        loaded failed failed    PulseAudio Sound System
pipewire.service                                                                                                        loaded active running   PipeWire Multimedia Service
pulseaudio.service                                                                                                      loaded active running   Sound Service
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

== 5/6 Criando script reutilizável ==
Script criado: /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh

== 6/6 Documentando como passo canônico de montagem ==
Documento criado:
/media/mochafast/MochaArch/ativo/documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md

Passo canônico criado:
/media/mochafast/MochaArch/ativo/passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md

Log salvo em:
/media/mochafast/MochaArch/ativo/auditorias/20260529-152907-canonizar-barra-sem-duplicidade/execucao.log
```

#### Fonte: `passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md`

Pontuação de relevância: 1

Linhas aproximadas 50-68:

```text
1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md`

Pontuação de relevância: 1

Linhas aproximadas 50-68:

```text
1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log`

Pontuação de relevância: 1

Linhas aproximadas 14-42:

```text
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

### Processos relevantes antes
1014 /usr/bin/pipewire
1015 /usr/bin/wireplumber
1056 /usr/bin/pulseaudio --daemonize=no --log-target=journal
1114 /usr/bin/plasmashell --no-respawn
2060 /usr/bin/kmix --keepvisibility
8437 tee /media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log

== 2/7 Confirmando que o volume do Plasma existe no system tray ==
OK: org.kde.plasma.volume existe no Plasma. Podemos remover apenas o KMix redundante da sessão/autostart.

== 3/7 Localizando arquivo original de autostart do KMix ==
Fonte encontrada: /etc/xdg/autostart/kmix_autostart.desktop

== 4/7 Criando override local com Hidden=true para KMix ==
Override final:
2:Exec=kmix --keepvisibility
4:OnlyShowIn=KDE;
69:Name=KMix
128:Hidden=true

== 5/7 Parando KMix nesta sessão ==
KMix após stop:
OK: kmix não está mais rodando.

```

Linhas aproximadas 54-97:

```text
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

### Processos relevantes depois
1014 /usr/bin/pipewire
1015 /usr/bin/wireplumber
1056 /usr/bin/pulseaudio --daemonize=no --log-target=journal
1114 /usr/bin/plasmashell --no-respawn
8437 tee /media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log

### Áudio continua respondendo?
String do servidor: /run/user/1000/pulse/native
Versão do protocolo da biblioteca: 35
Versão do protocolo do servidor: 35
É local: sim
Índice do cliente: 44
Tamanho de fragmento: 65472
Nome do usuário: hal
Nome da máquina: Mocha
Nome do servidor: pulseaudio
Versão do servidor: 17.0-98-gb096
Especificação padrão de amostragem: s16le 2ch 44100Hz
Mapa de canais padrão: front-left,front-right
Destino padrão: bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink
Fonte padrão: bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink.monitor
Cookie: ed82:a34c

2	alsa_output.pci-0000_01_00.1.hdmi-stereo	module-alsa-card.c	s16le 2ch 44100Hz	SUSPENDED
3	bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink	module-bluez5-device.c	s16le 2ch 44100Hz	SUSPENDED

### Bluetooth continua ativo?
active

== 7/7 Salvando documentação e script reutilizável ==
Documento criado:
/media/mochafast/MochaArch/ativo/documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md

Script reutilizável criado:
/media/mochafast/MochaArch/ativo/scripts/20260529-152700-mocha-desativar-kmix-volume-duplicado.sh

Log salvo em:
/media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log
```

### Bluetooth e volume duplicados

#### Fonte: `logs/20260529-154304-auditoria-estado-atual-para-manual.md`

Pontuação de relevância: 6

Linhas aproximadas 237-275:

```text
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
```

#### Fonte: `logs/20260529-153031-aplicar-barra-kde-mocha-aprovada.log`

Pontuação de relevância: 6

Linhas aproximadas 1-84:

```text
== Preflight ==
FAST montado: OK
Pasta de scripts: /media/mochafast/MochaArch/ativo/scripts
Config Plasma: /home/hal/.config/plasma-org.kde.plasma.desktop-appletsrc

== Procurando script aprovado da barra Mocha/KDE ==
Script escolhido:
  /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh

== Auditoria curta do script antes de executar ==
--- começo do script ---
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"

SUDO="sudo"
if [ -x /run/wrappers/bin/sudo ]; then
  SUDO="/run/wrappers/bin/sudo"
fi

apply_hidden_desktop_user() {
  local name="$1"
  local exec_line="$2"
  local comment="$3"
  local target="$HOME/.config/autostart/$name"
  local src=""

  mkdir -p "$HOME/.config/autostart"

  for candidate in \
    "/etc/xdg/autostart/$name" \
    "/usr/etc/xdg/autostart/$name" \
    "/usr/share/applications/$name"
  do
    if [ -f "$candidate" ]; then
      src="$candidate"
      break
    fi
  done

  if [ -n "$src" ]; then
    cp -a "$src" "$target"
  else
    cat > "$target" <<EOINNER
[Desktop Entry]
Type=Application
Name=$name
Comment=$comment
Exec=$exec_line
OnlyShowIn=KDE;
EOINNER
  fi

  if grep -q '^Hidden=' "$target"; then
    sed -i 's/^Hidden=.*/Hidden=true/' "$target"
  else
    printf '\nHidden=true\n' >> "$target"
  fi
}

write_hidden_desktop_skel() {
  local name="$1"
  local exec_line="$2"
  local comment="$3"
  local skel_dir="/etc/skel/.config/autostart"
  local target="$skel_dir/$name"
  local tmp

  $SUDO mkdir -p "$skel_dir"
  tmp="$(mktemp)"

  cat > "$tmp" <<EOINNER
[Desktop Entry]
Type=Application
Name=$name
Comment=$comment
Exec=$exec_line
OnlyShowIn=KDE;
Hidden=true
EOINNER

  $SUDO install -m 0644 "$tmp" "$target"
  rm -f "$tmp"
```

#### Fonte: `auditorias/20260529-152907-canonizar-barra-sem-duplicidade/execucao.log`

Pontuação de relevância: 6

Linhas aproximadas 1-31:

```text
== 1/6 Confirmando applets nativos do KDE/Plasma ==
75:plugin=org.kde.plasma.systemtray
114:plugin=org.kde.plasma.volume
145:plugin=org.kde.plasma.bluetooth

== 2/6 Aplicando permanência no usuário atual ==
OK usuário: /home/hal/.config/autostart/blueman.desktop
38:Name=Blueman Applet
78:Exec=blueman-applet
83:Hidden=true

OK usuário: /home/hal/.config/autostart/kmix_autostart.desktop
2:Exec=kmix --keepvisibility
4:OnlyShowIn=KDE;
69:Name=KMix
128:Hidden=true

== 3/6 Preparando /etc/skel para novos usuários do Mocha ==
OK /etc/skel: /etc/skel/.config/autostart/blueman.desktop
3:Name=blueman.desktop
5:Exec=blueman-applet
6:OnlyShowIn=KDE;
7:Hidden=true

OK /etc/skel: /etc/skel/.config/autostart/kmix_autostart.desktop
3:Name=kmix_autostart.desktop
5:Exec=kmix --keepvisibility
6:OnlyShowIn=KDE;
7:Hidden=true

== 4/6 Garantindo sessão atual limpa ==
```

#### Fonte: `passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md`

Pontuação de relevância: 6

Linhas aproximadas 1-44:

```text
# Mocha Arch/KDE — passo canônico: barra sem Bluetooth/volume duplicados

Timestamp: 20260529-152907

## Status

Aprovado pelo usuário em teste real.

## Sintoma corrigido

Na barra do KDE/Plasma havia duplicidade de:

- Bluetooth.
- Controle de volume.

## Causa confirmada

A barra já tinha os applets nativos do KDE/Plasma:

- `org.kde.plasma.bluetooth`
- `org.kde.plasma.volume`

Além disso, estavam subindo autostarts redundantes:

- `blueman-applet`
- `kmix --keepvisibility`

## Correção aprovada

Não remover pacotes.

Apenas criar overrides de autostart com:

`Hidden=true`

Arquivos do usuário atual:

- `~/.config/autostart/blueman.desktop`
- `~/.config/autostart/kmix_autostart.desktop`

Arquivos preparados para novos usuários:

- `/etc/skel/.config/autostart/blueman.desktop`
- `/etc/skel/.config/autostart/kmix_autostart.desktop`
```

#### Fonte: `documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md`

Pontuação de relevância: 6

Linhas aproximadas 1-44:

```text
# Mocha Arch/KDE — passo canônico: barra sem Bluetooth/volume duplicados

Timestamp: 20260529-152907

## Status

Aprovado pelo usuário em teste real.

## Sintoma corrigido

Na barra do KDE/Plasma havia duplicidade de:

- Bluetooth.
- Controle de volume.

## Causa confirmada

A barra já tinha os applets nativos do KDE/Plasma:

- `org.kde.plasma.bluetooth`
- `org.kde.plasma.volume`

Além disso, estavam subindo autostarts redundantes:

- `blueman-applet`
- `kmix --keepvisibility`

## Correção aprovada

Não remover pacotes.

Apenas criar overrides de autostart com:

`Hidden=true`

Arquivos do usuário atual:

- `~/.config/autostart/blueman.desktop`
- `~/.config/autostart/kmix_autostart.desktop`

Arquivos preparados para novos usuários:

- `/etc/skel/.config/autostart/blueman.desktop`
- `/etc/skel/.config/autostart/kmix_autostart.desktop`
```

#### Fonte: `scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

Pontuação de relevância: 6

Linhas aproximadas 5-87:

```bash

SUDO="sudo"
if [ -x /run/wrappers/bin/sudo ]; then
  SUDO="/run/wrappers/bin/sudo"
fi

apply_hidden_desktop_user() {
  local name="$1"
  local exec_line="$2"
  local comment="$3"
  local target="$HOME/.config/autostart/$name"
  local src=""

  mkdir -p "$HOME/.config/autostart"

  for candidate in \
    "/etc/xdg/autostart/$name" \
    "/usr/etc/xdg/autostart/$name" \
    "/usr/share/applications/$name"
  do
    if [ -f "$candidate" ]; then
      src="$candidate"
      break
    fi
  done

  if [ -n "$src" ]; then
    cp -a "$src" "$target"
  else
    cat > "$target" <<EOINNER
[Desktop Entry]
Type=Application
Name=$name
Comment=$comment
Exec=$exec_line
OnlyShowIn=KDE;
EOINNER
  fi

  if grep -q '^Hidden=' "$target"; then
    sed -i 's/^Hidden=.*/Hidden=true/' "$target"
  else
    printf '\nHidden=true\n' >> "$target"
  fi
}

write_hidden_desktop_skel() {
  local name="$1"
  local exec_line="$2"
  local comment="$3"
  local skel_dir="/etc/skel/.config/autostart"
  local target="$skel_dir/$name"
  local tmp

  $SUDO mkdir -p "$skel_dir"
  tmp="$(mktemp)"

  cat > "$tmp" <<EOINNER
[Desktop Entry]
Type=Application
Name=$name
Comment=$comment
Exec=$exec_line
OnlyShowIn=KDE;
Hidden=true
EOINNER

  $SUDO install -m 0644 "$tmp" "$target"
  rm -f "$tmp"
}

apply_hidden_desktop_user \
  "blueman.desktop" \
  "blueman-applet" \
  "Mocha KDE: disabled because KDE/Bluedevil already provides Bluetooth in the system tray"

apply_hidden_desktop_user \
  "kmix_autostart.desktop" \
  "kmix --keepvisibility" \
  "Mocha KDE: disabled because Plasma volume applet already provides volume control in the system tray"

write_hidden_desktop_skel \
  "blueman.desktop" \
```

#### Fonte: `documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md`

Pontuação de relevância: 6

Linhas aproximadas 1-35:

```text
# Mocha Arch/KDE — volume duplicado corrigido por desativação do KMix

Timestamp: 20260529-152700

## Diagnóstico

A barra apresentava volume duplicado.

A auditoria mostrou:

- O applet normal do Plasma para volume existe no system tray:
  - `org.kde.plasma.volume`
- O KMix também estava rodando por autostart:
  - `app-kmix_autostart@autostart.service`
  - processo `kmix --keepvisibility`

Isso cria redundância visual de volume.

## Ação aplicada

Foi criado/ajustado o override local:

`/home/hal/.config/autostart/kmix_autostart.desktop`

com:

`Hidden=true`

Também foi parado nesta sessão:

`app-kmix_autostart@autostart.service`

e encerrado o processo:

`kmix`
```

#### Fonte: `auditorias/20260529-152529-corrigir-blueman-auditar-volume/execucao.log`

Pontuação de relevância: 6

Linhas aproximadas 1-29:

```text
== 1/6 Estado antes ==

### Serviços de usuário relevantes antes
sys-devices-pci0000:00-0000:00:08.1-0000:09:00.4-usb5-5\x2d2-5\x2d2:1.0-bluetooth-hci0-hci0:1.device                    loaded active plugged   /sys/devices/pci0000:00/0000:00:08.1/0000:09:00.4/usb5/5-2/5-2:1.0/bluetooth/hci0/hci0:1
sys-devices-pci0000:00-0000:00:08.1-0000:09:00.4-usb5-5\x2d2-5\x2d2:1.0-bluetooth-hci0.device                           loaded active plugged   /sys/devices/pci0000:00/0000:00:08.1/0000:09:00.4/usb5/5-2/5-2:1.0/bluetooth/hci0
sys-subsystem-bluetooth-devices-hci0.device                                                                             loaded active plugged   /sys/subsystem/bluetooth/devices/hci0
sys-subsystem-bluetooth-devices-hci0:1.device                                                                           loaded active plugged   /sys/subsystem/bluetooth/devices/hci0:1
app-blueman@autostart.service                                                                                           loaded active running   Blueman Applet
app-kmix_autostart@autostart.service                                                                                    loaded active running   KMix
app-org.kde.bluedevilwizard@2c6d514fa32d417ea2e56bae877bd717.service                                                    loaded failed failed    Adicionar dispositivo Bluetooth - Adicionar dispositivo Bluetooth
app-pulseaudio@autostart.service                                                                                        loaded failed failed    PulseAudio Sound System
pipewire.service                                                                                                        loaded active running   PipeWire Multimedia Service
pulseaudio.service                                                                                                      loaded active running   Sound Service
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

### Processos relevantes antes
1014 /usr/bin/pipewire
1015 /usr/bin/wireplumber
1056 /usr/bin/pulseaudio --daemonize=no --log-target=journal
1114 /usr/bin/plasmashell --no-respawn
1994 /usr/bin/python /usr/bin/blueman-applet
2060 /usr/bin/kmix --keepvisibility

== 2/6 Criando override local para impedir autostart do Blueman ==
Criado override local a partir de: /etc/xdg/autostart/blueman.desktop
Override final:
```

#### Fonte: `auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log`

Pontuação de relevância: 5

Linhas aproximadas 1-34:

```text
== 1/7 Estado antes ==

### Serviços de usuário relevantes antes
sys-devices-pci0000:00-0000:00:08.1-0000:09:00.4-usb5-5\x2d2-5\x2d2:1.0-bluetooth-hci0-hci0:1.device                    loaded active plugged   /sys/devices/pci0000:00/0000:00:08.1/0000:09:00.4/usb5/5-2/5-2:1.0/bluetooth/hci0/hci0:1
sys-devices-pci0000:00-0000:00:08.1-0000:09:00.4-usb5-5\x2d2-5\x2d2:1.0-bluetooth-hci0.device                           loaded active plugged   /sys/devices/pci0000:00/0000:00:08.1/0000:09:00.4/usb5/5-2/5-2:1.0/bluetooth/hci0
sys-subsystem-bluetooth-devices-hci0.device                                                                             loaded active plugged   /sys/subsystem/bluetooth/devices/hci0
sys-subsystem-bluetooth-devices-hci0:1.device                                                                           loaded active plugged   /sys/subsystem/bluetooth/devices/hci0:1
app-kmix_autostart@autostart.service                                                                                    loaded active running   KMix
app-org.kde.bluedevilwizard@2c6d514fa32d417ea2e56bae877bd717.service                                                    loaded failed failed    Adicionar dispositivo Bluetooth - Adicionar dispositivo Bluetooth
app-pulseaudio@autostart.service                                                                                        loaded failed failed    PulseAudio Sound System
pipewire.service                                                                                                        loaded active running   PipeWire Multimedia Service
pulseaudio.service                                                                                                      loaded active running   Sound Service
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

### Processos relevantes antes
1014 /usr/bin/pipewire
1015 /usr/bin/wireplumber
1056 /usr/bin/pulseaudio --daemonize=no --log-target=journal
1114 /usr/bin/plasmashell --no-respawn
2060 /usr/bin/kmix --keepvisibility
8437 tee /media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log

== 2/7 Confirmando que o volume do Plasma existe no system tray ==
OK: org.kde.plasma.volume existe no Plasma. Podemos remover apenas o KMix redundante da sessão/autostart.

== 3/7 Localizando arquivo original de autostart do KMix ==
Fonte encontrada: /etc/xdg/autostart/kmix_autostart.desktop

== 4/7 Criando override local com Hidden=true para KMix ==
Override final:
2:Exec=kmix --keepvisibility
```

#### Fonte: `scripts/20260529-152700-mocha-desativar-kmix-volume-duplicado.sh`

Pontuação de relevância: 4

Linhas aproximadas 1-43:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

AUTO_USER="$HOME/.config/autostart/kmix_autostart.desktop"
mkdir -p "$HOME/.config/autostart"

SRC=""
for candidate in \
  "/etc/xdg/autostart/kmix_autostart.desktop" \
  "/usr/etc/xdg/autostart/kmix_autostart.desktop" \
  "/usr/share/applications/org.kde.kmix.desktop" \
  "/usr/share/applications/kmix.desktop"
do
  if [ -f "$candidate" ]; then
    SRC="$candidate"
    break
  fi
done

if [ -n "$SRC" ]; then
  cp -a "$SRC" "$AUTO_USER"
else
  cat > "$AUTO_USER" <<'EOINNER'
[Desktop Entry]
Type=Application
Name=KMix
Comment=Disabled by Mocha KDE because Plasma volume applet already provides volume control in the system tray
Exec=kmix --keepvisibility
OnlyShowIn=KDE;
EOINNER
fi

if grep -q '^Hidden=' "$AUTO_USER"; then
  sed -i 's/^Hidden=.*/Hidden=true/' "$AUTO_USER"
else
  printf '\nHidden=true\n' >> "$AUTO_USER"
fi

systemctl --user stop app-kmix_autostart@autostart.service 2>/dev/null || true
systemctl --user stop app-kmix@autostart.service 2>/dev/null || true
pkill -x kmix 2>/dev/null || true

echo "KMix autostart desativado para o usuário atual."
```

#### Fonte: `auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/resumo-auditoria.txt`

Pontuação de relevância: 3

Linhas aproximadas 76-118:

```text
plasmatube 26.04.1-2
plasma-vault 6.6.5-1
plasma-welcome 6.6.5-1
plasma-workspace 6.6.5-2
plasma-workspace-wallpapers 6.6.5-1
steam 1.0.0.85-7
steam-devices 1.0.0.85-7
wireplumber 0.5.14-1

### SERVIÇOS DO SISTEMA RELACIONADOS
● bluetooth.service - Bluetooth service
     Loaded: loaded (/usr/lib/systemd/system/bluetooth.service; enabled; preset: disabled)
     Active: active (running) since Fri 2026-05-29 14:29:45 -03; 54min ago
 Invocation: 040213ede68b4cc48886bc2a25c46bd6
       Docs: man:bluetoothd(8)
   Main PID: 617 (bluetoothd)
     Status: "Running"
      Tasks: 1 (limit: 18662)
     Memory: 2M (peak: 3.4M)
        CPU: 47ms
     CGroup: /system.slice/bluetooth.service
             └─617 /usr/lib/bluetooth/bluetoothd

mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSource/sbc
mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSink/sbc_xq_453
mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSource/sbc_xq_453
mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSink/sbc_xq_512
mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSource/sbc_xq_512
mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSink/sbc_xq_552
mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSource/sbc_xq_552
mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSink/faststream
mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSource/faststream
mai 29 15:01:55 Mocha bluetoothd[617]: /org/bluez/hci0/dev_0C_ED_E7_FF_AB_9D/sep1/fd0: fd(31) ready

### SERVIÇOS DE USUÁRIO RELACIONADOS
sys-devices-pci0000:00-0000:00:08.1-0000:09:00.4-usb5-5\x2d2-5\x2d2:1.0-bluetooth-hci0-hci0:1.device                    loaded active plugged   /sys/devices/pci0000:00/0000:00:08.1/0000:09:00.4/usb5/5-2/5-2:1.0/bluetooth/hci0/hci0:1
sys-devices-pci0000:00-0000:00:08.1-0000:09:00.4-usb5-5\x2d2-5\x2d2:1.0-bluetooth-hci0.device                           loaded active plugged   /sys/devices/pci0000:00/0000:00:08.1/0000:09:00.4/usb5/5-2/5-2:1.0/bluetooth/hci0
sys-subsystem-bluetooth-devices-hci0.device                                                                             loaded active plugged   /sys/subsystem/bluetooth/devices/hci0
sys-subsystem-bluetooth-devices-hci0:1.device                                                                           loaded active plugged   /sys/subsystem/bluetooth/devices/hci0:1
app-blueman@autostart.service                                                                                           loaded active running   Blueman Applet
app-org.kde.bluedevilwizard@2c6d514fa32d417ea2e56bae877bd717.service                                                    loaded failed failed    Adicionar dispositivo Bluetooth - Adicionar dispositivo Bluetooth
app-pulseaudio@autostart.service                                                                                        loaded failed failed    PulseAudio Sound System
pipewire.service                                                                                                        loaded active running   PipeWire Multimedia Service
```

#### Fonte: `auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/LEIA-ME.txt`

Pontuação de relevância: 2

Linhas aproximadas 1-11:

```text
Auditoria somente leitura da duplicidade de Bluetooth/volume.

Arquivos principais:
- resumo-auditoria.txt
- plasma-applets-volume-bluetooth-systemtray.txt
- plasma-org.kde.plasma.desktop-appletsrc.copia

Interpretação esperada:
- Se houver org.kde.plasma.volume como applet independente e também dentro do system tray, a correção provável é remover apenas o applet independente.
- Se houver org.kde.plasma.bluetooth como applet independente e também dentro do system tray, a correção provável é remover apenas o applet independente.
- Não corrigir por dedução. Corrigir apenas após confirmar no relatório.
```

### Barra Win11/Mocha KDE

#### Fonte: `kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh`

Pontuação de relevância: 7

Linhas aproximadas 1-58:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

echo "== MOCHA ARCH/KDE — restaurar barra Win11/Mocha aprovada =="

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

TS="$(date +%Y%m%d-%H%M%S)"
BASE="/media/mochafast/MochaArch"
TARGET="$BASE/ativo/kde/barra-win11-aprovada"
APPROVED="$TARGET/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617"
CFG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
BACKUP_DIR="$BASE/ativo/backups/plasma-barra"
LOG_DIR="$BASE/ativo/logs"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

LOG="$LOG_DIR/${TS}-restaurar-barra-win11-mocha-aprovada.log"
exec > >(tee -a "$LOG") 2>&1

if ! mountpoint -q /media/mochafast; then
  echo "ERRO: /media/mochafast não está montado."
  exit 1
fi

if [ ! -f "$APPROVED" ]; then
  echo "ERRO: appletsrc aprovado não encontrado:"
  echo "  $APPROVED"
  exit 1
fi

if [ ! -f "$CFG" ]; then
  echo "ERRO: appletsrc atual não encontrado:"
  echo "  $CFG"
  exit 1
fi

if ! grep -q 'plugin=org.kde.plasma.panelspacer' "$APPROVED"; then
  echo "ERRO: arquivo aprovado sem panelspacer. Abortando."
  exit 1
fi

if ! grep -Eq 'plugin=org\.kde\.plasma\.(icontasks|taskmanager)' "$APPROVED"; then
  echo "ERRO: arquivo aprovado sem icontasks/taskmanager. Abortando."
  exit 1
fi

BACKUP="$BACKUP_DIR/${TS}-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11"
cp -a "$CFG" "$BACKUP"

find "$BACKUP_DIR" -maxdepth 1 -type f -name '*plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11*' \
  -printf '%T@ %p\n' 2>/dev/null \
  | sort -nr \
  | awk 'NR>2 {sub(/^[^ ]+ /,""); print}' \
  | while IFS= read -r old; do
      [ -n "$old" ] && rm -f -- "$old"
    done || true
```

#### Fonte: `logs/20260529-154304-auditoria-estado-atual-para-manual.md`

Pontuação de relevância: 6

Linhas aproximadas 53-81:

```text
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
```

Linhas aproximadas 387-425:

```text
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
```

#### Fonte: `kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt`

Pontuação de relevância: 6

Linhas aproximadas 1-30:

```text
MOCHA ARCH / KDE — BARRA ESTILO WINDOWS 11 APROVADA
Timestamp: 20260528-225617

Status:
- Funcionou e foi aprovado pelo usuário nesta instalação EndeavourOS KDE.
- Deve ser preservado como solução de referência para MochaArch.

O que a solução faz:
- Audita o arquivo real:
  $HOME/.config/plasma-org.kde.plasma.desktop-appletsrc
- Cria backup com timestamp.
- Mantém no máximo 2 backups do arquivo da barra.
- Usa dois org.kde.plasma.panelspacer expansíveis.
- Centraliza Kickoff/Iniciar + icontasks/taskmanager.
- Preserva pager/outros applets à esquerda.
- Mantém systemtray/digitalclock/showdesktop à direita.
- Reinicia somente plasmashell.

Arquivos salvos:
- Snapshot aprovado:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
- Script reutilizável:
  /media/mochafast/MochaArch/scripts/mocha-kde-barra-win11-aprovada-20260528-225617.sh
- Log desta gravação:
  /home/hal/mocha-salvar-barra-win11-aprovada-20260528-225617.log

Observação:
- Não depende de X11.
- Não instala pacotes.
- Não mexe em kernel, NVIDIA, boot, Steam ou receita de performance.
```

#### Fonte: `logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log`

Pontuação de relevância: 5

Linhas aproximadas 1-22:

```text
Backup salvo em:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
Parando Plasma Shell...
Aplicando appletsrc aprovado...
Reiniciando Plasma Shell...

Validação:
18:plugin=org.kde.plasma.digitalclock
33:plugin=org.kde.plasma.panelspacer
36:expanding=true
40:plugin=org.kde.plasma.panelspacer
43:expanding=true
47:plugin=org.kde.plasma.kickoff
65:plugin=org.kde.plasma.icontasks
80:plugin=org.kde.plasma.systemtray
161:AppletOrder=4;6;23;3;5;24;7;21;22

Barra Win11/Mocha aprovada restaurada.
Log:
  /media/mochafast/MochaArch/ativo/logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log
Backup:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
```

#### Fonte: `logs/20260529-153335-aplicar-appletsrc-barra-win11-aprovada.log`

Pontuação de relevância: 5

Linhas aproximadas 1-51:

```text
== Preflight ==
FAST montado: OK
Pasta aprovada: OK
Arquivo aprovado: OK
Config atual: OK

== Auditoria do arquivo aprovado ==
Arquivo:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617

Assinaturas esperadas:
30:plugin=org.kde.plasma.digitalclock
45:plugin=org.kde.plasma.kickoff
63:plugin=org.kde.plasma.icontasks
78:plugin=org.kde.plasma.systemtray
155:AppletOrder=4;6;23;3;5;24;7;21;22
163:plugin=org.kde.plasma.panelspacer
166:expanding=true
170:plugin=org.kde.plasma.panelspacer
173:expanding=true

Assinatura da barra aprovada validada.

== Criando script reutilizável na pasta aprovada ==
Script reutilizável criado:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh

== Executando restauração da barra aprovada ==
== MOCHA ARCH/KDE — restaurar barra Win11/Mocha aprovada ==
Backup salvo em:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
Parando Plasma Shell...
Aplicando appletsrc aprovado...
Reiniciando Plasma Shell...

Validação:
18:plugin=org.kde.plasma.digitalclock
33:plugin=org.kde.plasma.panelspacer
36:expanding=true
40:plugin=org.kde.plasma.panelspacer
43:expanding=true
47:plugin=org.kde.plasma.kickoff
65:plugin=org.kde.plasma.icontasks
80:plugin=org.kde.plasma.systemtray
161:AppletOrder=4;6;23;3;5;24;7;21;22

Barra Win11/Mocha aprovada restaurada.
Log:
  /media/mochafast/MochaArch/ativo/logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log
Backup:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
```

#### Fonte: `logs/20260529-153249-aplicar-barra-win11-aprovada-pasta-certa.log`

Pontuação de relevância: 2

Linhas aproximadas 1-16:

```text
== Preflight ==
FAST montado: OK
Pasta aprovada encontrada: OK
Configuração Plasma encontrada: OK

== Conteúdo da pasta aprovada ==
2026-05-28 22:54  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
2026-05-28 22:56  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt

== Procurando script aprovado dentro da pasta correta ==
ERRO: não achei script .sh/.bash aprovado dentro de:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada

Arquivos encontrados:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
```

#### Fonte: `auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/plasma-applets-volume-bluetooth-systemtray.txt`

Pontuação de relevância: 2

Linhas aproximadas 1-28:

```text
### PLUGINS RELEVANTES ENCONTRADOS NO plasma-org.kde.plasma.desktop-appletsrc
16:plugin=org.kde.plasma.folder
17:wallpaperplugin=org.kde.image
25:plugin=org.kde.panel
26:wallpaperplugin=org.kde.image
30:plugin=org.kde.plasma.digitalclock
41:plugin=org.kde.plasma.showdesktop
45:plugin=org.kde.plasma.kickoff
56:plugin=org.kde.plasma.pager
60:plugin=org.kde.plasma.icontasks
67:plugin=org.kde.plasma.marginsseparator
75:plugin=org.kde.plasma.systemtray
78:wallpaperplugin=org.kde.image
82:plugin=org.kde.kscreen
86:plugin=org.kde.plasma.keyboardlayout
90:plugin=org.kde.plasma.weather
94:plugin=org.kde.plasma.clipboard
98:plugin=org.kde.plasma.keyboardindicator
102:plugin=org.kde.plasma.devicenotifier
106:plugin=org.kde.plasma.printmanager
110:plugin=org.kde.plasma.cameraindicator
114:plugin=org.kde.plasma.volume
121:plugin=org.kde.plasma.notifications
125:plugin=org.kde.plasma.manage-inputmethod
129:plugin=org.kde.plasma.networkmanagement
133:plugin=org.kde.merkuro.contact.applet
137:plugin=org.kde.plasma.brightness
141:plugin=org.kde.plasma.battery
```

Linhas aproximadas 38-66:

```text
      1 plugin=org.kde.merkuro.contact.applet
      1 plugin=org.kde.panel
      1 plugin=org.kde.plasma.battery
      1 plugin=org.kde.plasma.bluetooth
      1 plugin=org.kde.plasma.brightness
      1 plugin=org.kde.plasma.cameraindicator
      1 plugin=org.kde.plasma.clipboard
      1 plugin=org.kde.plasma.devicenotifier
      1 plugin=org.kde.plasma.digitalclock
      1 plugin=org.kde.plasma.folder
      1 plugin=org.kde.plasma.icontasks
      1 plugin=org.kde.plasma.keyboardindicator
      1 plugin=org.kde.plasma.keyboardlayout
      1 plugin=org.kde.plasma.kickoff
      1 plugin=org.kde.plasma.manage-inputmethod
      1 plugin=org.kde.plasma.marginsseparator
      1 plugin=org.kde.plasma.networkmanagement
      1 plugin=org.kde.plasma.notifications
      1 plugin=org.kde.plasma.pager
      1 plugin=org.kde.plasma.printmanager
      1 plugin=org.kde.plasma.showdesktop
      1 plugin=org.kde.plasma.systemtray
      1 plugin=org.kde.plasma.vault
      1 plugin=org.kde.plasma.volume
      1 plugin=org.kde.plasma.weather

### SUSPEITOS DIRETOS
75:plugin=org.kde.plasma.systemtray
114:plugin=org.kde.plasma.volume
```

#### Fonte: `logs/20260529-153031-aplicar-barra-kde-mocha-aprovada.log`

Pontuação de relevância: 1

Linhas aproximadas 1-22:

```text
== Preflight ==
FAST montado: OK
Pasta de scripts: /media/mochafast/MochaArch/ativo/scripts
Config Plasma: /home/hal/.config/plasma-org.kde.plasma.desktop-appletsrc

== Procurando script aprovado da barra Mocha/KDE ==
Script escolhido:
  /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh

== Auditoria curta do script antes de executar ==
--- começo do script ---
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"

SUDO="sudo"
if [ -x /run/wrappers/bin/sudo ]; then
  SUDO="/run/wrappers/bin/sudo"
fi

apply_hidden_desktop_user() {
```

Linhas aproximadas 109-134:

```text
systemctl --user stop app-kmix@autostart.service 2>/dev/null || true
pkill -x blueman-applet 2>/dev/null || true
pkill -x kmix 2>/dev/null || true

echo "Mocha KDE: autostarts redundantes de Blueman e KMix desativados."
echo "Bluetooth fica com KDE/Bluedevil. Volume fica com Plasma Volume."
--- fim da auditoria curta ---

== Backup da configuração atual do Plasma ==
Backup salvo em:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153031-plasma-org.kde.plasma.desktop-appletsrc.antes-barra-mocha
Mantendo no máximo 2 backups recentes desta configuração...

== Executando script documentado/aprovado da barra ==
Mocha KDE: autostarts redundantes de Blueman e KMix desativados.
Bluetooth fica com KDE/Bluedevil. Volume fica com Plasma Volume.

== Reiniciando Plasma Shell para refletir a barra, se necessário ==

== Finalizado ==
Barra Mocha aplicada usando:
  /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh
Log:
  /media/mochafast/MochaArch/ativo/logs/20260529-153031-aplicar-barra-kde-mocha-aprovada.log
Backup:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153031-plasma-org.kde.plasma.desktop-appletsrc.antes-barra-mocha
```

#### Fonte: `auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log`

Pontuação de relevância: 1

Linhas aproximadas 12-40:

```text
pulseaudio.service                                                                                                      loaded active running   Sound Service
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

### Processos relevantes antes
1014 /usr/bin/pipewire
1015 /usr/bin/wireplumber
1056 /usr/bin/pulseaudio --daemonize=no --log-target=journal
1114 /usr/bin/plasmashell --no-respawn
2060 /usr/bin/kmix --keepvisibility
8437 tee /media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log

== 2/7 Confirmando que o volume do Plasma existe no system tray ==
OK: org.kde.plasma.volume existe no Plasma. Podemos remover apenas o KMix redundante da sessão/autostart.

== 3/7 Localizando arquivo original de autostart do KMix ==
Fonte encontrada: /etc/xdg/autostart/kmix_autostart.desktop

== 4/7 Criando override local com Hidden=true para KMix ==
Override final:
2:Exec=kmix --keepvisibility
4:OnlyShowIn=KDE;
69:Name=KMix
128:Hidden=true

== 5/7 Parando KMix nesta sessão ==
KMix após stop:
```

Linhas aproximadas 53-81:

```text
pulseaudio.service                                                                                                      loaded active running   Sound Service
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

### Processos relevantes depois
1014 /usr/bin/pipewire
1015 /usr/bin/wireplumber
1056 /usr/bin/pulseaudio --daemonize=no --log-target=journal
1114 /usr/bin/plasmashell --no-respawn
8437 tee /media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log

### Áudio continua respondendo?
String do servidor: /run/user/1000/pulse/native
Versão do protocolo da biblioteca: 35
Versão do protocolo do servidor: 35
É local: sim
Índice do cliente: 44
Tamanho de fragmento: 65472
Nome do usuário: hal
Nome da máquina: Mocha
Nome do servidor: pulseaudio
Versão do servidor: 17.0-98-gb096
Especificação padrão de amostragem: s16le 2ch 44100Hz
Mapa de canais padrão: front-left,front-right
Destino padrão: bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink
Fonte padrão: bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink.monitor
Cookie: ed82:a34c
```

#### Fonte: `auditorias/20260529-152529-corrigir-blueman-auditar-volume/execucao.log`

Pontuação de relevância: 1

Linhas aproximadas 13-41:

```text
pulseaudio.service                                                                                                      loaded active running   Sound Service
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

### Processos relevantes antes
1014 /usr/bin/pipewire
1015 /usr/bin/wireplumber
1056 /usr/bin/pulseaudio --daemonize=no --log-target=journal
1114 /usr/bin/plasmashell --no-respawn
1994 /usr/bin/python /usr/bin/blueman-applet
2060 /usr/bin/kmix --keepvisibility

== 2/6 Criando override local para impedir autostart do Blueman ==
Criado override local a partir de: /etc/xdg/autostart/blueman.desktop
Override final:
38:Name=Blueman Applet
78:Exec=blueman-applet
83:Hidden=true

== 3/6 Parando Blueman Applet nesta sessão ==
Blueman após stop:
blueman-applet não está mais rodando.

== 4/6 Mantendo Bluetooth do KDE e serviço do sistema ==
bluetooth.service:
active

```

#### Fonte: `auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/LEIA-ME.txt`

Pontuação de relevância: 1

Linhas aproximadas 1-11:

```text
Auditoria somente leitura da duplicidade de Bluetooth/volume.

Arquivos principais:
- resumo-auditoria.txt
- plasma-applets-volume-bluetooth-systemtray.txt
- plasma-org.kde.plasma.desktop-appletsrc.copia

Interpretação esperada:
- Se houver org.kde.plasma.volume como applet independente e também dentro do system tray, a correção provável é remover apenas o applet independente.
- Se houver org.kde.plasma.bluetooth como applet independente e também dentro do system tray, a correção provável é remover apenas o applet independente.
- Não corrigir por dedução. Corrigir apenas após confirmar no relatório.
```

#### Fonte: `auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/resumo-auditoria.txt`

Pontuação de relevância: 1

Linhas aproximadas 115-143:

```text
app-blueman@autostart.service                                                                                           loaded active running   Blueman Applet
app-org.kde.bluedevilwizard@2c6d514fa32d417ea2e56bae877bd717.service                                                    loaded failed failed    Adicionar dispositivo Bluetooth - Adicionar dispositivo Bluetooth
app-pulseaudio@autostart.service                                                                                        loaded failed failed    PulseAudio Sound System
pipewire.service                                                                                                        loaded active running   PipeWire Multimedia Service
plasma-gmenudbusmenuproxy.service                                                                                       loaded active running   Proxies GTK DBus menus to a Plasma readable format
plasma-kaccess.service                                                                                                  loaded active running   KAccess
plasma-kactivitymanagerd.service                                                                                        loaded active running   KActivityManager Activity manager Service
plasma-kded6.service                                                                                                    loaded active running   KDE Daemon 6
plasma-ksmserver.service                                                                                                loaded active running   KDE Session Management Server
plasma-kwin_wayland.service                                                                                             loaded active running   KDE Wayland Compositor
plasma-plasmashell.service                                                                                              loaded active running   KDE Plasma Workspace
plasma-polkit-agent.service                                                                                             loaded active running   KDE PolicyKit Authentication Agent
plasma-powerdevil.service                                                                                               loaded active running   Powerdevil
plasma-xdg-desktop-portal-kde.service                                                                                   loaded active running   Xdg Desktop Portal For KDE
plasma-xembedsniproxy.service                                                                                           loaded active running   Handle legacy xembed system tray icons
pulseaudio.service                                                                                                      loaded active running   Sound Service
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth
plasma-core.target                                                                                                      loaded active active    KDE Plasma Workspace Core
plasma-workspace-wayland.target                                                                                         loaded active active    plasma-workspace-wayland.target
plasma-workspace.target                                                                                                 loaded active active    KDE Plasma Workspace

### ÁUDIO
String do servidor: /run/user/1000/pulse/native
Versão do protocolo da biblioteca: 35
Versão do protocolo do servidor: 35
É local: sim
```

Linhas aproximadas 157-185:

```text
3	bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink	module-bluez5-device.c	s16le 2ch 44100Hz	SUSPENDED

2	alsa_output.pci-0000_01_00.1.hdmi-stereo.monitor	module-alsa-card.c	s16le 2ch 44100Hz	SUSPENDED
3	bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink.monitor	module-bluez5-device.c	s16le 2ch 44100Hz	SUSPENDED

PipeWire 'pipewire-0' [1.6.6, hal@Mocha, cookie:1187326163]
 └─ Clients:
        32. kwin_wayland                        [1.6.6, hal@Mocha, pid:956]
        33. WirePlumber                         [1.6.6, hal@Mocha, pid:1015]
        41. WirePlumber [export]                [1.6.6, hal@Mocha, pid:1015]
        42. plasmashell                         [1.6.6, hal@Mocha, pid:1114]
        43. xdg-desktop-portal                  [1.6.6, hal@Mocha, pid:964]
        47. wpctl                               [1.6.6, hal@Mocha, pid:8278]

Audio
 ├─ Devices:
 │  
 ├─ Sinks:
 │  
 ├─ Sources:
 │  
 ├─ Filters:
 │  
 └─ Streams:

Video
 ├─ Devices:
 │  
 ├─ Sinks:
```

### Energia, CPU/GPU e agressividade

#### Fonte: `logs/20260529-154304-auditoria-estado-atual-para-manual.md`

Pontuação de relevância: 5

Linhas aproximadas 170-210:

```text
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
```

#### Fonte: `passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md`

Pontuação de relevância: 1

Linhas aproximadas 46-68:

```text
## Regra canônica

Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md`

Pontuação de relevância: 1

Linhas aproximadas 46-68:

```text
## Regra canônica

Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md`

Pontuação de relevância: 1

Linhas aproximadas 33-61:

```text
e encerrado o processo:

`kmix`

## O que não foi alterado

- Nenhum pacote foi removido.
- PipeWire não foi alterado.
- PulseAudio não foi alterado.
- Plasma volume applet foi preservado.
- Kernel, NVIDIA, Steam, MangoHud, GameMode e ajustes de performance não foram alterados.
- Bluetooth funcional foi preservado.
- O override anterior do Blueman foi preservado.

## Resultado esperado

- Ficar apenas um controle de volume na barra.
- Ficar apenas o Bluetooth do KDE/Bluedevil na barra.
- Desempenho e conectividade permanecem intactos.

## Reversão manual, se algum dia for necessário

Remover o override local:

```bash
rm -f "/home/hal/.config/autostart/kmix_autostart.desktop"
```

Depois encerrar sessão e entrar de novo.
```

#### Fonte: `documentacao/20260529-152416-baseline-superior-endeavour-steam-overlay-kde.md`

Pontuação de relevância: 1

Linhas aproximadas 20-30:

```text

## Decisão operacional

Este estado deve ser tratado como baseline positivo atual antes de qualquer alteração visual ou de painel.

Próximo passo seguro:

1. Auditar a configuração real do Plasma/KDE.
2. Identificar se a duplicidade vem de applets independentes, system tray, serviços auxiliares ou widgets fixados.
3. Corrigir somente o item duplicado identificado.
4. Não mexer em kernel, driver NVIDIA, Steam, agressividade/performance, Bluetooth funcional ou baseline de desempenho.
```

#### Fonte: `kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt`

Pontuação de relevância: 1

Linhas aproximadas 20-30:

```text
- Snapshot aprovado:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
- Script reutilizável:
  /media/mochafast/MochaArch/scripts/mocha-kde-barra-win11-aprovada-20260528-225617.sh
- Log desta gravação:
  /home/hal/mocha-salvar-barra-win11-aprovada-20260528-225617.log

Observação:
- Não depende de X11.
- Não instala pacotes.
- Não mexe em kernel, NVIDIA, boot, Steam ou receita de performance.
```

### Steam, MangoHud e wrapper

#### Fonte: `logs/20260529-154304-auditoria-estado-atual-para-manual.md`

Pontuação de relevância: 3

Linhas aproximadas 46-114:

```text
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
```

#### Fonte: `passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md`

Pontuação de relevância: 3

Linhas aproximadas 46-68:

```text
## Regra canônica

Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md`

Pontuação de relevância: 3

Linhas aproximadas 46-68:

```text
## Regra canônica

Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md`

Pontuação de relevância: 3

Linhas aproximadas 33-61:

```text
e encerrado o processo:

`kmix`

## O que não foi alterado

- Nenhum pacote foi removido.
- PipeWire não foi alterado.
- PulseAudio não foi alterado.
- Plasma volume applet foi preservado.
- Kernel, NVIDIA, Steam, MangoHud, GameMode e ajustes de performance não foram alterados.
- Bluetooth funcional foi preservado.
- O override anterior do Blueman foi preservado.

## Resultado esperado

- Ficar apenas um controle de volume na barra.
- Ficar apenas o Bluetooth do KDE/Bluedevil na barra.
- Desempenho e conectividade permanecem intactos.

## Reversão manual, se algum dia for necessário

Remover o override local:

```bash
rm -f "/home/hal/.config/autostart/kmix_autostart.desktop"
```

Depois encerrar sessão e entrar de novo.
```

#### Fonte: `auditorias/20260529-152416-plasma-duplicidade-bluetooth-volume/resumo-auditoria.txt`

Pontuação de relevância: 3

Linhas aproximadas 3-31:

```text

### KERNEL
Linux Mocha 7.0.10-arch1-1 #1 SMP PREEMPT_DYNAMIC Sat, 23 May 2026 14:21:20 +0000 x86_64 GNU/Linux

### PACOTES RELEVANTES
bluedevil 1:6.6.5-1
bluez 5.86-6
bluez-libs 5.86-6
bluez-qt 6.26.0-1
bluez-tools 0.2.0-6
gamemode 1.8.2-2
kdebugsettings 26.04.1-1
kdeclarative 6.26.0-1
kde-cli-tools 6.6.5-1
kdeconnect 26.04.1-1
kdecoration 6.6.5-1
kded 6.26.0-1
kde-dev-scripts 26.04.1-1
kde-dev-utils 26.04.1-1
kdeedu-data 26.04.1-1
kdegraphics-mobipocket 26.04.1-1
kdegraphics-thumbnailers 26.04.1-1
kde-gtk-config 6.6.5-1
kde-inotify-survey 26.04.1-2
kdenetwork-filesharing 26.04.1-1
kdenlive 26.04.1-1
kdepim-addons 26.04.1-1
kdepim-runtime 26.04.1-1
kdeplasma-addons 6.6.5-1
```

Linhas aproximadas 44-100:

```text
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
pipewire 1:1.6.6-1
pipewire-session-manager 1:1.6.6-1
plasma5support 6.6.5-1
plasma-activities 6.6.5-1
plasma-activities-stats 6.6.5-1
plasma-browser-integration 6.6.5-1
plasma-camera 26.04.1-1
plasma-desktop 6.6.5-1
plasma-disks 6.6.5-1
plasma-firewall 6.6.5-1
plasma-integration 6.6.5-2
plasma-keyboard 6.6.5-1
plasma-login-manager 6.6.5-1
plasma-nm 6.6.5-1
plasma-pa 6.6.5-1
plasma-sdk 6.6.5-1
plasma-systemmonitor 6.6.5-1
plasma-thunderbolt 6.6.5-1
plasmatube 26.04.1-2
plasma-vault 6.6.5-1
plasma-welcome 6.6.5-1
plasma-workspace 6.6.5-2
plasma-workspace-wallpapers 6.6.5-1
steam 1.0.0.85-7
steam-devices 1.0.0.85-7
wireplumber 0.5.14-1

### SERVIÇOS DO SISTEMA RELACIONADOS
● bluetooth.service - Bluetooth service
     Loaded: loaded (/usr/lib/systemd/system/bluetooth.service; enabled; preset: disabled)
     Active: active (running) since Fri 2026-05-29 14:29:45 -03; 54min ago
 Invocation: 040213ede68b4cc48886bc2a25c46bd6
       Docs: man:bluetoothd(8)
   Main PID: 617 (bluetoothd)
     Status: "Running"
      Tasks: 1 (limit: 18662)
     Memory: 2M (peak: 3.4M)
        CPU: 47ms
     CGroup: /system.slice/bluetooth.service
             └─617 /usr/lib/bluetooth/bluetoothd

mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSource/sbc
mai 29 14:29:54 Mocha bluetoothd[617]: Endpoint registered: sender=:1.50 path=/MediaEndpoint/A2DPSink/sbc_xq_453
```

#### Fonte: `kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh`

Pontuação de relevância: 1

Linhas aproximadas 1-24:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

echo "== MOCHA ARCH/KDE — restaurar barra Win11/Mocha aprovada =="

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

TS="$(date +%Y%m%d-%H%M%S)"
BASE="/media/mochafast/MochaArch"
TARGET="$BASE/ativo/kde/barra-win11-aprovada"
APPROVED="$TARGET/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617"
CFG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
BACKUP_DIR="$BASE/ativo/backups/plasma-barra"
LOG_DIR="$BASE/ativo/logs"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

LOG="$LOG_DIR/${TS}-restaurar-barra-win11-mocha-aprovada.log"
exec > >(tee -a "$LOG") 2>&1

if ! mountpoint -q /media/mochafast; then
  echo "ERRO: /media/mochafast não está montado."
  exit 1
```

#### Fonte: `logs/20260529-153031-aplicar-barra-kde-mocha-aprovada.log`

Pontuação de relevância: 1

Linhas aproximadas 8-37:

```text
  /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh

== Auditoria curta do script antes de executar ==
--- começo do script ---
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"

SUDO="sudo"
if [ -x /run/wrappers/bin/sudo ]; then
  SUDO="/run/wrappers/bin/sudo"
fi

apply_hidden_desktop_user() {
  local name="$1"
  local exec_line="$2"
  local comment="$3"
  local target="$HOME/.config/autostart/$name"
  local src=""

  mkdir -p "$HOME/.config/autostart"

  for candidate in \
    "/etc/xdg/autostart/$name" \
    "/usr/etc/xdg/autostart/$name" \
    "/usr/share/applications/$name"
  do
    if [ -f "$candidate" ]; then
      src="$candidate"
```

#### Fonte: `scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

Pontuação de relevância: 1

Linhas aproximadas 1-26:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"

SUDO="sudo"
if [ -x /run/wrappers/bin/sudo ]; then
  SUDO="/run/wrappers/bin/sudo"
fi

apply_hidden_desktop_user() {
  local name="$1"
  local exec_line="$2"
  local comment="$3"
  local target="$HOME/.config/autostart/$name"
  local src=""

  mkdir -p "$HOME/.config/autostart"

  for candidate in \
    "/etc/xdg/autostart/$name" \
    "/usr/etc/xdg/autostart/$name" \
    "/usr/share/applications/$name"
  do
    if [ -f "$candidate" ]; then
      src="$candidate"
```

#### Fonte: `documentacao/20260529-152416-baseline-superior-endeavour-steam-overlay-kde.md`

Pontuação de relevância: 1

Linhas aproximadas 1-30:

```text
# Mocha Arch/KDE — baseline superior ao Endeavour

Timestamp: 20260529-152416

## Resultado relatado pelo usuário

Este estado atual foi relatado como superior ao Endeavour em todos os aspectos principais:

- FPS alto usando a medição do overlay da Steam.
- Jogo fluido.
- Sistema em geral muito rápido.
- Sem problemas de conectividade Bluetooth.
- Desempenho geral superior ao Endeavour.

## Pendências observadas

- Há redundância relacionada ao Bluetooth.
- Há redundância no controle de volume.
- O controle de volume aparece duas vezes na barra de tarefas.

## Decisão operacional

Este estado deve ser tratado como baseline positivo atual antes de qualquer alteração visual ou de painel.

Próximo passo seguro:

1. Auditar a configuração real do Plasma/KDE.
2. Identificar se a duplicidade vem de applets independentes, system tray, serviços auxiliares ou widgets fixados.
3. Corrigir somente o item duplicado identificado.
4. Não mexer em kernel, driver NVIDIA, Steam, agressividade/performance, Bluetooth funcional ou baseline de desempenho.
```

#### Fonte: `scripts/mocha-aplicar-login-plasma-manager.sh`

Pontuação de relevância: 1

Linhas aproximadas 1-25:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

SUDO="/run/wrappers/bin/sudo"
[[ -x "$SUDO" ]] || SUDO="$(command -v sudo)"

echo "== MOCHA ARCH — aplicar login Plasma Manager =="
echo "Modo: troca display manager para plasma-login.service se existir."
echo "Não remove pacotes. Não toca XU. Não altera bootloader. Não configura X11."
echo

echo "== Auditoria antes da alteração =="
echo "-- display-manager.service --"
systemctl status display-manager.service --no-pager || true
echo
echo "-- estados relevantes --"
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || echo "plasma-login enabled: indisponível"
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || echo "plasma-login active: indisponível"
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || echo "sddm enabled: indisponível"
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || echo "sddm active: indisponível"
echo

```

#### Fonte: `scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh`

Pontuação de relevância: 1

Linhas aproximadas 1-25:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

SUDO="/run/wrappers/bin/sudo"
[[ -x "$SUDO" ]] || SUDO="$(command -v sudo)"

echo "== MOCHA ARCH — aplicar login Plasma Manager =="
echo "Modo: troca display manager para plasma-login.service se existir."
echo "Não remove pacotes. Não toca XU. Não altera bootloader. Não configura X11."
echo

echo "== Auditoria antes da alteração =="
echo "-- display-manager.service --"
systemctl status display-manager.service --no-pager || true
echo
echo "-- estados relevantes --"
systemctl is-enabled plasma-login.service 2>/dev/null | sed 's/^/plasma-login enabled: /' || echo "plasma-login enabled: indisponível"
systemctl is-active plasma-login.service 2>/dev/null | sed 's/^/plasma-login active: /' || echo "plasma-login active: indisponível"
systemctl is-enabled sddm.service 2>/dev/null | sed 's/^/sddm enabled: /' || echo "sddm enabled: indisponível"
systemctl is-active sddm.service 2>/dev/null | sed 's/^/sddm active: /' || echo "sddm active: indisponível"
echo

```

#### Fonte: `kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt`

Pontuação de relevância: 1

Linhas aproximadas 20-30:

```text
- Snapshot aprovado:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
- Script reutilizável:
  /media/mochafast/MochaArch/scripts/mocha-kde-barra-win11-aprovada-20260528-225617.sh
- Log desta gravação:
  /home/hal/mocha-salvar-barra-win11-aprovada-20260528-225617.log

Observação:
- Não depende de X11.
- Não instala pacotes.
- Não mexe em kernel, NVIDIA, boot, Steam ou receita de performance.
```

### Organização, limpeza e documentação

#### Fonte: `logs/20260529-154304-criar-manual-vivo-definitivo-mocha-arch-kde.log`

Pontuação de relevância: 3

Linhas aproximadas 1-12:

```text
== Preflight ==
FAST montado: OK
Pasta ativa: /media/mochafast/MochaArch/ativo

== Backup do manual anterior, se existir ==
Nenhum manual anterior com nome fixo.

== Gerando auditoria do estado atual ==
Auditoria salva:
  /media/mochafast/MochaArch/ativo/logs/20260529-154304-auditoria-estado-atual-para-manual.md

== Extraindo evidências e comandos salvos por tema ==
```

#### Fonte: `logs/20260529-154304-auditoria-estado-atual-para-manual.md`

Pontuação de relevância: 3

Linhas aproximadas 1-23:

```text
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
```

Linhas aproximadas 265-293:

```text
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
```

Linhas aproximadas 387-435:

```text
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
```

#### Fonte: `logs/20260529-153335-aplicar-appletsrc-barra-win11-aprovada.log`

Pontuação de relevância: 3

Linhas aproximadas 1-57:

```text
== Preflight ==
FAST montado: OK
Pasta aprovada: OK
Arquivo aprovado: OK
Config atual: OK

== Auditoria do arquivo aprovado ==
Arquivo:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617

Assinaturas esperadas:
30:plugin=org.kde.plasma.digitalclock
45:plugin=org.kde.plasma.kickoff
63:plugin=org.kde.plasma.icontasks
78:plugin=org.kde.plasma.systemtray
155:AppletOrder=4;6;23;3;5;24;7;21;22
163:plugin=org.kde.plasma.panelspacer
166:expanding=true
170:plugin=org.kde.plasma.panelspacer
173:expanding=true

Assinatura da barra aprovada validada.

== Criando script reutilizável na pasta aprovada ==
Script reutilizável criado:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh

== Executando restauração da barra aprovada ==
== MOCHA ARCH/KDE — restaurar barra Win11/Mocha aprovada ==
Backup salvo em:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
Parando Plasma Shell...
Aplicando appletsrc aprovado...
Reiniciando Plasma Shell...

Validação:
18:plugin=org.kde.plasma.digitalclock
33:plugin=org.kde.plasma.panelspacer
36:expanding=true
40:plugin=org.kde.plasma.panelspacer
43:expanding=true
47:plugin=org.kde.plasma.kickoff
65:plugin=org.kde.plasma.icontasks
80:plugin=org.kde.plasma.systemtray
161:AppletOrder=4;6;23;3;5;24;7;21;22

Barra Win11/Mocha aprovada restaurada.
Log:
  /media/mochafast/MochaArch/ativo/logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log
Backup:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11

== Finalizado ==
Log principal:
  /media/mochafast/MochaArch/ativo/logs/20260529-153335-aplicar-appletsrc-barra-win11-aprovada.log
Script salvo para uso futuro:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh
```

#### Fonte: `kde/barra-win11-aprovada/20260529-153335-aplicar-barra-win11-mocha-aprovada.sh`

Pontuação de relevância: 3

Linhas aproximadas 1-78:

```bash
#!/usr/bin/env bash
set -Eeuo pipefail

echo "== MOCHA ARCH/KDE — restaurar barra Win11/Mocha aprovada =="

export PATH="/run/wrappers/bin:/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"
export PAGER=cat SYSTEMD_PAGER=cat LESS=FRX

TS="$(date +%Y%m%d-%H%M%S)"
BASE="/media/mochafast/MochaArch"
TARGET="$BASE/ativo/kde/barra-win11-aprovada"
APPROVED="$TARGET/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617"
CFG="$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"
BACKUP_DIR="$BASE/ativo/backups/plasma-barra"
LOG_DIR="$BASE/ativo/logs"

mkdir -p "$BACKUP_DIR" "$LOG_DIR"

LOG="$LOG_DIR/${TS}-restaurar-barra-win11-mocha-aprovada.log"
exec > >(tee -a "$LOG") 2>&1

if ! mountpoint -q /media/mochafast; then
  echo "ERRO: /media/mochafast não está montado."
  exit 1
fi

if [ ! -f "$APPROVED" ]; then
  echo "ERRO: appletsrc aprovado não encontrado:"
  echo "  $APPROVED"
  exit 1
fi

if [ ! -f "$CFG" ]; then
  echo "ERRO: appletsrc atual não encontrado:"
  echo "  $CFG"
  exit 1
fi

if ! grep -q 'plugin=org.kde.plasma.panelspacer' "$APPROVED"; then
  echo "ERRO: arquivo aprovado sem panelspacer. Abortando."
  exit 1
fi

if ! grep -Eq 'plugin=org\.kde\.plasma\.(icontasks|taskmanager)' "$APPROVED"; then
  echo "ERRO: arquivo aprovado sem icontasks/taskmanager. Abortando."
  exit 1
fi

BACKUP="$BACKUP_DIR/${TS}-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11"
cp -a "$CFG" "$BACKUP"

find "$BACKUP_DIR" -maxdepth 1 -type f -name '*plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11*' \
  -printf '%T@ %p\n' 2>/dev/null \
  | sort -nr \
  | awk 'NR>2 {sub(/^[^ ]+ /,""); print}' \
  | while IFS= read -r old; do
      [ -n "$old" ] && rm -f -- "$old"
    done || true

echo "Backup salvo em:"
echo "  $BACKUP"

echo "Parando Plasma Shell..."
if command -v kquitapp6 >/dev/null 2>&1; then
  kquitapp6 plasmashell >/dev/null 2>&1 || true
else
  pkill -x plasmashell >/dev/null 2>&1 || true
fi

sleep 2

echo "Aplicando appletsrc aprovado..."
cp -a "$APPROVED" "$CFG"

echo "Reiniciando Plasma Shell..."
if command -v kstart6 >/dev/null 2>&1; then
  nohup kstart6 plasmashell >/tmp/mocha-plasmashell-${TS}.log 2>&1 &
elif command -v kstart >/dev/null 2>&1; then
```

#### Fonte: `logs/20260529-153031-aplicar-barra-kde-mocha-aprovada.log`

Pontuação de relevância: 3

Linhas aproximadas 1-26:

```text
== Preflight ==
FAST montado: OK
Pasta de scripts: /media/mochafast/MochaArch/ativo/scripts
Config Plasma: /home/hal/.config/plasma-org.kde.plasma.desktop-appletsrc

== Procurando script aprovado da barra Mocha/KDE ==
Script escolhido:
  /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh

== Auditoria curta do script antes de executar ==
--- começo do script ---
#!/usr/bin/env bash
set -Eeuo pipefail

export PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin:$PATH"

SUDO="sudo"
if [ -x /run/wrappers/bin/sudo ]; then
  SUDO="/run/wrappers/bin/sudo"
fi

apply_hidden_desktop_user() {
  local name="$1"
  local exec_line="$2"
  local comment="$3"
  local target="$HOME/.config/autostart/$name"
```

Linhas aproximadas 107-134:

```text
systemctl --user stop app-blueman@autostart.service 2>/dev/null || true
systemctl --user stop app-kmix_autostart@autostart.service 2>/dev/null || true
systemctl --user stop app-kmix@autostart.service 2>/dev/null || true
pkill -x blueman-applet 2>/dev/null || true
pkill -x kmix 2>/dev/null || true

echo "Mocha KDE: autostarts redundantes de Blueman e KMix desativados."
echo "Bluetooth fica com KDE/Bluedevil. Volume fica com Plasma Volume."
--- fim da auditoria curta ---

== Backup da configuração atual do Plasma ==
Backup salvo em:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153031-plasma-org.kde.plasma.desktop-appletsrc.antes-barra-mocha
Mantendo no máximo 2 backups recentes desta configuração...

== Executando script documentado/aprovado da barra ==
Mocha KDE: autostarts redundantes de Blueman e KMix desativados.
Bluetooth fica com KDE/Bluedevil. Volume fica com Plasma Volume.

== Reiniciando Plasma Shell para refletir a barra, se necessário ==

== Finalizado ==
Barra Mocha aplicada usando:
  /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh
Log:
  /media/mochafast/MochaArch/ativo/logs/20260529-153031-aplicar-barra-kde-mocha-aprovada.log
Backup:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153031-plasma-org.kde.plasma.desktop-appletsrc.antes-barra-mocha
```

#### Fonte: `auditorias/20260529-152907-canonizar-barra-sem-duplicidade/execucao.log`

Pontuação de relevância: 3

Linhas aproximadas 1-19:

```text
== 1/6 Confirmando applets nativos do KDE/Plasma ==
75:plugin=org.kde.plasma.systemtray
114:plugin=org.kde.plasma.volume
145:plugin=org.kde.plasma.bluetooth

== 2/6 Aplicando permanência no usuário atual ==
OK usuário: /home/hal/.config/autostart/blueman.desktop
38:Name=Blueman Applet
78:Exec=blueman-applet
83:Hidden=true

OK usuário: /home/hal/.config/autostart/kmix_autostart.desktop
2:Exec=kmix --keepvisibility
4:OnlyShowIn=KDE;
69:Name=KMix
128:Hidden=true

== 3/6 Preparando /etc/skel para novos usuários do Mocha ==
OK /etc/skel: /etc/skel/.config/autostart/blueman.desktop
```

Linhas aproximadas 39-60:

```text
sys-subsystem-bluetooth-devices-hci0:1.device                                                                           loaded active plugged   /sys/subsystem/bluetooth/devices/hci0:1
app-org.kde.bluedevilwizard@2c6d514fa32d417ea2e56bae877bd717.service                                                    loaded failed failed    Adicionar dispositivo Bluetooth - Adicionar dispositivo Bluetooth
app-pulseaudio@autostart.service                                                                                        loaded failed failed    PulseAudio Sound System
pipewire.service                                                                                                        loaded active running   PipeWire Multimedia Service
pulseaudio.service                                                                                                      loaded active running   Sound Service
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

== 5/6 Criando script reutilizável ==
Script criado: /media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh

== 6/6 Documentando como passo canônico de montagem ==
Documento criado:
/media/mochafast/MochaArch/ativo/documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md

Passo canônico criado:
/media/mochafast/MochaArch/ativo/passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md

Log salvo em:
/media/mochafast/MochaArch/ativo/auditorias/20260529-152907-canonizar-barra-sem-duplicidade/execucao.log
```

#### Fonte: `auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log`

Pontuação de relevância: 3

Linhas aproximadas 14-42:

```text
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

### Processos relevantes antes
1014 /usr/bin/pipewire
1015 /usr/bin/wireplumber
1056 /usr/bin/pulseaudio --daemonize=no --log-target=journal
1114 /usr/bin/plasmashell --no-respawn
2060 /usr/bin/kmix --keepvisibility
8437 tee /media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log

== 2/7 Confirmando que o volume do Plasma existe no system tray ==
OK: org.kde.plasma.volume existe no Plasma. Podemos remover apenas o KMix redundante da sessão/autostart.

== 3/7 Localizando arquivo original de autostart do KMix ==
Fonte encontrada: /etc/xdg/autostart/kmix_autostart.desktop

== 4/7 Criando override local com Hidden=true para KMix ==
Override final:
2:Exec=kmix --keepvisibility
4:OnlyShowIn=KDE;
69:Name=KMix
128:Hidden=true

== 5/7 Parando KMix nesta sessão ==
KMix após stop:
OK: kmix não está mais rodando.

```

Linhas aproximadas 54-97:

```text
wireplumber.service                                                                                                     loaded active running   Multimedia Service Session Manager
pipewire.socket                                                                                                         loaded active running   PipeWire Multimedia System Sockets
pulseaudio.socket                                                                                                       loaded active running   Sound System
bluetooth.target                                                                                                        loaded active active    Bluetooth

### Processos relevantes depois
1014 /usr/bin/pipewire
1015 /usr/bin/wireplumber
1056 /usr/bin/pulseaudio --daemonize=no --log-target=journal
1114 /usr/bin/plasmashell --no-respawn
8437 tee /media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log

### Áudio continua respondendo?
String do servidor: /run/user/1000/pulse/native
Versão do protocolo da biblioteca: 35
Versão do protocolo do servidor: 35
É local: sim
Índice do cliente: 44
Tamanho de fragmento: 65472
Nome do usuário: hal
Nome da máquina: Mocha
Nome do servidor: pulseaudio
Versão do servidor: 17.0-98-gb096
Especificação padrão de amostragem: s16le 2ch 44100Hz
Mapa de canais padrão: front-left,front-right
Destino padrão: bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink
Fonte padrão: bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink.monitor
Cookie: ed82:a34c

2	alsa_output.pci-0000_01_00.1.hdmi-stereo	module-alsa-card.c	s16le 2ch 44100Hz	SUSPENDED
3	bluez_sink.0C_ED_E7_FF_AB_9D.a2dp_sink	module-bluez5-device.c	s16le 2ch 44100Hz	SUSPENDED

### Bluetooth continua ativo?
active

== 7/7 Salvando documentação e script reutilizável ==
Documento criado:
/media/mochafast/MochaArch/ativo/documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md

Script reutilizável criado:
/media/mochafast/MochaArch/ativo/scripts/20260529-152700-mocha-desativar-kmix-volume-duplicado.sh

Log salvo em:
/media/mochafast/MochaArch/ativo/auditorias/20260529-152700-corrigir-kmix-volume-duplicado/execucao.log
```

#### Fonte: `kde/barra-win11-aprovada/NOTA-BARRA-WIN11-APROVADA-20260528-225617.txt`

Pontuação de relevância: 3

Linhas aproximadas 1-30:

```text
MOCHA ARCH / KDE — BARRA ESTILO WINDOWS 11 APROVADA
Timestamp: 20260528-225617

Status:
- Funcionou e foi aprovado pelo usuário nesta instalação EndeavourOS KDE.
- Deve ser preservado como solução de referência para MochaArch.

O que a solução faz:
- Audita o arquivo real:
  $HOME/.config/plasma-org.kde.plasma.desktop-appletsrc
- Cria backup com timestamp.
- Mantém no máximo 2 backups do arquivo da barra.
- Usa dois org.kde.plasma.panelspacer expansíveis.
- Centraliza Kickoff/Iniciar + icontasks/taskmanager.
- Preserva pager/outros applets à esquerda.
- Mantém systemtray/digitalclock/showdesktop à direita.
- Reinicia somente plasmashell.

Arquivos salvos:
- Snapshot aprovado:
  /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
- Script reutilizável:
  /media/mochafast/MochaArch/scripts/mocha-kde-barra-win11-aprovada-20260528-225617.sh
- Log desta gravação:
  /home/hal/mocha-salvar-barra-win11-aprovada-20260528-225617.log

Observação:
- Não depende de X11.
- Não instala pacotes.
- Não mexe em kernel, NVIDIA, boot, Steam ou receita de performance.
```

#### Fonte: `logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log`

Pontuação de relevância: 2

Linhas aproximadas 1-22:

```text
Backup salvo em:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
Parando Plasma Shell...
Aplicando appletsrc aprovado...
Reiniciando Plasma Shell...

Validação:
18:plugin=org.kde.plasma.digitalclock
33:plugin=org.kde.plasma.panelspacer
36:expanding=true
40:plugin=org.kde.plasma.panelspacer
43:expanding=true
47:plugin=org.kde.plasma.kickoff
65:plugin=org.kde.plasma.icontasks
80:plugin=org.kde.plasma.systemtray
161:AppletOrder=4;6;23;3;5;24;7;21;22

Barra Win11/Mocha aprovada restaurada.
Log:
  /media/mochafast/MochaArch/ativo/logs/20260529-153335-restaurar-barra-win11-mocha-aprovada.log
Backup:
  /media/mochafast/MochaArch/ativo/backups/plasma-barra/20260529-153335-plasma-org.kde.plasma.desktop-appletsrc.antes-restaurar-barra-win11
```

#### Fonte: `passos-canonicos/20260529-152907-passo-montagem-kde-desativar-blueman-kmix-autostart.md`

Pontuação de relevância: 2

Linhas aproximadas 8-36:

```text

## Sintoma corrigido

Na barra do KDE/Plasma havia duplicidade de:

- Bluetooth.
- Controle de volume.

## Causa confirmada

A barra já tinha os applets nativos do KDE/Plasma:

- `org.kde.plasma.bluetooth`
- `org.kde.plasma.volume`

Além disso, estavam subindo autostarts redundantes:

- `blueman-applet`
- `kmix --keepvisibility`

## Correção aprovada

Não remover pacotes.

Apenas criar overrides de autostart com:

`Hidden=true`

Arquivos do usuário atual:
```

Linhas aproximadas 48-68:

```text
Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md`

Pontuação de relevância: 2

Linhas aproximadas 8-36:

```text

## Sintoma corrigido

Na barra do KDE/Plasma havia duplicidade de:

- Bluetooth.
- Controle de volume.

## Causa confirmada

A barra já tinha os applets nativos do KDE/Plasma:

- `org.kde.plasma.bluetooth`
- `org.kde.plasma.volume`

Além disso, estavam subindo autostarts redundantes:

- `blueman-applet`
- `kmix --keepvisibility`

## Correção aprovada

Não remover pacotes.

Apenas criar overrides de autostart com:

`Hidden=true`

Arquivos do usuário atual:
```

Linhas aproximadas 48-68:

```text
Ao montar o Mocha Arch/KDE:

1. Preservar KDE/Bluedevil como Bluetooth visual da barra.
2. Preservar Plasma Volume como controle de volume da barra.
3. Desativar autostart redundante do Blueman Applet.
4. Desativar autostart redundante do KMix.
5. Não remover os pacotes.
6. Não mexer em PipeWire/PulseAudio durante esta etapa.
7. Não mexer em kernel, NVIDIA, Steam, MangoHud, GameMode ou ajustes de performance.

## Script reutilizável

`/media/mochafast/MochaArch/ativo/scripts/20260529-152907-mocha-kde-desativar-blueman-kmix-autostart.sh`

## Resultado esperado

- Um único ícone de Bluetooth.
- Um único controle de volume.
- Bluetooth funcional preservado.
- Áudio funcional preservado.
- Desempenho do baseline aprovado preservado.
```

#### Fonte: `documentacao/20260529-150104-login-plasma-manager-esquema-aprovado.md`

Pontuação de relevância: 2

Linhas aproximadas 25-41:

```text
1. Usar `plasma-login.service` como display manager quando disponível.
2. Desabilitar `sddm.service` para evitar conflito com login manager antigo.
3. Não usar X11/Xorg como fallback.
4. Não remover pacotes.
5. Não tocar na pasta XU.
6. Não apagar entradas de boot.
7. Antes de editar configuração, auditar o estado real.

## Script salvo

Script reutilizável:

`/media/mochafast/MochaArch/ativo/scripts/20260529-150104-mocha-aplicar-login-plasma-manager.sh`

Atalho estável atualizado:

`/media/mochafast/MochaArch/ativo/scripts/mocha-aplicar-login-plasma-manager.sh`
```

