# Manual de montagem - Mocha Arch KDE

Arquivo canônico operacional criado em 20260529-203750.


---

## PASSO ZERO - montar FAST e VMSTORE

Antes de procurar manual, aplicar tema, ajustar KDE, instalar kernel, mexer no driver NVIDIA ou documentar qualquer etapa, montar obrigatoriamente:


---

## ERRO PROIBIDO - comando grande sem validação de sintaxe

Não entregar blocos shell grandes com Python, heredocs ou aspas complexas sem gravar script temporário e validar com bash -n antes de executar ações reais.

Erro ocorrido em 2026-05-29: um bloco de instalação do kernel Zen/NVIDIA instalou pacotes e rodou DKMS/mkinitcpio, mas quebrou depois com erro de sintaxe perto de GRUB_CMDLINE_LINUX_DEFAULT=. Isso deixou o sistema em estado parcial.

Regra de reparo: depois de erro assim, auditar o estado real e completar/reparar. Não reinstalar às cegas, não reiniciar antes de validar bootloader, initramfs e módulos NVIDIA.

---

## ERRO PROIBIDO - printf com texto começando por hífen

Não usar printf diretamente com texto literal começando por hífen, como printf "- texto".

Forma correta: printf "%s\n" "- texto".

Regra operacional: em scripts Mocha, toda saída textual começando com hífen deve usar formato explícito ou outra forma segura.

---

## ERRO PROIBIDO - markdown fence ou heredoc aninhado dentro de heredoc colável

Não colocar documentação com cercas de Markdown nem heredocs internos dentro de um script que já está sendo entregue ao usuário como heredoc colável no terminal.

Erro ocorrido em 2026-05-29: ao tentar registrar no manual um exemplo com bloco de Markdown dentro do script, a colagem ficou presa no prompt secundário do shell.

Regra operacional: para escrever manual dentro de script colável, usar função append_line com printf "%s\n" "$texto" linha por linha, sem heredoc aninhado e sem cercas de Markdown.

---

## ERRO PROIBIDO - assumir congelamento como pontual sem auditoria

Em 2026-05-29 houve congelamento total após instalação parcial do kernel Zen/NVIDIA e montagem FAST/VMSTORE.

O log do boot anterior mostrou nvidia-modeset com Failed to initialize DMA e NVRM RC watchdog indicando GPU provavelmente travada.

Regra operacional: após congelamento, não reiniciar nem continuar bootloader/kernel por palpite. Auditar journalctl -b -1, pacman.log, DKMS, mkinitcpio, serviços de performance, mounts e estado real dos módulos antes de qualquer próxima alteração.

Regra adicional: não rodar nvidia-smi, serviço de persistence mode ou modprobe nvidia na sessão atual enquanto o driver não tiver sido preparado para assumir a GPU desde o boot limpo.

---

## PASSO DE REPARO - Zen NVIDIA após congelamento

Em 2026-05-29 foi preparado boot limpo com linux-zen e nvidia-open-dkms sem carregar NVIDIA na sessão atual.

A correção aplicada coloca módulos nvidia, nvidia_modeset, nvidia_uvm e nvidia_drm cedo no mkinitcpio, remove o hook kms para evitar nouveau cedo, adiciona blacklist nouveau e configura nvidia_drm.modeset=1 e nvidia_drm.fbdev=1 no bootloader.

GPU persistence mode e nvidia-smi não devem ser ativados antes do primeiro boot Zen validado.

## 20260529-205629 - Base de jogos e correções leves pós-auditoria
Estado lido antes da alteração: NVIDIA 595.71.05 carregada no boot auditado, receita Mocha de agressividade ativa, mas Steam/MangoHud/wrapper ausentes e overrides de blueman/kmix ausentes.
Ação aplicada: sem mexer em boot, kernel ou driver; apenas instalou pacotes de jogos disponíveis, recriou overrides Hidden=true para blueman/kmix no usuário atual e em /etc/skel, criou MangoHud config local e wrapper limpo /home/hal/.local/bin/mocha-steam-game-run.
Regra preservada: nenhuma Launch Option da Steam foi alterada automaticamente. O baseline sem linha continua preservado; o wrapper fica disponível apenas para teste controlado.
Proibições preservadas no wrapper: sem MANGOHUD_DLSYM, sem gamescope, sem vkbasalt e sem variáveis PRIME de notebook.

## 20260529-210324 - Login manager Plasma Login Manager aplicado, pendente de validação pós-boot

- Aplicado plasmalogin.service como display-manager.service.
- Não houve alteração de teclado.
- Não houve remoção de pacotes.
- Não houve uso de X11 como fallback.
- Verificação pós-boot: /media/mochafast/MochaArch/ativo/scripts/20260529-210324-mocha-verificar-plasmalogin-pos-boot.sh
