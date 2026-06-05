# Manual MochaArch - SDDM Login

## Estado funcional aprovado

Em 20260602-191845, o login SDDM funcionou sem reiniciar a máquina usando configuração limpa com Breeze em Wayland.
O fundo do login permaneceu com o papel de parede do Mocha.

Configuração funcional:

```ini
[Theme]
Current=breeze

[General]
DisplayServer=wayland
GreeterEnvironment=QT_WAYLAND_SHELL_INTEGRATION=layer-shell

[Wayland]
CompositorCommand=kwin_wayland --drm --no-lockscreen --no-global-shortcuts --locale1
```

Regra:
- Este estado é o fallback funcional do login.
- Não substituir por tema customizado sem auditoria e teste controlado.
- O login deve permanecer em Wayland.
- O visual do login deve continuar sincronizado com o papel de parede Mocha quando possível, sem sacrificar funcionamento.
