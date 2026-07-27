#!/usr/bin/env bash
set -Eeuo pipefail

PATH="/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/sbin:/run/wrappers/bin:/run/current-system/sw/bin:${PATH:-}"

TS="$(date +%Y%m%d-%H%M%S)"

FAST_BASE="/media/mochafast/MochaArch"
VM_BASE="/media/vmstore/MochaArch"
ACTIVE="$FAST_BASE/ativo"

DOC_DIR="$ACTIVE/documentacao"
SCRIPT_DIR="$ACTIVE/scripts"
REPORT_DIR="$ACTIVE/relatorios"

NEW_MANUAL="$DOC_DIR/${TS}-manual-instalacao-mocha-arch-em-ordem.md"
FIXED_MANUAL="$DOC_DIR/MANUAL-INSTALACAO-MOCHA-ARCH-ORDEM.md"
REFERENCE_INDEX="$REPORT_DIR/${TS}-indice-documentos-usados-no-manual.txt"
LOG="$REPORT_DIR/${TS}-organizar-manual-instalacao.log"
SCRIPT_COPY="$SCRIPT_DIR/${TS}-mocha-organizar-manual-instalacao-ordem.sh"

say() {
  printf '\n== %s ==\n' "$*"
}

fail() {
  printf '\nERRO: %s\n' "$*" >&2
  exit 1
}

require_mount() {
  local mountpoint="$1"
  findmnt -rno TARGET "$mountpoint" >/dev/null 2>&1 || fail "$mountpoint não está montado."
}

append_line() {
  printf '%s\n' "$*" >> "$NEW_MANUAL"
}

append_blank() {
  printf '\n' >> "$NEW_MANUAL"
}

append_section() {
  append_blank
  append_line "## $*"
  append_blank
}

append_step() {
  append_blank
  append_line "### $*"
  append_blank
}

say "Validando mounts obrigatórios"
require_mount "/media/mochafast"
require_mount "/media/vmstore"

say "Preparando diretórios do MochaArch"
mkdir -p "$DOC_DIR" "$SCRIPT_DIR" "$REPORT_DIR"

exec > >(tee -a "$LOG") 2>&1

say "Registrando índice dos documentos existentes"
{
  printf 'Índice gerado em: %s\n' "$TS"
  printf 'Diretório: %s\n\n' "$DOC_DIR"
  find "$DOC_DIR" -maxdepth 1 -type f \( -iname '*.md' -o -iname '*.txt' \) -printf '%TY-%Tm-%Td %TH:%TM  %p\n' 2>/dev/null | sort || true
} > "$REFERENCE_INDEX"

say "Preservando manual fixo anterior, se existir"
if [ -f "$FIXED_MANUAL" ]; then
  BACKUP="$DOC_DIR/${TS}-backup-MANUAL-INSTALACAO-MOCHA-ARCH-ORDEM.md"
  cp -a "$FIXED_MANUAL" "$BACKUP"
  printf 'Backup criado: %s\n' "$BACKUP"
fi

say "Mantendo no máximo 2 backups do manual fixo"
find "$DOC_DIR" -maxdepth 1 -type f -name '*-backup-MANUAL-INSTALACAO-MOCHA-ARCH-ORDEM.md' -printf '%T@ %p\0' 2>/dev/null \
  | sort -z -nr \
  | tail -z -n +3 \
  | cut -z -d' ' -f2- \
  | xargs -0r rm -f --

say "Criando manual reorganizado em ordem de instalação"
: > "$NEW_MANUAL"

append_line "# Manual de instalação do Mocha Arch — ordem de instalação"
append_blank
append_line "Gerado em: $TS"
append_line "Manual atual fixo: $FIXED_MANUAL"
append_line "Manual histórico desta rodada: $NEW_MANUAL"
append_line "Índice de documentos consultados: $REFERENCE_INDEX"
append_blank
append_line "Este manual organiza o procedimento usado na montagem atual do Mocha Arch/KDE em ordem de instalação. Ele registra o fluxo aprovado até agora e deve ser atualizado somente com passos que funcionaram ou foram explicitamente aprovados."

append_section "0. Regras antes de começar"

