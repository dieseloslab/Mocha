# Roteiro Calamares para MochaArch

Decisão inicial:
- O Calamares será tratado como instalador da ISO/live.
- A máquina atual é ambiente de desenvolvimento, não molde cego.
- As configs ficam versionadas dentro de /media/mochafast/MochaArch/calamares/mocha-calamares.
- A cópia para /etc/calamares só deve ocorrer em ambiente live/ISO ou teste controlado.

Fluxo esperado da instalação:
1. welcome
2. locale
3. keyboard
4. partition
5. users
6. summary
7. mount
8. unpackfs ou pacstrap/script controlado, conforme decisão do método da ISO
9. fstab
10. locale e keyboard no alvo instalado
11. users
12. displaymanager com SDDM Wayland
13. initramfs
14. bootloader
15. pós-instalação Mocha
16. finished

Pontos críticos:
- SDDM funcional aprovado: Breeze + Wayland + fundo Mocha.
- Não usar X11 como fallback.
- Não trocar GRUB/boot sem teste em VM.
- Não incluir rclone pessoal na ISO pública.
- Não incluir contas pessoais, tokens, caches, chaves SSH ou nuvens.
- Não usar pacotes de kernel especiais sem pinagem e validação.
- Mocha Gamer é o perfil padrão.
