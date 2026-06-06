# MochaArch - especificação inicial do mocha-hardware-advisor

Timestamp: 20260605-212159

## Objetivo

Sugerir ao usuário, após a instalação ou no primeiro boot, o melhor stack de kernel e driver disponível para o hardware detectado.

## Entradas

- CPU
- flags de CPU
- suporte x86-64-v3
- suporte x86-64-v4
- GPU
- driver de vídeo atual
- sessão gráfica esperada
- Wayland disponível
- kernels instalados
- bootloader
- stacks disponíveis no repo Mocha stable

## Saídas

- perfil recomendado
- stack recomendado
- justificativa curta
- opção de instalar agora
- opção de manter configuração segura atual

## Regras

1. Nunca habilitar CachyOS no cliente final.
2. Nunca instalar stack de staging em usuário comum.
3. Nunca instalar stack de testing em usuário comum por padrão.
4. Usar somente stable para recomendação normal.
5. Manter linux-lts instalado.
6. Manter linux-lts-headers instalado.
7. Não remover último kernel funcional.
8. Não alterar boot padrão sem validação.
9. Não forçar upgrade sem consentimento.
10. Registrar log local da recomendação e da instalação.

## Exemplo de texto para usuário

Seu computador suporta o perfil x86_64-v3-current.

Há um stack Mocha validado para melhor desempenho em jogos.

Kernel atual seguro:

linux-lts

Stack recomendado:

linux-mocha-v3-current + headers + driver de vídeo compatível

O kernel LTS será mantido como fallback.

Deseja instalar o stack recomendado agora?

## Estados possíveis

- seguro-default-lts
- recomendado-disponivel
- recomendado-indisponivel
- gpu-sem-stack-validado
- cpu-sem-perfil-otimizado
- upgrade-instalado
- rollback-disponivel
