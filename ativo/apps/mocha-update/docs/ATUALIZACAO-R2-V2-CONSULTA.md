# Motor de atualizações Mocha via R2 — consulta autenticada V2

## Escopo implementado

A V2 acrescenta um cliente de consulta que:

1. lê uma configuração local sem executar seu conteúdo;
2. aceita somente endpoint HTTPS;
3. baixa apenas o catálogo e sua assinatura destacada;
4. restringe protocolo e redirecionamentos a HTTPS;
5. impõe limites de tamanho;
6. verifica a assinatura com `gpgv` e keyring local;
7. chama o classificador Rust da V1;
8. grava no cache somente catálogos já autenticados e aceitos;
9. substitui os arquivos do cache por movimentação atômica;
10. falha sem modificar o sistema em qualquer divergência.

## Modos

- `--validate-config`: valida o contrato local do endpoint;
- `--local`: valida catálogo e assinatura fornecidos localmente;
- `--remote`: baixa do domínio R2, verifica e classifica.

## Limites desta etapa

A V2 não baixa os artefatos descritos pelo catálogo, não instala componentes,
não altera a interface gráfica e não modifica a instalação ativa. O teste usa
uma chave GPG temporária e um catálogo local, portanto não depende de o domínio
`updates.dieseloslab.org` já estar publicado.

## Próximas etapas

1. criar a chave oficial de assinatura de releases e instalar somente sua chave pública;
2. gerar automaticamente o estado real dos componentes instalados;
3. integrar a consulta ao backend assíncrono e à interface;
4. publicar um catálogo de homologação no R2;
5. implementar download e validação dos artefatos;
6. implementar staging, ativação atômica e reversão.
