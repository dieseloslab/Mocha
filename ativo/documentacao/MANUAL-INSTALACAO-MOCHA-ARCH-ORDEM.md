# Manual de instalação do Mocha Arch — ordem de instalação

<!-- MOCHA-CANONICO-MANGOHUD-GAMEMODE-NVIDIA-OC:BEGIN -->
## Mocha canonico - MangoHud e GameMode NVIDIA OC

### MangoHud aprovado

- Config ativa em runtime: ${HOME}/.config/MangoHud/mocha-active.conf.
- O wrapper Steam/Proton deve exportar MANGOHUD_CONFIGFILE="${HOME}/.config/MangoHud/mocha-active.conf".
- Layout aprovado: uma linha, sem telemetria grafica extra.
- Ordem visual aprovada: FPS, latencia, CPU, GPU, VRAM, hora HH:MM e indicador GameMode.
- Validacao aceita: teste visual real dentro do jogo usando o wrapper Steam Mocha aprovado.

### GameMode NVIDIA OC aprovado

- OC NVIDIA existe somente durante GameMode.
- Metodo aprovado em Wayland/NVIDIA: NV-CONTROL via nvidia-settings executado por helper root.
- Helper aprovado: /usr/local/lib/mocha/mocha-nvidia-oc-root-helper.
- Hook start aprovado: /usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system.
- Hook end aprovado: /usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system.
- Start aplica core +50 e transfer-rate +400, equivalente a +200 MHz visivel em memclock.
- End reverte core 0 e memoria 0.
- Sudoers necessario: /etc/sudoers.d/mocha-nvidia-oc-root-helper.
- A validacao deve limpar os logs antes do teste para evitar falso negativo por tentativa antiga.

### Regra para futura instalacao

- Quem montar o Mocha deve aplicar apenas este fluxo canonico.
- Entradas antigas removidas deste manual ficam no Manual Legado.
- Manual Legado: ativo/documentacao/MANUAL-LEGADO-INFORMACOES-ULTRAPASSADAS.md.
<!-- MOCHA-CANONICO-MANGOHUD-GAMEMODE-NVIDIA-OC:END -->
Gerado em: 20260530-104417
Manual atual fixo: /media/mochafast/MochaArch/ativo/documentacao/MANUAL-INSTALACAO-MOCHA-ARCH-ORDEM.md
Manual histórico desta rodada: /media/mochafast/MochaArch/ativo/documentacao/20260530-104417-manual-instalacao-mocha-arch-em-ordem.md
Índice de documentos consultados: /media/mochafast/MochaArch/ativo/relatorios/20260530-104417-indice-documentos-usados-no-manual.txt

Este manual organiza o procedimento usado na montagem atual do Mocha Arch/KDE em ordem de instalação. Ele registra o fluxo aprovado até agora e deve ser atualizado somente com passos que funcionaram ou foram explicitamente aprovados.

## 0. Regras antes de começar

- Trabalhar de forma incremental: auditar primeiro, alterar depois.
- Não empilhar remendos no ativo.
- Tudo que funcionar deve ser documentado.
- Tentativa que falhou deve ser apagada ou movida para quarentena, não deixada misturada no ativo.
- Arquivos novos devem ter timestamp no nome, salvo caminho canônico fixo necessário.
- Manter no máximo 1 ou 2 backups por arquivo.
- Não remover programas sem ordem expressa.
- Não usar Chrome como padrão nem recomendar para o Mocha.
- Não usar X11 como fallback. O caminho do Mocha é Wayland.
- AUR pode ser usado apenas por exceção, pacote a pacote, com auditoria. Nunca usar AUR/helper/Pamac para atualização geral.
- Comandos de instalação devem usar sudo -v no começo e keepalive para não pedir senha várias vezes.
- Comandos demorados devem mostrar progresso visível.
- Antes de mexer em arquivo real de configuração, ler/auditar o estado real.
- Repositórios e atualizações devem seguir política controlada: testar primeiro, promover depois.

## 1. Instalação base


