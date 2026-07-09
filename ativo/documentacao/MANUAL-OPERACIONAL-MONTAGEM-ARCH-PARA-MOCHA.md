# Manual operacional de montagem Mocha — Arch para Mocha

Estado: CANDIDATO OPERACIONAL, NAO CANONICO, NAO APROVADO.

Este manual responde a uma pergunta unica: como transformar um Arch recem-instalado em um sistema Mocha operacional.

Este documento nao substitui automaticamente o manual vivo interno, nao registra historico completo, nao contem auditorias longas e nao autoriza commit, push, instalacao, remocao ou reparo sem validacao.

## 1. Regra principal

Nenhuma especificacao deve ser escrita por inferencia quando existir runtime, arquivo ou artefato aprovado a consultar.

Antes de documentar o que um componente deve conter ou como deve funcionar, e obrigatorio auditar o estado atual aprovado desse componente.

Se a auditoria nao existir, a secao deve permanecer pendente.

Marcadores permitidos para incerteza:

    PENDENTE DE SCRIPT CANONICO TESTADO
    PENDENTE DE EVIDENCIA
    PENDENTE DE APROVACAO VISUAL
    PENDENTE DE TESTE REAL

Nao inventar substituicao. Nao recriar artefato parecido. Nao substituir implementacao aprovada por equivalente improvisado.

## 2. Escopo

Este manual deve conter somente instrucoes praticas de montagem.

Cada bloco operacional deve conter objetivo, evidencia auditada usada como base, artefato ou script canonico, comando de execucao, validacao, evidencia minima e pendencia bloqueante se falhar.

Ficam fora deste manual: historico de falhas, diffs longos, auditorias completas, planos antigos, quarentenas, justificativas extensas, logs integrais e discussoes de arquitetura que nao sejam comando de montagem.

## 3. Base de entrada

Sistema esperado antes de aplicar o Mocha:

- Arch Linux recem-instalado;
- boot funcional;
- usuario final criado;
- sudo funcional;
- rede funcional via NetworkManager;
- KDE Plasma instalado;
- sessao Plasma Wayland disponivel;
- SDDM instalado e habilitado.

Validacao inicial:

    id
    uname -a
    systemctl is-enabled NetworkManager
    systemctl is-active NetworkManager
    systemctl is-enabled sddm
    systemctl is-active sddm
    echo "$XDG_SESSION_TYPE"

## 4. Identidade visual Mocha

Objetivo: aplicar identidade visual Mocha ao usuario final e ao sistema.

Resultado esperado somente depois de auditoria/aprovacao visual:

- tema Mocha aplicado;
- cores Mocha aplicadas;
- wallpaper Mocha aplicado;
- painel inferior no padrao Mocha;
- comportamento visual proximo ao Windows 11;
- SDDM sem aparencia generica;
- Plasma sem primeira inicializacao generica aparente.

Evidencia auditada usada como base:

    PENDENTE DE EVIDENCIA

Script canonico:

    PENDENTE DE SCRIPT CANONICO TESTADO

Pendencia bloqueante: se painel, tema, wallpaper ou permissoes do HOME nao estiverem corretos, a identidade visual Mocha nao esta validada.

## 5. Painel KDE padrao Mocha

Objetivo: configurar o painel inferior no padrao Mocha, com comportamento semelhante ao Windows 11.

Evidencia auditada usada como base:

    PENDENTE DE EVIDENCIA

Script canonico:

    PENDENTE DE SCRIPT CANONICO TESTADO

Validacao minima:

    pgrep -a plasmashell
    ls -la "$HOME/.config/plasma-org.kde.plasma.desktop-appletsrc"

Pendencia bloqueante: nao documentar como pronto se o painel ainda depender de ajuste manual nao descrito, nao auditado ou nao testado.

## 6. SDDM, Wayland e usuario final

Objetivo: garantir login correto no Plasma Wayland com usuario final, sem duplicidade indevida e sem permissao quebrada.

Evidencia auditada usada como base:

    PENDENTE DE EVIDENCIA

Script canonico:

    PENDENTE DE SCRIPT CANONICO TESTADO

Validacao:

    systemctl is-enabled sddm
    systemctl is-active sddm
    grep -R "Session=" /etc/sddm.conf /etc/sddm.conf.d 2>/dev/null
    find "$HOME/.config" -maxdepth 1 ! -user "$(id -un)" -print

Pendencia bloqueante: se arquivos KDE no HOME do usuario final estiverem com dono incorreto, o sistema instalado nao esta validado.

## 7. Stack gamer Mocha

Objetivo: instalar e configurar a base gamer do Mocha.

Componentes esperados, apos evidencia:

- Steam;
- Proton/compatibilidade Steam;
- MangoHud;
- GameMode;
- TuneD;
- ferramentas NVIDIA quando aplicavel;
- wrapper Steam Mocha.

