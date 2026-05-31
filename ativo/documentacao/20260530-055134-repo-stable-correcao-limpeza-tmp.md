# Mocha Arch - correção da limpeza temporária do repo stable

Data: 20260530-055134

## Situação

A ativação do repositório local `mocha-stable` foi bem-sucedida.

O erro final foi restrito à limpeza de diretório temporário em `/tmp`:

- o teste de banco usou `sudo pacman -Sy` com `--dbpath` temporário;
- o pacman criou arquivos pertencentes ao root dentro do diretório temporário;
- o trap antigo usava `rm -rf "$TMPDIR"` sem sudo;
- por isso a limpeza falhou com permissão negada.

## Correção

- Temporários `/tmp/mocha-repo-stable-test-*` foram removidos com sudo.
- O script reutilizável foi corrigido para limpar o diretório temporário com a mesma camada `SUDO` já definida no script.
- O script anterior foi preservado em quarentena, não misturado no ativo.

## Estado validado

- `[mocha-stable]` está ativo em `/etc/pacman.conf`.
- O servidor aponta para `file:///media/vmstore/MochaArch/repos/mocha-stable/os/x86_64`.
- `[mocha-testing]` não está ativo.
- `core`, `extra` e `multilib` permanecem preservados.
- Nenhum `pacman -Syu` foi executado nesta correção.

## Arquivos

- Log: `/media/mochafast/MochaArch/ativo/relatorios/20260530-055134-corrigir-limpeza-tmp-repo-stable.log`
- Documento: `/media/mochafast/MochaArch/ativo/documentacao/20260530-055134-repo-stable-correcao-limpeza-tmp.md`
- Script corrigido: `/media/mochafast/MochaArch/ativo/scripts/20260530-055134-mocha-continuar-repo-stable-ativar-pacman-conf-corrigido.sh`
- Script anterior em quarentena: `/media/mochafast/MochaArch/quarentena/scripts-com-erro/20260530-055134-20260530-055006-mocha-continuar-repo-stable-ativar-pacman-conf.sh.quarentena`