### 1.1 Instalar a base Arch/KDE

- Instalar uma base Arch limpa com KDE Plasma.
- Usar Wayland como caminho obrigatório.
- Não improvisar troca de teclado se não foi necessária no fluxo aprovado.
- A instalação atual reproduzida usou uma base Arch/KDE limpa e depois recebeu as camadas Mocha.

### 1.2 Primeiro boot

- Entrar no sistema instalado.
- Confirmar usuário principal.
- Confirmar que a interface está utilizável.
- Antes de qualquer mudança pesada, auditar kernel, GPU, repositórios e mounts.

## 2. Auditoria inicial do sistema


### 2.1 Verificar kernel, GPU e sessão

- Conferir kernel ativo com uname -r.
- Conferir GPU com nvidia-smi quando o driver NVIDIA já estiver instalado.
- Conferir sessão gráfica e evitar qualquer fallback para X11.
- Registrar resultado em relatório no MochaArch.

### 2.2 Verificar pacman e repositórios

- Auditar /etc/pacman.conf antes de editar.
- Preservar repositórios oficiais necessários.
- Remover ou substituir entradas erradas, não deixar entrada quebrada comentada no ativo.
- Usar repositórios estáveis como base.
- Medir velocidade dos mirrors e manter os mais rápidos.
- Não tratar Pamac/AUR como fonte de atualização geral.

## 3. Montagem obrigatória de discos


### 3.1 Montar FAST e VMSTORE

- FAST deve estar em /media/mochafast.
- VMSTORE deve estar em /media/vmstore.
- Ambos devem montar de forma persistente no boot.
- Ambos devem ficar visíveis e utilizáveis sem depender de montagem manual pelo gerenciador de arquivos.
- Não danificar nem sobrescrever NVMe por confusão de device.
- Antes de alterar /etc/fstab, auditar as entradas reais.
- Se houver entrada errada, substituir pela correta; não empilhar duplicatas.

### 3.2 Estrutura de trabalho

- Pasta ativa principal: /media/mochafast/MochaArch/ativo.
- Documentação: /media/mochafast/MochaArch/ativo/documentacao.
- Scripts aprovados: /media/mochafast/MochaArch/ativo/scripts.
- Relatórios: /media/mochafast/MochaArch/ativo/relatorios.
- Quarentena deve ser separada do ativo.
- VMSTORE pode abrigar repositório seguro/controlado do Mocha e materiais grandes.

## 4. Login manager


### 4.1 Trocar para o login manager aprovado

- O login manager aprovado nesta fase é o plasmalogin em Wayland.
- O ajuste deve preservar teclado e não inventar alteração de layout.
- Não configurar X11 como fallback.
- Depois da alteração, reiniciar e validar login gráfico.

### 4.2 Validação pós-boot

- Confirmar que a tela de login abre corretamente.
- Confirmar que a sessão entra em Wayland.
- Confirmar que não houve regressão de teclado.

## 5. Kernel Zen e NVIDIA


### 5.1 Instalar kernel Zen

- Instalar linux-zen e linux-zen-headers pelos repositórios oficiais.
- Não usar comando grande sem validação de sintaxe.
- Colocar o Zen como primeira opção/default no bootloader.
- Validar com uname -r depois do reboot.

### 5.2 Instalar NVIDIA open

- Instalar o driver NVIDIA open compatível com o kernel em uso.
- Usar DKMS quando aplicável.
- Rodar mkinitcpio conforme necessário.
- Atualizar bootloader conforme necessário.
- Validar com nvidia-smi depois do reboot.
- Se houver erro no meio, auditar estado real antes de repetir instalação.

### 5.3 Cuidados obrigatórios

- Não misturar tentativa quebrada com ativo.
- Não usar heredoc ou Python inline frágil em bloco grande sem bash -n.
- Não deixar o bootloader apontando para fallback como default por engano.
- Após funcionar, documentar o procedimento e salvar script reutilizável.

## 6. Performance, energia e agressividade

