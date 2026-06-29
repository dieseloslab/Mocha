# MochaArch — Manual Canônico do Plano B
## Matriz Calam/Arch limpa para gerar Live ISO Mocha

Data canônica: 2026-06-21  
Escopo: gerar uma live ISO Mocha a partir de uma instalação Calam/Arch recém-instalada, mínima, limpa e sanitizada.

---

# 1. Objetivo

O Plano B existe para abandonar a linha frágil de remendar perfil ArchISO quando ela não entrega boot/live confiável.

A live ISO Mocha deve nascer de uma instalação real e limpa do Calam/Arch, usada como matriz.

Essa matriz deve conter apenas o necessário para o usuário iniciar a live, ver a identidade Mocha e clicar no instalador Calamares.

---

# 2. Regra principal

A matriz/live ISO **não é o Mocha final**.

A matriz/live ISO é apenas o ambiente de instalação.

O Mocha final será construído pelo Calamares no disco do usuário.

---

# 3. O que a matriz/live ISO deve conter

A matriz recém-instalada deve receber somente:

- base Calam/Arch limpa;
- KDE Plasma;
- sessão Wayland;
- SDDM funcional;
- autologin do usuário live, se necessário;
- usuário live público:
  - usuário: `mocha`
  - senha: `mocha`
- tema/branding Mocha;
- wallpaper Mocha;
- aparência/painel/barra de tarefas no estilo Mocha aprovado;
- NetworkManager;
- rede por DHCP;
- Calamares instalado e funcional;
- atalho `Instalar Mocha` na área de trabalho;
- ícone/branding do instalador;
- configurações mínimas para boot limpo da live.

---

# 4. O que a matriz/live ISO não deve conter

Não instalar na matriz/live:

- Steam;
- GameMode;
- MangoHud;
- TuneD gamer;
- ProtonUp-Qt;
- Protontricks;
- gamescope;
- vkBasalt;
- UFW/GUFW como firewall final;
- wrapper Steam Mocha;
- programa Mocha Kernel/Driver Updater como ferramenta da live;
- kernels gamer extras;
- driver NVIDIA proprietário/open como requisito da live;
- caches de pacman;
- caches de navegador;
- caches Steam;
- jogos;
- histórico de shell;
- dados pessoais;
- chaves SSH;
- machine-id persistente;
- configuração de IP/gateway fixo.

Esses itens pertencem ao sistema instalado pelo Calamares, não à live.

---

# 5. Rede: regra obrigatória

A live ISO nunca pode herdar IP/gateway fixos da máquina de desenvolvimento.

A live deve usar DHCP para:

- IP;
- gateway;
- rotas;
- DNS, preferencialmente recebido da rede.

Proibido na live:

- `method=manual`;
- `addresses=`;
- `gateway=`;
- `Address=`;
- `Gateway=`;
- perfil persistente em `/etc/NetworkManager/system-connections/`;
- configuração estática em `/etc/systemd/network/`;
- configuração estática em `/etc/netctl/`;
- `static ip_address`;
- `static routers`.

Motivo: se a live carregar IP/gateway da máquina de desenvolvimento, outro computador pode ficar sem internet ou causar conflito de rede.

---

# 6. Calamares: regra de rede no sistema instalado

O sistema instalado pelo Calamares também não pode herdar IP/gateway fixos.

O pós-install do Calamares deve garantir:

- NetworkManager habilitado;
- IP/gateway/rotas via DHCP/auto;
- remoção ou quarentena de perfis estáticos;
- nenhuma cópia de perfil de rede da live para o destino.

DNS/DoT pode ser aplicado no sistema instalado, mas sem travar IP/gateway.

---

# 7. O que o Calamares deve instalar/aplicar no sistema final

O Calamares é responsável por construir o Mocha final.

No sistema instalado, o Calamares deve aplicar:

- Steam;
- GameMode;
- MangoHud;
- TuneD;
- perfil `latency-performance`;
- agressividade Mocha;
- zram;
- sysctl Mocha;
- THP;
- UFW/GUFW;
- Proton/Protontricks;
- wrapper Steam Mocha;
- atalho Steam Mocha;
- programa Mocha Kernel/Driver Updater;
- tema final Mocha;
- wallpaper final;
- SDDM final;
- DNS/DoT final, se decidido;
- NetworkManager DHCP;
- configurações pós-instalação.

---

# 8. Fluxo correto de trabalho

## Etapa A — antes de formatar

1. Confirmar backup real dos dados.
2. Salvar este manual fora do disco que será apagado.
3. Confirmar que VMSTORE/FAST não serão formatados por engano.

## Etapa B — instalação limpa da matriz

1. Instalar Calam/Arch limpo.
2. Usar usuário `mocha`.
3. Usar senha `mocha`.
4. Instalar KDE Plasma.
5. Usar NetworkManager.
6. Não configurar IP fixo.
7. Não instalar stack gamer.
8. Não instalar Steam.
9. Não instalar MangoHud/GameMode/TuneD/Proton.

## Etapa C — primeiro boot da matriz

Após entrar no desktop da matriz:

1. Confirmar internet por DHCP.
2. Confirmar Plasma/Wayland.
3. Confirmar SDDM.
4. Aplicar tema/branding Mocha.
5. Aplicar wallpaper Mocha.
6. Aplicar estilo da barra/painel Mocha.
7. Instalar/configurar Calamares.
8. Criar atalho `Instalar Mocha` na área de trabalho.
9. Preparar autologin da live, se necessário.
10. Sanitizar a matriz.

