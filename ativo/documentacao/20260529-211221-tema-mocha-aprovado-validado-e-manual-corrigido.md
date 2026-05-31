# Tema Mocha aprovado validado e manual corrigido

Data: 20260529-211221

Estado antes:

- ColorScheme: BreezeDark
- Plasma Style: default

Estado validado depois:

- ColorScheme: MochaSolidCanonico
- Plasma Style: MochaPanelSolidCanonico

Correção do manual:

- Foi removida do manual vivo a entrada antiga com título exato: Tema Mocha aprovado reaplicado, caso existisse.
- A entrada removida foi movida para quarentena/manual quando encontrada.
- A entrada correta só foi registrada depois da validação real.

Arquivos:

- Fonte do esquema de cores: /media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/MochaSolidCanonico.colors
- Fonte do Plasma Style: /media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico
- Script reutilizável: /media/mochafast/MochaArch/ativo/scripts/20260529-211221-corrigir-manual-e-reaplicar-tema.sh
- Log: /media/mochafast/MochaArch/ativo/logs/20260529-211221-corrigir-manual-e-reaplicar-tema.log

Restrições preservadas:

- Não alterou teclado.
- Não usou X11.
- Não removeu programas.
- Não tocou na pasta XU.
- Não mexeu em kernel, NVIDIA, bootloader, mounts ou performance.

<!-- MOCHA-MANGOHUD-INICIO -->
## MangoHud padrão Mocha

Data da última revisão: 20260530-060042

### Pacotes obrigatórios

- `mangohud`
- `gamemode`

### Arquivos de configuração obrigatórios

- Configuração Mocha do usuário: `/home/hal/.config/MangoHud/Mocha-MangoHud.conf`
- Configuração padrão carregada pelo MangoHud: `/home/hal/.config/MangoHud/MangoHud.conf`
- Cópia canônica do sistema: `/etc/mocha/mangohud/MangoHud.conf`

Regra: o MangoHud do Mocha não deve depender de configuração genérica ou incerta. O arquivo Mocha precisa estar instalado e o `MANGOHUD_CONFIGFILE` deve apontar explicitamente para ele quando a Steam for usada em teste controlado.

### Launch Option oficial para Steam

`MANGOHUD_CONFIGFILE=/home/hal/.config/MangoHud/Mocha-MangoHud.conf mangohud gamemoderun %command%`

### Linha limpa sem overlay

`MANGOHUD=1 MANGOHUD_CONFIGFILE=/etc/mocha/mangohud/MangoHud.conf mangohud gamemoderun %command%`

Essa linha limpa só ativa GameMode. Ela não chama MangoHud.

### Proibições do padrão Mocha

- Não usar `MANGOHUD_DLSYM=1`.
- Não colocar `vkbasalt` ou `gamescope` no wrapper/Launch Option canônico do Mocha.
- Não trocar o arquivo de configuração do MangoHud sem registrar no manual.

### Validação pós-instalação

- Rodar `pacman -Q mangohud gamemode`.
- Rodar `mangohud --version`.
- Abrir jogo pela Steam com a Launch Option oficial.
- Confirmar overlay, FPS, frametime, fluidez, imagem e estabilidade.
<!-- MOCHA-MANGOHUD-FIM -->


## SEÇÃO OPERACIONAL APROVADA — MangoHud Mocha obrigatório

Registro acrescentado em: 20260530-064832

MangoHud faz parte da montagem gamer do Mocha Arch/KDE e deve respeitar o padrão visual/configuração Mocha.

Configuração canônica encontrada para esta instalação:

- /etc/mocha/mangohud/MangoHud.conf

Launch Option oficial para jogos Steam quando o overlay MangoHud for obrigatório:

MANGOHUD=1 MANGOHUD_CONFIGFILE=/etc/mocha/mangohud/MangoHud.conf mangohud gamemoderun %command%

Regras preservadas:

- Não usar MANGOHUD_DLSYM=1.
- Não reintroduzir vkbasalt no wrapper/linha canônica.
- Não reintroduzir gamescope no wrapper/linha canônica.
- A linha gamemoderun %command% sozinha chama GameMode, mas não garante MangoHud.
- Para teste comparativo sem overlay, deixar Launch Options vazias deve ser tratado como teste, não como linha canônica MangoHud.

---

# Entrada 20260530-101522 - Mocha Gamer Essentials

Foi registrada a política de seleção Gamer Essentials sem instalar/remover pacotes.