Esta seção é obrigatória no manual porque a receita de agressividade do Mocha não se resume à ZRAM. ZRAM é apenas um dos componentes. A receita completa também inclui sysctl de memória/latência, THP, TuneD, CPU em performance, GPU NVIDIA em máximo desempenho quando aplicável, GameMode, MangoHud padrão Mocha e validação real em jogos.

### 6.1 Receita de agressividade que não pode sumir do manual

A receita de agressividade deve aparecer explicitamente no manual com estes itens:

- CPU em modo performance.
- GPU NVIDIA em modo de máximo desempenho quando aplicável.
- TuneD ativo com perfil latency-performance.
- ZRAM ativa e configurada.
- THP em madvise.
- Sysctl de memória/latência documentado.
- GameMode instalado e funcional.
- MangoHud instalado e usando padrão visual Mocha.
- Baseline de jogo sem Launch Options preservado para comparação.

### 6.2 Valores da receita meio termo turbo usada como referência

Estes valores precisam constar no manual para evitar que a receita seja reduzida erroneamente à ZRAM:

- vm.swappiness=80
- vm.vfs_cache_pressure=50
- vm.page-cluster=0
- vm.dirty_background_bytes=67108864
- vm.dirty_bytes=268435456
- vm.max_map_count=16777216
- kernel.sched_autogroup_enabled=0
- transparent_hugepage=madvise
- zram com compressão zstd quando a implementação usada permitir
- zram com 100% de memória como alvo da receita
- zram com prioridade alta, alvo 32767 quando a implementação usada permitir
- TuneD habilitado
- perfil TuneD: latency-performance

Se o estado real do Arch estiver diferente desses valores, isso deve ser registrado como divergência ou adaptação da montagem atual, não apagado do manual.

### 6.3 CPU em performance

- A CPU deve priorizar desempenho, não economia.
- Validar governor em /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor.
- Quando existir energy_performance_preference, validar preferência em performance.
- Validar com cpupower quando disponível.
- A configuração precisa sobreviver ao reboot.

### 6.4 TuneD latency-performance

- TuneD faz parte da receita de agressividade.
- O perfil esperado é latency-performance.
- Validar com tuned-adm active.
- Validar serviço ativo com systemctl is-active tuned.
- Não substituir por perfil experimental sem teste em jogo e aprovação.

### 6.5 GPU NVIDIA em máximo desempenho

- A GPU NVIDIA deve preferir máximo desempenho quando a pilha atual permitir.
- Validar o driver com nvidia-smi.
- Registrar driver, power limit, clocks e modo de energia quando disponíveis.
- Evitar ajuste dependente de X11.
- Não alterar driver NVIDIA em atualização comum sem teste específico.

### 6.6 Sysctl da receita

O manual deve registrar estes sysctl, mesmo quando o comando de instalação apenas validar o estado atual:

- vm.swappiness
- vm.vfs_cache_pressure
- vm.page-cluster
- vm.dirty_background_bytes
- vm.dirty_bytes
- vm.max_map_count
- kernel.sched_autogroup_enabled
- kernel.nmi_watchdog, quando aplicado

A ausência desses valores no manual é falha de documentação, porque esconde parte da receita que influenciou o comportamento em jogo.

### 6.7 Transparent Huge Pages

- THP deve ficar documentado como madvise na receita.
- Validar em /sys/kernel/mm/transparent_hugepage/enabled.
- Registrar defrag quando relevante.
- Não mudar THP sem novo teste real em jogo.

### 6.8 ZRAM

- ZRAM é obrigatória, mas não é a receita inteira.
- Validar com zramctl.
- Validar com swapon --show.
- Registrar algoritmo, tamanho e prioridade.
- Alvo da receita: zstd, 100% de memória e prioridade 32767 quando a implementação usada permitir.

### 6.9 GameMode

- GameMode deve estar instalado e funcional.
- Linha Steam para testar somente GameMode:
- gamemoderun %command%
- Essa linha não chama MangoHud.

### 6.10 MangoHud padrão Mocha

