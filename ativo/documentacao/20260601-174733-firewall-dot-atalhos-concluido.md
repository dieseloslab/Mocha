# MochaArch — firewall e DNS-over-TLS concluídos

Timestamp: 20260601-174733

## Estado aprovado para teste

- firewalld ativo e habilitado.
- plasma-firewall instalado para integração KDE.
- firewall-config instalado como GUI alternativa do firewalld.
- Zona padrão: mocha-home.
- Entrada fechada por padrão.
- Saída permitida.
- Steam Remote Play não fica aberto por padrão.
- Atalho para GUI do firewall criado na Área de Trabalho.
- Atalhos para ativar/desativar Steam Remote Play criados.
- Atalhos para ativar/desativar Rede Local Gamer criados.
- DNS criptografado via Cloudflare DNS-over-TLS configurado com systemd-resolved.

## Serviços Mocha disponíveis

- mocha-steam-remoteplay: UDP 27031, UDP 27036, TCP 27036, TCP 27037.
- mocha-steam-vr: UDP 10400, UDP 10401.
- mocha-kde-connect: TCP/UDP 1714-1764.
- mocha-mdns: UDP 5353.

## Atalhos

- Mocha Firewall - Interface Gráfica.
- Mocha Firewall - Ativar Steam Remote Play.
- Mocha Firewall - Desativar Steam Remote Play.
- Mocha Firewall - Ativar Rede Local Gamer.
- Mocha Firewall - Desativar Rede Local Gamer.
- Mocha Firewall - Status.

## Caminhos

- Área de Trabalho: /home/hal/Área de trabalho
- Menu: /home/hal/.local/share/applications
- Log: /media/mochafast/MochaArch/ativo/relatorios/20260601-174733-concluir-firewall-dot-atalhos-pos-invalid-zone.log
