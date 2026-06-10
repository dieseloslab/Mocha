#!/usr/bin/env bash
set -Eeuo pipefail
export LC_ALL=C

BASE="/media/mochafast/MochaArch"
AUD="$BASE/auditorias"
TS="$(date +%Y%m%d-%H%M%S)"
REL="$AUD/mocha-auditoria-completa-fps-$TS.log"
RES="$AUD/mocha-auditoria-completa-fps-resumo-$TS.txt"
KEEPALIVE=""
PASS=0
WARN=0
FAIL=0
INFO=0

mkdir -p "$AUD"
: > "$RES"
exec > >(tee -a "$REL") 2>&1

cleanup() {
    if [ -n "${KEEPALIVE:-}" ]; then
        kill "$KEEPALIVE" 2>/dev/null || true
    fi
}
trap cleanup EXIT

section() {
    echo
    echo "============================================================"
    echo " $1"
    echo "============================================================"
}

pass() {
    PASS=$((PASS + 1))
    printf '[OK] %s\n' "$*" | tee -a "$RES"
}

warn() {
    WARN=$((WARN + 1))
    printf '[ATENÇÃO] %s\n' "$*" | tee -a "$RES"
}

fail() {
    FAIL=$((FAIL + 1))
    printf '[FALHA] %s\n' "$*" | tee -a "$RES"
}

info() {
    INFO=$((INFO + 1))
    printf '[INFO] %s\n' "$*" | tee -a "$RES"
}

have() {
    command -v "$1" >/dev/null 2>&1
}

show_file() {
    local file="$1"
    if [ -r "$file" ]; then
        echo "----- $file"
        sed -n '1,240p' "$file" || true
    elif sudo test -r "$file" 2>/dev/null; then
        echo "----- $file"
        sudo sed -n '1,240p' "$file" || true
    fi
}

show_unit() {
    local unit="$1"
    echo "----- $unit"
    systemctl is-enabled "$unit" 2>/dev/null || true
    systemctl is-active "$unit" 2>/dev/null || true
    systemctl status "$unit" --no-pager -l 2>/dev/null | sed -n '1,80p' || true
}

printf '============================================================\n'
printf ' MochaArch — auditoria completa de regressão de FPS\n'
printf ' Data: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"
printf ' Host: %s\n' "$(hostnamectl --static 2>/dev/null || hostname)"
printf ' Relatório: %s\n' "$REL"
printf ' Resumo: %s\n' "$RES"
printf ' Modo: SOMENTE LEITURA; nenhuma configuração será alterada\n'
printf '============================================================\n\n'

printf '==> Validando sudo para leituras privilegiadas\n'
sudo -v
(
    while true; do
        sudo -n true 2>/dev/null || exit
        sleep 50
    done
) &
KEEPALIVE=$!

section "1. Identificação, sessão e baseline"
date
uname -a
hostnamectl 2>/dev/null || true
printf 'XDG_SESSION_TYPE=%s\n' "${XDG_SESSION_TYPE:-}"
printf 'XDG_CURRENT_DESKTOP=%s\n' "${XDG_CURRENT_DESKTOP:-}"
printf 'DESKTOP_SESSION=%s\n' "${DESKTOP_SESSION:-}"
printf 'KDE_FULL_SESSION=%s\n' "${KDE_FULL_SESSION:-}"
printf 'WAYLAND_DISPLAY=%s\n' "${WAYLAND_DISPLAY:-}"
printf 'DISPLAY=%s\n' "${DISPLAY:-}"

