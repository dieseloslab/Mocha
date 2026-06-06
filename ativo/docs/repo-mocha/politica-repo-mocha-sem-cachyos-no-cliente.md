# MochaArch - política canônica do repositório controlado

Timestamp: 20260605-211422

## Decisão central

O usuário final do MochaArch não deve ter repositórios CachyOS habilitados no sistema.

O CachyOS pode ser usado pelo projeto MochaArch apenas como fonte upstream de coleta, comparação, teste ou inspiração técnica.

O usuário final deve consumir somente repositórios Mocha publicados em canal stable/tested:

- mocha-kernel
- mocha-core
- mocha-gaming

Nunca:

- cachyos
- cachyos-v3
- cachyos-v4
- cachyos-extra
- cachyos-extra-v3
- cachyos-extra-v4

## Motivo

Evitar contaminação do sistema do usuário por pacotes não curados, recompilações globais, prioridades de versão externas e combinações kernel/driver que não foram validadas pelo MochaArch.

## Política de kernel

O kernel do usuário deve vir de stacks fechados do Mocha.

Cada stack precisa conter, quando aplicável:

- kernel
- headers
- módulo NVIDIA correspondente
- nvidia-utils
- lib32-nvidia-utils
- opencl-nvidia
- nvidia-settings
- libxnvctrl
- egl-wayland
- linux-firmware-nvidia ou firmware necessário
- manifesto
- checksums
- banco pacman
- status de validação

## Perfis obrigatórios

### generic-x86_64-lts

Perfil padrão seguro para ISO e fallback.
Deve funcionar no maior número possível de máquinas Intel/AMD x86_64.

### generic-x86_64-current

Perfil Arch comum para máquinas modernas, sem otimização agressiva por microarquitetura.

### x86_64-v3-lts

Perfil otimizado para CPUs modernas compatíveis com x86-64-v3, usando kernel LTS quando disponível e validado.

### x86_64-v3-current

Perfil gamer/performance preferencial quando a CPU suportar x86-64-v3 e o stack passar em teste.

### x86_64-v4-current

Perfil opcional para CPUs compatíveis com x86-64-v4/AVX-512. Não deve ser padrão.

## Perfis futuros

- amd-zen4
- intel-modern

Esses perfis só devem existir publicamente se forem builds próprios do Mocha ou stacks reempacotados/validados especificamente.

## Fluxo obrigatório

1. incoming/upstream-arch
2. incoming/upstream-cachyos
3. incoming/local-builds
4. staging/kernel-stacks/<perfil>/<stack-id>
5. testing/<perfil>
6. stable/<perfil>
7. publicação externa, por exemplo Cloudflare R2

## Regra sobre incoming

incoming é área de coleta.

Não promover incoming inteiro.

Não configurar pacman de usuário final apontando para incoming.

## Regra sobre testing

testing é canal de validação.

Não deve ser habilitado por padrão em usuário comum.

## Regra sobre stable

stable é o único canal público normal para usuário final.

## Regra sobre Cloudflare R2

R2 deve ser espelho/CDN do canal stable.
A fonte canônica local continua sendo:

/media/vmstore/mocha-repo

## Regra sobre nomes

Preferir nomes Mocha para pacotes entregues ao usuário final quando houver reempacotamento ou build próprio:

- linux-mocha
- linux-mocha-lts
- linux-mocha-v3
- linux-mocha-v3-lts
- linux-mocha-headers
- linux-mocha-nvidia-open

Enquanto ainda estivermos importando pacotes externos sem reempacotar, eles devem ficar em canal Mocha fechado e validado, nunca em repo upstream habilitado no cliente.

## Regra sobre fallback

Todo perfil otimizado precisa ter fallback generic-x86_64-lts preservado.

Nenhuma atualização de kernel deve remover o último kernel funcional validado.
