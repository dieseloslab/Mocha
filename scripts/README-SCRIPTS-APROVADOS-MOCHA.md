# Scripts aprovados do Projeto Mocha

Regra canônica: todo procedimento aprovado deve ter script correspondente em `scripts/` e entrada no manual citando o caminho exato do script.

O manual nunca deve registrar apenas uma instrução abstrata quando o procedimento for reaplicável. Deve registrar:

- nome do procedimento;
- caminho do script canônico;
- comando para executar;
- validação esperada;
- se pode ser chamado no pós-install do Calamares.

## Repositórios locais kernel/driver

Script canônico versionado:

    /media/mochafast/MochaArch/scripts/repos/mocha-repos-maintain

Script instalado no sistema:

    /usr/local/sbin/mocha-repos-maintain

Timer semanal:

    mocha-repos-maintain.timer

Instalador pós-formatação/pós-install:

    /media/mochafast/MochaArch/scripts/postinstall/instala-mocha-repos-maintain

Comando manual:

    sudo /usr/local/sbin/mocha-repos-maintain

Validação sem travar:

    systemctl is-enabled mocha-repos-maintain.timer
    systemctl is-active mocha-repos-maintain.timer
    systemctl list-timers --all | grep -F mocha-repos-maintain
    readlink -f /media/vmstore/mocha-repo/manifests/latest-kernel-driver
    cat /media/vmstore/mocha-repo/manifests/latest-kernel-driver/04-trincas-completas.txt

Regra de segurança: kernel só pode ser instalado se existir no repo-only a trinca completa `linux-cachyos`, `linux-cachyos-headers` e `linux-cachyos-nvidia-open` para a mesma versão e arquitetura.

## Mocha Updater GUI real sem terminal V4 — 20260701-005434

Script canônico:
- /media/mochafast/MochaArch/scripts/mocha-updater-lqx-dkms-canonico-v2.sh

Função:
- recompila o Mocha Updater;
- remove o fluxo com terminal;
- executa ações reais via Polkit em segundo plano;
- mostra progresso e resultado dentro da própria interface;
- mantém helper administrativo em /usr/local/lib/mocha-updater/mocha-updater-root;
- mantém policy Polkit em /usr/share/polkit-1/actions/org.mocha.updater.policy;
- instala binário em /usr/local/bin/mocha-updater;
- mantém atalho canônico no menu Sistema e na área de trabalho;
- remove atalhos legados/duplicados.

Ações reais:
- preview: lista pacman e Flatpak;
- update: snapshot + pacman -Syu + Flatpak update;
- backup: snapshot em /var/lib/mocha-updater/snapshots;
- test-kernel: detecção real de CPU/GPU/driver;
- apply-kernel: instala kernel + driver disponível nos repositórios já configurados, sem adicionar repo CachyOS automaticamente.

## Mocha Updater layout final V5 — 20260701-005910

Script canônico:
- /media/mochafast/MochaArch/scripts/mocha-updater-lqx-dkms-canonico-v2.sh

Função:
- remove sidebar que espremia conteúdo;
- troca navegação para abas superiores;
- força cards em coluna única;
- quebra textos longos manualmente;
- mantém ações reais sem terminal via Polkit;
- mantém progresso dentro da própria interface;
- instala binário em /usr/local/bin/mocha-updater;
- mantém atalho canônico no menu Sistema e na área de trabalho;
- remove atalhos legados/duplicados.

## Mocha Updater status de usuário V6 — 20260701-010636

Script canônico:
- /media/mochafast/MochaArch/scripts/mocha-updater-lqx-dkms-canonico-v2.sh

Função:
- substitui log cru por status compreensível para usuário final;
- mostra "Atualizações disponíveis: Pacman X, Flatpak Y";
- mostra "Verificando", "Criando backup", "Instalando", "Finalizando";
- mostra resultado final: "Atualização instalada com sucesso" ou falha;
- move saída técnica para aba Detalhes;
- mantém ações reais sem terminal via Polkit;
- mantém atalho canônico no menu Sistema e na área de trabalho;
- remove atalhos legados/duplicados.
