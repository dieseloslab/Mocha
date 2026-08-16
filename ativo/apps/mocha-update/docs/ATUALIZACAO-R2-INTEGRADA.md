# Mocha Update — integração remota R2 stable

## Endpoints independentes

- Atualizações gerais e componentes Mocha: `https://updates.dieseloslab.org`, canal `stable`.
- Kernel e driver: `https://repo.dieseloslab.org/stable/x86_64`.

O motor R2 bloqueia IDs relacionados a kernel, NVIDIA, headers e firmware. O fluxo
geral não altera `/boot`, `/usr/lib/modules`, `pacman.conf` ou o chaveiro do Pacman.

## Contrato de artefato R2

Cada item instalável do catálogo assinado aponta para um arquivo tar. O servidor
também deve publicar a assinatura destacada no mesmo caminho acrescido de `.asc`.
O cliente exige, nesta ordem:

1. catálogo e assinatura válidos pelo keyring oficial;
2. componente presente na allowlist local;
3. download somente por HTTPS;
4. tamanho idêntico ao catálogo;
5. assinatura destacada válida do artefato;
6. SHA-256 idêntico ao valor autenticado pelo catálogo;
7. extração segura sob um único diretório `payload/`;
8. execução do validador local;
9. staging versionado, ativação e rollback em caso de falha.

Para `mocha-update`, o artefato contém `payload/rootfs/` e somente destinos da
aplicação. O binário staged e o binário instalado precisam aceitar `--self-test`.
Componentes usam diretórios versionados e launcher atômico. Conteúdos não possuem
launcher.