append_line "- Trabalhar de forma incremental: auditar primeiro, alterar depois."
append_line "- Não empilhar remendos no ativo."
append_line "- Tudo que funcionar deve ser documentado."
append_line "- Tentativa que falhou deve ser apagada ou movida para quarentena, não deixada misturada no ativo."
append_line "- Arquivos novos devem ter timestamp no nome, salvo caminho canônico fixo necessário."
append_line "- Manter no máximo 1 ou 2 backups por arquivo."
append_line "- Não remover programas sem ordem expressa."
append_line "- Não usar Chrome como padrão nem recomendar para o Mocha."
append_line "- Não usar X11 como fallback. O caminho do Mocha é Wayland."
append_line "- AUR pode ser usado apenas por exceção, pacote a pacote, com auditoria. Nunca usar AUR/helper/Pamac para atualização geral."
append_line "- Comandos de instalação devem usar sudo -v no começo e keepalive para não pedir senha várias vezes."
append_line "- Comandos demorados devem mostrar progresso visível."
append_line "- Antes de mexer em arquivo real de configuração, ler/auditar o estado real."
append_line "- Repositórios e atualizações devem seguir política controlada: testar primeiro, promover depois."

append_section "1. Instalação base"

append_step "1.1 Instalar a base Arch/KDE"
append_line "- Instalar uma base Arch limpa com KDE Plasma."
append_line "- Usar Wayland como caminho obrigatório."
append_line "- Não improvisar troca de teclado se não foi necessária no fluxo aprovado."
append_line "- A instalação atual reproduzida usou uma base Arch/KDE limpa e depois recebeu as camadas Mocha."

append_step "1.2 Primeiro boot"
append_line "- Entrar no sistema instalado."
append_line "- Confirmar usuário principal."
append_line "- Confirmar que a interface está utilizável."
append_line "- Antes de qualquer mudança pesada, auditar kernel, GPU, repositórios e mounts."

append_section "2. Auditoria inicial do sistema"

append_step "2.1 Verificar kernel, GPU e sessão"
append_line "- Conferir kernel ativo com uname -r."
append_line "- Conferir GPU com nvidia-smi quando o driver NVIDIA já estiver instalado."
append_line "- Conferir sessão gráfica e evitar qualquer fallback para X11."
append_line "- Registrar resultado em relatório no MochaArch."

append_step "2.2 Verificar pacman e repositórios"
append_line "- Auditar /etc/pacman.conf antes de editar."
append_line "- Preservar repositórios oficiais necessários."
append_line "- Remover ou substituir entradas erradas, não deixar entrada quebrada comentada no ativo."
append_line "- Usar repositórios estáveis como base."
append_line "- Medir velocidade dos mirrors e manter os mais rápidos."
append_line "- Não tratar Pamac/AUR como fonte de atualização geral."

append_section "3. Montagem obrigatória de discos"

append_step "3.1 Montar FAST e VMSTORE"
append_line "- FAST deve estar em /media/mochafast."
append_line "- VMSTORE deve estar em /media/vmstore."
append_line "- Ambos devem montar de forma persistente no boot."
append_line "- Ambos devem ficar visíveis e utilizáveis sem depender de montagem manual pelo gerenciador de arquivos."
append_line "- Não danificar nem sobrescrever NVMe por confusão de device."
append_line "- Antes de alterar /etc/fstab, auditar as entradas reais."
append_line "- Se houver entrada errada, substituir pela correta; não empilhar duplicatas."

append_step "3.2 Estrutura de trabalho"
append_line "- Pasta ativa principal: /media/mochafast/MochaArch/ativo."
append_line "- Documentação: /media/mochafast/MochaArch/ativo/documentacao."
append_line "- Scripts aprovados: /media/mochafast/MochaArch/ativo/scripts."
append_line "- Relatórios: /media/mochafast/MochaArch/ativo/relatorios."
append_line "- Quarentena deve ser separada do ativo."
append_line "- VMSTORE pode abrigar repositório seguro/controlado do Mocha e materiais grandes."

append_section "4. Login manager"

append_step "4.1 Trocar para o login manager aprovado"
append_line "- O login manager aprovado nesta fase é o plasmalogin em Wayland."
append_line "- O ajuste deve preservar teclado e não inventar alteração de layout."
append_line "- Não configurar X11 como fallback."
append_line "- Depois da alteração, reiniciar e validar login gráfico."

append_step "4.2 Validação pós-boot"
append_line "- Confirmar que a tela de login abre corretamente."
append_line "- Confirmar que a sessão entra em Wayland."
append_line "- Confirmar que não houve regressão de teclado."

