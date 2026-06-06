# MochaArch - política ISO, kernel LTS e upgrade assistido

Timestamp: 20260605-212159

## Decisão canônica

A ISO MochaArch e a instalação inicial devem usar por padrão o kernel Arch LTS genérico.

Base inicial obrigatória:

- linux-lts
- linux-lts-headers
- fallback funcional no boot
- KDE Plasma
- SDDM
- Wayland
- driver de vídeo seguro compatível
- repositórios Mocha próprios
- nenhum repositório CachyOS habilitado no cliente final

## Motivo

A primeira instalação precisa priorizar boot, compatibilidade e recuperação.

O perfil de performance deve ser sugerido depois que o hardware real for detectado e depois que houver um stack fechado validado no repositório Mocha stable.

## Regra de upgrade

Depois da instalação, ou no primeiro boot do sistema instalado, o Mocha deve executar ou oferecer um assistente de hardware.

Nome operacional sugerido:

mocha-hardware-advisor

Função:

Detectar CPU, arquitetura suportada, GPU e driver indicado.

A partir disso, sugerir o melhor stack kernel + headers + driver disponível no repositório Mocha stable.

## Perfis de CPU

Perfis mínimos:

- generic-x86_64
- x86_64-v3
- x86_64-v4

generic-x86_64 é o perfil seguro.

x86_64-v3 é o perfil gamer/performance preferencial quando a CPU suportar.

x86_64-v4 é opcional e não deve ser padrão.

## Detecção de GPU

O assistente deve detectar:

- NVIDIA
- AMD
- Intel
- GPU híbrida, quando aplicável

Para NVIDIA, o stack recomendado deve preservar compatibilidade entre:

- kernel
- headers
- módulo NVIDIA
- nvidia-utils
- lib32-nvidia-utils
- opencl-nvidia
- nvidia-settings
- libxnvctrl
- egl-wayland
- firmware necessário

## Consentimento obrigatório

O upgrade de performance nunca deve ser automático sem aceite explícito do usuário.

O texto da sugestão deve deixar claro:

- qual perfil foi detectado
- qual stack será instalado
- que o kernel LTS será mantido como fallback
- que o usuário pode continuar usando o perfil seguro

## Fallback obrigatório

O kernel Arch LTS genérico deve permanecer instalado.

Nenhuma atualização de kernel deve remover o último kernel funcional validado.

O bootloader deve manter entrada de recuperação para o LTS.

## Repositório

O upgrade deve vir apenas do repositório Mocha stable.

Nunca habilitar CachyOS no cliente final.

incoming é coleta.

staging é montagem de stack.

testing é validação.

stable é canal público normal.

Cloudflare R2 deve ser espelho/CDN do stable, não fonte de verdade local.

Fonte local canônica:

/media/vmstore/mocha-repo

## Política relacionada

Política repo Mocha:

/media/vmstore/mocha-repo/policy/20260605-211422-politica-repo-mocha-sem-cachyos-no-cliente.md

Snippet pacman sem CachyOS:

/media/vmstore/mocha-repo/policy/20260605-211422-pacman-snippet-usuario-final-sem-cachyos.conf

Ponteiro stack staging canônico:

/media/vmstore/mocha-repo/state/ULTIMO-STACK-STAGING-CANONICO-MOCHA.txt
