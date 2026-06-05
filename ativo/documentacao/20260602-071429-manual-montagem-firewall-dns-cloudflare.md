# MochaArch — firewall, regras, atalho e DNS Cloudflare criptografado

Timestamp: 20260602-071429

## Padrão canônico

- O firewall deve ficar ativo no boot antes de entregar a montagem.
- As regras abertas devem ser documentadas a partir do estado real do firewall, sem abrir portas amplas sem necessidade.
- Perfis de jogo/Steam devem ficar controláveis pela GUI do firewall, para ativação quando necessário.
- Deve existir acesso fácil à GUI do firewall pelo KDE, preferencialmente por atalho na área de trabalho e/ou menu.
- DNS criptografado Cloudflare deve ser DNS-over-TLS via systemd-resolved quando esse for o backend ativo.
- Cloudflare DoT é somente DNS criptografado; não é VPN.

## Servidores Cloudflare DoT canônicos

- 1.1.1.1#one.one.one.one
- 1.0.0.1#one.one.one.one
- 2606:4700:4700::1111#one.one.one.one
- 2606:4700:4700::1001#one.one.one.one

## Auditoria do estado real no momento do registro

### firewalld — estado do serviço

Comando auditado: systemctl status firewalld.service --no-pager

● firewalld.service - firewalld - dynamic firewall daemon
     Loaded: loaded (/usr/lib/systemd/system/firewalld.service; enabled; preset: disabled)
     Active: active (running) since Tue 2026-06-02 07:04:36 -03; 9min ago
 Invocation: 632f824496884896b3b2ba7040252a38
       Docs: man:firewalld(1)
   Main PID: 666 (firewalld)
      Tasks: 2 (limit: 18775)
     Memory: 37.5M (peak: 37.8M)
        CPU: 496ms
     CGroup: /system.slice/firewalld.service
             └─666 /usr/bin/python /usr/bin/firewalld --nofork --nopid

jun 02 07:04:36 Mocha systemd[1]: Started firewalld - dynamic firewall daemon.

### firewalld — estado runtime

Comando auditado: firewall-cmd --state

running

### firewalld — zona padrão

Comando auditado: firewall-cmd --get-default-zone

mocha-home

### firewalld — regras da zona padrão

Comando auditado: firewall-cmd --list-all

mocha-home (default, active)
  target: default
  ingress-priority: 0
  egress-priority: 0
  icmp-block-inversion: no
  interfaces: enp4s0
  sources: 
  services: 
  ports: 
  protocols: 
  forward: no
  masquerade: no
  forward-ports: 
  source-ports: 
  icmp-blocks: 
  rich rules: 

### systemd-resolved — estado

Comando auditado: systemctl status systemd-resolved.service --no-pager

● systemd-resolved.service - Network Name Resolution
     Loaded: loaded (/usr/lib/systemd/system/systemd-resolved.service; enabled; preset: enabled)
     Active: active (running) since Tue 2026-06-02 07:04:34 -03; 9min ago
 Invocation: 2acdd677c56e4f299b0221d0c4ce66d6
TriggeredBy: ● systemd-resolved-varlink.socket
             ● systemd-resolved-monitor.socket
       Docs: man:systemd-resolved.service(8)
             man:org.freedesktop.resolve1(5)
             https://systemd.io/WRITING_NETWORK_CONFIGURATION_MANAGERS
             https://systemd.io/WRITING_RESOLVER_CLIENTS
   Main PID: 458 (systemd-resolve)
     Status: "Processing requests..."
      Tasks: 1 (limit: 18775)
     Memory: 7.9M (peak: 9.3M)
        CPU: 136ms
     CGroup: /system.slice/systemd-resolved.service
             └─458 /usr/lib/systemd/systemd-resolved