Regras adicionadas ao manual:
1. O Mocha deve oferecer ferramentas comparáveis às distros gamer modernas: Steam, GameMode, MangoHud, GOverlay, launchers, Proton/Wine, periféricos gamer e captura.
2. Disponibilizar vkBasalt/gamescope não significa ativar essas ferramentas no wrapper oficial.
3. Wrapper/LaunchOptions oficial permanece limpo: sem MANGOHUD_DLSYM, sem vkBasalt e sem gamescope por padrão.
4. MangoHud é componente fundamental e precisa respeitar o padrão visual Mocha.
5. AUR não deve ser usado para atualização geral; somente pacote a pacote, auditado, ou promovido depois para repositório Mocha controlado.

Documentos desta etapa:
Relatório: /media/mochafast/MochaArch/ativo/relatorios/20260530-101522-mocha-gamer-essentials-auditoria.md
Política: /media/mochafast/MochaArch/ativo/documentacao/20260530-101522-mocha-gamer-essentials-politica.md
TSV: /media/mochafast/MochaArch/ativo/relatorios/20260530-101522-mocha-gamer-essentials-auditoria.tsv

---

# Entrada 20260530-102502 - Gamer Essentials corrigido com ProtonPlus

Foi aplicada a correção da camada Mocha Gamer Essentials.

Decisões registradas:

1. ProtonPlus passa a ser o gerenciador principal de Proton/Wine.
2. ProtonUp-Qt permanece disponível apenas como alternativa.
3. Pacotes oficiais continuam tendo prioridade.
4. Para ProtonPlus, a preferência é repo oficial se existir, depois Flatpak, depois AUR.
5. AUR é permitido somente pacote a pacote, sem atualização geral.
6. Softwares como vkBasalt, gamescope, LACT, CoreCtrl, Input Remapper, Oversteer e GOverlay ficam disponíveis ao usuário.
7. Disponível não significa ativado automaticamente.
8. O wrapper oficial permanece sem MANGOHUD_DLSYM, sem vkBasalt e sem gamescope por padrão.
9. MangoHud continua sendo componente fundamental do Mocha e deve respeitar o padrão visual Mocha.

Relatório: /media/mochafast/MochaArch/ativo/relatorios/20260530-102502-mocha-gamer-essentials-protonplus-install.md

Política: /media/mochafast/MochaArch/ativo/documentacao/20260530-102502-mocha-gamer-essentials-protonplus-politica.md

TSV: /media/mochafast/MochaArch/ativo/relatorios/20260530-102502-mocha-gamer-essentials-protonplus-install.tsv


---

# Entrada 20260530-103445 - Regra obrigatória para sudo, keepalive e instalações

## Problema corrigido

Comandos de instalação não podem pedir senha sudo repetidamente, especialmente durante instalação de vários pacotes oficiais, Flatpak ou AUR.

Se o usuário mandou instalar pacotes, o fluxo correto é assumir uma instalação não interativa depois da autenticação inicial.

## Regra obrigatória

1. Todo comando de instalação deve chamar sudo -v no começo.
2. Todo comando de instalação demorado deve manter sudo vivo com keepalive até o fim.
3. Depois da senha inicial, o comando não deve pedir senha pacote por pacote.
4. Em NixOS, quando aplicável, usar /run/wrappers/bin/sudo como sudo preferencial.
5. Em Arch/MochaArch, pacotes oficiais devem ser instalados em lote com pacman -S --needed.
6. AUR nunca deve ser instalado por atualização geral.
7. AUR só pode ser instalado pacote a pacote ou por lista explícita aprovada.
8. Para AUR, evitar deixar makepkg -si chamar sudo interativamente a cada pacote.
9. O fluxo preferido para AUR é construir como usuário normal e instalar os artefatos finais com sudo pacman -U --noconfirm em lote, ou usar sudo -n/PACMAN_AUTH equivalente com keepalive já ativo.
10. Se sudo -n falhar durante o script, o script deve parar com erro claro, não voltar a pedir senha repetidamente.
11. Antes de entregar comando de instalação, revisar especificamente se algum trecho pode chamar sudo por dentro sem respeitar o keepalive.

## Forma correta de esqueleto para comandos futuros

SUDO deve ser definido preferindo /run/wrappers/bin/sudo quando existir.
O comando deve executar sudo -v uma vez.
Um processo keepalive deve rodar sudo -n true periodicamente.
Pacotes oficiais devem ser instalados juntos, não um por um.
Pacotes AUR devem ser clonados/auditados/construídos como usuário normal.
A instalação final de pacotes AUR gerados deve ser feita com sudo pacman -U --noconfirm, preferencialmente em lote.

## Proibição operacional

Não entregar novamente comando que deixe makepkg -si, flatpak ou pacman pedir senha repetidamente durante uma instalação aprovada pelo usuário.
