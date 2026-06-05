# Base Calamares — Calam-Arch-Installer 2026-06

Esta pasta contém a base auditada do Calamares extraída da ISO Calam-Arch-Installer-2026-06 para adaptação ao MochaArch.

Origem local auditada:
/media/mochafast/MochaArch/calamares/trabalho-mocha-calamares-20260605-112806

Data de canonização:
20260605-113023

Estado:
- origem preservada sem edição;
- cópia de trabalho sincronizada para pasta estável do repositório;
- próxima etapa: transformar a configuração genérica em perfil Mocha Gamer;
- não alterar SDDM, boot, kernel ou ISO final sem auditoria específica.

Pontos iniciais identificados:
- substituir branding Arch/default por branding Mocha;
- reduzir netinstall para perfil Mocha Gamer;
- remover perfis genéricos de desktop que não farão parte do instalador Mocha padrão;
- trocar Chromium por navegadores/softwares canônicos do Mocha;
- revisar Xorg, LightDM, GNOME, XFCE, Mate, Cinnamon, Budgie, Deepin, i3 e Openbox fora do perfil padrão;
- manter foco em Plasma Wayland, SDDM, Steam, Lutris, Heroic, Bottles, ProtonUp-Qt, MangoHud, GOverlay, GameMode, TuneD, UFW, OnlyOffice, Vivaldi e ferramentas gamer aprovadas.
