# MochaArch — correção de input perdido em jogos após Alt+Tab

Timestamp: 20260602-113238

## Sintoma

Ao usar Alt+Tab durante jogos, o jogo continua renderizando e o Steam Overlay continua funcionando, mas o jogo perde input de teclado/mouse ao voltar.

## Diagnóstico

Esse comportamento indica perda de foco/captura de input na janela do jogo, não travamento do jogo, não falha de GPU e não falha direta do driver NVIDIA.

## Ajuste aplicado

Arquivo:

/home/hal/.config/kwinrc

Chaves aplicadas no grupo [Windows]:

- FocusPolicy=ClickToFocus
- FocusStealingPreventionLevel=0
- NextFocusPrefersMouse=false
- AutoRaise=false
- DelayFocusInterval=0

## Backup

/media/mochafast/MochaArch/ativo/relatorios/20260602-113238-kwinrc-backup-antes-input-alt-tab

## Log

/media/mochafast/MochaArch/ativo/relatorios/20260602-113238-mocha-kde-input-alt-tab-jogos.log

## Teste recomendado

1. Abrir Steam.
2. Abrir o jogo normalmente.
3. Entrar numa fase jogável.
4. Usar Alt+Tab para sair.
5. Voltar para o jogo pelo Alt+Tab ou clicando na janela.
6. Confirmar se teclado/mouse voltam a responder sem precisar fechar o jogo.

## Reversão manual, se necessário

Restaurar o backup:

cp -a "/media/mochafast/MochaArch/ativo/relatorios/20260602-113238-kwinrc-backup-antes-input-alt-tab" "/home/hal/.config/kwinrc"

Depois recarregar o KWin:

qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure

