# Status canônico dos repositórios VMSTORE

Data: 2026-07-03

## Preservar

- /media/vmstore/MochaArch/repo
  - Repo Pacman ativo apontado em /etc/pacman.conf:
    Server = file:///media/vmstore/MochaArch/repo/$arch
  - Contém CachyOS ativo/arquivado usado pelo Mocha.

- /media/vmstore/mocha-repo
  - Pool/arquivo canônico de pacotes, manifests, snapshots e repositórios locais.
  - Contém kernel-driver, kernel-liquorix/LQX, NVIDIA e material CachyOS.
  - Não apagar sem auditoria por subpasta exata.

- /media/vmstore/MochaArch/repo-local
  - Legado provável, mas preservado por enquanto.
  - Contém Calamares e pacotes Cachy/NVIDIA antigos.
  - Só mover/apagar depois de verificar dependências de ISO/build/Calamares.

## Removidos da área principal para quarentena auditável

- /media/vmstore/MochaRepos
  - Estrutura inicial de testes de repo de 2026-05-29/30.
  - Sem CachyOS, sem LQX, sem NVIDIA.
  - Movido para auditoria/quarentena em 2026-07-03.

- /media/vmstore/MochaArch/cachyos-repo-bootstrap-20260613-145735
  - Diretório vazio, sem pacotes, sem DB e sem referência.
  - Movido para auditoria/quarentena em 2026-07-03.

- /media/vmstore/MochaArch/repos
  - Estrutura antiga/vazia de repo stable inicial.
  - Sem pacotes úteis, sem CachyOS, sem LQX, sem NVIDIA.
  - Movido para auditoria/quarentena em 2026-07-03.

## Regra operacional

- Scripts devem apontar PRIMARY para /media/vmstore/mocha-repo.
- Scripts devem apontar SECONDARY para /media/vmstore/MochaArch/repo.
- Não recriar /media/vmstore/MochaRepos.
