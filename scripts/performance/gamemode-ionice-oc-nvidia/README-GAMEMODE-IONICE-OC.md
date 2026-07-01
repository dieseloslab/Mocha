# GameMode ionice + OC NVIDIA canônico

Marcador: MOCHA-GAMEMODE-IONICE-OC-CANONICO

Este pacote versiona somente os arquivos necessários ao stack aprovado de performance:

- `/etc/gamemode.ini`
- scripts start/end do GameMode em `/usr/local/lib/mocha/`
- sudoers/helper estritamente relacionados ao OC NVIDIA, quando existirem

Não incluir Steam wrapper, updater de kernel, PackageKit, scripts de repo ou outros componentes fora de GameMode/OC.

## Caminhos

Pacote versionado:

    /media/mochafast/MochaArch/scripts/performance/gamemode-ionice-oc-nvidia/

Instalador pós-install:

    /media/mochafast/MochaArch/scripts/postinstall/instala-gamemode-ionice-oc-nvidia

Validador:

    /media/mochafast/MochaArch/scripts/validacao/valida-gamemode-ionice-oc-nvidia

## Aplicação

    bash /media/mochafast/MochaArch/scripts/postinstall/instala-gamemode-ionice-oc-nvidia

## Validação

    bash /media/mochafast/MochaArch/scripts/validacao/valida-gamemode-ionice-oc-nvidia

Regra: validações devem usar `timeout` para não travar em `gamemoded`, `nvidia-smi`, `nvidia-settings` ou `systemctl`.
