

<!-- MOCHA-SOFTWARES-BARRA-BEGIN -->
## Barra KDE e lista canônica de softwares

Atualizado em: 20260703-164059

### Barra KDE

Formato/layout da barra e cor/paleta são separados.

Contrato:
- /media/mochafast/MochaArch/ativo/documentacao/CONTRATO-BARRA-KDE-MOCHA.md

Auditoria dos scripts candidatos:
- /media/mochafast/MochaArch/auditorias/audita-barra-softwares-canonicos-20260703-164059/candidatos-script-barra.txt
- /media/mochafast/MochaArch/auditorias/audita-barra-softwares-canonicos-20260703-164059/candidatos-script-barra-preview.txt

Regra:
- usar o script aprovado existente para formato/layout;
- não mexer na cor dentro desse script;
- cor vem do contrato visual KDE/paleta.

### Softwares Mocha

Contrato:
- /media/mochafast/MochaArch/ativo/documentacao/CONTRATO-SOFTWARES-MOCHA.md

Listas:
- /media/mochafast/MochaArch/ativo/sistema-base/pacotes-keep-base.txt
- /media/mochafast/MochaArch/ativo/sistema-base/pacotes-remove-candidatos.txt
- /media/mochafast/MochaArch/ativo/sistema-base/pacotes-review.txt

Auditoria desta máquina:
- /media/mochafast/MochaArch/auditorias/audita-barra-softwares-canonicos-20260703-164059/pacotes-explicitos.txt
- /media/mochafast/MochaArch/auditorias/audita-barra-softwares-canonicos-20260703-164059/remove-candidatos-instalados.txt
- /media/mochafast/MochaArch/auditorias/audita-barra-softwares-canonicos-20260703-164059/review-instalados.txt

Regra:
- transformar Arch normal em Mocha por script e listas versionadas;
- não depender de memória;
- não remover pacote sem passar pela lista canônica e revisão.
<!-- MOCHA-SOFTWARES-BARRA-END -->

<!-- MOCHA-BARRA-KDE-SCRIPT-APROVADO-BEGIN -->
## Script aprovado de formato/layout da barra KDE

Atualizado em: 20260703-165625

### Caminho aprovado original

- /media/mochafast/MochaArch/scripts/mocha-kde-barra-win11-aprovada-20260528-225617.sh

### Hash aprovado

- SHA256: 3212dfa72c464a649b5f4affb080544995e6199d9987450a73a3fcbb037ae5a4

### Caminhos canônicos

- FAST: /media/mochafast/MochaArch/ativo/kde/mocha-kde-barra-layout-aprovado.sh
- Nota: /media/mochafast/MochaArch/ativo/kde/mocha-kde-barra-layout-aprovado-nota.txt
- Sistema instalado: /usr/local/share/mocha/kde/mocha-kde-barra-layout-aprovado.sh
- Comando estável: /usr/local/bin/mocha-kde-barra-layout-aprovado

### O que altera

- arquivo do painel do usuário em HOME/.config/plasma-org.kde.plasma.desktop-appletsrc;
- ordem dos applets do painel via AppletOrder;
- dois espaçadores expansíveis org.kde.plasma.panelspacer;
- centralização de Kickoff/Iniciar e icontasks/taskmanager;
- manutenção de systemtray, digitalclock e showdesktop à direita;
- reinício somente do plasmashell.

### O que não altera

- não altera cor da barra;
- não altera tema/paleta KDE;
- não instala pacotes;
- não mexe em kernel;
- não mexe em NVIDIA;
- não mexe em boot.

### Comando de execução

mocha-kde-barra-layout-aprovado

### Regra

Formato/layout da barra e cor/paleta continuam separados. Este script é somente para layout/formato da barra. A cor deve vir do tema/paleta KDE Mocha canônica.
<!-- MOCHA-BARRA-KDE-SCRIPT-APROVADO-END -->
