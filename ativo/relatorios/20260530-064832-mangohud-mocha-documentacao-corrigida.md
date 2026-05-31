# MangoHud Mocha — auditoria e correção de documentação

- Timestamp: 20260530-064832
- Manual vivo: /media/mochafast/MochaArch/ativo/documentacao/20260529-211221-tema-mocha-aprovado-validado-e-manual-corrigido.md
- Manual alterado: sim
- Backup criado: /media/mochafast/MochaArch/ativo/documentacao/20260529-211221-tema-mocha-aprovado-validado-e-manual-corrigido.md.backup-20260530-064832.md
- Substituiu ocorrência exata de gamemoderun %command% sem MangoHud: sim
- Acrescentou seção MangoHud Mocha: sim
- Configuração canônica usada na documentação: /etc/mocha/mangohud/MangoHud.conf
- Launch Option oficial registrada: MANGOHUD=1 MANGOHUD_CONFIGFILE=/etc/mocha/mangohud/MangoHud.conf mangohud gamemoderun %command%
- Arquivo de ocorrências: /media/mochafast/MochaArch/ativo/relatorios/20260530-064832-mangohud-mocha-ocorrencias-documentacao.txt
- Arquivo de configs encontradas: /media/mochafast/MochaArch/ativo/relatorios/20260530-064832-mangohud-mocha-configs-encontradas.txt
- Script salvo: /media/mochafast/MochaArch/ativo/scripts/20260530-064832-mocha-corrigir-documentacao-mangohud.sh

## Estado antes da correção

- Manual mencionava MangoHud: sim
- Manual apontava configuração Mocha do MangoHud: sim
- Manual continha gamemoderun %command%: sim
- Manual continha a linha oficial completa calculada agora: não
- Manual continha marcador operacional aprovado: não

## Pacotes e comandos

pacman -Q mangohud gamemode:
mangohud 0.8.4-1
gamemode 1.8.2-2

command -v mangohud:
/usr/bin/mangohud

command -v gamemoderun:
/usr/bin/gamemoderun

## Regras confirmadas

- MangoHud é parte obrigatória da configuração gamer Mocha.
- GameMode sozinho não chama MangoHud.
- A linha oficial com overlay precisa chamar MangoHud e apontar para a configuração Mocha.
- MANGOHUD_DLSYM=1 não deve voltar.
- vkbasalt e gamescope não entram na linha/wrapper canônico.
