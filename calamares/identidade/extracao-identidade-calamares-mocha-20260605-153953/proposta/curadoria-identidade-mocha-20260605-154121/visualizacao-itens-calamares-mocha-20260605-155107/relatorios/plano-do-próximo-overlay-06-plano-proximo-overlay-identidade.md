# Plano do próximo overlay de identidade Calamares Mocha

## Estado atual

Extração usada:

- /media/mochafast/MochaArch/calamares/identidade/extracao-identidade-calamares-mocha-20260605-153953

Arquivos já separados:

- imagens/
- textos/
- slideshow-welcome/
- yaml-configs/
- manifestos/
- proposta/

## Próxima ação segura

A próxima etapa não deve gerar airootfs.sfs ainda.

A próxima etapa deve criar um overlay de proposta contendo apenas:

1. branding.desc ajustado para Mocha;
2. show.qml/slideshow com textos próprios;
3. welcome.conf revisado;
4. imagens substituídas por logo e wallpaper Mocha;
5. traduções iniciais em inglês e português;
6. estrutura preparada para futuras traduções;
7. validação YAML/QML;
8. aplicação em cópia de airootfs;
9. auditoria visual/textual;
10. somente depois empacotar novo airootfs.sfs.

## Restrições

- Não mexer em kernel.
- Não mexer em boot.
- Não mexer em SDDM funcional fora do escopo do Calamares.
- Não mexer no wrapper Steam.
- Não mexer em firewall.
- Não oferecer GNOME/XFCE/MATE/Cinnamon/Budgie/Deepin/i3/Openbox.
- Não usar português como fallback global.
- Não copiar texto literal da ISO base.

## Relatórios gerados nesta curadoria

- 01-arquivos-criticos-calamares.txt
- 02-residuos-e-alvos-de-reescrita.tsv
- 03-amostra-textos-editaveis.txt
- 04-inventario-imagens.txt
- 05-proposta-textos-base-mocha.md
- 06-plano-proximo-overlay-identidade.md
