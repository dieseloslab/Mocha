# Mocha Update: consolidação de kernel e OC — 04/10/2026

A interface identifica o pacote proprietário do kernel iniciado pelo Pacman, usando pkgbase. O recasamento do kernel atual confere os headers, sua origem em /usr e a versão do pacote, identifica a fonte NVIDIA DKMS pela lista de arquivos instalada e valida cada linha DKMS de forma exata. O kernel fallback e Recovery permanecem sob as entradas de boot existentes.

O canal de instalação continua sendo mocha-kernel. Seus pacotes publicados linux-mocha-lqx são candidatos do repositório, e não um critério para declarar ausência das famílias GCC e Clang locais. Alterar a nomenclatura do repositório exige uma publicação correspondente; esta correção não publica pacotes remotos.

O OC usa exclusivamente o backend NVML e só fica habilitado mediante preferência temporária ou OC_ENABLED=1 persistente. Instaladores não distribuem preferência permanente. Toda a cadeia (hooks, pontes, scripts, wrapper, NVML e sudoers) faz parte do payload, recebe modos e donos corretos e é validada antes de anunciar sucesso. O instalador interno antigo delega ao instalador consolidado, impedindo retorno ao NV-CONTROL.

A configuração GameMode é mesclada somente na seção custom para os hooks canônicos, preservando os demais ajustes. Nenhum comando de instalação aplica ou remove offsets; status e check-oc são consultas.

O fonte e o payload ficam em ativo. Os executáveis instalados ficam em /usr e os arquivos operacionais em /etc ou /run. A instalação recusa dependências dinâmicas/RPATH em /media ou /mnt. Logs ficam em ~/Documentos e backup de executáveis e fontes em /var/backups/mocha.

Validação preparada: oito testes Rust do inventário, testes Cargo de todos os alvos, compilação release de todos os executáveis, backend C com -Wall -Wextra -Werror, hashes do payload, donos/modos/sudoers e consulta NVML. A aplicação exige que os testes e a compilação tenham êxito antes de substituir o runtime. Cinco cenários da instalação da cadeia foram simulados no ambiente de preparação.
