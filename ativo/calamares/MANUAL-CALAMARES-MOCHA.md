

<!-- MOCHA_TEMA_COMPLETO_USUARIOS_CANONICO_V1_START -->
## Tema completo Mocha obrigatório para Calamares e novos usuários

Registro corrigido em: 20260627-184133

### Decisão canônica

O Mocha não pode depender de ajuste manual pós-instalação para parecer Mocha.

A instalação só é válida se o usuário criado pelo Calamares receber automaticamente:

- wallpaper Mocha;
- ColorScheme `MochaSolidCanonico`;
- Plasma Style `MochaPanelSolidCanonico`;
- painel/barra com cor Mocha sólida;
- Kickoff/menu com cor Mocha sólida;
- popups/widgets com cor Mocha;
- painel canônico preservado com altura de 48 px;
- permissões corretas no home do usuário.

Se o usuário criado pelo Calamares abrir sessão com KDE genérico, painel transparente, menu preto/transparente ou permissões quebradas no `$HOME`, a etapa visual está reprovada.

### Regra técnica obrigatória

Não basta aplicar apenas `MochaSolidCanonico.colors`.

A barra, o Kickoff/menu e os popups do Plasma dependem do Plasma Style real, com SVG/SVGZ corrigidos.

Tema obrigatório:

`MochaPanelSolidCanonico`

ColorScheme obrigatório:

`MochaSolidCanonico`

Altura canônica do painel:

`48 px`

### Artefatos canônicos salvos na pasta ativa

Plasma Style canônico:

`/media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/MochaPanelSolidCanonico`

SVG/SVGZ críticos atuais:

`/media/mochafast/MochaArch/ativo/kde/plasma-style-barra-mocha/svgz-criticos-atuais`

ColorScheme canônico:

`/media/mochafast/MochaArch/ativo/kde/esquemas-cores-aprovados/MochaSolidCanonico.colors`

Painel/barra aprovado atual:

`/media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-atual`

Payload do Calamares:

`/media/mochafast/MochaArch/ativo/calamares/payload/tema-completo`

Finalizador obrigatório do Calamares:

`/media/mochafast/MochaArch/ativo/calamares/scripts/mocha-finaliza-tema-completo-usuarios.sh`

Script local reaplicável:

`/media/mochafast/MochaArch/ativo/scripts/mocha-reaplicar-tema-completo-usuarios.sh`

### SVG/SVGZ críticos do Plasma Style

Devem ser preservados e reaplicados quando existirem:

- `widgets/panel-background.svgz`
- `dialogs/background.svgz`
- `widgets/background.svgz`
- `widgets/viewitem.svgz`
- `widgets/listitem.svgz`
- `widgets/tasks.svgz`
- `widgets/button.svgz`
- `widgets/lineedit.svgz`
- `widgets/frame.svgz`

Também devem ser consideradas variantes `opaque`, `solid` e `translucent` quando existirem no tema.

### Paleta canônica usada no tema Mocha

- Fundo profundo: `#171412`
- Fundo janela: `#1f201f`
- Fundo painel/barra: `#2f2924`
- Fundo popup/menu: `#28231f`
- Fundo botão: `#322a24`
- Borda: `#5c4638`
- Accent: `#c98758`
- Hover: `#d99e68`
- Accent claro: `#f4be82`
- Texto: `#ece2d7`
- Texto discreto: `#aea296`

### Aplicação obrigatória no Calamares

O finalizador deve rodar depois da criação do usuário e antes do encerramento/desmontagem do target.

Ele deve aplicar o tema em:

- `/target/usr/share/plasma/desktoptheme/MochaPanelSolidCanonico`
- `/target/usr/share/color-schemes/MochaSolidCanonico.colors`
- `/target/etc/skel`
- `/target/home/<usuario_criado>`

Para cada usuário real em `/target/home`, devem ser criados ou corrigidos:

- `~/.local/share/plasma/desktoptheme/MochaPanelSolidCanonico`
- `~/.local/share/color-schemes/MochaSolidCanonico.colors`
- `~/.config/plasmarc`
- `~/.config/kdeglobals`
- `~/.config/plasma-org.kde.plasma.desktop-appletsrc`

Depois da cópia, deve ser aplicado `chown -R usuario:usuario` nos arquivos gravados dentro do home do usuário.

### Limpeza obrigatória de cache

Para cada usuário real:

- `~/.cache/ksvg-elements`
- `~/.cache/plasma_theme_MochaPanelSolidCanonico.kcache`

### Regra de escopo

Quando a tarefa for apenas registrar ou reaplicar o tema visual, não mexer em:

- SDDM;
- GRUB;
- boot;
- kernel;
- driver NVIDIA;
- firewall;
- Steam;
- wrapper Steam;
- MangoHud.

### Comando local de reaplicação

Usar somente quando for necessário reaplicar o tema completo na instalação atual:

`/media/mochafast/MochaArch/ativo/scripts/mocha-reaplicar-tema-completo-usuarios.sh`

Para reiniciar Plasma explicitamente:

`/media/mochafast/MochaArch/ativo/scripts/mocha-reaplicar-tema-completo-usuarios.sh --restart-plasma`
<!-- MOCHA_TEMA_COMPLETO_USUARIOS_CANONICO_V1_END -->
