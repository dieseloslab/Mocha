# MochaArch Calamares

Objetivo: preparar o Calamares como instalador gráfico do MochaArch, preservando a instalação atual e evitando mudanças destrutivas durante o desenvolvimento.

Princípios:
- Não mexer no SDDM, GRUB, boot ou tema da máquina atual por dedução.
- Não clonar cegamente o sistema atual para o usuário final.
- Usar uma instalação limpa, reproduzível e documentada.
- Separar perfil público ISO de itens pessoais/laboratório.
- Manter Mocha Gamer como perfil padrão, salvo ordem explícita.
- Usar Calamares com branding Mocha, particionamento, usuários, locale, fstab, initramfs, bootloader e pós-instalação controlada.
- Testar em VM antes de qualquer uso em máquina real.

Fases:
1. Auditoria de pacote Calamares e módulos disponíveis.
2. Esqueleto local de configuração.
3. Definição do rootfs/install target.
4. Integração com archiso.
5. Teste em VM.
6. Ajuste de branding e perfis.
7. Validação de instalação UEFI.
8. Registro no manual e commit.
