# Backend operacional do Mocha Update

## Fronteira de privilégio

A interface executa somente o binário fixo `/usr/lib/mocha-update/mocha-update-helper`. As operações administrativas passam por `/usr/bin/pkexec`; o arquivo Polkit associa a autorização ao caminho absoluto do helper instalado. O helper rejeita operações desconhecidas, argumentos excedentes, identificadores de rollback inválidos e operações administrativas sem EUID 0.

Não existe execução por shell, entrada de comando livre, escolha arbitrária de pacote ou substituição do helper por variável de ambiente nas operações privilegiadas.

## Operações aceitas

- `check-general`
- `apply-general`
- `check-kernel`
- `apply-kernel`
- `remarry`
- `check-rollbacks`
- `apply-rollback <mocha-update-...>`
- `check-oc`
- `enable-oc-session`
- `enable-oc-persistent`
- `disable-oc`

## Invariantes

1. A atualização geral não instala nem atualiza kernels, a pilha NVIDIA ou o próprio pacote `mocha-update`.
2. O fluxo de kernel utiliza exclusivamente o repositório `mocha-kernel` e os pacotes `linux-mocha-lqx`, `linux-mocha-lqx-headers` e `linux-mocha-lqx-docs`.
3. O recasamento reinstala arquivos exatos do cache e não muda versões.
4. Toda alteração administrativa cria snapshots thin dos volumes distintos usados por `/` e `/home`, além de backup SHA-256 de `/boot` e da EFI separada.
5. `/` e `/home` precisam ser thin LVM; `/boot` permanece linear/ext4 e é protegido por backup de arquivos, sem bloquear a operação.
6. O rollback só aceita snapshots criados e registrados pelo próprio Mocha Update.
7. O rollback valida novamente a origem montada e a existência de cada LV antes de agendar qualquer merge.
8. A interface seleciona automaticamente o rollback válido mais recente, pois o desenho aprovado não contém uma lista interativa.
9. Operações administrativas são mutuamente exclusivas e respeitam o lock do Pacman.
10. A interface permanece responsiva; o helper roda em thread Rust e envia progresso estruturado ao event loop do Qt.
11. A atualização do próprio aplicativo fica fora deste backend e será distribuída em outro domínio.
12. O Mocha OC usa somente offsets fixos de `+50/+400`; não altera tensão, limite de potência ou ventoinhas.
13. Os offsets são aplicados somente enquanto o GameMode estiver ativo e o estado anterior é salvo uma única vez por ciclo para restauração no encerramento.
14. O modo temporário existe somente em `/run`; o modo persistente grava apenas a preferência em `/etc`, nunca o OC contínuo.

## Protocolo entre backend e helper

O helper grava logs legíveis e também publica linhas estruturadas em stdout:

- `@@MOCHA_PROGRESS@@` para percentual e etapa atual;
- `@@MOCHA_DATA@@` para estado e resumos;
- `@@MOCHA_RESULT@@` para conclusão, necessidade de reinício e caminho do relatório.

O backend não interpreta saída livre de ferramentas administrativas como comandos ou dados confiáveis; somente as linhas com prefixos definidos no protocolo alteram o estado da interface.

## Rollback multivolume

Cada ponto contém um diretório em `/var/lib/mocha-update/rollbacks/<id>` com:

- `metadata.conf`, que registra operação, data, kernel, driver e de um a três volumes;
- `packages.txt`, com o inventário Pacman anterior à alteração.

Os snapshots permitem somente `/` e `/home`; volumes que compartilham a mesma origem são registrados uma vez. Cada diretório de rollback também contém `boot.tar`, `boot.sha256` e, quando a EFI é separada, `efi.tar` e `efi.sha256`. A restauração de boot é agendada somente depois que todos os merges LVM foram aceitos e ocorre no próximo boot por uma unidade systemd condicionada ao marcador.


## Mocha OC e GameMode

O fluxo gráfico usa Polkit para alterar a preferência temporária ou persistente. A aplicação real dos offsets percorre a cadeia canônica do GameMode: hooks de autoridade, pontes `legacy-*.cmd`, scripts legacy aprovados e, por fim, o caminho fixo `/usr/local/lib/mocha/mocha-nvidia-oc-root-helper`. Esse wrapper aceita apenas comandos enumerados e chama o mesmo helper administrativo com operações internas não expostas pela interface.

Arquivos de estado:

- `/run/mocha-update/mocha-oc-session.enabled`: preferência válida até o reinício;
- `/etc/mocha/nvidia-game-oc.conf`: preferência persistente do GameMode;
- `/run/mocha-update/mocha-oc-runtime.conf`: valores anteriores de core, memória e PowerMizer, usados para restauração.

O runtime grava o terceiro arquivo somente na primeira entrada. Entradas repetidas reaplicam o perfil sem substituir os valores originais. No fim do GameMode, o helper restaura esses valores e remove o estado de runtime.

## Backend NVML nativo

O runtime do Mocha OC usa `/usr/local/lib/mocha/mocha-nvidia-oc-nvml`, que carrega
`libnvidia-ml.so.1` dinamicamente e chama as funções oficiais de leitura e escrita
dos offsets de GPC e memória. `nvidia-settings` não participa da aplicação, da
consulta nem da restauração do OC.
