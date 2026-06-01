# MochaArch — aprovados operacionais

Timestamp: 20260531-215226

Este arquivo registra somente itens testados, aprovados ou decididos como regra operacional para o MochaArch.

## Aprovados para preservar

1. Barra KDE estilo Windows 11 / Mocha
   - Solução aprovada: usar o appletsrc aprovado em:
     /media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
   - Fluxo correto: validar arquivo aprovado, fazer backup do appletsrc atual, parar plasmashell, copiar o appletsrc aprovado e reiniciar plasmashell.

2. Duplicidade de Bluetooth e volume na barra
   - Solução aprovada: manter Bluetooth nativo do KDE/Bluedevil e volume nativo do Plasma.
   - Desativar apenas autostart redundante de blueman-applet e kmix via arquivos .desktop com Hidden=true.
   - Não remover pacotes blueman nem kmix por causa disso.

3. Cores KDE
   - Esquema aprovado/candidato: MochaSolidCanonico.
   - Plasma Style aprovado/candidato para painel: MochaPanelSolidCanonico.
   - Se alguma cor destoar do padrão Mocha, voltar a testar antes de canonizar mais.

4. Site Diesel OS Lab / Mocha Arch Edition
   - Pacote publicável aprovado: dieseloslab-cloudflare-ultrahd-20260531.zip.
   - Requisitos: fidelidade ao modelo aprovado, tema escuro bronze/cobre, Ultra HD, seletor multilíngue português/inglês/francês/espanhol e botões PayPal funcionando.

5. Programas padrão decididos
   - Incluir Vivaldi.
   - Incluir Bitwarden Desktop.
   - Validar nomes reais dos pacotes no repositório alvo antes de gerar comando de instalação.

6. MangoHud
   - MangoHud é parte fundamental da configuração gamer do Mocha.
   - Deve ter configuração visual Mocha documentada e reaproveitável.

7. Política de repositórios e atualizações
   - MochaArch deve ser rolling release com curadoria própria, não atualização liberada às pressas para usuário final.
   - AUR não é tabu absoluto, mas só deve ser usado pacote a pacote, com auditoria e justificativa.
   - Nunca usar AUR/helper/Pamac para atualização geral do sistema.
   - Avaliar repositório próprio local no VMSTORE e futuramente Cloudflare R2.

## Não aprovado / em revisão

1. Hibernação
   - Estado atual: em revisão.
   - Não registrar como aprovada enquanto persistir erro de resume/boot.
   - Não canonizar comandos recentes de hibernação até nova validação limpa.

## Regra operacional

- Tudo que funcionar e for aprovado deve virar documentação e, quando aplicável, script reutilizável.
- Tentativa quebrada não entra no ativo.
- Remendo falho deve ser apagado ou movido para quarentena, nunca misturado com solução aprovada.
- O ativo do MochaArch deve conter apenas material aprovado, funcional ou em refino controlado.
