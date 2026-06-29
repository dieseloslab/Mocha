# Mocha — Wrapper Steam canônico

Registro: 20260628-011105

Este é o verdadeiro wrapper Steam canônico do Mocha para Alt+Tab/input.

Fonte canônica:
/media/mochafast/MochaArch/auditorias/backup-audio-alt-tab-definitivo-20260611-203707/mocha-steam-game-run.bak

Destino runtime:
/usr/local/bin/mocha-steam-game-run

Linha oficial dos jogos Steam:
/usr/local/bin/mocha-steam-game-run %command%

SHA256:
3d58607f9f7c3bd1aaa8e3924a9f4eb7e1f13531bf64c10fd5587aec271b0235

Regra operacional:
- Este é o verdadeiro wrapper Steam canônico.
- Não substituir por wrapper mínimo criado em 2026-06-28.
- Não escolher automaticamente o backup mais recente.
- Para perda de input após Alt+Tab, restaurar este wrapper primeiro.
- Separar Alt+Tab/input de MangoHud.
- Não mexer em prefixos Proton, user.reg, compatdata ou localconfig da Steam como primeira tentativa.

Comando de restauração:
sudo install -Dm755 /media/mochafast/MochaArch/auditorias/backup-audio-alt-tab-definitivo-20260611-203707/mocha-steam-game-run.bak /usr/local/bin/mocha-steam-game-run