## Etapa D — sanitização antes da ISO

Remover/limpar:

- `/etc/machine-id`;
- `/var/lib/dbus/machine-id`;
- logs antigos;
- cache pacman;
- cache de usuário;
- histórico shell;
- chaves SSH host;
- perfis NetworkManager persistentes;
- arquivos temporários;
- qualquer dado pessoal.

A live deve subir limpa e genérica.

## Etapa E — gerar ISO

Gerar a live ISO a partir da matriz limpa.

Publicar a ISO em:

`/media/vmstore/MochaArch/iso`

Não usar:

`/media/vmstore/MochaArch/isos`

## Etapa F — testar ISO

Antes de formatar computador real:

1. Bootar ISO em VM.
2. Confirmar que entra direto na sessão live.
3. Confirmar tema Mocha.
4. Confirmar rede por DHCP.
5. Confirmar Calamares abrindo pelo atalho.
6. Instalar em VM.
7. Bootar sistema instalado em VM.
8. Confirmar rede DHCP no sistema instalado.
9. Confirmar que o Calamares aplicou Mocha final.
10. Só então considerar instalação em hardware real.

---

# 9. Checklist da live ISO pronta

A live está correta se:

- entra no Plasma/Wayland;
- não pede login manual;
- mostra identidade visual Mocha;
- possui atalho `Instalar Mocha`;
- Calamares abre;
- internet funciona por DHCP;
- não tem Steam;
- não tem stack gamer;
- não tem IP/gateway fixo;
- não contém dados pessoais;
- não contém cache pesado;
- não contém configuração da máquina de desenvolvimento.

---

# 10. Checklist do sistema instalado pelo Calamares

O sistema final está correto se:

- boot limpa;
- usuário criado pelo Calamares entra;
- rede funciona por DHCP;
- tema Mocha aplicado;
- SDDM Mocha aplicado;
- Steam instalado;
- wrapper Steam Mocha instalado;
- GameMode instalado;
- MangoHud instalado;
- TuneD instalado e ativo;
- agressividade aplicada;
- UFW/GUFW conforme política final;
- Kernel/Driver Updater disponível;
- sem herança de IP/gateway fixo.

---

# 11. Decisão permanente

Se houver conflito entre scripts antigos e este manual, este manual vence.

A live ISO do Plano B deve ser mínima.

O sistema final Mocha deve ser produzido pelo Calamares.

Não misturar novamente as camadas.

---

# 12. Frase de controle

Antes de qualquer comando novo, validar:

“Estou mexendo na matriz/live mínima ou no sistema final instalado pelo Calamares?”

Se for matriz/live mínima: não instalar stack gamer.

Se for sistema final via Calamares: aplicar stack Mocha completo.

<!-- MOCHA_FAST_VMSTORE_NAO_HERDAR_LIVE_V2_INICIO -->
# FAST e VMSTORE na matriz: montagem temporária, nunca herdada pela live ISO

## Regra obrigatória

Durante a preparação da matriz limpa, será necessário montar os discos de trabalho:

- FAST: `/media/mochafast/MochaArch`
- VMSTORE: `/media/vmstore/MochaArch`

Eles serão usados apenas para acessar:

- manual canônico;
- tema/branding Mocha;
- wallpapers;
- assets;
- scripts de preparação;
- logs;
- saída da ISO;
- backups.

Esses mounts são parte do ambiente de trabalho do desenvolvedor.

Eles **não podem ser herdados pela live ISO**.

## Caminhos canônicos do manual

Manual principal:

`/media/vmstore/MochaArch/iso/manual/PLANO-B-MATRIZ-CALAM-LIVE-ISO.md`

Cópia espelhada:

`/media/mochafast/MochaArch/ativo/PLANO-B-MATRIZ-CALAM-LIVE-ISO.md`

## O que pode acontecer na matriz durante a preparação

É permitido montar temporariamente:

- `/media/vmstore`
- `/media/mochafast`

É permitido usar esses caminhos para copiar arquivos Mocha para dentro da matriz.

É permitido gerar a ISO final em:

`/media/vmstore/MochaArch/iso`

## O que é proibido levar para a live ISO

Antes de gerar a ISO, a sanitização deve remover qualquer herança de FAST/VMSTORE:

- entradas em `/etc/fstab`;
- unidades systemd `.mount`;
- unidades systemd `.automount`;
- atalhos para `/media/vmstore`;
- atalhos para `/media/mochafast`;
- bookmarks de gerenciador de arquivos;
- scripts contendo mounts automáticos desses discos;
- caches;
- histórico de terminal;
- referências persistentes a `/media/vmstore`;
- referências persistentes a `/media/mochafast`;
- UUIDs privados desses discos;
- credenciais, chaves ou tokens.

## Auditoria obrigatória antes de gerar a ISO

Antes de empacotar a matriz como live ISO, procurar e remover referências persistentes a:

- `/media/vmstore`
- `/media/mochafast`

Referências internas de branding Mocha são permitidas.

Referências a FAST/VMSTORE não são permitidas.

## Regra curta

FAST e VMSTORE podem ser montados para preparar a matriz e gerar a ISO.

FAST e VMSTORE não podem existir como dependência, atalho, mount automático ou configuração persistente dentro da live ISO.

## Frase de controle

Montar FAST/VMSTORE é ferramenta de preparação.

Herdar FAST/VMSTORE na live é erro de ISO.
<!-- MOCHA_FAST_VMSTORE_NAO_HERDAR_LIVE_V2_FIM -->
