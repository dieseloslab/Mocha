# Manual específico — Barra Win11/Mocha aprovada

Pasta correta:

```text
/media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/
```

Arquivo visual aprovado:

```text
/media/mochafast/MochaArch/ativo/kde/barra-win11-aprovada/plasma-org.kde.plasma.desktop-appletsrc-aprovado-20260528-225617
```

Arquivo real do Plasma:

```text
~/.config/plasma-org.kde.plasma.desktop-appletsrc
```

Procedimento aprovado:

1. Validar que `/media/mochafast` está montado.
2. Fazer backup do arquivo real do Plasma.
3. Validar que o arquivo aprovado contém:
   - `plugin=org.kde.plasma.panelspacer`
   - `plugin=org.kde.plasma.icontasks` ou `plugin=org.kde.plasma.taskmanager`
   - `plugin=org.kde.plasma.systemtray`
   - `AppletOrder=`
4. Parar `plasmashell`.
5. Copiar o arquivo aprovado para o caminho real.
6. Reiniciar `plasmashell`.
7. Validar visualmente.

Observação importante:

A solução aprovada é o `appletsrc`. Script pode automatizar, mas a fonte visual canônica é o arquivo aprovado nesta pasta.