jun 02 07:04:34 Mocha systemd[1]: Starting Network Name Resolution...
jun 02 07:04:34 Mocha systemd-resolved[458]: Positive Trust Anchors:
jun 02 07:04:34 Mocha systemd-resolved[458]: . IN DS 20326 8 2 e06d44b80b8f1d39a95c0b0d7c65d08458e880409bbc683457104237c7f8ec8d
jun 02 07:04:34 Mocha systemd-resolved[458]: . IN DS 38696 8 2 683d2d0acb8c9b712a1948b27f741219298d0a450d612c483af444a4c0fb2b16
jun 02 07:04:34 Mocha systemd-resolved[458]: Negative trust anchors: home.arpa 10.in-addr.arpa 16.172.in-addr.arpa 17.172.in-addr.arpa 18.172.in-addr.arpa 19.172.in-addr.arpa 20.172.in-addr.arpa 21.172.in-addr.arpa 22.172.in-addr.arpa 23.172.in-addr.arpa 24.172.in-addr.arpa 25.172.in-addr.arpa 26.172.in-addr.arpa 27.172.in-addr.arpa 28.172.in-addr.arpa 29.172.in-addr.arpa 30.172.in-addr.arpa 31.172.in-addr.arpa 170.0.0.192.in-addr.arpa 171.0.0.192.in-addr.arpa 168.192.in-addr.arpa d.f.ip6.arpa ipv4only.arpa resolver.arpa corp home internal intranet lan local private test
jun 02 07:04:34 Mocha systemd-resolved[458]: Using system hostname 'Mocha'.
jun 02 07:04:34 Mocha systemd[1]: Started Network Name Resolution.
jun 02 07:04:41 Mocha systemd-resolved[458]: enp4s0: Bus client set default route setting: yes
jun 02 07:04:41 Mocha systemd-resolved[458]: enp4s0: Bus client set DNS server list to: fe80::1
jun 02 07:04:43 Mocha systemd-resolved[458]: enp4s0: Bus client set DNS server list to: 192.168.100.1, fe80::1

### resolvectl — DNS ativo

Comando auditado: resolvectl status

Global
           Protocols: -LLMNR +mDNS +DNSOverTLS DNSSEC=no/unsupported
    resolv.conf mode: stub
  Current DNS Server: 1.1.1.1#cloudflare-dns.com
         DNS Servers: 1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com
                      2606:4700:4700::1111#cloudflare-dns.com
                      2606:4700:4700::1001#cloudflare-dns.com
Fallback DNS Servers: 1.1.1.1#cloudflare-dns.com 1.0.0.1#cloudflare-dns.com
          DNS Domain: ~.

Link 2 (enp4s0)
    Current Scopes: DNS mDNS/IPv4 mDNS/IPv6
         Protocols: +DefaultRoute -LLMNR +mDNS +DNSOverTLS DNSSEC=no/unsupported
Current DNS Server: 192.168.100.1
       DNS Servers: 192.168.100.1 fe80::1%2
     Default Route: yes

### Atalhos de firewall encontrados

Diretório auditado: /home/hal/Área de trabalho
- /home/hal/Área de trabalho/mocha-firewall-gui.desktop
- /home/hal/Área de trabalho/mocha-firewall-gamer-local-off.desktop
- /home/hal/Área de trabalho/mocha-firewall-gamer-local-on.desktop
- /home/hal/Área de trabalho/mocha-firewall-status.desktop
- /home/hal/Área de trabalho/mocha-firewall-steam-off.desktop
- /home/hal/Área de trabalho/mocha-firewall-steam-on.desktop
Diretório auditado: /home/hal/.local/share/applications
- /home/hal/.local/share/applications/mocha-firewall-gui.desktop
- /home/hal/.local/share/applications/mocha-firewall-steam-on.desktop
- /home/hal/.local/share/applications/mocha-firewall-steam-off.desktop
- /home/hal/.local/share/applications/mocha-firewall-gamer-local-on.desktop
- /home/hal/.local/share/applications/mocha-firewall-gamer-local-off.desktop
- /home/hal/.local/share/applications/mocha-firewall-status.desktop
