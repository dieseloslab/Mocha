# Mocha Arch/KDE — Auditoria GameMode

- Data: 20260529-161327
- Modo: somente leitura

## Objetivo

Verificar se GameMode está instalado, se o daemon responde, se ativa durante execução via `gamemoderun` e se volta ao estado normal depois.

Esta auditoria ajuda a comparar três cenários:

1. Jogo sem Launch Options.
2. Jogo com GameMode puro.
3. Jogo com wrapper Mocha.


## Sistema atual

```
Kernel:
Linux Mocha 7.0.10-arch1-1 #1 SMP PREEMPT_DYNAMIC Sat, 23 May 2026 14:21:20 +0000 x86_64 GNU/Linux

Sessão:
XDG_SESSION_TYPE=wayland
DESKTOP_SESSION=/usr/share/wayland-sessions/plasma.desktop

CPU governor atual:
analisando o CPU 3:
  política de frequência atual deve estar entre 2.39 GHz e 4.67 GHz.
                  O regulador "performance" deve decidir qual velocidade usar
                  dentro desse limite.

NVIDIA:
NVIDIA GeForce RTX 5060 Ti, 595.71.05, P0, [Requested functionality has been deprecated], 24.26 W, 180.00 W, 2617 MHz, 14001 MHz
```

## Pacotes GameMode

```
gamemode 1.8.2-2
lib32-gamemode 1.8.2-1
```

## Binários

```
gamemoded: /usr/bin/gamemoded
gamemoderun: /usr/bin/gamemoderun
systemctl: /usr/bin/systemctl
dbus-send: /usr/bin/dbus-send
busctl: /usr/bin/busctl
```

## systemd --user

```
gamemoded.service                                                      enabled   enabled

Status gamemoded.service:
● gamemoded.service - gamemoded
     Loaded: loaded (/usr/lib/systemd/user/gamemoded.service; enabled; preset: enabled)
     Active: active (running) since Fri 2026-05-29 14:29:52 -03; 1h 43min ago
 Invocation: 329730a11b8f4be8b9d131248658a170
   Main PID: 884 (gamemoded)
     Status: "[1;36mGameMode is currently deactivated.[0m"
      Tasks: 2 (limit: 18662)
     Memory: 1.5M (peak: 4.5M)
        CPU: 63ms
     CGroup: /user.slice/user-1000.slice/user@1000.service/app.slice/gamemoded.service
             └─884 /usr/bin/gamemoded

mai 29 15:48:25 Mocha gamemoded[884]: ERROR: Skipping ioprio on client [11390,11390]: ioprio was (0) but we expected (4)
mai 29 15:48:25 Mocha gamemoded[884]: ERROR: Skipping ioprio on client [11391,11391]: ioprio was (0) but we expected (4)
mai 29 16:07:08 Mocha pkexec[12261]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 1]
mai 29 16:07:08 Mocha gamemoded[12261]: Error executing command as another user: Not authorized
mai 29 16:07:08 Mocha gamemoded[12261]: This incident has been reported.
mai 29 16:07:08 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:07:08 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:07:08 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
mai 29 16:07:08 Mocha gamemoded[884]: ERROR: Could not inspect tasks for client [11324]! Skipping ioprio optimisation.
mai 29 16:07:08 Mocha gamemoded[884]: ERROR: Unable to find executable for PID 11324: No such file or directory
```

## Status inicial

```
gamemode is inactive

Processos gamemoded:
884 /usr/bin/gamemoded
```

## Teste gamemoded -t

