# MochaArch — Contrato de localização do sistema instalado

## Regra canônica

As escolhas feitas pelo usuário no Calamares devem ser persistidas no sistema final instalado.

Isso inclui:

- idioma / locale;
- layout de teclado;
- fuso horário / timezone.

Essas escolhas pertencem ao usuário e não devem ser sobrescritas por defaults do projeto Mocha após a instalação.

## Idioma / locale

O idioma escolhido no instalador deve ser aplicado ao sistema instalado.

Requisitos esperados:

- `/etc/locale.conf` coerente com a escolha do usuário;
- geração do locale correspondente em `/etc/locale.gen`, quando aplicável;
- fallback seguro em inglês quando algum texto próprio do Mocha não tiver tradução;
- sem forçar `pt_BR.UTF-8` se o usuário escolheu outro idioma.

## Teclado

O layout de teclado escolhido no instalador deve ser aplicado ao sistema instalado.

Requisitos esperados:

- console configurado de forma compatível, normalmente por `/etc/vconsole.conf`;
- sessão gráfica e SDDM respeitando o layout escolhido;
- sem reset automático para `br-abnt2` quando o usuário escolheu outro layout.

## Fuso horário

O fuso horário escolhido no instalador deve ser aplicado ao sistema instalado.

Requisitos esperados:

- `/etc/localtime` apontando para a zona escolhida;
- configuração de timezone coerente;
- relógio configurado conforme a política normal do Arch;
- sem reset automático para timezone brasileiro quando o usuário escolheu outro fuso.

## Relação com as quatro línguas oficiais do Mocha

As quatro línguas oficiais do Mocha continuam sendo:

- Português;
- Inglês;
- Francês;
- Espanhol.

Essa regra vale para textos próprios do Mocha, branding, slideshow e documentação curta.

Ela não limita a escolha de idioma do usuário.

Se o Arch Linux e o Calamares suportarem determinado idioma, layout de teclado ou fuso horário, o usuário deve poder escolhê-lo.

Exemplo: se a base Arch/Calamares permitir instalação em árabe, teclado árabe e fuso de uma região árabe, o Mocha não deve bloquear isso artificialmente.

## Proibições

É proibido:

- limitar artificialmente o seletor de idioma a PT/EN/FR/ES;
- sobrescrever idioma escolhido pelo usuário no pós-instalação;
- sobrescrever layout de teclado escolhido pelo usuário no pós-instalação;
- sobrescrever fuso horário escolhido pelo usuário no pós-instalação;
- aplicar defaults brasileiros globais depois que o usuário já escolheu outra localização.

## Auditoria pré-ISO

Antes de gerar ISO com Calamares, auditar:

- presença dos módulos de idioma, teclado e fuso na sequência do Calamares;
- presença dos jobs que persistem locale/teclado/timezone no sistema instalado;
- ausência de scripts próprios do Mocha forçando `pt_BR`, `br-abnt2`, `America/Sao_Paulo` ou equivalentes no alvo instalado.
