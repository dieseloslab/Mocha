# Mocha Repo Seguro — testing/stable operacional

Data: 20260529-234741

- Base: /media/vmstore/MochaRepos
- Incoming: /media/vmstore/MochaRepos/incoming
- Testing: mocha-testing em /media/vmstore/MochaRepos/testing/x86_64
- Stable: mocha-stable em /media/vmstore/MochaRepos/stable/x86_64
- Quarentena: /media/vmstore/MochaRepos/quarantine
- Script reutilizável: /media/vmstore/MochaRepos/scripts/20260529-234741-mocha-promover-repo-seguro.sh
- Primeiro pacote real inofensivo: mocha-docs-base 0.1.20260529.234741-1
- Documento principal: /media/vmstore/MochaRepos/docs/20260529-234741-repo-seguro-testing-stable-criado.md
- Manifesto: /media/vmstore/MochaRepos/manifests/20260529-234741-repo-seguro-testing-stable-criado.txt

O teste validou incoming -> testing -> stable com pacman temporário, sem instalar nada e sem alterar /etc/pacman.conf.