if [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
    pass "Sessão gráfica está em Wayland."
else
    fail "Sessão atual não está em Wayland: XDG_SESSION_TYPE=${XDG_SESSION_TYPE:-vazio}."
fi

section "2. Kernel atual, pacotes, origem e resíduos do RC"
KERNEL="$(uname -r)"
printf 'Kernel em execução: %s\n' "$KERNEL"

if [[ "$KERNEL" =~ (^|[-.])[Rr][Cc][0-9]*($|[-.]) ]]; then
    fail "Kernel RC ainda está em execução: $KERNEL."
else
    pass "Kernel em execução não é RC: $KERNEL."
fi

PKGBASE_FILE="/usr/lib/modules/$KERNEL/pkgbase"
PKGBASE=""
if [ -r "$PKGBASE_FILE" ]; then
    PKGBASE="$(cat "$PKGBASE_FILE")"
    printf 'pkgbase=%s\n' "$PKGBASE"
else
    warn "Não foi possível ler $PKGBASE_FILE."
fi

printf '\nPacotes de kernel instalados:\n'
pacman -Q 2>/dev/null | grep -E '^(linux($|-)|linux-cachyos|linux-zen|linux-lts|linux-mainline|linux-.*rc)' || true

printf '\nPacotes RC detectados:\n'
RC_PKGS="$(pacman -Qq 2>/dev/null | grep -Ei '(^|-)rc($|-)|linux.*rc|rc.*headers' || true)"
if [ -n "$RC_PKGS" ]; then
    printf '%s\n' "$RC_PKGS"
    warn "Ainda existem pacotes com aparência de RC instalados; revisar a lista acima."
else
    pass "Nenhum pacote de kernel RC foi encontrado pelo nome."
fi

printf '\nDiretórios de módulos presentes:\n'
find /usr/lib/modules -mindepth 1 -maxdepth 1 -type d -printf '%f\n' 2>/dev/null | sort -V || true

if [ -n "$PKGBASE" ]; then
    if pacman -Q "$PKGBASE" >/dev/null 2>&1; then
        pass "Pacote proprietário do kernel em execução está instalado: $PKGBASE."
        pacman -Qi "$PKGBASE" 2>/dev/null | sed -n '1,80p' || true
    else
        fail "pkgbase do kernel em execução não corresponde a pacote instalado: $PKGBASE."
    fi

    if pacman -Q "${PKGBASE}-headers" >/dev/null 2>&1; then
        pass "Headers correspondentes instalados: ${PKGBASE}-headers."
    else
        fail "Headers correspondentes ausentes: ${PKGBASE}-headers."
    fi
fi

printf '\nLinha de comando do kernel:\n'
cat /proc/cmdline

printf '\nParâmetros potencialmente relevantes:\n'
for token in amd_pstate mitigations preempt threadirqs split_lock_detect pcie_aspm pci intel_pstate nowatchdog nvidia_drm.modeset nvidia_drm.fbdev; do
    grep -oE "(^| )${token}=[^ ]+" /proc/cmdline 2>/dev/null || true
done

if grep -Eq '(^| )mitigations=off( |$)' /proc/cmdline; then
    info "mitigations=off está ativo; pode favorecer desempenho, com redução de segurança."
else
    info "mitigations=off não está ativo."
fi

printf '\nArquivos de boot e initramfs:\n'
ls -lh /boot 2>/dev/null | sed -n '1,160p' || true

printf '\nConfiguração mkinitcpio relevante:\n'
show_file /etc/mkinitcpio.conf
find /etc/mkinitcpio.conf.d -maxdepth 1 -type f -name '*.conf' -print -exec sudo sed -n '1,200p' {} \; 2>/dev/null || true

if have lsinitcpio; then
    printf '\nMódulos NVIDIA encontrados nos initramfs:\n'
    for image in /boot/initramfs-*.img; do
        [ -e "$image" ] || continue
        echo "----- $image"
        sudo lsinitcpio "$image" 2>/dev/null | grep -E '(^|/)(nvidia|nvidia_drm|nvidia_modeset|nvidia_uvm)(\.ko|/)' | head -n 80 || true
    done
fi

printf '\nHistórico recente de kernel/NVIDIA no pacman.log:\n'
sudo grep -Ei '\[(ALPM|PACMAN)\].*(linux-cachyos|linux.*rc|nvidia|mkinitcpio|dracut|grub)' /var/log/pacman.log 2>/dev/null | tail -n 320 || true

section "3. NVIDIA: pacotes, módulo, DKMS e consistência"
printf 'Pacotes NVIDIA instalados:\n'
pacman -Q 2>/dev/null | grep -E '^(nvidia|lib32-nvidia|opencl-nvidia|lib32-opencl-nvidia|egl-wayland|vulkan-icd-loader)' || true

printf '\nEstado DKMS:\n'
if have dkms; then
    dkms status || true
else
    echo "dkms não instalado"
fi

printf '\nMódulos carregados:\n'
lsmod | grep -E '^(nvidia|nouveau)' || true

if grep -q '^nouveau ' /proc/modules 2>/dev/null; then
    fail "nouveau está carregado junto da pilha NVIDIA proprietária/open."
else
    pass "nouveau não está carregado."
fi

if grep -q '^nvidia ' /proc/modules 2>/dev/null; then
    pass "Módulo NVIDIA está carregado."
else
    fail "Módulo NVIDIA não está carregado."
fi

printf '\nInformações do módulo NVIDIA:\n'
for mod in nvidia nvidia_drm nvidia_modeset nvidia_uvm; do
    echo "----- $mod"
    modinfo "$mod" 2>/dev/null | grep -E '^(filename|version|license|firmware|vermagic|parm):' | head -n 100 || true
done

NVIDIA_MOD_VERSION="$(cat /sys/module/nvidia/version 2>/dev/null || true)"
printf 'Versão do módulo carregado: %s\n' "${NVIDIA_MOD_VERSION:-indisponível}"

if [ -n "$NVIDIA_MOD_VERSION" ]; then
    NVUTILS_VERSION="$(pacman -Q nvidia-utils 2>/dev/null | awk '{print $2}' | sed 's/-[0-9][0-9]*$//' || true)"
    printf 'Versão base nvidia-utils: %s\n' "${NVUTILS_VERSION:-indisponível}"
    if [ -n "$NVUTILS_VERSION" ] && [ "$NVIDIA_MOD_VERSION" = "$NVUTILS_VERSION" ]; then
        pass "Módulo NVIDIA e nvidia-utils usam a mesma versão: $NVIDIA_MOD_VERSION."
    else
        fail "Possível descasamento NVIDIA: módulo=${NVIDIA_MOD_VERSION:-?}, nvidia-utils=${NVUTILS_VERSION:-?}."
    fi
fi

printf '\nArquivo real do módulo e pacote proprietário:\n'
NVIDIA_KO="$(modinfo -n nvidia 2>/dev/null || true)"
printf 'nvidia.ko=%s\n' "${NVIDIA_KO:-indisponível}"
if [ -n "$NVIDIA_KO" ] && [ -e "$NVIDIA_KO" ]; then
    pacman -Qo "$NVIDIA_KO" 2>/dev/null || warn "O arquivo do módulo NVIDIA não pertence diretamente a um pacote; isso é normal para DKMS, mas confirma uso de módulo compilado localmente."
fi

printf '\nParâmetros do módulo:\n'
for f in /sys/module/nvidia_drm/parameters/modeset /sys/module/nvidia_drm/parameters/fbdev /sys/module/nvidia/parameters/NVreg_EnableGpuFirmware /sys/module/nvidia/parameters/NVreg_PreserveVideoMemoryAllocations; do
    if sudo test -r "$f" 2>/dev/null; then
        printf '%s=' "$f"
        sudo cat "$f" 2>/dev/null || true
    fi
done

MODESET="$(sudo cat /sys/module/nvidia_drm/parameters/modeset 2>/dev/null || true)"
if [ "$MODESET" = "Y" ] || [ "$MODESET" = "1" ]; then
    pass "nvidia_drm.modeset está ativo."
else
    fail "nvidia_drm.modeset não está ativo."
fi

printf '\nConfigurações modprobe NVIDIA/nouveau:\n'
find /etc/modprobe.d /usr/lib/modprobe.d -maxdepth 1 -type f \( -iname '*nvidia*' -o -iname '*nouveau*' -o -iname '*blacklist*' \) -print 2>/dev/null | while read -r f; do
    echo "----- $f"
    grep -Ev '^[[:space:]]*(#|$)' "$f" 2>/dev/null || true
done

if have nvidia-smi; then
    printf '\nnvidia-smi resumo:\n'
    nvidia-smi || true
    printf '\nConsultas principais:\n'
    nvidia-smi --query-gpu=index,name,driver_version,pstate,temperature.gpu,utilization.gpu,utilization.memory,memory.total,memory.used,power.draw,power.limit,clocks.current.graphics,clocks.current.memory,clocks.max.graphics,clocks.max.memory,pcie.link.gen.current,pcie.link.gen.max,pcie.link.width.current,pcie.link.width.max --format=csv,noheader,nounits 2>/dev/null || true
    printf '\nDetalhes de desempenho, clocks, energia, temperatura e PCIe:\n'
    nvidia-smi -q 2>/dev/null || true
    pass "nvidia-smi respondeu corretamente."
else
    fail "nvidia-smi não está disponível."
fi

section "4. GPU, PCIe, BAR, DRM e monitor"
printf 'Controladores gráficos:\n'
lspci -nnk | grep -A4 -Ei 'VGA|3D|Display' || true

GPU_BDF="$(lspci -Dnn 2>/dev/null | awk '/VGA compatible controller|3D controller|Display controller/ && /NVIDIA/ && !found {print $1; found=1}')"
printf 'GPU_BDF=%s\n' "${GPU_BDF:-indisponível}"
if [ -n "$GPU_BDF" ]; then
    sudo lspci -s "$GPU_BDF" -vv 2>/dev/null | sed -n '/LnkCap:/p;/LnkSta:/p;/LnkCtl:/p;/Resizable BAR/p;/BAR /p;/Capabilities:/p' || true
    printf '\nNUMA e afinidade local da GPU:\n'
    for f in numa_node local_cpulist local_cpus; do
        if [ -r "/sys/bus/pci/devices/$GPU_BDF/$f" ]; then
            printf '%s=' "$f"
            cat "/sys/bus/pci/devices/$GPU_BDF/$f"
        fi
    done
fi

printf '\nResizable BAR pelo driver NVIDIA:\n'
if [ -r /proc/driver/nvidia/gpus/0000:01:00.0/information ]; then
    grep -Ei 'Model|IRQ|GPU UUID|Video BIOS|Bus Location|Device Minor|Blacklisted|Architecture' /proc/driver/nvidia/gpus/*/information 2>/dev/null || true
fi
nvidia-smi -q 2>/dev/null | grep -A4 -Ei 'BAR1 Memory Usage|Resizable BAR' || true

printf '\nSaídas KScreen/Wayland:\n'
if have kscreen-doctor; then
    kscreen-doctor -o || true
else
    echo "kscreen-doctor não disponível"
fi

printf '\nDRM connectors:\n'
for status in /sys/class/drm/card*-*/status; do
    [ -r "$status" ] || continue
    connector="${status%/status}"
    if [ "$(cat "$status" 2>/dev/null)" = "connected" ]; then
        echo "----- ${connector##*/}"
        printf 'status='; cat "$status"
        [ -r "$connector/modes" ] && sed -n '1,30p' "$connector/modes"
        [ -r "$connector/enabled" ] && { printf 'enabled='; cat "$connector/enabled"; }
    fi
done

section "5. CPU: driver, governor, EPP, boost, clocks e energia"
lscpu
printf '\nCPU vulnerabilities/mitigations:\n'
grep . /sys/devices/system/cpu/vulnerabilities/* 2>/dev/null || true

printf '\nPolíticas cpufreq:\n'
CPU_GOV_BAD=0
CPU_EPP_BAD=0
POLICY_COUNT=0
for p in /sys/devices/system/cpu/cpufreq/policy*; do
    [ -d "$p" ] || continue
    POLICY_COUNT=$((POLICY_COUNT + 1))
    echo "----- ${p##*/}"
    for f in scaling_driver scaling_governor energy_performance_preference energy_performance_available_preferences scaling_min_freq scaling_max_freq cpuinfo_min_freq cpuinfo_max_freq affected_cpus; do
        if [ -r "$p/$f" ]; then
            printf '%s=' "$f"
            cat "$p/$f"
        fi
    done
    GOV="$(cat "$p/scaling_governor" 2>/dev/null || true)"
    EPP="$(cat "$p/energy_performance_preference" 2>/dev/null || true)"
    [ "$GOV" = "performance" ] || CPU_GOV_BAD=$((CPU_GOV_BAD + 1))
    if [ -n "$EPP" ] && [ "$EPP" != "performance" ]; then
        CPU_EPP_BAD=$((CPU_EPP_BAD + 1))
    fi