Script canonico:

    PENDENTE DE SCRIPT CANONICO TESTADO

Validacao:

    command -v steam
    command -v mangohud
    command -v gamemoderun
    command -v tuned-adm
    gamemoderun true

Pendencia bloqueante: nao declarar stack gamer pronta sem teste real de jogo.

## 8. Steam Mocha e wrapper

Objetivo: garantir que jogos Steam/Proton passem pelo wrapper Mocha aprovado.

Evidencia auditada nesta geracao:

- STEAM_WRAPPER_CANONICO: path=/usr/local/bin/mocha-steam-game-run exists=SIM tipo=arquivo executavel=SIM sha256=d2517c0fb53b5955744128bdb498581cc117ed277e8e671a90761c8bbc78e7b6 itens_ou_bytes=3276
- STEAM_WRAPPER_SYMLINK_USUARIO: path=/home/hal/.local/bin/mocha-steam-game-run exists=SIM tipo=symlink executavel=SIM sha256=d2517c0fb53b5955744128bdb498581cc117ed277e8e671a90761c8bbc78e7b6 itens_ou_bytes=3276
- STEAM_WRAPPER_SYMLINK_SKEL: path=/etc/skel/.local/bin/mocha-steam-game-run exists=SIM tipo=symlink executavel=SIM sha256=d2517c0fb53b5955744128bdb498581cc117ed277e8e671a90761c8bbc78e7b6 itens_ou_bytes=3276

Wrapper esperado quando validado:

    /usr/local/bin/mocha-steam-game-run %command%

Regras dependentes de validacao real:

- MangoHud deve ser ativado pelo wrapper;
- GameMode deve ser integrado;
- correcoes de Alt+Tab devem ser aplicadas;
- jogos novos tambem devem receber a linha correta;
- nao basta validar apenas jogos antigos.

Proibido no wrapper padrao:

- gamescope;
- vkBasalt;
- MANGOHUD_DLSYM.

Validacao:

    test -x /usr/local/bin/mocha-steam-game-run
    grep -R "mocha-steam-game-run %command%" "$HOME/.steam" "$HOME/.local/share/Steam" 2>/dev/null

Pendencia bloqueante: se jogos novos nao receberem automaticamente a linha do wrapper, o pipeline Steam Mocha nao esta validado.

## 9. MangoHud Mocha

Objetivo: aplicar overlay MangoHud Mocha conforme o runtime aprovado, sem inventar lista por memoria.

Evidencia auditada nesta geracao:

- Arquivo ativo: /home/hal/.config/MangoHud/mocha-active.conf
- Existe: SIM
- SHA256: f176609653b7a5dec8b8d6832177d32e92dbbc7bf4c05aa662cae8d4db85593c
- Linhas ativas: 25
- Espelho /usr/local alinhado ao ativo: SIM
- Espelho /etc/skel alinhado ao ativo: SIM
- Evidencia FPS: SIM
- Evidencia CPU: SIM
- Evidencia GPU: SIM
- Evidencia VRAM: SIM
- Evidencia temperatura: SIM
- Evidencia frequencia/MHz/clock: SIM
- Evidencia hora: SIM
- Evidencia GameMode: SIM
- Bloqueio por evidencia incompleta: NAO

Config ativa auditada, sem comentarios e sem linhas vazias:

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

Formato esperado do MangoHud Mocha:

O formato esperado deve corresponder ao arquivo ativo auditado acima e a aprovacao visual vigente.

Itens que devem estar presentes quando suportados pelo hardware/runtime:

- FPS;
- latencia/frame time conforme configuracao aprovada;
- CPU;
- frequencia/MHz/clock quando suportado;
- temperatura quando suportada;
- GPU;
- VRAM;
- hora;
- indicador GameMode.

Proibido descaracterizar o overlay aprovado sem novo teste visual.

Validacao:

    test -f "$HOME/.config/MangoHud/mocha-active.conf"
    test -f /usr/local/share/mocha/mangohud/MangoHud.conf
    test -f /etc/skel/.config/MangoHud/mocha-active.conf
    sha256sum "$HOME/.config/MangoHud/mocha-active.conf" /usr/local/share/mocha/mangohud/MangoHud.conf /etc/skel/.config/MangoHud/mocha-active.conf

Evidencia minima:

- hashes dos arquivos auditados;
- overlay visivel em jogo real;
- FPS visivel;
- latencia/frame time visivel conforme configuracao aprovada;
- CPU/GPU visiveis;
- frequencia/MHz/clock visivel quando suportado;
- temperatura visivel quando suportada;
- VRAM visivel;
- hora visivel;
- indicador GameMode visivel;
- aprovacao visual.

