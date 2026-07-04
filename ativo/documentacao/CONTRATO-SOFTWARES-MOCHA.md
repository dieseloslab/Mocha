# Contrato de softwares Mocha

Atualizado em: 20260703-164059

Este contrato define a base para transformar uma instalação Arch normal em Mocha antes de existir uma ISO plenamente pronta.

## Listas canônicas

Pacotes que ficam:

- /media/mochafast/MochaArch/ativo/sistema-base/pacotes-keep-base.txt

Candidatos a remover:

- /media/mochafast/MochaArch/ativo/sistema-base/pacotes-remove-candidatos.txt

Pacotes para revisão:

- /media/mochafast/MochaArch/ativo/sistema-base/pacotes-review.txt

## Auditoria desta máquina

Pacotes explícitos:

- /media/mochafast/MochaArch/auditorias/audita-barra-softwares-canonicos-20260703-164059/pacotes-explicitos.txt

Pacotes explícitos de repo:

- /media/mochafast/MochaArch/auditorias/audita-barra-softwares-canonicos-20260703-164059/pacotes-explicitos-repo.txt

Pacotes AUR/locais:

- /media/mochafast/MochaArch/auditorias/audita-barra-softwares-canonicos-20260703-164059/pacotes-explicitos-aur-ou-locais.txt

Órfãos:

- /media/mochafast/MochaArch/auditorias/audita-barra-softwares-canonicos-20260703-164059/pacotes-orfaos.txt

Candidatos a remover instalados:

- /media/mochafast/MochaArch/auditorias/audita-barra-softwares-canonicos-20260703-164059/remove-candidatos-instalados.txt

Pacotes de revisão instalados:

- /media/mochafast/MochaArch/auditorias/audita-barra-softwares-canonicos-20260703-164059/review-instalados.txt

## Regra

Não remover pacote por nome genérico sem revisar função real no Mocha.

Antes da ISO, esta lista deve ser refinada a cada conversão Arch -> Mocha.

## Futuro script seguro

O script de conversão Arch -> Mocha deve ter fases:

1. instalar keep-base;
2. aplicar runtime gaming;
3. aplicar visual KDE;
4. aplicar barra/painel;
5. aplicar Mocha Updater;
6. aplicar Calamares/finalizadores;
7. listar candidatos a remover;
8. remover somente candidatos aprovados;
9. validar.
