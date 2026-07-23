# Validação da implementação — 2026-07-22

## Escopo validado no ambiente de preparação

- pacote de fontes original extraído sem alterar a referência visual;
- backend gráfico ligado aos botões e indicadores existentes;
- correção do bridge CXX-Qt movido para a biblioteca compartilhada, cobrindo testes da biblioteca, binário gráfico e helper;
- correção do empréstimo Rust `E0502` na emissão do caminho do relatório;
- helper administrativo separado, com operações fixas e sem shell;
- política Polkit com caminho absoluto do helper;
- atualização geral separada de kernel, NVIDIA e do próprio `mocha-update`;
- fluxo de kernel restrito ao repositório `mocha-kernel` e aos três pacotes canônicos;
- recasamento restrito às versões exatas encontradas no cache do Pacman;
- rollback thin LVM cobrindo os volumes distintos de `/`, `/boot` e `/home`;
- merge conjunto dos snapshots depois da validação integral do ponto de restauração;
- ausência de referências ao pacote antigo proibido;
- sintaxe Bash do instalador;
- estrutura XML da política Polkit;
- balanceamento léxico de delimitadores Rust e QML;
- guia Mocha OC com modos temporário, persistente no GameMode e desativação total;
- executor fixo do OC, regra sudoers restrita e validação dos hooks canônicos;
- validação compatível com a cadeia canônica atual: hooks de autoridade, pontes legacy, scripts legacy e executor fixo do Mocha OC;
- proteção contra sobrescrita do estado original em entradas repetidas do GameMode;
- hashes SHA-256 de todos os arquivos entregues.

## Validação executada na máquina de instalação

O script `scripts/install-local.sh` executa obrigatoriamente, antes de copiar qualquer artefato para o sistema:

```text
cargo fmt --all
cargo test --all-targets
cargo build --release --bins
```

A instalação é interrompida antes de qualquer alteração caso formatação, testes, Qt 6, dependências operacionais ou compilação falhem.

## Erros do pacote anterior tratados

- correção estrutural da proteção do próprio `mocha-update`: o pacote foi removido da pilha opcional NVIDIA e incluído exatamente uma vez em `PROTECTED_GENERAL_PACKAGES`, independentemente da formatação aplicada pelo `rustfmt`;

1. Os símbolos CXX-Qt gerados eram ligados também aos alvos de teste e ao helper, mas o módulo Rust do bridge existia somente no binário gráfico. O bridge agora pertence à biblioteca compartilhada e o executável gráfico referencia explicitamente essa biblioteca.
2. `Reporter::finish` emprestava `self` de forma mutável e `self.log_path` de forma imutável na mesma chamada. O caminho agora é materializado antes de chamar `self.data`.
3. `mocha-update` foi removido da lista opcional da pilha NVIDIA e permanece apenas entre os pacotes protegidos.

## Limite do ambiente de preparação

O ambiente usado para montar este pacote não possui a cadeia Rust nem os módulos de desenvolvimento Qt 6. Por isso, a compilação CXX-Qt completa não foi executada aqui. As operações Pacman, DKMS, LVM, initramfs, GRUB e Polkit também não foram executadas fora da máquina Mocha, pois alteram o sistema real.

## Correção integral V7

- snapshots thin restritos a `/` e `/home`;
- backup transacional de `/boot` e da EFI separada, ambos com SHA-256;
- restauração de boot no mesmo reinício do merge LVM;
- PowerMizer aplicado antes dos offsets NVIDIA;
- consulta real de core e memória no status do Mocha OC;
- validação direta e pelo GameMode, incluindo reversão para `0/0`.