done

if [ "$POLICY_COUNT" -eq 0 ]; then
    warn "Nenhuma política cpufreq foi encontrada."
elif [ "$CPU_GOV_BAD" -eq 0 ]; then
    pass "Todas as políticas CPU estão com governor performance."
else
    fail "$CPU_GOV_BAD política(s) CPU não estão em governor performance."
fi

if [ "$CPU_EPP_BAD" -eq 0 ]; then
    pass "Todas as políticas com EPP disponível estão em performance."
else
    fail "$CPU_EPP_BAD política(s) CPU usam EPP diferente de performance."
fi

printf '\nBoost e AMD P-State:\n'
for f in /sys/devices/system/cpu/cpufreq/boost /sys/devices/system/cpu/amd_pstate/status /sys/devices/system/cpu/amd_pstate/cppc_dynamic_boost /sys/devices/system/cpu/amd_pstate/prefcore; do
    if [ -r "$f" ]; then
        printf '%s=' "$f"
        cat "$f"
    fi
done

if [ -r /sys/devices/system/cpu/cpufreq/boost ]; then
    BOOST="$(cat /sys/devices/system/cpu/cpufreq/boost)"
    if [ "$BOOST" = "1" ]; then
        pass "CPU boost está habilitado."
    else
        fail "CPU boost está desabilitado."
    fi
