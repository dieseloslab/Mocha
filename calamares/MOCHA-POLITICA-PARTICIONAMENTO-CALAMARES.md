# MochaArch - politica de particionamento da ISO

## Regra principal

O Calamares nao deve iniciar com particionamento automatico pre-selecionado.

O usuario precisa escolher explicitamente uma das opcoes:

- instalar lado a lado com Windows/outro sistema;
- substituir uma particao existente;
- apagar/usar o disco inteiro;
- particionamento manual.

## Windows / dual boot

A instalacao lado a lado com Windows deve permanecer disponivel sempre que o Calamares detectar espaco ou conseguir redimensionar uma particao existente.

Nao devemos ocultar nem quebrar essa opcao.

## Usar disco inteiro

Quando o usuario escolher conscientemente usar o disco inteiro, a politica Mocha e:

1. EFI FAT32 em `/boot/efi`, tamanho recomendado de 2 GiB.
2. Raiz `/` em ext4.
3. `/home` separado em XFS usando o restante disponivel.
4. Swap inicial: nenhum, com opcoes para swap pequeno ou swapfile.

## Manual

No particionamento manual:

- EFI deve ser FAT32.
- `/` deve ser ext4.
- `/home` pode ser XFS ou ext4, com XFS recomendado.
