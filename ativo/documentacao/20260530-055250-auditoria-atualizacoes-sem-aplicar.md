# Mocha Arch - auditoria de atualizações sem aplicar

Data: 20260530-055250

## Resultado

- O sistema foi auditado sem aplicar atualizações.
- Não foi executado `pacman -Syu`.
- O comando usado para atualizações disponíveis foi `pacman -Qu`.
- O repositório `mocha-stable` está ativo.
- O repositório `mocha-testing` não está ativo.

## Totais

- Atualizações disponíveis: 1
- Pacotes foreign/AUR/locais instalados: 2

## Política aplicada

- Kernel, NVIDIA, Mesa, Vulkan, Wayland e pilha gráfica foram classificados como bloqueados.
- Base crítica, boot, initramfs, pacman, keyring, glibc, systemd e sudo foram classificados como bloqueados.
- Programas comuns foram classificados apenas como candidatos de teste.
- AUR/foreign foi apenas listado; não entra em atualização geral.
- A promoção para o Mocha deve continuar pacote a pacote, primeiro em teste, depois em stable.

## Arquivos gerados

- Log: `/media/mochafast/MochaArch/ativo/relatorios/20260530-055250-auditoria-atualizacoes-sem-aplicar.log`
- Repositórios ativos: `/media/mochafast/MochaArch/ativo/relatorios/20260530-055250-repositorios-ativos-pacman.txt`
- Saída bruta do `pacman -Qu`: `/media/mochafast/MochaArch/ativo/relatorios/20260530-055250-pacman-Qu-bruto.txt`
- Classificação TSV: `/media/mochafast/MochaArch/ativo/relatorios/20260530-055250-pacman-Qu-classificado.tsv`
- Pacotes foreign/AUR/locais: `/media/mochafast/MochaArch/ativo/relatorios/20260530-055250-pacotes-foreign-aur-ou-locais.txt`
- Script reutilizável: `/media/mochafast/MochaArch/ativo/scripts/20260530-055250-mocha-auditar-atualizacoes-sem-aplicar.sh`

## Resumo por classe

- CANDIDATO_TESTE: 1

## Bloqueados

- Nenhum pacote bloqueado apareceu na lista de atualizações.

## Próxima ação recomendada

- Não atualizar ainda.
- Revisar a lista de candidatos comuns.
- Escolher um lote pequeno de pacotes não críticos para teste controlado.
- Manter kernel/NVIDIA/Mesa/Vulkan/boot congelados até teste específico.