```
gamemode request succeeded and is active
Quitting by request...
: Loading config
: Running tests

:: Basic client tests
:: Passed

:: Dual client tests
:: Passed

:: Gamemoderun and reaper thread tests
: Loading config
: Running tests

:: Basic client tests
:: Passed

:: Dual client tests
:: Passed

:: Gamemoderun and reaper thread tests
...Waiting for child to quit...
...Waiting for reaper thread (reaper_frequency set to 5 seconds)...
:: Passed

:: Supervisor tests
:: Passed

:: Feature tests
::: Verifying CPU governor setting
::: Passed
::: Verifying Scripts
::: Passed (no scripts configured to run)
::: Verifying GPU Optimisations
::: Passed (gpu optimisations not configured to run)
::: Verifying renice
::: Passed (no renice configured)
::: Verifying ioprio
: Loading config
: Running tests

:: Basic client tests
:: Passed

:: Dual client tests
:: Passed

:: Gamemoderun and reaper thread tests
...Waiting for child to quit...
...Waiting for reaper thread (reaper_frequency set to 5 seconds)...
:: Passed

:: Supervisor tests
:: Passed

:: Feature tests
::: Verifying CPU governor setting
::: Passed
::: Verifying Scripts
::: Passed (no scripts configured to run)
::: Verifying GPU Optimisations
::: Passed (gpu optimisations not configured to run)
::: Verifying renice
::: Passed (no renice configured)
::: Verifying ioprio
::: Passed
:: Passed

: All Tests Passed!
```

## Teste prático de ativação

```
Iniciando processo controlado: gamemoderun sleep 20
PID do processo de teste: 13497

--- Status durante gamemoderun ---
gamemode is active

--- Processos gamemoded durante teste ---
884 /usr/bin/gamemoded

--- Processo de teste ---
    PID    PPID STAT COMMAND         COMMAND
  13497   13284 S+   sleep           sleep 20

--- Status depois do término ---
gamemode is inactive

--- Processos gamemoded depois ---
884 /usr/bin/gamemoded
```

## Logs recentes

