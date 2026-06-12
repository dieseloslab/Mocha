# MochaArch — Política de idiomas do instalador Calamares

## Regra canônica

A instalação do MochaArch deve permitir que o usuário escolha o idioma de instalação.

As quatro línguas oficiais sacramentadas para textos próprios do Mocha são:

- Português
- Inglês
- Francês
- Espanhol

Essas quatro línguas são obrigatórias para conteúdo próprio do projeto, como branding, slideshow, mensagens institucionais e documentação curta exibida no instalador.

## Fallback

Quando uma tradução própria do Mocha não existir, o fallback obrigatório deve ser o inglês.

## Liberdade de escolha do usuário

O instalador não deve impor uma whitelist artificial limitada a PT/EN/FR/ES.

Se o Calamares e o Arch Linux suportarem determinado idioma, o usuário deve poder escolhê-lo durante a instalação.

<!-- MOCHA-PERSISTENCIA-LOCALIZACAO-INICIO -->
## Persistência no sistema instalado

As escolhas feitas pelo usuário no Calamares devem ser aplicadas ao sistema final instalado:

- idioma / locale;
- layout de teclado;
- fuso horário / timezone.

Essas escolhas não são apenas preferências da sessão live. Elas devem ser gravadas no alvo instalado.

O Mocha não deve sobrescrever posteriormente essas escolhas com defaults próprios, como `pt_BR`, `br-abnt2` ou `America/Sao_Paulo`, quando o usuário tiver escolhido outros valores.
<!-- MOCHA-PERSISTENCIA-LOCALIZACAO-FIM -->
