# GameMode, system76-scheduler, TuneD e OC NVIDIA — payload de instalação

Estado: cadeia validada em runtime em 2026-07-10 no host `derp-x8664`.

O nome do diretório `gamemode-oc-nvidia-nvml` é histórico. O runtime aprovado atual usa NV-CONTROL por `nvidia-settings`, chamado pelo helper root do OC. Não renomear o diretório sem migração separada e aprovada.

## Ordem operacional

1. Fora do GameMode, `com.system76.Scheduler.service` permanece ativo, o OC fica em `0/0` e o TuneD mantém `mocha-latency-performance`.
2. No início do GameMode, o wrapper de autoridade chama `mocha-system76-authority-helper start`, suspende o scheduler e depois executa o start legacy do OC.
3. O start legacy solicita `core +50` e `MEMORY_TRANSFER_RATE_OFFSET=400`, cujo efeito real esperado é aproximadamente `+200 MHz` na memória.
4. No fim do GameMode, o end legacy restaura `core 0 / memória 0`.
5. O wrapper end reasserta o TuneD, encerra a autoridade, religa o scheduler somente se ele estava ativo antes e reasserta o TuneD novamente.

## Artefatos runtime preservados

- `/etc/mocha/nvidia-game-oc.conf`
- `/etc/sudoers.d/mocha-nvidia-oc-root-helper`
- `/usr/local/lib/mocha/mocha-nvidia-oc-root-helper`
- `/usr/local/sbin/mocha-system76-authority-helper`
- `/etc/sudoers.d/mocha-gamemode-system76-authority`
- `/usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system`
- `/usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system`
- `/usr/local/lib/mocha/gamemode-start-agressivo-oc.sh`
- `/usr/local/lib/mocha/gamemode-end-agressivo-oc.sh`
- `/etc/mocha/gamemode/legacy-start-system.cmd`
- `/etc/mocha/gamemode/legacy-end-system.cmd`
- `/etc/gamemode.ini`

## Integração obrigatória do GameMode

```ini
[custom]
start=/usr/local/lib/mocha/performance/mocha-gamemode-start-authority-system
end=/usr/local/lib/mocha/performance/mocha-gamemode-end-authority-system
```

Os nomes `gamemode-start-agressivo-oc.sh` e `gamemode-end-agressivo-oc.sh` permanecem apenas porque são os artefatos reais aprovados preservados como legacy. Eles não devem voltar a ser apontados diretamente por `/etc/gamemode.ini`.

Não substituir nenhum item por equivalente aproximado. Alterações futuras exigem teste real completo de GameMode, scheduler, OC e `tuned-adm verify`.