append_section "5. Kernel Zen e NVIDIA"

append_step "5.1 Instalar kernel Zen"
append_line "- Instalar linux-zen e linux-zen-headers pelos repositórios oficiais."
append_line "- Não usar comando grande sem validação de sintaxe."
append_line "- Colocar o Zen como primeira opção/default no bootloader."
append_line "- Validar com uname -r depois do reboot."

append_step "5.2 Instalar NVIDIA open"
append_line "- Instalar o driver NVIDIA open compatível com o kernel em uso."
append_line "- Usar DKMS quando aplicável."
append_line "- Rodar mkinitcpio conforme necessário."
append_line "- Atualizar bootloader conforme necessário."
append_line "- Validar com nvidia-smi depois do reboot."
append_line "- Se houver erro no meio, auditar estado real antes de repetir instalação."

append_step "5.3 Cuidados obrigatórios"
append_line "- Não misturar tentativa quebrada com ativo."
append_line "- Não usar heredoc ou Python inline frágil em bloco grande sem bash -n."
append_line "- Não deixar o bootloader apontando para fallback como default por engano."
append_line "- Após funcionar, documentar o procedimento e salvar script reutilizável."

append_section "6. Performance, energia e agressividade"

append_step "6.1 CPU em performance"
append_line "- Configurar CPU para entregar desempenho máximo."
append_line "- Usar perfil de baixa latência/performance."
append_line "- Tornar permanente, não apenas para a sessão atual."
append_line "- Validar serviço/perfil após reboot."

append_step "6.2 GPU NVIDIA em máximo desempenho"
append_line "- Configurar GPU para preferir desempenho máximo quando aplicável."
append_line "- Validar com ferramentas NVIDIA disponíveis."
append_line "- Não aplicar ajuste que quebre Wayland."

append_step "6.3 TuneD"
append_line "- TuneD deve usar perfil latency-performance no fluxo aprovado."
append_line "- Validar serviço ativo."
append_line "- Registrar estado no manual."

append_step "6.4 ZRAM"
append_line "- ZRAM faz parte da base gamer/performance do Mocha."
append_line "- Validar se está ativa."
append_line "- Registrar algoritmo, tamanho e prioridade quando aplicados."

append_section "7. Flatpak, Flathub e Discover"

append_step "7.1 Habilitar Flatpak"
append_line "- Flatpak/Flathub faz parte da base boa do Mocha."
append_line "- Discover pode manter suporte a Flatpak."
append_line "- Confirmar que Flathub está disponível."
append_line "- Não usar Chrome como app padrão."

append_section "8. Steam, GameMode e MangoHud"

append_step "8.1 Steam"
append_line "- Instalar Steam."
append_line "- Confirmar abertura e login."
append_line "- Testar jogos antes de canonizar qualquer resultado final."

append_step "8.2 GameMode"
append_line "- GameMode deve estar instalado e funcional."
append_line "- Linha simples de teste sem MangoHud: gamemoderun %command%."
append_line "- Essa linha não chama MangoHud sozinha."

append_step "8.3 MangoHud padrão Mocha"
append_line "- MangoHud é parte fundamental do Mocha gamer."
append_line "- Deve existir configuração visual Mocha para MangoHud."
append_line "- O manual deve registrar o que instalar, onde fica o arquivo de configuração e qual linha usar na Steam."
append_line "- Linha Steam oficial quando o usuário quiser GameMode mais MangoHud: mangohud gamemoderun %command%."
append_line "- Se for usado arquivo específico, definir MANGOHUD_CONFIGFILE apontando para o arquivo Mocha aprovado."
append_line "- Preservar o padrão visual Mocha."
append_line "- Teste de desempenho pode comparar jogo sem linha nenhuma, gamemoderun %command% e mangohud gamemoderun %command%."

append_step "8.4 Wrapper Steam"
append_line "- O wrapper canônico deve partir do comportamento sem Launch Options como baseline."
append_line "- Não reintroduzir MANGOHUD_DLSYM."
append_line "- Não colocar vkBasalt/gamescope no wrapper canônico por padrão."
append_line "- vkBasalt e gamescope podem ficar disponíveis ao usuário, mas não devem contaminar o wrapper padrão."

