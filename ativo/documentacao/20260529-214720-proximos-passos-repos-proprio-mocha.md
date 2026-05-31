# Próximos passos — repositório próprio Mocha e limpeza controlada

Data: 20260529-214720

## Propósito

Implantar o repositório próprio do Mocha sem improviso, sem atualizar usuário final direto do Arch e sem misturar legado Nix/XU com a nova base Arch/KDE.

## Regras de contenção

- Não apontar o pacman do usuário final para Arch upstream direto.
- Não usar AUR para atualização geral.
- Não atualizar kernel, NVIDIA, Mesa, Plasma, Wayland, systemd, glibc ou pacman sem promoção manual.
- Não apagar MochaArch ativo, documentação aprovada, scripts aprovados ou assets atuais.
- Não inventar pacote, tema, ajuste visual ou política nova sem registrar e aprovar.
- Toda mudança funcional aprovada deve gerar documentação Markdown e, quando couber, script reutilizável.

## Ordem correta de implantação

1. Revisar esta auditoria e confirmar o que é legado removível.
2. Criar estrutura local: /media/vmstore/MochaRepos.
3. Criar primeiro repositório local [mocha] somente com pacotes próprios do Mocha.
4. Criar pacote mocha-keyring para chave pública do Mocha.
5. Criar primeiro pacote simples do Mocha para provar que pacman instala pelo repo local.
6. Só depois criar espelho bruto upstream-arch no VMSTORE.
7. Criar staging para testes.
8. Criar stable para liberação.
9. Promover pacotes de staging para stable apenas após teste.
10. Publicar stable no R2 somente depois do fluxo local funcionar.

## Estrutura alvo

- /media/vmstore/MochaRepos/upstream-arch
- /media/vmstore/MochaRepos/staging
- /media/vmstore/MochaRepos/stable
- /media/vmstore/MochaRepos/quarantine
- /media/vmstore/MochaRepos/logs
- /media/vmstore/MochaRepos/manifests
- /media/vmstore/MochaRepos/scripts

## Itens que exigem trava manual

- kernel e headers
- NVIDIA e nvidia-utils
- Mesa e Vulkan
- Plasma, KWin e Wayland
- systemd
- glibc
- pacman
- mkinitcpio e bootloader

## Primeira ação depois desta auditoria

Criar somente o esqueleto de /media/vmstore/MochaRepos e o repositório local [mocha], sem tocar ainda em core, extra, multilib ou atualização geral do sistema.
