# Resumo para análise do Calamares Mocha

## Pedido

Analisar imagens, textos e identidade visual/textual do Calamares Mocha.
Separar o que deve ser mantido, substituído, reescrito ou ignorado.

## Regras do projeto

- Mocha inicialmente oferece somente KDE Plasma.
- SDDM e Wayland são a base gráfica inicial.
- Inglês deve ser base e fallback.
- Português pode existir como tradução, mas não como fallback global.
- Não reaproveitar textos literais da ISO Calam-Arch.
- Não oferecer GNOME, XFCE, MATE, Cinnamon, Budgie, Deepin, i3, Openbox ou outros desktops.
- Identidade deve refletir foco gamer, Arch/KDE, Steam/Proton, GameMode, MangoHud e causa social.
- Não mexer em kernel, boot, firewall, Steam wrapper ou SDDM funcional nesta etapa.

## Arquivos incluídos para análise

- 00-RESUMO-PARA-CHATGPT.md
- 01-TEXTOS-CRITICOS-CONSOLIDADOS.md
- relatorios/01-arquivos-criticos-calamares.txt
- relatorios/02-residuos-e-alvos-de-reescrita.tsv
- relatorios/04-inventario-imagens.txt
- relatorios/05-proposta-textos-base-mocha.md
- relatorios/06-plano-proximo-overlay-identidade.md
- relatorios/mocha-curadoria-identidade-calamares-20260605-154121.log
- textos/etc-calamares/netinstall.yaml
- textos/etc-calamares/settings.conf
- textos/etc-calamares/settings-online.conf

## Resíduos/alvos principais encontrados