- MangoHud é parte fundamental da configuração gamer do Mocha.
- MangoHud deve usar o padrão visual/configuração Mocha.
- Linha Steam para GameMode com MangoHud:
- mangohud gamemoderun %command%
- Quando houver arquivo canônico de configuração, usar MANGOHUD_CONFIGFILE apontando para o arquivo Mocha aprovado.
- Não usar MANGOHUD_DLSYM no wrapper canônico.

### 6.11 Baseline de teste em jogos

A validação deve comparar estes cenários:

1. Sem Launch Options.
2. gamemoderun %command%.
3. mangohud gamemoderun %command%.
4. Wrapper Mocha somente depois de revisado.

O melhor resultado observado anteriormente incluiu teste sem nenhuma Launch Option. Esse baseline não deve ser apagado nem substituído por wrapper sem comparação.

### 6.12 Relatórios ligados a esta correção

- Leitura do manual antes da edição: /media/mochafast/MochaArch/ativo/relatorios/20260530-105437-leitura-manual-antes-da-correcao-agressividade.txt
- Estado real da receita/agressividade na máquina: /media/mochafast/MochaArch/ativo/relatorios/20260530-105437-estado-real-receita-agressividade.txt
- Backup do manual antes da correção: /media/mochafast/MochaArch/ativo/documentacao/20260530-105437-backup-MANUAL-INSTALACAO-MOCHA-ARCH-ORDEM.md

## 7. Flatpak, Flathub e Discover


### 7.1 Habilitar Flatpak

- Flatpak/Flathub faz parte da base boa do Mocha.
- Discover pode manter suporte a Flatpak.
- Confirmar que Flathub está disponível.
- Não usar Chrome como app padrão.

## 8. Steam, GameMode e MangoHud


### 8.1 Steam

- Instalar Steam.
- Confirmar abertura e login.
- Testar jogos antes de canonizar qualquer resultado final.

### 8.2 GameMode

- GameMode deve estar instalado e funcional.
- Linha simples de teste sem MangoHud: gamemoderun %command%.
- Essa linha não chama MangoHud sozinha.

### 8.3 MangoHud padrão Mocha

- MangoHud é parte fundamental do Mocha gamer.
- Deve existir configuração visual Mocha para MangoHud.
- O manual deve registrar o que instalar, onde fica o arquivo de configuração e qual linha usar na Steam.
- Linha Steam oficial quando o usuário quiser GameMode mais MangoHud: mangohud gamemoderun %command%.
- Se for usado arquivo específico, definir MANGOHUD_CONFIGFILE apontando para o arquivo Mocha aprovado.
- Preservar o padrão visual Mocha.
- Teste de desempenho pode comparar jogo sem linha nenhuma, gamemoderun %command% e mangohud gamemoderun %command%.

### 8.4 Wrapper Steam

- O wrapper canônico deve partir do comportamento sem Launch Options como baseline.
- Não reintroduzir MANGOHUD_DLSYM.
- Não colocar vkBasalt/gamescope no wrapper canônico por padrão.
- vkBasalt e gamescope podem ficar disponíveis ao usuário, mas não devem contaminar o wrapper padrão.

## 9. Programas gamer disponíveis


### 9.1 Ferramentas úteis

- Manter disponíveis ferramentas comuns de distro gamer quando fizer sentido.
- Exemplos a manter na lista de avaliação/instalação: GOverlay, LACT, ProtonPlus, ferramentas de mapeamento de mouse/controle, ferramentas de volante, MangoHud, GameMode, Steam e utilitários Vulkan.
- ProtonPlus é preferido ao ProtonUp-Qt neste fluxo.
- Se algum item só existir no AUR, instalar apenas pacote a pacote, com auditoria e sem usar AUR para atualização geral.

### 9.2 vkBasalt e gamescope

- O fato de o Mocha não usar vkBasalt/gamescope no wrapper padrão não impede que o usuário escolha usar.
- Podem ficar disponíveis como ferramenta opcional.
- Não devem ser ativados por padrão no wrapper canônico.

