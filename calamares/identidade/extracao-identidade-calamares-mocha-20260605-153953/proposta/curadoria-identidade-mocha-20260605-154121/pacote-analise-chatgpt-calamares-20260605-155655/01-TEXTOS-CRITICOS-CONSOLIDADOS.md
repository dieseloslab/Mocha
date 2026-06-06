# Textos críticos do Calamares Mocha para análise

Gerado em: 20260605-155655

Extração: /media/mochafast/MochaArch/calamares/identidade/extracao-identidade-calamares-mocha-20260605-153953
Curadoria: /media/mochafast/MochaArch/calamares/identidade/extracao-identidade-calamares-mocha-20260605-153953/proposta/curadoria-identidade-mocha-20260605-154121

## Observação

Este arquivo consolida apenas os textos prováveis de branding, welcome, slideshow, pacote e netinstall.
Ele é feito para ser enviado ao ChatGPT, sem precisar abrir a visualização HTML local.


================================================================
ARQUIVO: etc-calamares/branding/mocha/branding.desc
================================================================

     1	# MochaArch - branding inicial Calamares
     2	---
     3	componentName: mocha
     4	
     5	strings:
     6	    productName:         MochaArch
     7	    shortProductName:    Mocha
     8	    version:             rolling
     9	    shortVersion:        rolling
    10	    versionedName:       MochaArch rolling
    11	    shortVersionedName:  Mocha rolling
    12	    bootloaderEntryName: MochaArch
    13	    productUrl:          https://github.com/dieseloslab/Mocha
    14	    supportUrl:          https://github.com/dieseloslab/Mocha
    15	    knownIssuesUrl:      https://github.com/dieseloslab/Mocha
    16	    releaseNotesUrl:     https://github.com/dieseloslab/Mocha
    17	
    18	images:
    19	    productLogo:         logo.png
    20	    productIcon:         logo.png
    21	    productWelcome:      welcome.png
    22	
    23	style:
    24	    sidebarBackground:   "#3b2a22"
    25	    sidebarText:         "#f3e6d3"
    26	    sidebarTextSelect:   "#ffffff"
    27	
    28	slideshow:               show.qml
    29	slideshowAPI:            2
    30	windowExpanding:         normal

================================================================
ARQUIVO: etc-calamares/branding/mocha/show.qml
================================================================

     1	import QtQuick 2.15
     2	
     3	Rectangle {
     4	    width: 800
     5	    height: 480
     6	
     7	    Text {
     8	        anchors.centerIn: parent
     9	        text: "Instalando o MochaArch"
    10	        font.pixelSize: 28
    11	    }
    12	}

================================================================
ARQUIVO: etc-calamares/modules/displaymanager.conf
================================================================

     1	---
     2	displaymanagers:
     3	- sddm
     4	defaultDesktopEnvironment:
     5	  executable: /usr/bin/startplasma-wayland
     6	  desktopFile: plasma
     7	basicSetup: false
     8	sysconfigSetup: false

================================================================
ARQUIVO: etc-calamares/modules/packagechooser.conf
================================================================

     1	---
     2	mode: required
     3	method: netinstall-select
     4	items:
     5	- id: Mocha-Gamer-KDE
     6	  name: "Mocha Gamer KDE"
     7	  description: "Instalação inicial do Mocha com KDE Plasma e SDDM. Outros desktops não são oferecidos nesta fase."
     8	  screenshot: /usr/share/calamares/branding/mocha/welcome.png
     9	  selected: true

================================================================
ARQUIVO: etc-calamares/modules/services-systemd.conf
================================================================

     1	---
     2	units:
     3	- name: NetworkManager.service
     4	  action: enable
     5	- name: systemd-resolved.service
     6	  action: enable
     7	- name: ufw.service
     8	  action: enable
     9	- name: sddm.service
    10	  action: enable
    11	- name: cups.service
    12	  action: enable
    13	- name: avahi-daemon.service
    14	  action: enable
    15	- name: systemd-timesyncd.service
    16	  action: enable
    17	- name: power-profiles-daemon.service
    18	  action: enable
    19	- name: bluetooth.service
    20	  action: enable
    21	- name: fstrim.timer
    22	  action: enable
    23	- name: graphical.target
    24	  action: set-default

