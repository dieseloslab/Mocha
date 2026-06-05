# MochaArch — fluxo inicial canônico: FAST, VMSTORE, atualização e kernel CachyOS

Timestamp: 20260602-071452

<!-- MOCHAARCH-FLUXO-INICIAL-FAST-VMSTORE-KERNEL-CACHY-CANONICO -->

## Regra canônica

Quando for dado o comando operacional **“vamos montar o Mocha”**, o fluxo inicial da montagem deve seguir esta ordem.

## 1. Logo após a inicialização do Mocha

Antes de iniciar a instalação pesada ou o polimento do sistema, montar os discos de trabalho:

- FAST em `/media/mochafast`;
- VMSTORE em `/media/vmstore`.

Esses pontos devem cumprir quatro requisitos:

- montagem persistente no boot;
- acessíveis pelo usuário normal;
- visíveis/usáveis pelo Dolphin;
- sem depender de montagem manual posterior.

FAST continua sendo área leve de trabalho/refino.  
VMSTORE continua sendo o local de repositório, pacotes, kernels, drivers, manifests pesados e artefatos grandes.

## 2. Antes de instalar ou trocar kernel

Antes de instalar o kernel do CachyOS ou alterar o kernel padrão, fazer uma atualização completa do sistema.

A atualização completa deve ocorrer **antes** da instalação do kernel CachyOS.

Regra operacional:

- primeiro atualizar todo o sistema;
- depois instalar o kernel;
- depois configurar o kernel padrão;
- depois seguir o restante do manual.

## 3. Política de kernels

O MochaArch deve manter somente estes kernels como caminho normal:

- kernel do próprio Arch;
- kernel comum do CachyOS.

O kernel comum do CachyOS passa a ser o **kernel padrão de boot do MochaArch**, até ordem explícita em contrário.

## 4. Kernels que não devem ser usados

Não usar como padrão nem instalar como parte do fluxo canônico:

- CachyOS Bore;
- CachyOS Bore LTO;
- CachyOS EEVDF LTO;
- outros kernels especiais do CachyOS;
- kernels experimentais de terceiros.

Exceção somente com ordem explícita posterior.

## 5. Pacotes-alvo do kernel CachyOS

Quando o repositório CachyOS for usado apenas para trazer o kernel, o alvo deve ser o kernel comum:

- `linux-cachyos`;
- `linux-cachyos-headers`.

Não substituir isso por variantes Bore, LTO, EEVDF ou similares.

## 6. Ordem resumida da montagem inicial

1. Iniciar o Mocha.
2. Montar FAST e VMSTORE de forma persistente e visível no Dolphin.
3. Confirmar que `/media/mochafast` e `/media/vmstore` estão acessíveis.
4. Atualizar completamente o sistema.
5. Instalar o kernel comum do CachyOS.
6. Definir o kernel comum do CachyOS como padrão de boot.
7. Manter o kernel do Arch como alternativa.
8. Seguir o restante do manual de montagem.

<!-- FIM MOCHAARCH-FLUXO-INICIAL-FAST-VMSTORE-KERNEL-CACHY-CANONICO -->
