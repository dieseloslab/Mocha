# Roteiro de identidade do Calamares Mocha

## Estado

Esta pasta contém a extração dos textos, imagens, configs, branding, welcome e slideshow atuais do Calamares aplicado no airootfs Mocha.

O conteúdo atual ainda é provisório. Não deve ser tratado como identidade final.

## Objetivo

Substituir imagens e textos genéricos por conteúdo próprio do Mocha.

A identidade do instalador deve comunicar:

- Mocha como distribuição Arch/KDE focada em jogos.
- KDE Plasma como interface inicial única.
- SDDM e Wayland como base gráfica inicial.
- Ferramentas gamer, Steam/Proton, GameMode, MangoHud e otimizações como parte do propósito do sistema.
- Projeto com causa social e intenção de apoiar doações.
- Estética Mocha baseada no logo oficial e no papel de parede aprovado.
- Inglês como base e fallback.
- Traduções conforme idioma escolhido no instalador quando houver tradução disponível.

## Arquivos extraídos

- imagens/
  Imagens atuais encontradas no Calamares.

- textos/
  Arquivos textuais atuais: YAML, QML, configs, desktop, markdown, txt, json, xml.

- slideshow-welcome/
  Arquivos ligados a branding, welcome, show.qml, slides e slideshow.

- yaml-configs/
  Configs críticas usadas pelo Calamares.

- manifestos/
  Inventários, hashes e índice de linhas editáveis.

## Próxima etapa

Criar uma proposta de branding Mocha com:

1. textos base em inglês;
2. versão portuguesa inicial;
3. estrutura preparada para futuras traduções;
4. imagens substituídas por logo/papel de parede Mocha;
5. validação YAML/QML;
6. novo overlay;
7. aplicação em airootfs;
8. geração de novo airootfs.sfs somente depois da validação visual e textual.

## Regras

- Não copiar literalmente textos da ISO base.
- Não oferecer outros desktops além de KDE Plasma.
- Não usar português como fallback global.
- Não prometer suporte além do que será entregue.
- Não mexer em SDDM, boot, kernel, Steam wrapper ou firewall nesta etapa.