Pendencia bloqueante: nao alterar nem canonizar layout MangoHud sem teste visual aprovado. Se temperatura ou frequencia/MHz/clock nao aparecerem quando deveriam aparecer, a secao MangoHud fica bloqueada.

## 10. GameMode

Objetivo: ativar otimizacoes de jogo por GameMode.

Evidencia auditada nesta geracao:

- GAMEMODE_CONFIG: path=/etc/gamemode.ini exists=SIM tipo=arquivo executavel=NAO sha256=a1931485550ae90d23ba00f752be652c0b3925342d75b07da6c3fb9dd26e090b itens_ou_bytes=388
- GAMEMODE_HOOK_START: path=/usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system exists=SIM tipo=arquivo executavel=SIM sha256=fffc494f2f74f0f589e92d4cba310970b548a383149fe19e31d9760415f5a45a itens_ou_bytes=345
- GAMEMODE_HOOK_END: path=/usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system exists=SIM tipo=arquivo executavel=SIM sha256=8e81f3b2b57b30e027e54f1096d8cb515d182bac2343a6ed784e9cb534c05294 itens_ou_bytes=459

Validacao:

    command -v gamemoderun
    gamemoderun true
    systemctl --user status gamemoded.service --no-pager

Pendencia bloqueante: se GameMode nao executar com sucesso, Steam Mocha nao esta validado.

## 11. TuneD e agressividade Mocha

Objetivo: aplicar perfil de desempenho Mocha validado.

Evidencia auditada nesta geracao:

- TUNED_PROFILE_MOCHA: path=/etc/tuned/profiles/mocha-latency-performance/tuned.conf exists=SIM tipo=arquivo executavel=NAO sha256=be49a8332756e6f242101d1bcaca84a42e4568254b019daf9927121dd39729a6 itens_ou_bytes=692

Perfil esperado quando validado:

    mocha-latency-performance

Validacao:

    tuned-adm active
    sudo tuned-adm verify

Pendencia bloqueante: nao declarar agressividade canonica se tuned-adm verify falhar.

## 12. OC NVIDIA opcional via GameMode

Objetivo: permitir OC NVIDIA opcional somente quando aprovado pelo usuario e aplicado via GameMode.

Regra: OC NVIDIA nao deve ser aplicado solto ou permanente.

Evidencia auditada nesta geracao:

- OC_NVIDIA_HELPER: path=/usr/local/lib/mocha/mocha-nvidia-oc-root-helper exists=SIM tipo=arquivo executavel=SIM sha256=49ddac5121cc42fbf58a91167dc4ec9a7903f0897ba82b5742c911fb66d0074e itens_ou_bytes=5197
- GAMEMODE_HOOK_START: path=/usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system exists=SIM tipo=arquivo executavel=SIM sha256=fffc494f2f74f0f589e92d4cba310970b548a383149fe19e31d9760415f5a45a itens_ou_bytes=345
- GAMEMODE_HOOK_END: path=/usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system exists=SIM tipo=arquivo executavel=SIM sha256=8e81f3b2b57b30e027e54f1096d8cb515d182bac2343a6ed784e9cb534c05294 itens_ou_bytes=459

Validacao:

    nvidia-smi
    gamemoderun true

Pendencia bloqueante: se o end nao reverter o OC, o recurso nao pode ser considerado pronto.

## 13. Kernel, NVIDIA e fallback

Objetivo: definir kernel padrao e fallback seguro.

Decisao operacional vigente:

- LQX/Liquorix e o padrao atual do Mocha ate evidencia em contrario;
- Arch LTS deve existir como fallback;
- CachyOS v3 e opcional pos-instalacao, vindo dos repositorios oficiais CachyOS, se puder ser testado localmente.

Validacao:

    uname -a
    pacman -Qs 'linux|nvidia'
    bootctl status 2>/dev/null || true
    grep -R "menuentry" /boot/grub/grub.cfg 2>/dev/null | head -n 20

Pendencia bloqueante: nao manter como padrao algo que nao possa ser testado localmente.

## 14. Repositorio fallback pacman

Objetivo: manter um repositorio/arquivo incremental de fallback para usuarios, futuramente publicavel.

Evidencia auditada nesta geracao:

- REPO_FALLBACK_PACMAN: path=/media/vmstore/mocha-repo exists=SIM tipo=diretorio executavel=NAO sha256= itens_ou_bytes=itens_maxdepth1=3

Funcao:

- oferecer rollback/fallback seguro;
- preservar versoes antigas;
- adicionar versoes novas ausentes;
- reindexar sem remocao.

Regra acumulativa:

- nao apagar pacotes antigos;
- nao prunar;
- nao usar repo-add -R;
- nao usar find -delete;
- nao limpar versoes antigas.

Caminho local conhecido:

    /media/vmstore/mocha-repo/

Script de atualizacao periodica:

    PENDENTE DE SCRIPT CANONICO TESTADO

