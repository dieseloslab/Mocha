# REGRA CANÔNICA — MOCHAARCH — FIREWALL, IP FIXO E DNS CLOUDFLARE DOT

Esta regra é padrão permanente do MochaArch.

Sempre que o MochaArch for montado, devem ser aplicados e validados:

- UFW e GUFW instalados;
- firewall ativo;
- entrada bloqueada por padrão;
- saída liberada por padrão;
- perfis Steam disponíveis, mas fechados por padrão;
- atalho para GUI do firewall;
- atalho para liberar regras Steam;
- atalho para fechar regras Steam;
- IPv4 manual/fixo no perfil ativo quando aplicável;
- Cloudflare DNS-over-TLS via systemd-resolved;
- NetworkManager integrado ao systemd-resolved;
- DNS automático do roteador ignorado.

As portas Steam não devem ficar abertas permanentemente. Elas devem ser acionadas por perfil/atalho apenas quando necessário.
