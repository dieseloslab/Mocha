# Mocha Update — entrega ao Calamares

Checkpoint: V76, 20260726-205020

## Localizações

- Código-fonte canônico: `/media/mochafast/MochaArch/ativo/apps/mocha-update`
- Instalador local preservado: `/media/mochafast/MochaArch/ativo/apps/mocha-update/scripts/install-local.sh`
- Instalador manual sem Calamares:
  `/media/mochafast/MochaArch/ativo/apps/mocha-update/INSTALAR-MOCHA-UPDATE.sh`
- Instruções da reinstalação manual:
  `/media/mochafast/MochaArch/ativo/apps/mocha-update/INSTRUCOES-REINSTALACAO.md`
- Binários correspondentes às fontes:
  - `/media/mochafast/MochaArch/ativo/apps/mocha-update/target/release/mocha-update`
  - `/media/mochafast/MochaArch/ativo/apps/mocha-update/target/release/mocha-update-helper`
  - `/media/mochafast/MochaArch/ativo/apps/mocha-update/target/release/mocha-snapshot-admin`
- Payload de runtime: `/media/mochafast/MochaArch/ativo/apps/mocha-update/calamares/payload/airootfs`
- Instalador para a raiz-alvo: `/media/mochafast/MochaArch/ativo/apps/mocha-update/calamares/INSTALAR-MOCHA-UPDATE-NO-ALVO.sh`
- Manifesto de componentes: `/media/mochafast/MochaArch/ativo/apps/mocha-update/calamares/MANIFESTO-RUNTIME.txt`
- Dependências ELF: `/media/mochafast/MochaArch/ativo/apps/mocha-update/calamares/DEPENDENCIAS-LDD.txt`
- Pacotes observados no host validado: `/media/mochafast/MochaArch/ativo/apps/mocha-update/calamares/PACOTES-RUNTIME-OBSERVADOS.txt`
- Dependências Rust fixadas: `/media/mochafast/MochaArch/ativo/apps/mocha-update/calamares/DEPENDENCIAS-CARGO-LOCK.txt`
- SHA-256 do aplicativo: `8957eedd4375407c0c957574caed7eb366a46b2afa7e52b33fbde74e27616336`
- SHA-256 do helper V70: `6848e2a21cb92311b06cde354af871d2a4a50b6c8b92114db34ee796c4542682`
- SHA-256 do administrador de snapshots: `f75aa5b2d4fe102b6f9f39f1fc87f3d706f587da0aeb3a9a5dd858a24f30b557`

## Contrato de instalação

O Calamares não deve compilar Rust ou C++ durante a instalação. Ele deve:

1. instalar os pacotes de runtime listados em
   `PACOTES-RUNTIME-OBSERVADOS.txt`, preferencialmente como dependências de
   um pacote Arch `mocha-update`;
2. copiar o payload para a raiz do sistema instalado, preservando modos e
   deixando os arquivos do sistema como `root:root`;
3. criar vazias as árvores `/var/lib/mocha-update`,
   `/var/lib/mocha-update/snapshot-index`,
   `/var/lib/mocha-update/rollbacks` e `/var/log/mocha-update`;
4. habilitar `mocha-update-snapshot-index.timer` no sistema instalado;
5. manter instalados o helper privilegiado, a política Polkit, o hook ALPM,
   as unidades systemd, o atalho e o ícone;
6. nunca copiar os snapshots, o índice ou o estado desta máquina para uma
   instalação nova.

O instalador offline recebe exatamente um argumento: o ponto de montagem da
raiz-alvo fornecido pelo Calamares. Ele recusa `/` para impedir instalação
acidental no ambiente live.

Para reinstalar diretamente em um sistema Mocha já iniciado, use o instalador
manual da raiz desta pasta. Ele valida os hashes, instala somente dependências
ausentes, cria backup recuperável, aplica o mesmo payload e preserva todo o
estado e todos os snapshots existentes.

## Condição para rollback

A interface e as atualizações podem ser instaladas pelo Calamares, mas
snapshot e restauração só podem ser anunciados como disponíveis quando o
sistema instalado usar o layout LVM thin esperado pelo Mocha Update e quando
o ponto possuir metadados, inventário de pacotes e cópias coerentes de
`/boot` e EFI. Na ausência dessas condições, o rollback deve permanecer
fail-closed.

## Validação antes da ISO

- `ldd /usr/bin/mocha-update` sem `not found`;
- `ldd /usr/lib/mocha-update/mocha-update-helper` sem `not found`;
- atalho `org.mocha.update.desktop` abre o aplicativo e resolve o ícone;
- Polkit autoriza somente as operações administrativas previstas;
- timer de índice habilitado e ativo após o primeiro boot;
- índice JSON legível e tela Rollback carregada;
- atualização, recasamento e rollback testados separadamente.