fi

printf '\ncpupower:\n'
if have cpupower; then
    cpupower frequency-info || true
    cpupower idle-info || true
else
    echo "cpupower não disponível"
fi

printf '\nTopologia, isolamento e estado online:\n'
printf 'online='; cat /sys/devices/system/cpu/online 2>/dev/null || true
printf 'isolated='; cat /sys/devices/system/cpu/isolated 2>/dev/null || true
printf 'nohz_full='; cat /sys/devices/system/cpu/nohz_full 2>/dev/null || true

printf '\nC-states/idle drivers:\n'
for f in /sys/devices/system/cpu/cpuidle/current_driver /sys/devices/system/cpu/cpuidle/current_governor /sys/devices/system/cpu/cpuidle/current_governor_ro; do
    [ -r "$f" ] && { printf '%s=' "$f"; cat "$f"; }
done

printf '\nSensores e temperaturas:\n'
if have sensors; then
    sensors || true
else
    echo "sensors não disponível"
fi

section "6. TuneD, GameMode e serviços que alteram energia"
printf 'TuneD:\n'
if have tuned-adm; then
    tuned-adm active || true
    tuned-adm verify || true
    TUNED_ACTIVE="$(tuned-adm active 2>/dev/null | sed -n 's/^Current active profile: //p' | tail -n 1)"
    if [ "$TUNED_ACTIVE" = "mocha-latency-performance" ]; then
        pass "Perfil TuneD correto está ativo: mocha-latency-performance."
    else
        fail "Perfil TuneD ativo diverge do padrão Mocha: ${TUNED_ACTIVE:-indisponível}."
    fi
