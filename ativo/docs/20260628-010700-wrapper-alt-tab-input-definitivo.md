# Mocha — Wrapper Steam que resolveu Alt+Tab/input

Data de consolidação: 2026-06-28

Wrapper que aparentemente resolve a perda de input após Alt+Tab:

/media/mochafast/MochaArch/auditorias/backup-audio-alt-tab-definitivo-20260611-203707/mocha-steam-game-run.bak

Linha oficial da Steam:

/usr/local/bin/mocha-steam-game-run %command%

Regra operacional:

- Não reescrever o wrapper do zero quando o problema for perda de input após Alt+Tab.
- Não escolher automaticamente o backup mais recente.
- Restaurar primeiro o wrapper definitivo acima.
- Separar correção de Alt+Tab/input da correção do MangoHud.
- Não mexer em prefixos Proton, user.reg, compatdata ou localconfig da Steam como primeira tentativa.
- O wrapper mínimo criado em 2026-06-28 não deve ser tratado como solução definitiva, pois não resolveu sozinho a perda de input.

Comando de restauração recomendado:

sudo install -Dm755 /media/mochafast/MochaArch/auditorias/backup-audio-alt-tab-definitivo-20260611-203707/mocha-steam-game-run.bak /usr/local/bin/mocha-steam-game-run
