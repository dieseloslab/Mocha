# MochaArch — separação de jogos casuais por perfil

Timestamp: 20260601-111446

## Decisão

A edição Gamer do MochaArch não deve carregar o pacote amplo de joguinhos casuais da instalação padrão.

Exceção mantida no perfil Gamer: Mahjong e Go.

O restante dos joguinhos casuais detectados fica separado para outro perfil, principalmente Escola/Casual.

Nenhum pacote foi removido do sistema por este script. A separação foi feita em listas de perfil.

## Arquivos gerados

- Gamer, manter Mahjong/Go: /media/mochafast/MochaArch/ativo/perfis/gamer/20260601-111446-jogos-casuais-permitidos-mahjong-go.pacmanlist
- Gamer, retirar da lista principal: /media/mochafast/MochaArch/ativo/perfis/gamer/20260601-111446-retirar-do-perfil-gamer-jogos-casuais.pacmanlist
- Escola/Casual, lista de jogos: /media/mochafast/MochaArch/ativo/perfis/escola/20260601-111446-jogos-casuais-escola.pacmanlist
- Escola/Casual, candidatos a revisar: /media/mochafast/MochaArch/ativo/perfis/escola/20260601-111446-revisar-candidatos-jogos-casuais.txt
- Log: /media/mochafast/MochaArch/ativo/relatorios/20260601-111446-separar-jogos-casuais-perfis.log

## Conteúdo do perfil Gamer permitido

- kajongg
- kigo
- kmahjongg
- kshisen

## Conteúdo movido para perfil Escola/Casual

- bomber
- bovo
- granatier
- kapman
- katomic
- kblackbox
- kblocks
- kbounce
- kbreakout
- kdiamond
- kfourinline
- kgoldrunner
- killbots
- kiriki
- kjumpingcube
- klickety
- klines
- kmines
- knavalbattle
- knetwalk
- knights
- kolf
- kollision
- konquest
- kpat
- kreversi
- ksirk
- ksnakeduel
- kspaceduel
- ksquares
- ksudoku
- ktuberling
- kubrick
- lskat
- palapeli
- picmi

## Candidatos a revisar manualmente

- Nenhum candidato adicional foi detectado pela descrição/grupo do pacote.

## Regra para a ISO

Na ISO Gamer, não importar automaticamente a lista Escola/Casual.

Na ISO Escola/Casual, importar a lista Escola/Casual quando fizer sentido pedagógico/recreativo.

Mahjong/Go podem continuar no perfil Gamer como exceção leve, desde que não arrastem metapacotes amplos de jogos.