================================================================
ARQUIVO: etc-calamares/modules/welcome.conf
================================================================

     1	---
     2	showSupportUrl: true
     3	showKnownIssuesUrl: true
     4	showReleaseNotesUrl: false
     5	showDonateUrl: true
     6	requirements:
     7	  requiredStorage: 5.5
     8	  requiredRam: 1.0
     9	  internetCheckUrl: https://archlinux.org/
    10	  check:
    11	  - storage
    12	  - ram
    13	  - power
    14	  - internet
    15	  - root
    16	  - screen
    17	  required:
    18	  - ram
    19	geoip:
    20	  style: none
    21	  url: https://geoip.kde.org/v1/ubiquity
    22	  selector: CountryCode
    23	requiredStorage: 40.0
    24	requiredRam: 4.0
    25	internetCheckUrl: https://archlinux.org/
    26	check:
    27	- storage
    28	- ram
    29	- power
    30	- internet
    31	- root
    32	- screen
    33	required:
    34	- storage
    35	- ram
    36	- root
    37	- screen

================================================================
ARQUIVO: etc-calamares/netinstall.yaml
================================================================

     1	---
     2	- name: "Mocha Core System"
     3	  description: "Base mínima do Mocha para instalação Arch com NetworkManager, GRUB, firmware e ferramentas essenciais."
     4	  hidden: false
     5	  selected: true
     6	  critical: true
     7	  packages:
     8	  - base
     9	  - base-devel
    10	  - linux
    11	  - linux-headers
    12	  - linux-firmware
    13	  - amd-ucode
    14	  - intel-ucode
    15	  - grub
    16	  - efibootmgr
    17	  - os-prober
    18	  - mtools
    19	  - dosfstools
    20	  - btrfs-progs
    21	  - xfsprogs
    22	  - exfatprogs
    23	  - ntfs-3g
    24	  - networkmanager
    25	  - iwd
    26	  - wpa_supplicant
    27	  - wireless-regdb
    28	  - modemmanager
    29	  - mobile-broadband-provider-info
    30	  - sudo
    31	  - polkit
    32	  - dbus
    33	  - nano
    34	  - vim
    35	  - git
    36	  - wget
    37	  - curl
    38	  - rsync
    39	  - openssh
    40	  - pacman-contrib
    41	  - reflector
    42	  - arch-install-scripts
    43	  - squashfs-tools
    44	  - cpio
    45	  - busybox
    46	  - pv
    47	  - dialog
    48	  - bash-completion
    49	  - xdg-user-dirs
    50	  - xdg-utils
    51	  - shared-mime-info
    52	  - desktop-file-utils
    53	  - appstream-glib
    54	  - pipewire
    55	  - pipewire-alsa
    56	  - pipewire-pulse
    57	  - pipewire-jack
    58	  - wireplumber
    59	  - alsa-utils
    60	  - pavucontrol
    61	  - bluez
    62	  - bluez-utils
    63	  - bluedevil
    64	  - smartmontools
    65	  - hdparm
    66	  - sdparm
    67	  - nvme-cli
    68	  - usbutils
    69	  - pciutils
    70	  - lsb-release
    71	  - hwinfo
    72	  - htop
    73	  - glances
    74	  - ufw
    75	  - gufw
    76	  - firewalld
    77	- name: "Mocha KDE Plasma Wayland SDDM"
    78	  description: "Interface inicial única do Mocha: KDE Plasma com SDDM e Wayland. XWayland entra apenas para compatibilidade de aplicativos/jogos."
    79	  hidden: false
    80	  selected: true
    81	  critical: true
    82	  packages:
    83	  - plasma-meta
    84	  - plasma-desktop
    85	  - plasma-nm
    86	  - plasma-pa
    87	  - powerdevil
    88	  - sddm
    89	  - sddm-kcm
    90	  - breeze
    91	  - breeze-gtk
    92	  - kde-gtk-config
    93	  - xdg-desktop-portal
    94	  - xdg-desktop-portal-kde
    95	  - dolphin
    96	  - konsole
    97	  - kate
    98	  - ark
    99	  - spectacle
   100	  - gwenview
   101	  - okular
   102	  - partitionmanager
   103	  - kcalc
   104	  - kcharselect
   105	  - ffmpegthumbs
   106	  - kdegraphics-thumbnailers
   107	  - kio-extras
   108	  - kio-admin
   109	  - kio-fuse
   110	  - xorg-xwayland
   111	  - mesa
   112	  - vulkan-icd-loader
   113	  - lib32-vulkan-icd-loader
   114	  - noto-fonts
   115	  - noto-fonts-cjk
   116	  - noto-fonts-emoji
   117	  - ttf-dejavu
   118	  - ttf-liberation
   119	  - ttf-carlito
   120	  - ttf-caladea
   121	  - gvfs
   122	  - gvfs-mtp
   123	  - gvfs-gphoto2
   124	  - gvfs-nfs
   125	  - gvfs-smb
   126	  - sshfs
   127	  - fuse3
   128	- name: "Mocha Gamer Default"
   129	  description: "Camada gamer padrão: Steam, Wine/Proton, overlays, GameMode, ferramentas Vulkan e launchers disponíveis nos repositórios ativos."
   130	  hidden: false
   131	  selected: true
   132	  critical: false
   133	  packages:
   134	  - steam
   135	  - wine
   136	  - winetricks
   137	  - wine-mono
   138	  - wine-gecko
   139	  - gamemode
   140	  - lib32-gamemode
   141	  - mangohud
   142	  - lib32-mangohud
   143	  - goverlay
   144	  - gamescope
   145	  - protontricks
   146	  - lutris
   147	  - vulkan-tools
   148	  - vulkan-headers
   149	  - vulkan-validation-layers
   150	  - mesa-utils
   151	  - piper
   152	  - libratbag
   153	  - antimicrox
   154	  - openrgb
   155	- name: "Mocha Creation Office Streaming"
   156	  description: "Ferramentas úteis para criação, documentação e uso geral sem transformar o perfil em desktop corporativo ou educacional."
   157	  hidden: false
   158	  selected: true
   159	  critical: false
   160	  packages:
   161	  - obs-studio
   162	  - kdenlive
   163	  - krita
   164	  - inkscape
   165	  - gimp
   166	  - audacity
   167	  - vivaldi
   168	  - vivaldi-ffmpeg-codecs
   169	  - bitwarden
   170	  - flatpak
   171	  - discover
   172	  - packagekit-qt6
   173	- name: "Mocha GPU Mesa AMD Intel"
   174	  description: "Pilha Mesa/Vulkan aberta para AMD e Intel."
   175	  hidden: false
   176	  selected: true
   177	  critical: false
   178	  packages:
   179	  - mesa
   180	  - lib32-mesa
   181	  - vulkan-radeon
   182	  - lib32-vulkan-radeon
   183	  - vulkan-intel
   184	  - lib32-vulkan-intel
   185	  - vulkan-nouveau
   186	  - lib32-vulkan-nouveau
   187	- name: "Mocha GPU NVIDIA Proprietary"
   188	  description: "Drivers NVIDIA proprietários opcionais. A escolha final do driver/kernel será refinada na montagem da ISO."
   189	  hidden: false
   190	  selected: false
   191	  critical: false
   192	  packages:
   193	  - nvidia-utils
   194	  - lib32-nvidia-utils
   195	  - nvidia-settings
   196	  - nvidia-prime
   197	  - opencl-nvidia
   198	  - nvidia-open
   199	  - nvidia-open-dkms
   200	  - libva-nvidia-driver
   201	- name: "Mocha Compatibility Hardware Network"
   202	  description: "Compatibilidade adicional de rede, impressoras, VPNs, arquivos e dispositivos externos."
   203	  hidden: false
   204	  selected: false
   205	  critical: false
   206	  packages:
   207	  - networkmanager-openvpn
   208	  - networkmanager-openconnect
   209	  - networkmanager-pptp
   210	  - networkmanager-vpnc
   211	  - openvpn
   212	  - openconnect
   213	  - vpnc
   214	  - pptpclient
   215	  - xl2tpd
   216	  - rp-pppoe
   217	  - ethtool
   218	  - whois
   219	  - nss-mdns
   220	  - avahi
   221	  - cups
   222	  - system-config-printer
   223	  - sane
   224	  - simple-scan
   225	  - android-tools
   226	  - android-udev
   227	  - mtpfs
   228	  - gvfs-afc
   229	  - nfs-utils
   230	  - smbclient
   231	  - cifs-utils
   232	  - unrar
   233	  - unzip
   234	  - zip
   235	  - lrzip
   236	  - lzop
   237	  - lzip
   238	  - gparted
   239	  - fsarchiver
   240	  - ddrescue
   241	  - testdisk

