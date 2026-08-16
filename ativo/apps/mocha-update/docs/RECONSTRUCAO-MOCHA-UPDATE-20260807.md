# Mocha Update — reconstrução consolidada

Este pacote é a fonte canônica para reinstalação e manutenção do Mocha Update.

## Contrato de canais

| Fluxo | Origem autorizada | Regra |
|---|---|---|
| Atualização do Sistema | `https://updates.dieseloslab.org`, canal `stable` | Nunca instala kernel, headers, NVIDIA ou `mocha-update`. |
| Kernel e Driver (padrão) | `https://repo.dieseloslab.org/stable/x86_64`, repositório `mocha-kernel` | Instala apenas `linux-mocha-lqx*` e a pilha NVIDIA associada, após validação GPG. |
| Kernel oficial Arch (opcional) | repositórios oficiais Arch já configurados | Só é acionado pelo botão próprio; coexiste com o kernel Mocha. |

`[liquorix]` e `linux-lqx` não fazem parte da configuração permitida do Mocha.

## Regra de segurança da atualização normal

A classificação de proteção bloqueia tanto os nomes canônicos quanto qualquer
família `linux-*`, `nvidia*`, `lib32-nvidia*` e `opencl-nvidia*`. Antes de
executar `pacman -Syu`, o executor acrescenta ao `--ignore` todos os pacotes
protegidos que a própria consulta encontrou. Assim, uma variante imprevista
como `linux-lqx` não atravessa a tela de atualização normal.

## Validação antes da instalação

No diretório do pacote, execute:

```bash
./scripts/validar-pacote-reconstruido.sh
./scripts/install-local.sh
```

O segundo comando exige as dependências já documentadas no instalador e cria
backup dos arquivos instalados antes de substituí-los.
