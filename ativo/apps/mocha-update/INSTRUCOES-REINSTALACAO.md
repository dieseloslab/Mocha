# Mocha Update — reinstalação manual sem Calamares

Checkpoint V76, 20260726-205020.

Esta pasta contém o código-fonte, os três binários correspondentes às fontes,
o payload completo do runtime, as políticas Polkit, o hook ALPM, as unidades
systemd, o atalho, o ícone, os inventários de dependências e os hashes.

Para reinstalar no sistema Mocha em execução:

```bash
cd -- "/media/mochafast/MochaArch/ativo/apps/mocha-update" && \
sudo -v && \
sudo bash -- ./INSTALAR-MOCHA-UPDATE.sh
```

O instalador valida o payload por SHA-256, instala pelo pacman somente os
pacotes de runtime ausentes, cria um backup recuperável em
`/var/backups/mocha`, reinstala os componentes e habilita o timer do índice.
Ele preserva `/var/lib/mocha-update`, os índices, o catálogo de rollbacks e
todos os snapshots existentes.

Para uma reinstalação sem acesso à rede, quando as dependências já estiverem
instaladas:

```bash
cd -- "/media/mochafast/MochaArch/ativo/apps/mocha-update" && \
sudo -v && \
sudo bash -- ./INSTALAR-MOCHA-UPDATE.sh --sem-instalar-dependencias
```

O instalador do Calamares continua separado em
`calamares/INSTALAR-MOCHA-UPDATE-NO-ALVO.sh`; ele recebe a raiz montada do
sistema novo e recusa instalar sobre `/`.
