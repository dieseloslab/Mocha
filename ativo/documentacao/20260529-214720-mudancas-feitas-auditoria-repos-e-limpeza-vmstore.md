# Mudanças feitas — auditoria de repositórios e limpeza VMSTORE

Data: 20260529-214720
Host: Mocha
Kernel em uso: 7.0.10-zen1-1-zen

## O que foi feito nesta execução

- Criada auditoria somente-leitura para preparar a implantação do repositório próprio Mocha.
- Criada área de relatórios em: /media/mochafast/MochaArch/ativo/auditorias/20260529-214720-repos-proprio-limpeza-vmstore
- Criado inventário de pacotes explícitos, pacotes estrangeiros/AUR, serviços relevantes, mounts, pacman.conf e arquivos importantes do MochaArch.
- Classificados como legado removível os materiais XU/Nix/NixOS/Cachy antigos da fase anterior, incluindo candidatos encontrados por nome.
- Nenhum pacote foi instalado.
- Nenhuma atualização foi executada.
- Nenhum arquivo de configuração do sistema foi editado.
- Nada foi apagado do VMSTORE.

## Estado de espaço capturado

- VMSTORE: 942G livres de 1,9T total; uso 50%
- FAST: 281G livres de 448G total; uso 32%
- Pacotes estrangeiros/AUR detectados: 4
- Candidatos a legado Nix/XU/Cachy detectados: 5022

## Maiores itens no topo do VMSTORE

- 189680456 — /media/vmstore/XU
- 121086756 — /media/vmstore/Fast
- 77792320 — /media/vmstore/Mocha
- 67840664 — /media/vmstore/Lgy
- 45853460 — /media/vmstore/mocha-operation-logs
- 45332528 — /media/vmstore/tmp
- 40078564 — /media/vmstore/boreltonvidia
- 14806856 — /media/vmstore/MochaCanonico
- 8825684 — /media/vmstore/MochaCanonico-NOVO-20260519-114138
- 4957504 — /media/vmstore/kdePCan
- 4513568 — /media/vmstore/Xu709
- 4258416 — /media/vmstore/PRESERVAR-FAST-ANTES-FORMATAR
- 7540 — /media/vmstore/GptMemories.md
- 7520 — /media/vmstore/GPTM.md
- 7520 — /media/vmstore/GptMemories
- 7520 — /media/vmstore/GPTMD.backup-before-visual-doc-path-20260509-153016
- 7520 — /media/vmstore/GPTMD.backup-before-mocha-visual-recipe-20260509-152716
- 7520 — /media/vmstore/GPTMD.backup-before-mocha-visual-20260509-150516
- 7520 — /media/vmstore/GPTMD
- 4132 — /media/vmstore/themaquasecanonico
- 2892 — /media/vmstore/GLF
- 2412 — /media/vmstore/documentacao-preservada
- 880 — /media/vmstore/boreltonvidia-move-logs-20260509-071401
- 764 — /media/vmstore/mocha-test-bore-lto-705-finaldry-20260511-234300
- 608 — /media/vmstore/DOCUMENTO-UNIFICADO-MIGRACAO-MOCHAFAST-PARA-BTRFS-ULTIMO.md

## Arquivos de auditoria criados

- Relatório geral: /media/mochafast/MochaArch/ativo/auditorias/20260529-214720-repos-proprio-limpeza-vmstore/20260529-214720-auditoria-geral-repos-e-vmstore.md
- Dados brutos: /media/mochafast/MochaArch/ativo/auditorias/20260529-214720-repos-proprio-limpeza-vmstore/raw
- Manifestos: /media/mochafast/MochaArch/ativo/auditorias/20260529-214720-repos-proprio-limpeza-vmstore/manifests

## Regra registrada

- A fase atual do Mocha é Arch/KDE.
- XU, Nix, NixOS, flakes antigos, caches boreltonvidia e materiais Cachy/Xu antigos são legado removível quando houver necessidade de espaço.
- MochaArch ativo, documentação aprovada, scripts aprovados, tema, wallpaper, barra KDE e ajustes atuais devem ser preservados.