else
    fail "tuned-adm não está disponível."
fi
show_unit tuned.service

printf '\nPerfil Mocha do TuneD:\n'
find /etc/tuned /usr/lib/tuned -maxdepth 3 -type f -path '*mocha-latency-performance*' -print -exec sudo sed -n '1,260p' {} \; 2>/dev/null || true

printf '\nGameMode:\n'
if have gamemoded; then
    gamemoded -t || warn "gamemoded -t encontrou falha; ver saída acima."
else
    fail "gamemoded não está disponível."
fi
systemctl --user status gamemoded.service --no-pager -l 2>/dev/null | sed -n '1,100p' || true

printf '\nServiços potencialmente conflitantes:\n'
for unit in power-profiles-daemon.service tlp.service auto-cpufreq.service cpupower.service irqbalance.service thermald.service nvidia-persistenced.service lactd.service; do
    show_unit "$unit"
done

for unit in power-profiles-daemon.service tlp.service auto-cpufreq.service; do
    if systemctl is-active --quiet "$unit" 2>/dev/null; then
        warn "$unit está ativo e pode disputar políticas com o TuneD."
    fi
done

section "7. Memória, zram, swap, THP e sysctl de agressividade"
free -h
printf '\nSwap:\n'
swapon --show --output=NAME,TYPE,SIZE,USED,PRIO 2>/dev/null || true

ZRAM_LINE="$(swapon --show --noheadings --raw --output=NAME,PRIO 2>/dev/null | awk '$1 ~ /zram/ && !found {print; found=1}' || true)"
if [ -n "$ZRAM_LINE" ]; then
    ZRAM_PRIO="$(awk '{print $2}' <<< "$ZRAM_LINE")"
    if [ "$ZRAM_PRIO" = "32767" ]; then
        pass "zram está ativa com prioridade 32767."
    else
        fail "zram está ativa, mas prioridade é ${ZRAM_PRIO:-?}, esperada 32767."
    fi
else
    fail "Nenhuma swap zram ativa foi encontrada."
fi

printf '\nAlgoritmo e estatísticas zram:\n'
for z in /sys/block/zram*; do
    [ -d "$z" ] || continue
    echo "----- ${z##*/}"
    for f in comp_algorithm disksize mem_used_total compr_data_size orig_data_size; do
        [ -r "$z/$f" ] && { printf '%s=' "$f"; cat "$z/$f"; }
    done
done

SWAPPINESS="$(sysctl -n vm.swappiness 2>/dev/null || true)"
PAGE_CLUSTER="$(sysctl -n vm.page-cluster 2>/dev/null || true)"
THP="$(cat /sys/kernel/mm/transparent_hugepage/enabled 2>/dev/null || true)"
printf 'vm.swappiness=%s\n' "$SWAPPINESS"
printf 'vm.page-cluster=%s\n' "$PAGE_CLUSTER"
printf 'THP=%s\n' "$THP"

[ "$SWAPPINESS" = "133" ] && pass "vm.swappiness=133 conforme baseline Mocha." || fail "vm.swappiness=${SWAPPINESS:-?}; esperado 133."
[ "$PAGE_CLUSTER" = "0" ] && pass "vm.page-cluster=0 conforme baseline Mocha." || fail "vm.page-cluster=${PAGE_CLUSTER:-?}; esperado 0."
if [[ "$THP" == *"[madvise]"* ]]; then
    pass "THP está em madvise."