## 10. Tema KDE, wallpaper e identidade visual


### 10.1 Esquema de cores

- O esquema MochaSolidCanonico foi aprovado visualmente como bom ponto de partida.
- Se alguma cor destoar do padrão Mocha, voltar aos testes.
- Não mudar geometria por causa de tema: evitar mexer em tamanhos, margens e comportamento estrutural sem aprovação.

### 10.2 Wallpaper

- Copiar e aplicar o wallpaper Mocha aprovado para a pasta ativa.
- Remover referências sutis ao GNOME quando o objetivo for Mocha Arch/KDE.
- Substituir por referência muito sutil ao Arch quando aprovado.

### 10.3 Barra Mocha estilo Windows 11

- A barra aprovada fica em: /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/.
- O arquivo aprovado usado foi o plasma-org.kde.plasma.desktop-appletsrc aprovado salvo nessa pasta.
- Fluxo correto: validar arquivo aprovado, fazer backup do appletsrc atual, parar plasmashell, copiar appletsrc aprovado, reiniciar plasmashell.
- Não procurar script inexistente quando o arquivo aprovado já existe.

## 11. Correções de barra: Bluetooth e volume duplicados


### 11.1 Correção aprovada

- Manter Bluetooth nativo do KDE/Bluedevil.
- Manter volume nativo do Plasma.
- Desativar apenas autostarts redundantes de blueman-applet e kmix.
- Usar overrides .desktop com Hidden=true.
- Não remover pacotes blueman ou kmix.
- Aplicar também em /etc/skel para novos usuários quando for preparar imagem final.

## 12. Repositório próprio e política de atualizações


### 12.1 Política rolling controlada

- Mocha Arch será rolling release com curadoria própria.
- A máquina de laboratório pode receber atualização para teste.
- Isso não significa liberação pública ao usuário final.
- Atualizações devem passar por teste, documentação e promoção.

### 12.2 Repositório controlado

- O repositório seguro/controlado deve ser criado no VMSTORE.
- Futuramente pode ser promovido para Cloudflare R2.
- AUR nunca deve participar de atualização geral.
- Pacotes AUR úteis podem ser avaliados e instalados pontualmente.

## 13. Limpeza e organização da pasta MochaArch


### 13.1 Ativo limpo

- A pasta MochaArch/ativo deve conter apenas material funcional, aprovado ou em refino controlado.
- Lixo deve ir para o lixo.
- Tentativa que pode ser útil depois deve ir para quarentena.
- Não guardar cacarecos no ativo.

### 13.2 Documentação obrigatória

- Todo comando que funcionar deve gerar documentação Markdown.
- Quando fizer sentido, também deve gerar script reutilizável.
- Documentação deve conter somente solução correta/aprovada, não tentativas falhas.
- Este manual deve ser atualizado a cada novo passo aprovado.

## 14. Ordem resumida para reinstalar o Mocha Arch

1. Instalar base Arch/KDE limpa.
2. Fazer primeiro boot e auditar sistema.
3. Auditar pacman.conf e repositórios.
4. Medir e ajustar mirrors.
5. Montar FAST em /media/mochafast e VMSTORE em /media/vmstore de forma persistente.
6. Criar/validar estrutura /media/mochafast/MochaArch/ativo.
7. Trocar/validar login manager aprovado em Wayland.
8. Instalar kernel Zen e headers.
9. Instalar NVIDIA open/DKMS compatível.
10. Atualizar initramfs e bootloader.
11. Garantir Zen como entrada padrão.
12. Reiniciar e validar uname -r, nvidia-smi e Wayland.
13. Aplicar CPU performance, GPU maximum performance e TuneD latency-performance.
14. Configurar/validar ZRAM.
15. Habilitar Flatpak/Flathub e integração com Discover.
16. Instalar Steam, GameMode e MangoHud.
17. Configurar MangoHud padrão Mocha.
18. Registrar Launch Options oficiais e baseline sem linha.
19. Instalar ferramentas gamer disponíveis: GOverlay, LACT, ProtonPlus, mapeadores, volante e afins.
20. Aplicar esquema de cores MochaSolidCanonico.
21. Aplicar wallpaper Mocha/Arch aprovado.
22. Aplicar barra Mocha/Win11 aprovada.
23. Corrigir duplicidade blueman/kmix por autostart Hidden=true.
24. Validar jogos e desempenho.
25. Documentar o estado aprovado.
26. Só então promover ajustes para pasta ativa/canônica.

