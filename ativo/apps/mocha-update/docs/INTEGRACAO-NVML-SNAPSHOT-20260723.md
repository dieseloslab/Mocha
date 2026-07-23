# Mocha Update — backend NVML e rollback transacional

## Estado canônico

O Mocha OC usa diretamente a biblioteca `libnvidia-ml.so.1`, fornecida por
`nvidia-utils`. O runtime não usa `nvidia-settings`, não depende de X11 e opera
normalmente na sessão KDE Wayland.

O perfil aplicado durante o GameMode é fixo:

- offset de GPU: `+50`;
- offset de taxa de transferência da memória: `+400`;
- tensão, limite de potência e controle de ventoinhas: inalterados.

Antes da primeira aplicação de cada ciclo, o helper grava os offsets encontrados
em `/run/mocha-update/mocha-oc-runtime.conf`. O encerramento do GameMode restaura
exatamente esses valores e remove o arquivo de estado. Reiniciar a máquina também
elimina qualquer preferência temporária e retorna o hardware ao estado normal.

## Snapshot e cópia de boot

O ponto de restauração combina:

1. snapshots LVM thin independentes de `/` e `/home`;
2. arquivo `boot.tar` com o conteúdo de `/boot` no mesmo instante lógico;
3. arquivo `efi.tar` separado quando `/boot/efi` estiver montado;
4. hashes SHA-256 dos arquivos de boot;
5. restauração de `/boot` e EFI no próximo boot, após o agendamento do merge LVM;
6. cópia emergencial do estado encontrado no boot antes de substituir arquivos.

A restauração de boot limpa somente o sistema de arquivos correspondente. Quando
EFI é uma montagem separada, ela nunca é incorporada por engano ao arquivo de
`/boot`.

## Validações obrigatórias

- `cargo fmt --all`;
- `cargo test --all-targets`;
- compilação release dos dois binários Rust;
- compilação C com `-Wall -Wextra -Werror`;
- confirmação NVML de `0/0`, `+50/+400` e retorno a `0/0`;
- teste real dos hooks do GameMode;
- criação e leitura dos arquivos temporários de backup de `/boot` e EFI;
- validação da unidade `mocha-update-boot-restore.service`;
- comparação dos hashes dos binários candidatos e instalados.

## Artefatos instalados

- `/usr/bin/mocha-update`;
- `/usr/lib/mocha-update/mocha-update-helper`;
- `/usr/local/lib/mocha/mocha-nvidia-oc-root-helper`;
- `/usr/local/lib/mocha/mocha-nvidia-oc-nvml`;
- `/usr/lib/mocha-update/mocha-boot-restore`;
- `/usr/lib/systemd/system/mocha-update-boot-restore.service`.