else
    fail "THP não está em madvise."
fi

printf '\nSysctls relevantes:\n'
for key in \
    vm.swappiness vm.page-cluster vm.vfs_cache_pressure vm.dirty_background_ratio vm.dirty_ratio \
    vm.dirty_background_bytes vm.dirty_bytes vm.compaction_proactiveness vm.watermark_boost_factor \
    vm.watermark_scale_factor vm.min_free_kbytes vm.zone_reclaim_mode kernel.nmi_watchdog \
    kernel.sched_autogroup_enabled kernel.split_lock_mitigate kernel.sched_rt_runtime_us \
    fs.inotify.max_user_watches fs.file-max; do
    printf '%s=' "$key"
    sysctl -n "$key" 2>/dev/null || echo "indisponível"
done

printf '\nArquivos sysctl que mencionam parâmetros de desempenho:\n'
find /etc/sysctl.d /usr/lib/sysctl.d -maxdepth 1 -type f -name '*.conf' -print 2>/dev/null | while read -r f; do
    if grep -Eqi 'swappiness|page-cluster|hugepage|dirty_|watermark|sched_|nmi_watchdog|zone_reclaim|compaction' "$f" 2>/dev/null; then
        echo "----- $f"
        grep -Ein 'swappiness|page-cluster|hugepage|dirty_|watermark|sched_|nmi_watchdog|zone_reclaim|compaction' "$f" || true
    fi
done

printf '\nZram-generator:\n'
find /etc/systemd/zram-generator.conf /etc/systemd/zram-generator.conf.d -maxdepth 2 -type f -print -exec sudo sed -n '1,220p' {} \; 2>/dev/null || true

section "8. Discos, filesystem, scheduler e montagem"
findmnt -o TARGET,SOURCE,FSTYPE,OPTIONS / /home /media/mochafast /media/vmstore 2>/dev/null || true
lsblk -e7 -o NAME,TYPE,SIZE,FSTYPE,MOUNTPOINTS,ROTA,SCHED,DISC-GRAN,DISC-MAX,MODEL || true

printf '\nSchedulers por bloco:\n'
for d in /sys/block/nvme* /sys/block/sd*; do
    [ -d "$d" ] || continue
    printf '%s scheduler=' "${d##*/}"
    cat "$d/queue/scheduler" 2>/dev/null || true
    printf '%s rotational=' "${d##*/}"
    cat "$d/queue/rotational" 2>/dev/null || true
    printf '%s read_ahead_kb=' "${d##*/}"
    cat "$d/queue/read_ahead_kb" 2>/dev/null || true
done

printf '\nF2FS status/tunables quando disponíveis:\n'
find /sys/fs/f2fs -maxdepth 2 -type f \( -name gc_urgent -o -name gc_idle -o -name iostat_enable -o -name reclaim_segments -o -name max_victim_search \) -print -exec cat {} \; 2>/dev/null || true

section "9. IRQ, interrupções e latência"
printf 'IRQ balance:\n'
show_unit irqbalance.service

printf '\nInterrupções NVIDIA, NVMe, áudio e rede:\n'
grep -Ei 'nvidia|nvme|xhci|snd|eth|enp|wlp|amdgpu' /proc/interrupts 2>/dev/null || true

printf '\nSoftirqs:\n'
cat /proc/softirqs 2>/dev/null || true

printf '\nLimites realtime e memlock:\n'
ulimit -a
find /etc/security/limits.d -maxdepth 1 -type f -print 2>/dev/null | while read -r f; do
    if grep -Eqi 'rtprio|memlock|nice' "$f" 2>/dev/null; then
        echo "----- $f"
        grep -Ein 'rtprio|memlock|nice' "$f" || true
    fi
done

section "10. KDE/Wayland, compositor e variáveis gráficas"
printf 'Processos gráficos:\n'
ps -eo pid,ni,cls,rtprio,psr,comm,args | grep -E 'kwin_wayland|plasmashell|Xwayland|steam|gamescope|mangohud' | grep -v grep || true

printf '\nVariáveis de ambiente que podem alterar renderização/desempenho:\n'
env | sort | grep -E '^(KWIN_|__GL_|GBM_|WLR_|VK_|MESA_|DXVK_|VKD3D_|PROTON_|WINE|MANGOHUD|GAMEMODE|LIBVA_|VDPAU_|QT_QPA_PLATFORM|SDL_VIDEODRIVER)' || true

