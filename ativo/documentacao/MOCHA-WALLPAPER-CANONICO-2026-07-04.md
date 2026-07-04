<!-- MOCHA-WALLPAPER-CANONICO-2026-07-04:START -->
## MOCHA-WALLPAPER-CANONICO-2026-07-04

Fonte canônica do wallpaper aprovado:

```text
/media/mochafast/MochaArch/ativo/assets/branding/wallpaper/
```

Regra: não escolher wallpaper a partir de imagens de Calamares, slides, screenshots, análises visuais, mosaicos, miniaturas ou diretórios de auditoria. A pasta acima é a única fonte canônica.

Wallpaper padrão atualmente selecionado para configurações:

```text
Wall.png
```

Caminhos de implantação:

```text
Fonte repo:
  ativo/assets/branding/wallpaper/

Payload sistema instalado:
  ativo/calamares/payload/tema-completo/usr/share/backgrounds/mocha/

Skel/local do usuário:
  ativo/calamares/payload/kde/skel/.local/share/backgrounds/mocha/

Caminho runtime esperado no sistema instalado:
  /usr/share/backgrounds/mocha/Wall.png
```

Configurações:

```text
Desktop Plasma:
  plasma-org.kde.plasma.desktop-appletsrc
  Image=file:///usr/share/backgrounds/mocha/Wall.png

Tela de bloqueio:
  kscreenlockerrc
  Image=file:///usr/share/backgrounds/mocha/Wall.png
  PreviewImage=file:///usr/share/backgrounds/mocha/Wall.png

SDDM:
  theme.conf.user do tema SDDM Mocha, quando presente no payload
  background=/usr/share/backgrounds/mocha/Wall.png
```
<!-- MOCHA-WALLPAPER-CANONICO-2026-07-04:END -->
