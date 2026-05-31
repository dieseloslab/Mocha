# Mocha Gamer Essentials - política de seleção de softwares

Data: 20260530-101522

## Decisão

O Mocha deve entregar ao usuário uma seleção comparável às distros gamer modernas, incluindo Steam, GameMode, MangoHud, GOverlay, launchers, ferramentas Proton/Wine, periféricos gamer e ferramentas de captura.

## Camadas

PADRAO: candidato a vir instalado por padrão quando estiver em repositório confiável ou empacotamento Mocha controlado.
DISPONIVEL_SEM_ATIVAR: pode estar instalado ou disponível, mas não é chamado automaticamente pelo wrapper oficial.
CANDIDATO_AUDITAR: precisa teste prático antes de entrar como padrão.

## Regras permanentes

1. AUR não entra em atualização geral do sistema.
2. AUR só pode ser usado pacote a pacote, com auditoria e justificativa.
3. Se um pacote AUR virar parte oficial do Mocha, o caminho preferido é promover para repositório Mocha controlado.
4. vkBasalt e gamescope podem estar disponíveis para o usuário, mas não entram no wrapper oficial por padrão.
5. MangoHud é parte fundamental do padrão gamer Mocha e deve usar configuração visual Mocha.
6. A linha oficial atual de teste permanece gamemoderun %command% até validação específica do wrapper/integração MangoHud, sem MANGOHUD_DLSYM.

## Auditoria associada

/media/mochafast/MochaArch/ativo/relatorios/20260530-101522-mocha-gamer-essentials-auditoria.md