## 15. Checklist de validação pós-instalação

- /media/mochafast montado.
- /media/vmstore montado.
- KDE Plasma em Wayland.
- Login manager aprovado funcionando.
- Kernel Zen ativo.
- NVIDIA funcionando com nvidia-smi.
- Bootloader apontando para entrada correta.
- TuneD ativo em latency-performance.
- CPU em performance.
- GPU em modo de desempenho quando aplicável.
- ZRAM ativa.
- Steam abre.
- GameMode funciona.
- MangoHud usa padrão Mocha.
- Linha Steam com MangoHud: mangohud gamemoderun %command%.
- Baseline de teste sem linha nenhuma preservado.
- Tema Mocha aplicado.
- Wallpaper aplicado.
- Barra Mocha/Win11 aplicada.
- Bluetooth duplicado removido sem remover pacote.
- Volume duplicado removido sem remover pacote.
- Flatpak/Flathub funcionando.
- Manual atualizado.

## 16. Arquivos de documentação encontrados nesta organização

- Índice gerado em: 20260530-104417
- Diretório: /media/mochafast/MochaArch/ativo/documentacao
-
- 2026-05-29 15:01  /media/mochafast/MochaArch/ativo/documentacao/20260529-150104-login-plasma-manager-esquema-aprovado.md
- 2026-05-29 15:24  /media/mochafast/MochaArch/ativo/documentacao/20260529-152416-baseline-superior-endeavour-steam-overlay-kde.md
- 2026-05-29 15:27  /media/mochafast/MochaArch/ativo/documentacao/20260529-152700-volume-duplicado-corrigido-kmix-desativado.md
- 2026-05-29 15:29  /media/mochafast/MochaArch/ativo/documentacao/20260529-152907-passo-canonico-barra-kde-sem-blueman-kmix-duplicados.md
- 2026-05-29 15:43  /media/mochafast/MochaArch/ativo/documentacao/20260529-154304-MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md
- 2026-05-29 15:44  /media/mochafast/MochaArch/ativo/documentacao/20260529-154451-wrapper-steam-auditoria-e-implantacao.md
- 2026-05-29 15:46  /media/mochafast/MochaArch/ativo/documentacao/20260529-154612-wrapper-steam-corrigido-falso-positivo.md
- 2026-05-29 16:13  /media/mochafast/MochaArch/ativo/documentacao/20260529-161327-auditoria-gamemode-on-off.md
- 2026-05-29 16:34  /media/mochafast/MochaArch/ativo/documentacao/20260529-163403-wallpaper-kdePCan-aplicado.md
- 2026-05-29 17:24  /media/mochafast/MochaArch/ativo/documentacao/20260529-172415-steam-launcher-mangohud-padrao-telemetria.md
- 2026-05-29 17:31  /media/mochafast/MochaArch/ativo/documentacao/20260529-173139-steam-telemetria-ruim-nao-usar.md
- 2026-05-29 17:33  /media/mochafast/MochaArch/ativo/documentacao/20260529-173325-coletor-externo-leve-jogo.md
- 2026-05-29 17:58  /media/mochafast/MochaArch/ativo/documentacao/20260529-175841-esquema-cores-kde-mocha-solid-canonico-aplicado.md
- 2026-05-29 18:03  /media/mochafast/MochaArch/ativo/documentacao/20260529-180309-plasma-style-barra-mocha-aplicado.md
- 2026-05-29 18:27  /media/mochafast/MochaArch/ativo/documentacao/20260529-182750-zen-default-grub-seguro.md
- 2026-05-29 20:00  /media/mochafast/MochaArch/ativo/documentacao/20260529-200013-pendencias-auditoria-pre-formatacao-corrigidas.md
- 2026-05-29 20:57  /media/mochafast/MochaArch/ativo/documentacao/20260529-205629-base-jogos-wrapper-limpo-autostarts.md
- 2026-05-29 21:05  /media/mochafast/MochaArch/ativo/documentacao/20260529-210324-login-manager-plasmalogin-aplicado-pendente-pos-boot.md
- 2026-05-29 21:05  /media/mochafast/MochaArch/ativo/documentacao/manual-montagem-mochaarch.md
- 2026-05-29 21:14  /media/mochafast/MochaArch/ativo/documentacao/20260529-211408-wallpaper-e-barra-mocha-aplicados.md
- 2026-05-29 21:16  /media/mochafast/MochaArch/ativo/documentacao/20260529-211622-MARCO-ESTADO-REPRODUZIDO-POS-FORMATACAO.md
- 2026-05-29 21:27  /media/mochafast/MochaArch/ativo/documentacao/20260529-212702-levantamento-programas-jogos-atualizacao-zero.md
- 2026-05-29 21:28  /media/mochafast/MochaArch/ativo/documentacao/20260529-212825-atualizacoes-oficiais-seguras.md
- 2026-05-29 22:14  /media/mochafast/MochaArch/ativo/documentacao/20260529-214720-mudancas-feitas-auditoria-repos-e-limpeza-vmstore.md
- 2026-05-29 22:14  /media/mochafast/MochaArch/ativo/documentacao/20260529-214720-proximos-passos-repos-proprio-mocha.md
- 2026-05-29 22:46  /media/mochafast/MochaArch/ativo/documentacao/20260529-224555-repositorio-proprio-mocha-estrutura-criada.md
- 2026-05-29 23:44  /media/mochafast/MochaArch/ativo/documentacao/20260529-234449-primeiro-pacote-repo-seguro-vmstore.md
- 2026-05-29 23:47  /media/mochafast/MochaArch/ativo/documentacao/20260529-234741-repo-seguro-testing-stable-criado.md
- 2026-05-30 00:19  /media/mochafast/MochaArch/ativo/documentacao/20260530-001926-pacote-mocha-pacman-policy.md
- 2026-05-30 05:50  /media/mochafast/MochaArch/ativo/documentacao/20260530-055006-repo-stable-validado-e-pacman-conf-ativado.md
- 2026-05-30 05:51  /media/mochafast/MochaArch/ativo/documentacao/20260530-055134-repo-stable-correcao-limpeza-tmp.md
- 2026-05-30 05:52  /media/mochafast/MochaArch/ativo/documentacao/20260530-055250-auditoria-atualizacoes-sem-aplicar.md
- 2026-05-30 05:54  /media/mochafast/MochaArch/ativo/documentacao/20260530-055358-atualizacao-controlada-apenas-mangohud.md
- 2026-05-30 06:00  /media/mochafast/MochaArch/ativo/documentacao/20260529-211221-tema-mocha-aprovado-validado-e-manual-corrigido.md.backup-20260530-064832.md
- 2026-05-30 06:00  /media/mochafast/MochaArch/ativo/documentacao/20260530-060042-mangohud-padrao-mocha-fixado.md
- 2026-05-30 10:15  /media/mochafast/MochaArch/ativo/documentacao/20260530-101522-mocha-gamer-essentials-politica.md
- 2026-05-30 10:33  /media/mochafast/MochaArch/ativo/documentacao/20260530-102502-mocha-gamer-essentials-protonplus-politica.md
- 2026-05-30 10:34  /media/mochafast/MochaArch/ativo/documentacao/20260529-211221-tema-mocha-aprovado-validado-e-manual-corrigido.md

