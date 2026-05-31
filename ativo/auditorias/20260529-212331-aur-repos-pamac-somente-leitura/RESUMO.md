# Mocha Arch — auditoria AUR/repositórios

Data: 2026-05-29T21:23:33-03:00

Pasta: /media/mochafast/MochaArch/ativo/auditorias/20260529-212331-aur-repos-pamac-somente-leitura

## Resultado curto

Pacotes foreign/AUR/locais detectados: 2
Helpers AUR/Pamac detectados: nenhum
Repositórios fora do Arch puro: nenhum
Repositórios AUR/binários suspeitos: nenhum

## Decisão operacional recomendada

1. Não usar yay -Syu, paru -Syu nem Pamac para atualizar esta máquina agora.
2. Se chaotic-aur ou outro repo AUR/binário estiver ativo, não fazer pacman -Syu antes de decidir se ele será desativado.
3. Pacotes foreign podem permanecer instalados para teste, mas não devem entrar automaticamente na edição final do Mocha.
4. Para a edição final, preferir pacotes dos repositórios Arch oficiais, Flatpak/Flathub quando fizer sentido, e AUR só por exceção documentada.

## Arquivos gerados

01-repositorios-pacman.txt
02-helpers-aur-pamac.txt
03-pacotes-foreign-detalhados.txt
04-classificacao-repos.txt
05-pamac-config.txt