================================================================
ARQUIVO: etc-calamares/settings.conf
================================================================

     1	modules-search:
     2	- local
     3	sequence:
     4	- show:
     5	  - welcome
     6	  - locale
     7	  - keyboard
     8	  - partition
     9	  - packagechooser
    10	  - netinstall
    11	  - users
    12	  - summary
    13	- exec:
    14	  - partition
    15	  - mount
    16	  - pacstrap
    17	  - machineid
    18	  - fstab
    19	  - locale
    20	  - keyboard
    21	  - localecfg
    22	  - luksopenswaphookcfg
    23	  - luksbootkeyfile
    24	  - plymouthcfg
    25	  - initcpiocfg
    26	  - initcpio
    27	  - networkcfg
    28	  - packages
    29	  - users
    30	  - displaymanager
    31	  - hwclock
    32	  - services-systemd
    33	  - grubcfg
    34	  - bootloader
    35	  - umount
    36	- show:
    37	  - finished
    38	branding: mocha
    39	prompt-install: false
    40	dont-chroot: false
    41	oem-setup: false
    42	disable-cancel: false
    43	disable-cancel-during-exec: false
    44	quit-at-end: false

================================================================
ARQUIVO: etc-calamares/settings-online.conf
================================================================

     1	modules-search:
     2	- local
     3	sequence:
     4	- show:
     5	  - welcome
     6	  - locale
     7	  - keyboard
     8	  - partition
     9	  - packagechooser
    10	  - netinstall
    11	  - users
    12	  - summary
    13	- exec:
    14	  - partition
    15	  - mount
    16	  - pacstrap
    17	  - machineid
    18	  - fstab
    19	  - locale
    20	  - keyboard
    21	  - localecfg
    22	  - luksopenswaphookcfg
    23	  - luksbootkeyfile
    24	  - plymouthcfg
    25	  - initcpiocfg
    26	  - initcpio
    27	  - networkcfg
    28	  - packages
    29	  - users
    30	  - displaymanager
    31	  - hwclock
    32	  - services-systemd
    33	  - grubcfg
    34	  - bootloader
    35	  - umount
    36	- show:
    37	  - finished
    38	branding: mocha
    39	prompt-install: false
    40	dont-chroot: false
    41	oem-setup: false
    42	disable-cancel: false
    43	disable-cancel-during-exec: false
    44	quit-at-end: false

