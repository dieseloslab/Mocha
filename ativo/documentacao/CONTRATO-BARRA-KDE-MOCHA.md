# Contrato barra/painel KDE Mocha

Atualizado em: 20260703-164059

## Regra principal

Formato/layout da barra e cor/paleta são responsabilidades separadas.

O script aprovado que ajusta formato/layout da barra deve ser preservado e chamado como etapa própria.

A cor da barra deve vir do tema/paleta KDE canônica, não de tentativa manual dentro do script de layout.

## Auditoria de scripts candidatos

Arquivo com candidatos:

- /media/mochafast/MochaArch/auditorias/audita-barra-softwares-canonicos-20260703-164059/candidatos-script-barra.txt

Preview dos candidatos:

- /media/mochafast/MochaArch/auditorias/audita-barra-softwares-canonicos-20260703-164059/candidatos-script-barra-preview.txt

## Ação pendente

Selecionar explicitamente o script funcional aprovado e registrar aqui:

- caminho do script aprovado;
- o que ele altera;
- o que ele NÃO altera;
- comando exato para executar;
- validação depois da execução.

## Regra bloqueante

Não substituir script de barra já funcional por script novo sem auditoria.
Não misturar correção de layout com correção de cor.
Não depender de memória para cor, painel ou tema.

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