printf '\nArquivos globais com variáveis relevantes:\n'
for f in /etc/environment /etc/profile "$HOME/.profile" "$HOME/.bash_profile" "$HOME/.config/environment.d"/*.conf /etc/environment.d/*.conf; do
    [ -e "$f" ] || continue
    echo "----- $f"
    grep -Ein 'KWIN_|__GL_|GBM_|WLR_|VK_|MESA_|DXVK_|VKD3D_|PROTON_|WINE|MANGOHUD|GAMEMODE|LIBVA_|VDPAU_|QT_QPA_PLATFORM|SDL_VIDEODRIVER' "$f" 2>/dev/null || true
done

printf '\nConfigurações KWin/KScreen relevantes:\n'
for f in "$HOME/.config/kwinrc" "$HOME/.config/kwinoutputconfig.json" "$HOME/.config/kscreenlockerrc"; do
    [ -r "$f" ] || continue
    echo "----- $f"
    grep -Ein 'latency|vsync|tearing|allowTearing|adaptive|vrr|render|composit|backend|refresh|scale|hdr|rgb|color' "$f" 2>/dev/null || true
done

printf '\nColor management/ICC:\n'
find "$HOME/.local/share/color" "$HOME/.config" /var/lib/colord -maxdepth 4 -type f \( -iname '*.icc' -o -iname '*.icm' \) -print 2>/dev/null || true
if have colormgr; then
    colormgr get-devices 2>/dev/null || true
fi

section "11. Steam, wrapper Mocha, MangoHud, Proton e PortProton"
WRAPPER="$HOME/.local/bin/mocha-steam-game-run"
printf 'Wrapper canônico: %s\n' "$WRAPPER"
if [ -x "$WRAPPER" ]; then
    pass "Wrapper Mocha existe e é executável."
    nl -ba "$WRAPPER" | sed -n '1,260p'
    if grep -Eqi 'fgmod|vkbasalt|gamescope|MANGOHUD_DLSYM' "$WRAPPER"; then
        fail "Wrapper contém componente proibido na baseline limpa (fgmod/vkBasalt/Gamescope/MANGOHUD_DLSYM)."
    else
        pass "Wrapper não contém fgmod, vkBasalt, Gamescope nem MANGOHUD_DLSYM."
    fi
    if grep -Eq 'gamemoderun|gamemode' "$WRAPPER"; then
        pass "Wrapper contém integração com GameMode."
    else
        warn "Wrapper não contém referência visível ao GameMode."
    fi
else
    fail "Wrapper Mocha canônico não existe ou não é executável."
fi

printf '\nConfigurações MangoHud:\n'
for f in "$HOME/.config/MangoHud/MangoHud.conf" "$HOME/.config/MangoHud"/*.conf /etc/MangoHud.conf; do
    [ -r "$f" ] || continue
    echo "----- $f"
    sed -n '1,260p' "$f"
done
if grep -RqsEi '(^|[[:space:]])time([[:space:]]|=|$)|time_format' "$HOME/.config/MangoHud" 2>/dev/null; then
    pass "Configuração MangoHud contém relógio/horário."
else
    warn "Não foi encontrada configuração de horário no MangoHud."
fi

printf '\nConfigurações GameMode:\n'
for f in "$HOME/.config/gamemode.ini" /etc/gamemode.ini /usr/share/gamemode/gamemode.ini; do
    [ -r "$f" ] || continue
    echo "----- $f"
    sed -n '1,260p' "$f"
done

printf '\nFerramentas Proton instaladas:\n'
find "$HOME/.local/share/Steam/compatibilitytools.d" -mindepth 1 -maxdepth 2 -type d -printf '%P\n' 2>/dev/null | sort | sed -n '1,200p' || true

printf '\nLaunch options e referências de desempenho no Steam:\n'
find "$HOME/.local/share/Steam/userdata" -type f \( -name 'localconfig.vdf' -o -name 'sharedconfig.vdf' \) -print 2>/dev/null | while read -r f; do
    echo "----- $f"
    grep -Ein -C2 'LaunchOptions|mocha-steam-game-run|gamemoderun|fgmod|gamescope|vkbasalt|MANGOHUD_DLSYM|portproton' "$f" 2>/dev/null | tail -n 240 || true
done

printf '\nResíduos PortProton/fgmod/GOverlay capazes de interferir:\n'
find "$HOME/.config" "$HOME/.local/share" "$HOME/.local/bin" -maxdepth 5 \
    \( -iname '*portproton*' -o -iname '*fgmod*' -o -path '*goverlay/gameconfig*' \) -print 2>/dev/null | sed -n '1,260p' || true

section "12. Logs do boot atual: NVIDIA, PCIe, CPU, memória e falhas"
printf 'Kernel warnings/errors do boot atual:\n'
sudo journalctl -k -b --no-pager -p warning..alert 2>/dev/null | tail -n 420 || true

printf '\nEventos críticos selecionados:\n'
sudo journalctl -k -b --no-pager 2>/dev/null | grep -Ei 'NVRM|Xid|nvidia|nouveau|pcie|AER:|BAR|IOMMU|AMD-Vi|thrott|thermal|watchdog|lockup|oom|out of memory|segfault|amdgpu|firmware|taint|failed|error' | tail -n 520 || true

printf '\nFalhas de unidades no boot:\n'
systemctl --failed --no-pager || true

printf '\nCoredumps recentes relacionados a jogo/driver/compositor:\n'
coredumpctl --no-pager --since '7 days ago' 2>/dev/null | grep -Ei 'wine|steam|kwin|nvidia|gamescope|mangohud|gamemode|proton' | tail -n 160 || true

section "13. Pacotes e arquivos alterados desde a experiência com kernel RC"
printf 'Pacotes explicitamente instalados/removidos/atualizados nos últimos 7 dias:\n'
sudo awk -v start="$(date -d '7 days ago' '+%Y-%m-%d')" '
    /^\[/ {
        date=substr($0,2,10)
        if (date >= start && $0 ~ /\[ALPM\] (installed|upgraded|downgraded|removed)/) print
    }
' /var/log/pacman.log 2>/dev/null | tail -n 700 || true

printf '\nArquivos de configuração de desempenho modificados nos últimos 7 dias:\n'
find /etc "$HOME/.config" "$HOME/.local/bin" -xdev -type f -mtime -7 \
    \( -path '/etc/tuned/*' -o -path '/etc/modprobe.d/*' -o -path '/etc/sysctl.d/*' -o \
       -path '/etc/systemd/*' -o -path '/etc/mkinitcpio*' -o -path '/etc/default/grub' -o \
       -path '*/MangoHud/*' -o -path '*/gamemode.ini' -o -path '*/kwinrc' -o \
       -path '*/environment.d/*' -o -name 'mocha-steam-game-run' \) \
    -printf '%TY-%Tm-%Td %TH:%TM:%TS %p\n' 2>/dev/null | sort | tail -n 400 || true

section "14. Verificações finais automáticas"

if systemctl is-active --quiet tuned.service 2>/dev/null; then
    pass "tuned.service está ativo."
else
    fail "tuned.service não está ativo."
fi

FAILED_UNITS="$(systemctl --failed --no-legend 2>/dev/null || true)"
if [ -n "$FAILED_UNITS" ]; then
    warn "Existem unidades systemd em estado failed."
else
    pass "Nenhuma unidade systemd está em estado failed."
fi

KLOG_FINAL="$(sudo journalctl -k -b --no-pager 2>/dev/null || true)"
if grep -Eqi 'NVRM: Xid' <<< "$KLOG_FINAL"; then
    fail "O boot atual contém erro NVIDIA Xid."
else
    pass "Nenhum NVIDIA Xid foi encontrado no boot atual."
fi

if grep -Eqi 'PCIe Bus Error|AER:.*error' <<< "$KLOG_FINAL"; then
    warn "Foram encontrados erros PCIe/AER no boot atual."
else
    pass "Nenhum erro PCIe/AER evidente foi encontrado no boot atual."
fi

if [ -n "$GPU_BDF" ]; then
    GPU_NUMA="$(cat "/sys/bus/pci/devices/$GPU_BDF/numa_node" 2>/dev/null || true)"
    info "GPU NUMA node: ${GPU_NUMA:-indisponível}."
fi

section "15. Resumo consolidado"
printf 'OK=%d\nATENÇÕES=%d\nFALHAS=%d\nINFORMAÇÕES=%d\n' "$PASS" "$WARN" "$FAIL" "$INFO" | tee -a "$RES"
printf '\nRelatório completo: %s\n' "$REL" | tee -a "$RES"
printf 'Resumo: %s\n' "$RES" | tee -a "$RES"
printf '\nLeitura recomendada: primeiro todas as linhas [FALHA], depois [ATENÇÃO].\n' | tee -a "$RES"

printf '\n============================================================\n'
printf ' AUDITORIA CONCLUÍDA\n'
printf '============================================================\n'
printf 'Relatório completo: %s\n' "$REL"
printf 'Resumo automático: %s\n' "$RES"
printf '\nCole aqui primeiro o conteúdo do resumo automático e, em seguida, as seções 2, 3, 5, 6, 7, 11 e 12 do relatório.\n'