arquivo	linha	texto
etc-calamares/branding/mocha/show.qml	9	text: "Instalando o MochaArch"
etc-calamares/modules/bootloader.conf	23	kernelSearchPath: "/usr/lib/modules"
etc-calamares/modules/bootloader.conf	44	grubInstall: "grub-install"
etc-calamares/modules/bootloader.conf	83	installEFIFallback: true
etc-calamares/modules/displaymanager.conf	3	- sddm
etc-calamares/modules/displaymanager.conf	4	defaultDesktopEnvironment:
etc-calamares/modules/displaymanager.conf	5	executable: /usr/bin/startplasma-wayland
etc-calamares/modules/displaymanager.conf	6	desktopFile: plasma
etc-calamares/modules/initcpio.conf	16	kernel: linux
etc-calamares/modules/locale.conf	6	url: https://geoip.kde.org/v1/calamares
etc-calamares/modules/netinstall.conf	2	groupsUrl: file:///etc/calamares/netinstall.yaml
etc-calamares/modules/packagechooser.conf	3	method: netinstall-select
etc-calamares/modules/packagechooser.conf	5	- id: Mocha-Gamer-KDE
etc-calamares/modules/packagechooser.conf	6	name: "Mocha Gamer KDE"
etc-calamares/modules/packagechooser.conf	7	description: "Instalação inicial do Mocha com KDE Plasma e SDDM. Outros desktops não são oferecidos nesta fase."
etc-calamares/modules/packagechooser.conf	8	screenshot: /usr/share/calamares/branding/mocha/welcome.png
etc-calamares/modules/services-systemd.conf	9	- name: sddm.service
etc-calamares/modules/unpackfs.conf	95	-   source: src/qml/calamares/slideshow
etc-calamares/modules/unpackfs.conf	97	destination: "/tmp/slideshow/"
etc-calamares/modules/welcome.conf	2	showSupportUrl: true
etc-calamares/modules/welcome.conf	9	internetCheckUrl: https://archlinux.org/
etc-calamares/modules/welcome.conf	21	url: https://geoip.kde.org/v1/ubiquity
etc-calamares/modules/welcome.conf	25	internetCheckUrl: https://archlinux.org/
etc-calamares/netinstall.yaml	3	description: "Base mínima do Mocha para instalação Arch com NetworkManager, GRUB, firmware e ferramentas essenciais."
etc-calamares/netinstall.yaml	10	- linux
etc-calamares/netinstall.yaml	11	- linux-headers
etc-calamares/netinstall.yaml	12	- linux-firmware
etc-calamares/netinstall.yaml	42	- arch-install-scripts
etc-calamares/netinstall.yaml	52	- desktop-file-utils
etc-calamares/netinstall.yaml	77	- name: "Mocha KDE Plasma Wayland SDDM"
etc-calamares/netinstall.yaml	78	description: "Interface inicial única do Mocha: KDE Plasma com SDDM e Wayland. XWayland entra apenas para compatibilidade de aplicativos/jogos."
etc-calamares/netinstall.yaml	83	- plasma-meta
etc-calamares/netinstall.yaml	84	- plasma-desktop
etc-calamares/netinstall.yaml	85	- plasma-nm
etc-calamares/netinstall.yaml	86	- plasma-pa
etc-calamares/netinstall.yaml	88	- sddm
etc-calamares/netinstall.yaml	89	- sddm-kcm
etc-calamares/netinstall.yaml	92	- kde-gtk-config
etc-calamares/netinstall.yaml	93	- xdg-desktop-portal
etc-calamares/netinstall.yaml	94	- xdg-desktop-portal-kde
etc-calamares/netinstall.yaml	106	- kdegraphics-thumbnailers
etc-calamares/netinstall.yaml	110	- xorg-xwayland
etc-calamares/netinstall.yaml	128	- name: "Mocha Gamer Default"
etc-calamares/netinstall.yaml	129	description: "Camada gamer padrão: Steam, Wine/Proton, overlays, GameMode, ferramentas Vulkan e launchers disponíveis nos repositórios ativos."
etc-calamares/netinstall.yaml	134	- steam
etc-calamares/netinstall.yaml	139	- gamemode
etc-calamares/netinstall.yaml	140	- lib32-gamemode
etc-calamares/netinstall.yaml	144	- gamescope
etc-calamares/netinstall.yaml	145	- protontricks
etc-calamares/netinstall.yaml	156	description: "Ferramentas úteis para criação, documentação e uso geral sem transformar o perfil em desktop corporativo ou educacional."
etc-calamares/netinstall.yaml	162	- kdenlive
etc-calamares/netinstall.yaml	239	- fsarchiver
etc-calamares/settings.conf	1	modules-search:
etc-calamares/settings.conf	5	- welcome
etc-calamares/settings.conf	10	- netinstall
etc-calamares/settings.conf	38	branding: mocha
etc-calamares/settings.conf	39	prompt-install: false
etc-calamares/settings-online.conf	1	modules-search:
etc-calamares/settings-online.conf	5	- welcome
etc-calamares/settings-online.conf	10	- netinstall
etc-calamares/settings-online.conf	38	branding: mocha
etc-calamares/settings-online.conf	39	prompt-install: false
usr-share-calamares/branding/arch/show.qml	3	*   Copyright 2015, Teo Mrnjavac <teo@kde.org>
usr-share-calamares/branding/arch/show.qml	5	*   Calamares is free software: you can redistribute it and/or modify
usr-share-calamares/branding/arch/show.qml	10	*   Calamares is distributed in the hope that it will be useful,
usr-share-calamares/branding/arch/show.qml	16	*   along with Calamares. If not, see <http://www.gnu.org/licenses/>.
usr-share-calamares/branding/arch/show.qml	20	* Slides images dimensions are 800x440px.
usr-share-calamares/branding/arch/show.qml	24	import calamares.slideshow 1.0;
usr-share-calamares/branding/arch/show.qml	34	onTriggered: presentation.goToNextSlide()
usr-share-calamares/branding/arch/show.qml	37	Slide {
usr-share-calamares/branding/arch/show.qml	41	source: "slide1.png"
usr-share-calamares/branding/arch/show.qml	56	Slide {
usr-share-calamares/branding/arch/show.qml	60	source: "slide2.png"
usr-share-calamares/branding/arch/show.qml	75	Slide {
usr-share-calamares/branding/arch/show.qml	79	source: "slide3.png"
usr-share-calamares/branding/arch/show.qml	94	Slide {
usr-share-calamares/branding/arch/show.qml	98	source: "slide4.png"
usr-share-calamares/branding/arch/show.qml	113	Slide {
usr-share-calamares/branding/arch/show.qml	117	source: "slide5.png"
usr-share-calamares/branding/arch/show.qml	131	Slide {
usr-share-calamares/branding/arch/show.qml	135	source: "slide6.png"
usr-share-calamares/branding/arch/show.qml	150	Slide {
usr-share-calamares/branding/arch/show.qml	154	source: "slide7.png"
usr-share-calamares/branding/arch/show.qml	169	Slide {
usr-share-calamares/branding/arch/show.qml	173	source: "slide8.png"
usr-share-calamares/branding/arch/show.qml	188	Slide {
usr-share-calamares/branding/arch/show.qml	192	source: "slide9.png"
usr-share-calamares/branding/default/show.qml	3	*   SPDX-FileCopyrightText: 2015 Teo Mrnjavac <teo@kde.org>
usr-share-calamares/branding/default/show.qml	4	*   SPDX-FileCopyrightText: 2018 Adriaan de Groot <groot@kde.org>
usr-share-calamares/branding/default/show.qml	7	*   Calamares is Free Software: see the License-Identifier above.
usr-share-calamares/branding/default/show.qml	12	import calamares.slideshow 1.0;
usr-share-calamares/branding/default/show.qml	18	function nextSlide() {
usr-share-calamares/branding/default/show.qml	19	console.log("QML Component (default slideshow) Next slide");
usr-share-calamares/branding/default/show.qml	20	presentation.goToNextSlide();
usr-share-calamares/branding/default/show.qml	26	running: presentation.activatedInCalamares
usr-share-calamares/branding/default/show.qml	28	onTriggered: nextSlide()
usr-share-calamares/branding/default/show.qml	31	Slide {
usr-share-calamares/branding/default/show.qml	43	text: "This is a customizable QML slideshow.<br/>"+
usr-share-calamares/branding/default/show.qml	44	"Distributions should provide their own slideshow and list it in <br/>"+
usr-share-calamares/branding/default/show.qml	45	"their custom branding.desc file.<br/>"+
usr-share-calamares/branding/default/show.qml	46	"To create a Calamares presentation in QML, import calamares.slideshow,<br/>"+
usr-share-calamares/branding/default/show.qml	47	"define a Presentation element with as many Slide elements as needed."
usr-share-calamares/branding/default/show.qml	54	Slide {
usr-share-calamares/branding/default/show.qml	55	centeredText: qsTr("This is a second Slide element.")
usr-share-calamares/branding/default/show.qml	58	Slide {
usr-share-calamares/branding/default/show.qml	59	centeredText: qsTr("This is a third Slide element.")
usr-share-calamares/branding/default/show.qml	69	console.log("QML Component (default slideshow) activated");
usr-share-calamares/branding/default/show.qml	70	presentation.currentSlide = 0;
usr-share-calamares/branding/default/show.qml	74	console.log("QML Component (default slideshow) deactivated");
usr-share-calamares/branding/mocha/show.qml	3	*   Copyright 2015, Teo Mrnjavac <teo@kde.org>
usr-share-calamares/branding/mocha/show.qml	5	*   Calamares is free software: you can redistribute it and/or modify
usr-share-calamares/branding/mocha/show.qml	10	*   Calamares is distributed in the hope that it will be useful,
usr-share-calamares/branding/mocha/show.qml	16	*   along with Calamares. If not, see <http://www.gnu.org/licenses/>.
usr-share-calamares/branding/mocha/show.qml	20	* Slides images dimensions are 800x440px.
usr-share-calamares/branding/mocha/show.qml	24	import calamares.slideshow 1.0;
usr-share-calamares/branding/mocha/show.qml	34	onTriggered: presentation.goToNextSlide()
usr-share-calamares/branding/mocha/show.qml	37	Slide {
usr-share-calamares/branding/mocha/show.qml	41	source: "slide1.png"
usr-share-calamares/branding/mocha/show.qml	56	Slide {
usr-share-calamares/branding/mocha/show.qml	60	source: "slide2.png"
usr-share-calamares/branding/mocha/show.qml	75	Slide {
usr-share-calamares/branding/mocha/show.qml	79	source: "slide3.png"
usr-share-calamares/branding/mocha/show.qml	94	Slide {
usr-share-calamares/branding/mocha/show.qml	98	source: "slide4.png"
usr-share-calamares/branding/mocha/show.qml	113	Slide {
usr-share-calamares/branding/mocha/show.qml	117	source: "slide5.png"
usr-share-calamares/branding/mocha/show.qml	131	Slide {
usr-share-calamares/branding/mocha/show.qml	135	source: "slide6.png"
usr-share-calamares/branding/mocha/show.qml	150	Slide {
usr-share-calamares/branding/mocha/show.qml	154	source: "slide7.png"
usr-share-calamares/branding/mocha/show.qml	169	Slide {
usr-share-calamares/branding/mocha/show.qml	173	source: "slide8.png"
usr-share-calamares/branding/mocha/show.qml	188	Slide {
usr-share-calamares/branding/mocha/show.qml	192	source: "slide9.png"
usr-share-calamares/modules/bootloader.conf	23	kernelSearchPath: "/usr/lib/modules"
usr-share-calamares/modules/bootloader.conf	44	grubInstall: "grub-install"
usr-share-calamares/modules/bootloader.conf	83	installEFIFallback: true
usr-share-calamares/modules/chrootcfg.conf	13	- archlinux
usr-share-calamares/modules/chrootcfg.conf	14	- manjaro
usr-share-calamares/modules/contextualprocess.conf	61	"branding.shortVersion":
usr-share-calamares/modules/displaymanager.conf	3	- sddm
usr-share-calamares/modules/displaymanager.conf	4	defaultDesktopEnvironment:
usr-share-calamares/modules/displaymanager.conf	5	executable: /usr/bin/startplasma-wayland
usr-share-calamares/modules/displaymanager.conf	6	desktopFile: plasma
usr-share-calamares/modules/initcpio.conf	16	kernel: linux
usr-share-calamares/modules/license.conf	35	url:      http://support.amd.com/en-us/download/eula
usr-share-calamares/modules/license.conf	48	name: Calamares Proprietary License
usr-share-calamares/modules/license.conf	49	vendor: Calamares, Inc.
usr-share-calamares/modules/locale.conf	6	url: https://geoip.kde.org/v1/calamares
usr-share-calamares/modules/netinstall.conf	2	groupsUrl: file:///etc/calamares/netinstall.yaml
usr-share-calamares/modules/packagechooser.conf	3	method: netinstall-select
usr-share-calamares/modules/packagechooser.conf	5	- id: Mocha-Gamer-KDE
usr-share-calamares/modules/packagechooser.conf	6	name: "Mocha Gamer KDE"
usr-share-calamares/modules/packagechooser.conf	7	description: "Instalação inicial do Mocha com KDE Plasma e SDDM. Outros desktops não são oferecidos nesta fase."
usr-share-calamares/modules/packagechooser.conf	8	screenshot: /usr/share/calamares/branding/mocha/welcome.png
usr-share-calamares/modules/plasmalnf.conf	62	- org.kde.fuzzy-pig.desktop
usr-share-calamares/modules/plasmalnf.conf	63	- theme: org.kde.breeze.desktop
usr-share-calamares/modules/plasmalnf.conf	65	- theme: org.kde.breezedark.desktop
usr-share-calamares/modules/plasmalnf.conf	67	- org.kde.fluffy-bunny.desktop

## Próxima decisão desejada

Gerar uma lista objetiva:

1. imagens que servem;
2. imagens que precisam ser substituídas;
3. textos que devem ser reescritos;
4. textos que podem ficar;
5. arquivos exatos que devem entrar no próximo overlay de identidade.
