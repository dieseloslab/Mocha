# Mocha — Vivaldi nativo e Plasma Browser Integration — 20260530-162055

## Ação feita

- Instalado/preservado pacote nativo: vivaldi
- Instalado/preservado pacote KDE: plasma-browser-integration
- Executável nativo detectado: /usr/bin/vivaldi-stable
- Desktop file usado: vivaldi-stable.desktop
- Flatpak removido, se existia: com.vivaldi.Vivaldi
- Perfil Flatpak preservado por segurança em: ~/.var/app/com.vivaldi.Vivaldi
- Atualização geral do sistema não foi feita.
- Kernel e driver de vídeo não foram alterados por este script.

## Motivo

O Vivaldi Flatpak pode atrapalhar a integração nativa do KDE Plasma Browser Integration por causa da sandbox e também confunde qual navegador está sendo aberto.

## Verificação

Abrir o Vivaldi nativo com:

/usr/bin/vivaldi-stable

Depois conferir a extensão Plasma Integration dentro do Vivaldi nativo.

Se a extensão ainda reclamar de native host, conferir:

/etc/chromium/native-messaging-hosts/org.kde.plasma.browser_integration.json
