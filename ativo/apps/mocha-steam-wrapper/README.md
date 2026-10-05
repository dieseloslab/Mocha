# Mocha Steam: cadeia canônica

Fontes copiadas do sistema instalado e auditadas em 04/10/2026.

| Fonte em `files` | Destino instalado | Função |
| --- | --- | --- |
| `usr/local/bin/mocha-steam-game-run` | `/usr/local/bin/mocha-steam-game-run` | Entrada Steam e ambiente MangoHud |
| `usr/local/lib/mocha/mocha-steam-game-run-alt-tab-core` | `/usr/local/lib/mocha/mocha-steam-game-run-alt-tab-core` | Correção input/Alt+Tab e GameMode |
| `usr/local/lib/mocha/mocha-steam-profile-loader` | `/usr/local/lib/mocha/mocha-steam-profile-loader` | Perfis por AppID, lidos sem executar configurações |

Os três arquivos instalados são independentes dos discos FAST e VM. Usam os caminhos do sistema em `/usr/local`; perfis ficam em `/usr/local/share/mocha/steam-profiles` e nos diretórios XDG do usuário.

A opção de lançamento é `/usr/local/bin/mocha-steam-game-run %command%`. A receita específica da biblioteca da matriz é versionada somente no repositório privado Mocha-Interno. Ela cria perfis ausentes e preserva os existentes; não instala os três wrappers. Seus registros de montagem são escritos somente nos manuais canônicos do Interno/ativo.

Verificações: sintaxe Bash e cinco cenários isolados — ausência de comando, preservação de argumentos e passagem pelo GameMode, prefixo já corrigido, padrões sem limite FPS e validação de perfis sem execução de conteúdo. Estes testes não substituem testes reais em jogos.

