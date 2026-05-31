# Mocha Arch - repositório mocha-stable validado e ativado

Data: 20260530-055006

## Resultado

- O repositório local mocha-stable foi validado no VMSTORE.
- Caminho: /media/vmstore/MochaArch/repos/mocha-stable/os/x86_64
- Banco principal: /media/vmstore/MochaArch/repos/mocha-stable/os/x86_64/mocha-stable.db.tar.zst
- Link usado pelo pacman: /media/vmstore/MochaArch/repos/mocha-stable/os/x86_64/mocha-stable.db
- O arquivo real auditado e alterado foi /etc/pacman.conf.
- Somente [mocha-stable] foi ativado.
- [mocha-testing] não foi habilitado.
- [core], [extra] e [multilib] foram preservados quando já existiam.
- Não foi executado pacman -Syu.
- Foi executado somente pacman -Syy para sincronizar bancos.

## Correção aplicada

- A tentativa anterior criou o banco do repositório, mas falhou na validação porque pacman -Sy com dbpath temporário também precisa de root.
- Este script corrigiu a validação usando sudo apenas para o pacman temporário e para a escrita final do pacman.conf.

## Política

- mocha-stable é a camada local controlada do Mocha.
- core/extra/multilib continuam fornecendo a base Arch rolling nesta fase.
- mocha-testing permanece fora do uso normal.
- A promoção para mocha-stable deve ser feita pacote a pacote, após teste.
- AUR não entra em atualização geral do sistema.

## Arquivos

- Backup do pacman.conf: /etc/pacman.conf.mocha-backup-20260530-055006
- Log: /media/mochafast/MochaArch/ativo/relatorios/20260530-055006-continuar-repo-stable-ativar-pacman-conf.log
- Script reutilizável: /media/mochafast/MochaArch/ativo/scripts/20260530-055006-mocha-continuar-repo-stable-ativar-pacman-conf.sh