append_section "9. Programas gamer disponíveis"

append_step "9.1 Ferramentas úteis"
append_line "- Manter disponíveis ferramentas comuns de distro gamer quando fizer sentido."
append_line "- Exemplos a manter na lista de avaliação/instalação: GOverlay, LACT, ProtonPlus, ferramentas de mapeamento de mouse/controle, ferramentas de volante, MangoHud, GameMode, Steam e utilitários Vulkan."
append_line "- ProtonPlus é preferido ao ProtonUp-Qt neste fluxo."
append_line "- Se algum item só existir no AUR, instalar apenas pacote a pacote, com auditoria e sem usar AUR para atualização geral."

append_step "9.2 vkBasalt e gamescope"
append_line "- O fato de o Mocha não usar vkBasalt/gamescope no wrapper padrão não impede que o usuário escolha usar."
append_line "- Podem ficar disponíveis como ferramenta opcional."
append_line "- Não devem ser ativados por padrão no wrapper canônico."

append_section "10. Tema KDE, wallpaper e identidade visual"

append_step "10.1 Esquema de cores"
append_line "- O esquema MochaSolidCanonico foi aprovado visualmente como bom ponto de partida."
append_line "- Se alguma cor destoar do padrão Mocha, voltar aos testes."
append_line "- Não mudar geometria por causa de tema: evitar mexer em tamanhos, margens e comportamento estrutural sem aprovação."

append_step "10.2 Wallpaper"
append_line "- Copiar e aplicar o wallpaper Mocha aprovado para a pasta ativa."
append_line "- Remover referências sutis ao GNOME quando o objetivo for Mocha Arch/KDE."
append_line "- Substituir por referência muito sutil ao Arch quando aprovado."

append_step "10.3 Barra Mocha estilo Windows 11"
append_line "- A barra aprovada fica em: /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/."
append_line "- O arquivo aprovado usado foi o plasma-org.kde.plasma.desktop-appletsrc aprovado salvo nessa pasta."
append_line "- Fluxo correto: validar arquivo aprovado, fazer backup do appletsrc atual, parar plasmashell, copiar appletsrc aprovado, reiniciar plasmashell."
append_line "- Não procurar script inexistente quando o arquivo aprovado já existe."

append_section "11. Correções de barra: Bluetooth e volume duplicados"

append_step "11.1 Correção aprovada"
append_line "- Manter Bluetooth nativo do KDE/Bluedevil."
append_line "- Manter volume nativo do Plasma."
append_line "- Desativar apenas autostarts redundantes de blueman-applet e kmix."
append_line "- Usar overrides .desktop com Hidden=true."
append_line "- Não remover pacotes blueman ou kmix."
append_line "- Aplicar também em /etc/skel para novos usuários quando for preparar imagem final."

append_section "12. Repositório próprio e política de atualizações"

append_step "12.1 Política rolling controlada"
append_line "- Mocha Arch será rolling release com curadoria própria."
append_line "- A máquina de laboratório pode receber atualização para teste."
append_line "- Isso não significa liberação pública ao usuário final."
append_line "- Atualizações devem passar por teste, documentação e promoção."

append_step "12.2 Repositório controlado"
append_line "- O repositório seguro/controlado deve ser criado no VMSTORE."
append_line "- Futuramente pode ser promovido para Cloudflare R2."
append_line "- AUR nunca deve participar de atualização geral."
append_line "- Pacotes AUR úteis podem ser avaliados e instalados pontualmente."

append_section "13. Limpeza e organização da pasta MochaArch"

append_step "13.1 Ativo limpo"
append_line "- A pasta MochaArch/ativo deve conter apenas material funcional, aprovado ou em refino controlado."
append_line "- Lixo deve ir para o lixo."
append_line "- Tentativa que pode ser útil depois deve ir para quarentena."
append_line "- Não guardar cacarecos no ativo."

append_step "13.2 Documentação obrigatória"
append_line "- Todo comando que funcionar deve gerar documentação Markdown."
append_line "- Quando fizer sentido, também deve gerar script reutilizável."
append_line "- Documentação deve conter somente solução correta/aprovada, não tentativas falhas."
append_line "- Este manual deve ser atualizado a cada novo passo aprovado."

append_section "14. Ordem resumida para reinstalar o Mocha Arch"

