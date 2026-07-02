# Mocha Updater — fluxo canônico

## Caminho canônico

O Mocha Updater vive no projeto público em:

    apps/mocha-updater

Ele é o aplicativo gráfico canônico para:

- atualização geral do sistema;
- atualização de Flatpaks quando disponíveis;
- verificação conservadora de mirrors;
- área separada para kernel/driver de vídeo casados;
- detecção de CPU/GPU antes de recomendar kernel;
- evitar conversão indevida do sistema para CachyOS;
- oferecer rollback/fallback quando kernel ou driver se comportarem mal.

## Regra de interface

A interface principal deve ser orientada a usuário comum:

- cards;
- listas visuais;
- botões claros de ação/cancelamento;
- abas/áreas separadas;
- nenhum fluxo principal baseado em log bruto.

Logs técnicos podem existir, mas devem ficar em uma área separada de detalhes técnicos.

## Idiomas

O aplicativo deve suportar apenas:

- português;
- inglês;
- francês;
- espanhol.

O idioma segue o locale do sistema quando começar com `pt`, `en`, `fr` ou `es`.

Qualquer outro idioma deve cair automaticamente para inglês.

## Visual

A identidade visual aprovada é mocha escuro/neutro:

- café/mocha escuro;
- cobre discreto;
- texto creme suave;
- evitar laranja/amarelo forte como cor dominante.

## Atalhos

O Mocha Updater deve possuir:

    /usr/share/applications/mocha-updater.desktop

Categoria KDE/menu:

    System;Settings;

Quando aplicável em ambiente de teste, também pode existir um atalho canônico na área de trabalho do usuário.

Atalhos antigos, duplicados, inúteis ou ultrapassados devem ser removidos para evitar confusão.

## Scripts canônicos

Instalação local/teste:

    sudo bash /media/mochafast/MochaArch/scripts/mocha-instala-updater-canonico-v1.sh

Validação:

    bash /media/mochafast/MochaArch/scripts/mocha-testa-updater-canonico-v1.sh

## Commits

Alterações do Mocha Updater devem ser commitadas granularmente:

1. app/interface;
2. atalhos/instalação;
3. documentação;
4. auditorias internas, quando existirem, apenas no repo interno.
