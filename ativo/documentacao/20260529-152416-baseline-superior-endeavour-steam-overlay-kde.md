# Mocha Arch/KDE — baseline superior ao Endeavour

Timestamp: 20260529-152416

## Resultado relatado pelo usuário

Este estado atual foi relatado como superior ao Endeavour em todos os aspectos principais:

- FPS alto usando a medição do overlay da Steam.
- Jogo fluido.
- Sistema em geral muito rápido.
- Sem problemas de conectividade Bluetooth.
- Desempenho geral superior ao Endeavour.

## Pendências observadas

- Há redundância relacionada ao Bluetooth.
- Há redundância no controle de volume.
- O controle de volume aparece duas vezes na barra de tarefas.

## Decisão operacional

Este estado deve ser tratado como baseline positivo atual antes de qualquer alteração visual ou de painel.

Próximo passo seguro:

1. Auditar a configuração real do Plasma/KDE.
2. Identificar se a duplicidade vem de applets independentes, system tray, serviços auxiliares ou widgets fixados.
3. Corrigir somente o item duplicado identificado.
4. Não mexer em kernel, driver NVIDIA, Steam, agressividade/performance, Bluetooth funcional ou baseline de desempenho.