append_line "1. Instalar base Arch/KDE limpa."
append_line "2. Fazer primeiro boot e auditar sistema."
append_line "3. Auditar pacman.conf e repositórios."
append_line "4. Medir e ajustar mirrors."
append_line "5. Montar FAST em /media/mochafast e VMSTORE em /media/vmstore de forma persistente."
append_line "6. Criar/validar estrutura /media/mochafast/MochaArch/ativo."
append_line "7. Trocar/validar login manager aprovado em Wayland."
append_line "8. Instalar kernel Zen e headers."
append_line "9. Instalar NVIDIA open/DKMS compatível."
append_line "10. Atualizar initramfs e bootloader."
append_line "11. Garantir Zen como entrada padrão."
append_line "12. Reiniciar e validar uname -r, nvidia-smi e Wayland."
append_line "13. Aplicar CPU performance, GPU maximum performance e TuneD latency-performance."
append_line "14. Configurar/validar ZRAM."
append_line "15. Habilitar Flatpak/Flathub e integração com Discover."
append_line "16. Instalar Steam, GameMode e MangoHud."
append_line "17. Configurar MangoHud padrão Mocha."
append_line "18. Registrar Launch Options oficiais e baseline sem linha."
append_line "19. Instalar ferramentas gamer disponíveis: GOverlay, LACT, ProtonPlus, mapeadores, volante e afins."
append_line "20. Aplicar esquema de cores MochaSolidCanonico."
append_line "21. Aplicar wallpaper Mocha/Arch aprovado."
append_line "22. Aplicar barra Mocha/Win11 aprovada."
append_line "23. Corrigir duplicidade blueman/kmix por autostart Hidden=true."
append_line "24. Validar jogos e desempenho."
append_line "25. Documentar o estado aprovado."
append_line "26. Só então promover ajustes para pasta ativa/canônica."

append_section "15. Checklist de validação pós-instalação"

append_line "- /media/mochafast montado."
append_line "- /media/vmstore montado."
append_line "- KDE Plasma em Wayland."
append_line "- Login manager aprovado funcionando."
append_line "- Kernel Zen ativo."
append_line "- NVIDIA funcionando com nvidia-smi."
append_line "- Bootloader apontando para entrada correta."
append_line "- TuneD ativo em latency-performance."
append_line "- CPU em performance."
append_line "- GPU em modo de desempenho quando aplicável."
append_line "- ZRAM ativa."
append_line "- Steam abre."
append_line "- GameMode funciona."
append_line "- MangoHud usa padrão Mocha."
append_line "- Linha Steam com MangoHud: mangohud gamemoderun %command%."
append_line "- Baseline de teste sem linha nenhuma preservado."
append_line "- Tema Mocha aplicado."
append_line "- Wallpaper aplicado."
append_line "- Barra Mocha/Win11 aplicada."
append_line "- Bluetooth duplicado removido sem remover pacote."
append_line "- Volume duplicado removido sem remover pacote."
append_line "- Flatpak/Flathub funcionando."
append_line "- Manual atualizado."

append_section "16. Arquivos de documentação encontrados nesta organização"

if [ -s "$REFERENCE_INDEX" ]; then
  while IFS= read -r ref_line; do
    append_line "- $ref_line"
  done < "$REFERENCE_INDEX"
else
  append_line "- Nenhum documento anterior encontrado no índice."
fi

append_section "17. Pendências controladas"

append_line "- Testar jogos antes de chamar o estado de definitivo."
append_line "- Refinar wrapper Steam sem prejudicar o baseline sem Launch Options."
append_line "- Consolidar repositório próprio no VMSTORE."
append_line "- Separar claramente ativo, quarentena e legado."
append_line "- Atualizar este manual a cada nova etapa aprovada."

say "Publicando manual fixo atual"
cp -a "$NEW_MANUAL" "$FIXED_MANUAL"

say "Salvando cópia do script usado"
cp -a "$0" "$SCRIPT_COPY"
chmod +x "$SCRIPT_COPY"

say "Resultado"
printf 'Manual histórico: %s\n' "$NEW_MANUAL"
printf 'Manual fixo atual: %s\n' "$FIXED_MANUAL"
printf 'Índice de referência: %s\n' "$REFERENCE_INDEX"
printf 'Log: %s\n' "$LOG"
printf 'Script salvo: %s\n' "$SCRIPT_COPY"

say "Concluído"