```
mai 29 16:07:08 Mocha pkexec[12261]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 1]
mai 29 16:07:08 Mocha gamemoded[12261]: Error executing command as another user: Not authorized
mai 29 16:07:08 Mocha gamemoded[12261]: This incident has been reported.
mai 29 16:07:08 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:07:08 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:07:08 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
mai 29 16:07:08 Mocha gamemoded[884]: ERROR: Could not inspect tasks for client [11324]! Skipping ioprio optimisation.
mai 29 16:07:08 Mocha gamemoded[884]: ERROR: Unable to find executable for PID 11324: No such file or directory
mai 29 16:13:27 Mocha pkexec[13319]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/cpugovctl set performance]
mai 29 16:13:27 Mocha gamemoded[13319]: Error executing command as another user: Not authorized
mai 29 16:13:27 Mocha gamemoded[13319]: This incident has been reported.
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: Failed to update cpu governor policy
mai 29 16:13:27 Mocha pkexec[13324]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 0]
mai 29 16:13:27 Mocha gamemoded[13324]: Error executing command as another user: Not authorized
mai 29 16:13:27 Mocha gamemoded[13324]: This incident has been reported.
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: Skipping ioprio on client [13318,13318]: ioprio was (0) but we expected (4)
mai 29 16:13:27 Mocha pkexec[13329]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 1]
mai 29 16:13:27 Mocha gamemoded[13329]: Error executing command as another user: Not authorized
mai 29 16:13:27 Mocha gamemoded[13329]: This incident has been reported.
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
mai 29 16:13:27 Mocha pkexec[13335]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/cpugovctl set performance]
mai 29 16:13:27 Mocha gamemoded[13335]: Error executing command as another user: Not authorized
mai 29 16:13:27 Mocha gamemoded[13335]: This incident has been reported.
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: Failed to update cpu governor policy
mai 29 16:13:27 Mocha pkexec[13340]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 0]
mai 29 16:13:27 Mocha gamemoded[13340]: Error executing command as another user: Not authorized
mai 29 16:13:27 Mocha gamemoded[13340]: This incident has been reported.
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
mai 29 16:13:27 Mocha pkexec[13345]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 1]
mai 29 16:13:27 Mocha gamemoded[13345]: Error executing command as another user: Not authorized
mai 29 16:13:27 Mocha gamemoded[13345]: This incident has been reported.
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
mai 29 16:13:27 Mocha pkexec[13351]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/cpugovctl set performance]
mai 29 16:13:27 Mocha gamemoded[13351]: Error executing command as another user: Not authorized
mai 29 16:13:27 Mocha gamemoded[13351]: This incident has been reported.
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: Failed to update cpu governor policy
mai 29 16:13:27 Mocha pkexec[13356]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 0]
mai 29 16:13:27 Mocha gamemoded[13356]: Error executing command as another user: Not authorized
mai 29 16:13:27 Mocha gamemoded[13356]: This incident has been reported.
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:27 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
mai 29 16:13:29 Mocha pkexec[13361]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 1]
mai 29 16:13:29 Mocha gamemoded[13361]: Error executing command as another user: Not authorized
mai 29 16:13:29 Mocha gamemoded[13361]: This incident has been reported.
mai 29 16:13:29 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:29 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:29 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
mai 29 16:13:29 Mocha gamemoded[884]: ERROR: Could not inspect tasks for client [13350]! Skipping ioprio optimisation.
mai 29 16:13:29 Mocha gamemoded[884]: ERROR: Unable to find executable for PID 13350: No such file or directory
mai 29 16:13:32 Mocha pkexec[13412]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/cpugovctl set performance]
mai 29 16:13:32 Mocha gamemoded[13412]: Error executing command as another user: Not authorized
mai 29 16:13:32 Mocha gamemoded[13412]: This incident has been reported.
mai 29 16:13:32 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:32 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:32 Mocha gamemoded[884]: ERROR: Failed to update cpu governor policy
mai 29 16:13:32 Mocha pkexec[13418]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 0]
mai 29 16:13:32 Mocha gamemoded[13418]: Error executing command as another user: Not authorized
mai 29 16:13:32 Mocha gamemoded[13418]: This incident has been reported.
mai 29 16:13:32 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:32 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:32 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
mai 29 16:13:32 Mocha pkexec[13423]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 1]
mai 29 16:13:32 Mocha gamemoded[13423]: Error executing command as another user: Not authorized
mai 29 16:13:32 Mocha gamemoded[13423]: This incident has been reported.
mai 29 16:13:32 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:32 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:32 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
mai 29 16:13:33 Mocha pkexec[13428]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/cpugovctl set performance]
mai 29 16:13:33 Mocha gamemoded[13428]: Error executing command as another user: Not authorized
mai 29 16:13:33 Mocha gamemoded[13428]: This incident has been reported.
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Failed to update cpu governor policy
mai 29 16:13:33 Mocha gamemoded[884]: v1.8.2
mai 29 16:13:33 Mocha gamemoded[884]: cpu L3 cache was uniform, this is not a x3D with multiple chiplets
mai 29 16:13:33 Mocha gamemoded[884]: cpu frequency was uniform, this is not a big.LITTLE type of system
mai 29 16:13:33 Mocha gamemoded[884]: Successfully initialised bus with name [com.feralinteractive.GameMode]...
mai 29 16:13:33 Mocha gamemoded[884]: Adding game: 11303 [/usr/bin/env]
mai 29 16:13:33 Mocha gamemoded[884]: Entering Game Mode...
mai 29 16:13:33 Mocha gamemoded[884]: governor was initially set to [performance]
mai 29 16:13:33 Mocha gamemoded[884]: Requesting update of governor policy to performance
mai 29 16:13:33 Mocha gamemoded[884]: Requesting update of split_lock_mitigate to 0
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process...
mai 29 16:13:33 Mocha gamemoded[884]: Adding game: 11324 [/usr/bin/bash]
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process...
mai 29 16:13:33 Mocha gamemoded[884]: Adding game: 11325 [/usr/bin/readlink]
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process...
mai 29 16:13:33 Mocha gamemoded[884]: Removing game: 11325 [/usr/bin/readlink]
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process back to all online cores...
mai 29 16:13:33 Mocha gamemoded[884]: Adding game: 11390 [/home/hal/.local/share/Steam/steamapps/common/SteamLinuxRuntime_4/pressure-vessel/libexec/steam-runtime-tools-0/x86_64-linux-gnu-inspect-library]
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process...
mai 29 16:13:33 Mocha gamemoded[884]: Removing game: 11390 [/home/hal/.local/share/Steam/steamapps/common/SteamLinuxRuntime_4/pressure-vessel/libexec/steam-runtime-tools-0/x86_64-linux-gnu-inspect-library]
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process back to all online cores...
mai 29 16:13:33 Mocha gamemoded[884]: Adding game: 11391 [/home/hal/.local/share/Steam/steamapps/common/SteamLinuxRuntime_4/pressure-vessel/libexec/steam-runtime-tools-0/i386-linux-gnu-inspect-library]
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process...
mai 29 16:13:33 Mocha gamemoded[884]: Removing game: 11391 [/home/hal/.local/share/Steam/steamapps/common/SteamLinuxRuntime_4/pressure-vessel/libexec/steam-runtime-tools-0/i386-linux-gnu-inspect-library]
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process back to all online cores...
mai 29 16:13:33 Mocha gamemoded[884]: Removing game: 11303 [/usr/bin/env]
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process back to all online cores...
mai 29 16:13:33 Mocha gamemoded[884]: Removing expired game [11324]...
mai 29 16:13:33 Mocha gamemoded[884]: Removing game: 11324 [/usr/bin/bash]
mai 29 16:13:33 Mocha gamemoded[884]: Leaving Game Mode...
mai 29 16:13:33 Mocha gamemoded[884]: Requesting update of split_lock_mitigate to 1
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process back to all online cores...
mai 29 16:13:33 Mocha gamemoded[884]: Properly cleaned up all expired games.
mai 29 16:13:33 Mocha gamemoded[884]: Adding game: 13318 [/usr/bin/gamemoded]
mai 29 16:13:33 Mocha gamemoded[884]: Entering Game Mode...
mai 29 16:13:33 Mocha gamemoded[884]: governor was initially set to [performance]
mai 29 16:13:33 Mocha gamemoded[884]: Requesting update of governor policy to performance
mai 29 16:13:33 Mocha gamemoded[884]: Requesting update of split_lock_mitigate to 0
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process...
mai 29 16:13:33 Mocha gamemoded[884]: Removing game: 13318 [/usr/bin/gamemoded]
mai 29 16:13:33 Mocha gamemoded[884]: Leaving Game Mode...
mai 29 16:13:33 Mocha gamemoded[884]: Requesting update of split_lock_mitigate to 1
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process back to all online cores...
mai 29 16:13:33 Mocha gamemoded[884]: Adding game: 13334 [/usr/bin/gamemoded]
mai 29 16:13:33 Mocha gamemoded[884]: Entering Game Mode...
mai 29 16:13:33 Mocha gamemoded[884]: governor was initially set to [performance]
mai 29 16:13:33 Mocha gamemoded[884]: Requesting update of governor policy to performance
mai 29 16:13:33 Mocha gamemoded[884]: Requesting update of split_lock_mitigate to 0
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process...
mai 29 16:13:33 Mocha gamemoded[884]: Adding game: 13318 [/usr/bin/gamemoded]
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process...
mai 29 16:13:33 Mocha gamemoded[884]: Removing game: 13318 [/usr/bin/gamemoded]
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process back to all online cores...
mai 29 16:13:33 Mocha gamemoded[884]: Removing game: 13334 [/usr/bin/gamemoded]
mai 29 16:13:33 Mocha gamemoded[884]: Leaving Game Mode...
mai 29 16:13:33 Mocha gamemoded[884]: Requesting update of split_lock_mitigate to 1
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process back to all online cores...
mai 29 16:13:33 Mocha gamemoded[884]: Adding game: 13350 [/usr/bin/sleep]
mai 29 16:13:33 Mocha gamemoded[884]: Entering Game Mode...
mai 29 16:13:33 Mocha gamemoded[884]: governor was initially set to [performance]
mai 29 16:13:33 Mocha gamemoded[884]: Requesting update of governor policy to performance
mai 29 16:13:33 Mocha gamemoded[884]: Requesting update of split_lock_mitigate to 0
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process...
mai 29 16:13:33 Mocha gamemoded[884]: Removing expired game [13350]...
mai 29 16:13:33 Mocha gamemoded[884]: Removing game: 13350 [/usr/bin/sleep]
mai 29 16:13:33 Mocha gamemoded[884]: Leaving Game Mode...
mai 29 16:13:33 Mocha gamemoded[884]: Requesting update of split_lock_mitigate to 1
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process back to all online cores...
mai 29 16:13:33 Mocha gamemoded[884]: Properly cleaned up all expired games.
mai 29 16:13:33 Mocha gamemoded[884]: Adding game: 13411 [/usr/bin/gamemoded]
mai 29 16:13:33 Mocha gamemoded[884]: Entering Game Mode...
mai 29 16:13:33 Mocha gamemoded[884]: governor was initially set to [performance]
mai 29 16:13:33 Mocha gamemoded[884]: Requesting update of governor policy to performance
mai 29 16:13:33 Mocha gamemoded[884]: Requesting update of split_lock_mitigate to 0
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process...
mai 29 16:13:33 Mocha gamemoded[884]: Removing game: 13411 [/usr/bin/gamemoded]
mai 29 16:13:33 Mocha gamemoded[884]: Leaving Game Mode...
mai 29 16:13:33 Mocha gamemoded[884]: Requesting update of split_lock_mitigate to 1
mai 29 16:13:33 Mocha gamemoded[884]: Setting ioprio value...
mai 29 16:13:33 Mocha gamemoded[884]: Pinning process back to all online cores...
mai 29 16:13:33 Mocha gamemoded[884]: Adding game: 13318 [/usr/bin/gamemoded]
mai 29 16:13:33 Mocha gamemoded[884]: Entering Game Mode...
mai 29 16:13:33 Mocha gamemoded[884]: governor was initially set to [performance]
mai 29 16:13:33 Mocha gamemoded[884]: Requesting update of governor policy to performance
mai 29 16:13:33 Mocha pkexec[13433]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 0]
mai 29 16:13:33 Mocha gamemoded[884]: Requesting update of split
mai 29 16:13:33 Mocha gamemoded[13433]: Error executing command as another user: Not authorized
mai 29 16:13:33 Mocha gamemoded[13433]: This incident has been reported.
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
mai 29 16:13:33 Mocha pkexec[13438]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 1]
mai 29 16:13:33 Mocha gamemoded[13438]: Error executing command as another user: Not authorized
mai 29 16:13:33 Mocha gamemoded[13438]: This incident has been reported.
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
mai 29 16:13:33 Mocha pkexec[13443]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/cpugovctl set performance]
mai 29 16:13:33 Mocha gamemoded[13443]: Error executing command as another user: Not authorized
mai 29 16:13:33 Mocha gamemoded[13443]: This incident has been reported.
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Failed to update cpu governor policy
mai 29 16:13:33 Mocha pkexec[13448]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 0]
mai 29 16:13:33 Mocha gamemoded[13448]: Error executing command as another user: Not authorized
mai 29 16:13:33 Mocha gamemoded[13448]: This incident has been reported.
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
mai 29 16:13:33 Mocha pkexec[13453]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 1]
mai 29 16:13:33 Mocha gamemoded[13453]: Error executing command as another user: Not authorized
mai 29 16:13:33 Mocha gamemoded[13453]: This incident has been reported.
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
mai 29 16:13:33 Mocha pkexec[13459]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/cpugovctl set performance]
mai 29 16:13:33 Mocha gamemoded[13459]: Error executing command as another user: Not authorized
mai 29 16:13:33 Mocha gamemoded[13459]: This incident has been reported.
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Failed to update cpu governor policy
mai 29 16:13:33 Mocha pkexec[13464]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 0]
mai 29 16:13:33 Mocha gamemoded[13464]: Error executing command as another user: Not authorized
mai 29 16:13:33 Mocha gamemoded[13464]: This incident has been reported.
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
mai 29 16:13:33 Mocha pkexec[13473]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 1]
mai 29 16:13:33 Mocha gamemoded[13473]: Error executing command as another user: Not authorized
mai 29 16:13:33 Mocha gamemoded[13473]: This incident has been reported.
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
mai 29 16:13:33 Mocha pkexec[13480]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/cpugovctl set performance]
mai 29 16:13:33 Mocha gamemoded[13480]: Error executing command as another user: Not authorized
mai 29 16:13:33 Mocha gamemoded[13480]: This incident has been reported.
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Failed to update cpu governor policy
mai 29 16:13:33 Mocha pkexec[13485]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 0]
mai 29 16:13:33 Mocha gamemoded[13485]: Error executing command as another user: Not authorized
mai 29 16:13:33 Mocha gamemoded[13485]: This incident has been reported.
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
mai 29 16:13:33 Mocha pkexec[13490]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 1]
mai 29 16:13:33 Mocha gamemoded[13490]: Error executing command as another user: Not authorized
mai 29 16:13:33 Mocha gamemoded[13490]: This incident has been reported.
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
mai 29 16:13:33 Mocha pkexec[13501]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/cpugovctl set performance]
mai 29 16:13:33 Mocha gamemoded[13501]: Error executing command as another user: Not authorized
mai 29 16:13:33 Mocha gamemoded[13501]: This incident has been reported.
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Failed to update cpu governor policy
mai 29 16:13:33 Mocha pkexec[13506]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 0]
mai 29 16:13:33 Mocha gamemoded[13506]: Error executing command as another user: Not authorized
mai 29 16:13:33 Mocha gamemoded[13506]: This incident has been reported.
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
mai 29 16:13:33 Mocha gamemoded[884]: ERROR: Skipping ioprio on client [13497,13497]: ioprio was (0) but we expected (4)
mai 29 16:13:53 Mocha pkexec[13526]: hal: Error executing command as another user: Not authorized [USER=root] [TTY=unknown] [CWD=/home/hal] [COMMAND=/usr/lib/gamemode/procsysctl split_lock_mitigate 1]
mai 29 16:13:53 Mocha gamemoded[13526]: Error executing command as another user: Not authorized
mai 29 16:13:53 Mocha gamemoded[13526]: This incident has been reported.
mai 29 16:13:53 Mocha gamemoded[884]: ERROR: External process failed with exit code 127
mai 29 16:13:53 Mocha gamemoded[884]: ERROR: Output was:
mai 29 16:13:53 Mocha gamemoded[884]: ERROR: Failed to update split_lock_mitigate
```

## Conclusão automática

- `gamemoded` presente: sim
- `gamemoderun` presente: sim

Interpretação:

- Se `gamemoded -s` mostrou ativo durante o `gamemoderun sleep 20`, o GameMode está funcionando.
- Se estava inativo antes/depois e ativo durante, o comportamento está correto.
- Se o jogo parece melhor sem wrapper, o próximo teste correto é comparar:
  - sem Launch Options;
  - `gamemoderun %command%` puro;
  - wrapper Mocha limpo.

Linha de teste GameMode puro para Steam:

```text
gamemoderun %command%
```

Linha de teste wrapper Mocha limpo:

```text
/home/hal/.local/bin/mocha-steam-game-run %command%
```