Validacao:

    test -d /media/vmstore/mocha-repo
    find /media/vmstore/mocha-repo -maxdepth 1 -type f | sort | head
    find /media/vmstore/mocha-repo -maxdepth 1 -type f | sort | tail

Pendencia bloqueante: qualquer comando que remova pacote antigo invalida a funcao de fallback.

## 15. Calamares e ISO

Objetivo: registrar somente o necessario para montagem operacional quando o fluxo envolver ISO/instalador.

Regra para este manual curto:

- manter apenas resumo executavel;
- detalhes longos ficam no manual vivo interno;
- falhas historicas ficam em auditorias;
- planos antigos nao entram aqui.

Pontos operacionais conhecidos dependentes de teste de ISO:

- live deve abrir Calamares sem senha;
- deve haver um unico atalho de instalacao;
- unpackfs deve apontar para o airootfs correto;
- senha fraca deve ser permitida quando essa for a decisao de produto;
- sistema instalado deve receber tema, stack gamer e permissoes corretas.

Script canonico:

    PENDENTE DE SCRIPT CANONICO TESTADO

Validacao:

    PENDENTE DE FLUXO ISO TESTADO

Pendencia bloqueante: nao declarar ISO pronta sem boot, Calamares, instalacao e primeiro login testados.

## 16. Validacao final do sistema Mocha

Checklist:

- sistema inicia;
- rede funciona;
- SDDM funciona;
- Plasma Wayland inicia;
- usuario final correto;
- HOME sem permissao quebrada;
- tema Mocha aplicado;
- painel Mocha aplicado;
- Steam Mocha abre;
- jogo Proton abre;
- MangoHud aparece com o conteudo aprovado auditado, incluindo temperatura e frequencia/MHz/clock quando suportados;
- GameMode funciona;
- TuneD ativo e verificado;
- kernel padrao e fallback coerentes;
- NVIDIA funcional quando aplicavel;
- repo fallback preserva pacotes antigos;
- nenhuma pendencia foi declarada canonica sem teste.

Comandos de validacao geral:

    id
    uname -a
    systemctl is-active NetworkManager
    systemctl is-active sddm
    echo "$XDG_SESSION_TYPE"
    command -v steam
    command -v mangohud
    command -v gamemoderun
    command -v tuned-adm
    gamemoderun true
    tuned-adm active
    sudo tuned-adm verify

## 17. Proibido e obsoleto

Proibido:

- declarar canonicidade sem teste e aprovacao;
- propor especificacao sem antes auditar o runtime/arquivo aprovado quando ele existir;
- reparar runtime sem evidencia;
- substituir artefato canonico por improviso;
- usar busca ampla perigosa para escolher executavel;
- instalar, copiar ou remover fora do escopo;
- remover pacote antigo do repo fallback;
- usar repo-add -R no repo fallback;
- antecipar commit;
- antecipar push;
- colocar gamescope, vkBasalt ou MANGOHUD_DLSYM no wrapper padrao;
- documentar correcao como aprovada sem teste real.

## 18. Pendencias bloqueantes abertas

Enquanto os scripts abaixo nao forem identificados, testados e aprovados, este manual permanece candidato:

- script canonico de identidade visual;
- script canonico de painel KDE;
- script canonico de SDDM/Wayland/usuario;
- script canonico de stack gamer;
- script canonico de Steam wrapper/autoinsercao;
- validacao visual atual do MangoHud apos qualquer alteracao;
- script canonico de TuneD/agressividade;
- script canonico de OC NVIDIA opcional;
- script canonico de kernel/fallback;
- script canonico de atualizacao do repo fallback;
- script canonico de fluxo Calamares/ISO quando aplicavel.

## 19. Relacao com outros documentos

Manual vivo interno:

    /media/mochafast/MochaArch-Interno/ativo/MANUAL-UNICO-VIVO-MONTAGEM-MOCHA-ARCH-KDE.md

Manual curto antigo identificado pela auditoria:

    /media/mochafast/MochaArch/ativo/documentacao/MANUAL-CURTO-MONTAGEM-MOCHA.md

Auditoria que motivou este novo manual:

    /media/mochafast/MochaArch-Interno/ativo/auditorias/manual-curto-arch-para-mocha-20260709-080150

Auditoria runtime usada nesta geracao:

    /media/mochafast/MochaArch-Interno/ativo/auditorias/criacao-manual-operacional-arch-para-mocha-corrigida-20260709-082638/EVIDENCIAS-RUNTIME-USADAS-NO-MANUAL.tsv
    /media/mochafast/MochaArch-Interno/ativo/auditorias/criacao-manual-operacional-arch-para-mocha-corrigida-20260709-082638/MANGOHUD-LINHAS-ATIVAS-AUDITADAS.txt

Este documento novo nao substitui automaticamente nenhum deles.
