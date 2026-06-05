# MochaArch Calamares — branding provisório

Data: 20260605-121142

## Estado atual

A árvore ativa do Calamares em:

/media/mochafast/MochaArch/calamares/mocha-calamares

foi promovida a partir do staging validado e está funcional para avanço técnico.

Os arquivos atuais de branding do diretório:

/media/mochafast/MochaArch/calamares/mocha-calamares/usr/share/calamares/branding/mocha

são provisórios.

## Regra canônica

Antes da ISO pública, substituir o branding provisório por identidade própria do Mocha, baseada em:

- logo oficial do projeto Mocha;
- papel de parede Mocha aprovado;
- paleta visual KDE/Mocha atual canonizada;
- inglês como texto base e fallback;
- traduções conforme idioma escolhido no instalador, quando disponíveis.

## Arquivos marcados como provisórios

- logo.png
- splash.png
- welcome.png
- slide1.png até slide9.png
- show.qml, se o layout precisar ser ajustado
- branding.desc, se metadados, dimensões ou identidade visual precisarem ser ajustados

## Restrições

Não herdar identidade visual da Calam-Arch na versão final.

Não alterar SDDM, boot, kernel, Steam wrapper, firewall, DNS ou perfil gamer por causa desta etapa.

Não substituir imagens sem antes auditar dimensões, referências em branding.desc/show.qml e carregamento do slideshow.

## Próximo trabalho futuro

Criar pacote visual próprio do Calamares Mocha com logo e wallpaper oficiais, validar assets, atualizar branding.desc/show.qml se necessário e testar carregamento do instalador.
