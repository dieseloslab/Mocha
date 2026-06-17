# Correção canônica — pacman CachyOS v3 e arquitetura inválida

Erro observado: package architecture is not valid para pacotes x86_64_v3.

Causa: pacman.conf temporário usava Architecture = auto.

Correção: em pacman.conf temporário usado para instalar pacotes CachyOS v3, declarar:

Architecture = x86_64 x86_64_v3

Regra permanente: nunca instalar pacotes linux-cachyos x86_64_v3 com Architecture = auto.

Pacotes afetados nesta ocorrência:
- linux-cachyos
- linux-cachyos-headers
- linux-cachyos-nvidia-open
