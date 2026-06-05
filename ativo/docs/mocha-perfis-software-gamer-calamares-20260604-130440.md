# Adendo MochaArch — Perfis de software e perfil Gamer padrão

Estado aprovado:
A instalação atual foi limpa para o perfil Mocha Gamer.

Resultado validado:
- Foram removidos 68 pacotes fora do perfil gamer.
- O total removido foi de aproximadamente 767,19 MiB.
- Nenhum pacote bloqueado permaneceu na transação corrigida.
- A lista final de pacotes não-gamer instalados ficou vazia.
- Os jogos casuais mantidos no perfil gamer são:
  - kmahjongg
  - kpat
  - kigo

Regra canônica:
O perfil padrão da ISO Mocha Gamer deve instalar os softwares gamer, criação básica e utilitários essenciais, mas não deve trazer por padrão os grupos de aplicativos KDE de educação, PIM, escritório redundante ou jogos casuais completos.

Perfis separados para Calamares:
- Mocha Gamer: perfil padrão.
- Mocha Criador: ferramentas opcionais de criação de conteúdo.
- Mocha Escritório: suíte de escritório alternativa, PIM, e-mail, agenda, digitalização, acesso remoto e produtividade.
- Mocha Escola: aplicativos educacionais KDE e softwares didáticos.

Jogos casuais:
Manter somente:
- kmahjongg
- kpat
- kigo

Remover do perfil gamer:
- kde-games-meta
- kde-education-meta
- kde-pim-meta
- jogos KDE casuais fora da lista mantida
- KDE PIM completo
- aplicativos educacionais KDE
- suítes redundantes fora do perfil escolhido

Regra de segurança:
Órfãos após limpeza devem ser apenas auditados. Não remover automaticamente sem auditoria específica, porque alguns podem ser bibliotecas ainda úteis para KDE, Qt, OnlyOffice ou ferramentas instaladas.

Arquivos de perfil:
- /media/mochafast/MochaArch/ativo/software/perfis/mocha-gamer-default.pkglist
- /media/mochafast/MochaArch/ativo/software/perfis/mocha-criador.pkglist
- /media/mochafast/MochaArch/ativo/software/perfis/mocha-escritorio.pkglist
- /media/mochafast/MochaArch/ativo/software/perfis/mocha-escola.pkglist
- /media/mochafast/MochaArch/ativo/software/perfis/mocha-jogos-casuais-manter.pkglist
- /media/mochafast/MochaArch/ativo/software/perfis/mocha-jogos-casuais-remover-do-gamer.pkglist
- /media/mochafast/MochaArch/ativo/software/perfis/mocha-perfis-calamares-notas.txt

Observação:
vkBasalt e Gamescope podem existir no sistema como ferramentas gamer opcionais, mas não entram no wrapper canônico Steam/Mocha nem nas Launch Options padrão, salvo ordem explícita de teste.