================================================================
ARQUIVO: usr-share-calamares/branding/arch/show.qml
================================================================

     1	/* === This file is part of Calamares - <http://github.com/calamares> ===
     2	 *
     3	 *   Copyright 2015, Teo Mrnjavac <teo@kde.org>
     4	 *
     5	 *   Calamares is free software: you can redistribute it and/or modify
     6	 *   it under the terms of the GNU General Public License as published by
     7	 *   the Free Software Foundation, either version 3 of the License, or
     8	 *   (at your option) any later version.
     9	 *
    10	 *   Calamares is distributed in the hope that it will be useful,
    11	 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
    12	 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    13	 *   GNU General Public License for more details.
    14	 *
    15	 *   You should have received a copy of the GNU General Public License
    16	 *   along with Calamares. If not, see <http://www.gnu.org/licenses/>.
    17	 */
    18	
    19	/*
    20	 * Slides images dimensions are 800x440px.
    21	 */
    22	
    23	import QtQuick 2.0;
    24	import calamares.slideshow 1.0;
    25	
    26	Presentation
    27	{
    28	    id: presentation
    29	
    30	    Timer {
    31	        interval: 20000
    32	        running: true
    33	        repeat: true
    34	        onTriggered: presentation.goToNextSlide()
    35	    }
    36	    
    37	    Slide {
    38	
    39	        Image {
    40	            id: background1
    41	            source: "slide1.png"
    42	            width: 800; height: 440
    43	            fillMode: Image.PreserveAspectFit
    44	            anchors.centerIn: parent
    45	        }
    46	        Text {
    47	            anchors.horizontalCenter: background1.horizontalCenter
    48	            anchors.top: background1.bottom
    49	            text: ""
    50	            wrapMode: Text.WordWrap
    51	            width: 800
    52	            horizontalAlignment: Text.Center
    53	        }
    54	    }
    55	
    56	    Slide {
    57	
    58	        Image {
    59	            id: background2
    60	            source: "slide2.png"
    61	            width: 800; height: 440
    62	            fillMode: Image.PreserveAspectFit
    63	            anchors.centerIn: parent
    64	        }
    65	        Text {
    66	            anchors.horizontalCenter: background2.horizontalCenter
    67	            anchors.top: background2.bottom
    68	            text: ""
    69	            wrapMode: Text.WordWrap
    70	            width: 800
    71	            horizontalAlignment: Text.Center
    72	        }
    73	    }
    74	
    75	    Slide {
    76	
    77	        Image {
    78	            id: background3
    79	            source: "slide3.png"
    80	            width: 800; height: 440
    81	            fillMode: Image.PreserveAspectFit
    82	            anchors.centerIn: parent
    83	        }
    84	        Text {
    85	            anchors.horizontalCenter: background3.horizontalCenter
    86	            anchors.top: background3.bottom
    87	            text: ""
    88	            wrapMode: Text.WordWrap
    89	            width: 800
    90	            horizontalAlignment: Text.Center
    91	        }
    92	    }
    93	
    94	    Slide {
    95	
    96	        Image {
    97	            id: background4
    98	            source: "slide4.png"
    99	            width: 800; height: 440
   100	            fillMode: Image.PreserveAspectFit
   101	            anchors.centerIn: parent
   102	        }
   103	        Text {
   104	            anchors.horizontalCenter: background4.horizontalCenter
   105	            anchors.top: background4.bottom
   106	            text: ""
   107	            wrapMode: Text.WordWrap
   108	            width: 800
   109	            horizontalAlignment: Text.Center
   110	        }
   111	    }
   112	
   113	    Slide {
   114	
   115	        Image {
   116	            id: background5
   117	            source: "slide5.png"
   118	            width: 800; height: 440
   119	            fillMode: Image.PreserveAspectFit
   120	            anchors.centerIn: parent
   121	        }
   122	        Text {
   123	            anchors.horizontalCenter: background5.horizontalCenter
   124	            anchors.top: background5.bottom
   125	            text: ""
   126	            wrapMode: Text.WordWrap
   127	            width: 800
   128	            horizontalAlignment: Text.Center
   129	        }
   130	    }
   131	    Slide {
   132	
   133	        Image {
   134	            id: background6
   135	            source: "slide6.png"
   136	            width: 800; height: 440
   137	            fillMode: Image.PreserveAspectFit
   138	            anchors.centerIn: parent
   139	        }
   140	        Text {
   141	            anchors.horizontalCenter: background6.horizontalCenter
   142	            anchors.top: background6.bottom
   143	            text: ""
   144	            wrapMode: Text.WordWrap
   145	            width: 800
   146	            horizontalAlignment: Text.Center
   147	        }
   148	    }
   149	
   150	    Slide {
   151	
   152	        Image {
   153	            id: background7
   154	            source: "slide7.png"
   155	            width: 800; height: 440
   156	            fillMode: Image.PreserveAspectFit
   157	            anchors.centerIn: parent
   158	        }
   159	        Text {
   160	            anchors.horizontalCenter: background7.horizontalCenter
   161	            anchors.top: background7.bottom
   162	            text: ""
   163	            wrapMode: Text.WordWrap
   164	            width: 800
   165	            horizontalAlignment: Text.Center
   166	        }
   167	    }
   168	
   169	    Slide {
   170	
   171	        Image {
   172	            id: background8
   173	            source: "slide8.png"
   174	            width: 800; height: 440
   175	            fillMode: Image.PreserveAspectFit
   176	            anchors.centerIn: parent
   177	        }
   178	        Text {
   179	            anchors.horizontalCenter: background8.horizontalCenter
   180	            anchors.top: background8.bottom
   181	            text: ""
   182	            wrapMode: Text.WordWrap
   183	            width: 800
   184	            horizontalAlignment: Text.Center
   185	        }
   186	    }
   187	
   188	    Slide {
   189	
   190	        Image {
   191	            id: background9
   192	            source: "slide9.png"
   193	            width: 800; height: 440
   194	            fillMode: Image.PreserveAspectFit
   195	            anchors.centerIn: parent
   196	        }
   197	        Text {
   198	            anchors.horizontalCenter: background9.horizontalCenter
   199	            anchors.top: background9.bottom
   200	            text: ""
   201	            wrapMode: Text.WordWrap
   202	            width: 800
   203	            horizontalAlignment: Text.Center
   204	        }
   205	    }
   206	}
