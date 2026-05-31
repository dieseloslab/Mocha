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

`gamemoderun %command%`

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

