# MochaArch - política ISO, kernel LTS e upgrade assistido

Timestamp: 20260605-221240

## Decisão canônica

A ISO MochaArch e a instalação inicial devem usar por padrão o kernel Arch LTS genérico.

Pacotes base:

- linux-lts
- linux-lts-headers

## Stack LTS baixado

Stack:

arch-linux-lts-6.18.34-1-iso-base-20260605-221240

Perfil:

generic-x86_64-lts

Versão linux-lts:

6.18.34-1

Caminho local:

/media/vmstore/mocha-repo/staging/kernel-stacks/generic-x86_64-lts/arch-linux-lts-6.18.34-1-iso-base-20260605-221240

Origem:

Arch Linux oficial, repo core.

## Função

O LTS é a base segura da ISO e o fallback obrigatório do sistema instalado.

A ISO não deve nascer agressiva.

Depois da instalação ou no primeiro boot, o Mocha pode detectar CPU/GPU e sugerir upgrade para o stack Mocha de melhor desempenho compatível com a máquina.

## Upgrade assistido

O upgrade deve ser sugerido por ferramenta como:

mocha-hardware-advisor

Ela deve detectar:

- generic-x86_64
- x86_64-v3
- x86_64-v4
- GPU NVIDIA, AMD ou Intel
- driver recomendado
- stack Mocha stable compatível

## Consentimento

O upgrade nunca deve ser automático sem aceite explícito do usuário.

## Fallback

linux-lts deve permanecer instalado.

Nenhuma atualização de kernel pode remover o último kernel funcional validado.

## Repositório

O usuário final não deve ter CachyOS habilitado.

O upgrade deve vir do repo Mocha stable.

incoming é coleta.

staging é montagem de stack.

testing é validação.

stable é canal público normal.

R2 deve ser espelho/CDN do stable.

## Referências

Política repo Mocha:

/media/vmstore/mocha-repo/policy/20260605-211422-politica-repo-mocha-sem-cachyos-no-cliente.md

Snippet pacman sem CachyOS:

/media/vmstore/mocha-repo/policy/20260605-211422-pacman-snippet-usuario-final-sem-cachyos.conf

Ponteiro ISO LTS:

/media/vmstore/mocha-repo/state/ULTIMO-STACK-ISO-LTS-MOCHA.txt

Manifesto:

/media/vmstore/mocha-repo/staging/kernel-stacks/generic-x86_64-lts/arch-linux-lts-6.18.34-1-iso-base-20260605-221240/manifest-20260605-221240.txt

Checksums:

/media/vmstore/mocha-repo/staging/kernel-stacks/generic-x86_64-lts/arch-linux-lts-6.18.34-1-iso-base-20260605-221240/checksums-20260605-221240.sha256