## 17. Pendências controladas

- Testar jogos antes de chamar o estado de definitivo.
- Refinar wrapper Steam sem prejudicar o baseline sem Launch Options.
- Consolidar repositório próprio no VMSTORE.
- Separar claramente ativo, quarentena e legado.
- Atualizar este manual a cada nova etapa aprovada.

## Registro 20260530-105856 — receita de agressividade de teste

Foi aplicada uma receita de agressividade candidata, não canonizada.

Valores principais:

- vm.swappiness=100
- vm.vfs_cache_pressure=35
- vm.page-cluster=0
- vm.dirty_background_bytes=100663296
- vm.dirty_bytes=402653184
- vm.max_map_count=33554432
- kernel.sched_autogroup_enabled=0
- kernel.nmi_watchdog=0
- THP=madvise
- TuneD=latency-performance
- CPU=performance
- ZRAM=zstd, zram-size=ram, swap-priority=32767

Relatórios:

- /media/mochafast/MochaArch/ativo/relatorios/20260530-105856-leitura-manual-antes-agressividade-teste.txt
- /media/mochafast/MochaArch/ativo/relatorios/20260530-105856-estado-antes-agressividade-teste.txt
- /media/mochafast/MochaArch/ativo/relatorios/20260530-105856-estado-depois-agressividade-teste.txt
- /media/mochafast/MochaArch/ativo/documentacao/20260530-105856-receita-agressividade-teste-aplicada.md
- Rollback: /media/mochafast/MochaArch/ativo/scripts/20260530-105856-mocha-rollback-receita-agressividade-teste.sh


