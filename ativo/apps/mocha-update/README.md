# Mocha Update

Central gráfica de atualização e recuperação do Mocha Linux.

## Arquitetura

- Interface: Qt 6, Qt Quick e QML.
- Backend gráfico: Rust e CXX-Qt.
- Executor administrativo: binário Rust separado, instalado como `root`.
- Autorização: Polkit por meio de `pkexec` e caminho fixo.
- Repositório de kernel: `mocha-kernel` em `https://repo.dieseloslab.org/stable/x86_64`.
- Pacotes canônicos: `linux-mocha-lqx`, `linux-mocha-lqx-headers` e `linux-mocha-lqx-docs`.
- Fingerprint GPG: `CC16C3925C923E1826860641CB1EFF2340CBAB47`.

O executor aceita somente operações previamente definidas. A interface não pode encaminhar comandos arbitrários, nomes livres de pacotes nem caminhos de arquivos para execução privilegiada. A atualização do próprio Mocha Update não faz parte deste backend e será distribuída em domínio separado.

## Dependências de execução

- `pacman` e `pacman-contrib` (`checkupdates`);
- `flatpak`;
- `polkit` (`pkexec`);
- `lvm2` com volumes thin para os pontos protegidos;
- `dkms`, `mkinitcpio`, `grub` e `gnupg`;
- `gamemode`, `nvidia-settings`, `sudo` e os hooks canônicos do Mocha;
- pilha Qt 6 necessária pela interface.

## Fluxos operacionais

### Atualização do Sistema

Atualiza os pacotes normais do Pacman e os aplicativos Flatpak. Todos os kernels, a pilha NVIDIA e o pacote do próprio `mocha-update` são enviados ao Pacman como pacotes protegidos por `--ignore`. O backend compara as versões protegidas antes e depois da operação e interrompe o fluxo caso detecte alteração inesperada.

### Kernel e Driver

Usa exclusivamente o repositório `mocha-kernel`. Valida a seção do repositório, a URL canônica, a chave GPG, a ausência de atualizações gerais pendentes e a origem dos três pacotes. Instala conjuntamente o kernel Mocha, headers, documentação e a pilha NVIDIA, reconstrói DKMS, regenera initramfs e atualiza o GRUB.

### Recasar Kernel e Driver

Reinstala exatamente as versões atualmente instaladas usando os arquivos correspondentes no cache do Pacman. A operação é bloqueada quando algum pacote exato não está disponível, impedindo troca silenciosa de versão. Em seguida, reconstrói DKMS, initramfs e GRUB.


### Mocha OC

Controla o perfil NVIDIA validado de `+50 MHz` no clock da GPU e `+400` no controlador de memória, correspondente a cerca de `+200 MHz` no clock real da memória. O perfil nunca fica aplicado fora do GameMode.

- **Ativar OC:** grava uma preferência em `/run`; ela vale somente na sessão atual e desaparece no reinício.
- **Ativar OC permanentemente no GameMode:** grava a preferência em `/etc/mocha/nvidia-game-oc.conf`, mas os offsets continuam sendo aplicados apenas entre os hooks de início e fim do GameMode.
- **Desativar totalmente:** remove as duas preferências e restaura imediatamente os valores anteriores salvos na entrada do GameMode.

Os hooks aprovados continuam em `/usr/local/lib/mocha/performance/`. Eles acionam as pontes `legacy-*.cmd`, que executam os scripts legacy aprovados. Esses scripts chamam o executor fixo `/usr/local/lib/mocha/mocha-nvidia-oc-root-helper`, único artefato substituído pelo instalador, e instala uma regra `sudoers` limitada aos argumentos `start`, `end`, `reset`, `stop` e `status`. Chamadas repetidas de início não sobrescrevem o estado original que será restaurado no encerramento.

### Rollback

Antes de cada operação administrativa, cria snapshots thin LVM dos volumes distintos usados por `/` e `/home`. Como `/boot` permanece fora do thin pool, o conteúdo de `/boot` é salvo em um arquivo tar verificado por SHA-256; uma EFI montada separadamente em `/boot/efi` recebe backup próprio. Os artefatos e metadados ficam em `/var/lib/mocha-update/rollbacks`.

A tela de rollback localiza e seleciona automaticamente o ponto válido mais recente. Antes da restauração, o helper confirma os volumes de origem, os snapshots e os hashes dos backups de boot. O merge é agendado com `lvconvert --merge`; no mesmo reinício, o serviço `mocha-update-boot-restore.service` restaura `/boot` e a EFI correspondente.

## Segurança operacional

- caminho privilegiado fixo: `/usr/lib/mocha-update/mocha-update-helper`;
- operações administrativas serializadas por `/run/lock/mocha-update.lock`;
- bloqueio quando o Pacman possui `db.lck`;
- nenhum uso de shell para construir comandos;
- argumentos e identificadores de rollback validados;
- snapshots compensatoriamente removidos se a preparação falhar antes da alteração do sistema.

## Relatórios

- Operações administrativas: `/var/log/mocha-update/`.
- Verificações sem privilégio: `${XDG_STATE_HOME:-$HOME/.local/state}/mocha-update/logs/`.

## Compilar e instalar

```bash
./scripts/install-local.sh
```

O instalador executa `cargo fmt`, testes e compilação dos dois binários antes de alterar o sistema. Se qualquer validação falhar, nada é instalado.
