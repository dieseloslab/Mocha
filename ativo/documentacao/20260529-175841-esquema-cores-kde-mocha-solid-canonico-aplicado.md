# Esquema de cores KDE MochaSolidCanonico aplicado — 20260529-175841

## Resultado

O esquema `MochaSolidCanonico` foi instalado e aplicado no KDE do usuário atual.

## Origem

`/media/mochafast/MochaKDE-BaseAtiva-20260527-221154/kdedeutoflake/tema-kde-atual-salvo-20260524-212342/home-config/.local/share/color-schemes`

## Destino ativo MochaArch

`/media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados`

## Destino do usuário

`/home/hal/.local/share/color-schemes`

## Arquivos preservados/copied
- `MochaSolidCanonico.colors`
- `MochaKDE.colors`
- `MochaDark.colors`
- `Mocha-Windows11.colors`

## Correção aplicada

O comando anterior abortava ao contar HEX porque alguns arquivos `.colors` usam RGB e não `#RRGGBB`. Esta versão usa `grep ... || true` nos contadores e não interrompe o fluxo.

## Confirmação

`kdeglobals -> General -> ColorScheme = MochaSolidCanonico`