<!-- MOCHA-MANGOHUD-STEAM-RUNTIME-CONF-START -->
## MangoHud aprovado — Steam Runtime / Proton / wrapper Alt+Tab

Estado aprovado pelo teste real em jogo Steam/Proton em 2026-07-04:

- Esta é a configuração que funciona perfeitamente com o wrapper Alt+Tab do Mocha.
- Caminho ativo funcional do MangoHud no wrapper:
  - variável: MANGOHUD_CONFIGFILE="${HOME}/.config/MangoHud/mocha-active.conf"
  - arquivo real por usuário: ~/.config/MangoHud/mocha-active.conf
- Motivo: dentro do Steam Runtime / pressure-vessel, o processo do jogo pode não aplicar visualmente o /usr/local/share/... do host.
- A validação correta é fechar e abrir novamente o jogo.
- Não depender de reload_cfg, Shift_L+F4 ou recarga em processo vivo.
- Steam aberta pelo atalho normal steam %U não garante herança da configuração Mocha.
- A abertura correta é via Steam Mocha ou launch option que use mocha-steam-game-run %command%.

Wrapper Steam Mocha / Alt+Tab deve preservar a lógica de input/Alt+Tab e exportar apenas o ambiente MangoHud necessário:

    export MANGOHUD=1
    export MANGOHUD_CONFIGFILE="${HOME}/.config/MangoHud/mocha-active.conf"
    unset MANGOHUD_CONFIG
    unset MANGOHUD_DLSYM

Proibido no wrapper/config MangoHud:
- MANGOHUD_CONFIG= inline
- MANGOHUD_DLSYM

- gamescope
- vkBasalt
- graphs

Config aprovada:

    legacy_layout=0
    horizontal
    hud_no_margin
    position=top-left
    font_size=17
    round_corners=0
    background_alpha=0.35
    alpha=1.0

    time
    time_format="%H:%M"
    time_no_label

    fps
    frametime
    cpu_stats
    cpu_temp
    cpu_mhz
    gpu_stats
    gpu_temp
    gpu_core_clock
    gpu_mem_clock
    vram
    ram
    gamemode

    toggle_hud=Shift_R+F12
    reload_cfg=none

Regra operacional:

- Se o MangoHud voltar ao padrão, primeiro verificar o ambiente do processo e o namespace com /proc/<PID>/root.
- Não recriar wrapper.
- Não insistir em Shift_L+F4.
- Não voltar para /usr/local/share/... como caminho primário.
- Ajuste de fonte aprovado: font_size=17.
<!-- MOCHA-MANGOHUD-STEAM-RUNTIME-CONF-END -->
