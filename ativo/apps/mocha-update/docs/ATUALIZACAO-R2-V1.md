# Motor de atualizações Mocha via R2 — contrato V1

## Objetivo

O Mocha Update consulta um único catálogo assinado e classifica cada item em:

- `application`: atualização do próprio Mocha Update;
- `component`: wrapper da Steam e outros componentes Mocha versionados;
- `content`: links de apoio, patrocinadores, textos e recursos remotos.

Atualizações normais do Arch Linux, kernel e driver continuam em fluxos separados.

## Endpoint

Endpoint público proposto: `https://updates.dieseloslab.org` ligado a um bucket
Cloudflare R2 somente para leitura pública. O cliente busca objetos por caminho
exato; não depende de listagem do bucket.

Objetos iniciais:

- `stable/catalog-v1.json`
- `stable/catalog-v1.json.asc`
- `stable/application/...`
- `stable/component/...`
- `stable/content/...`

## Cadeia de confiança

1. baixar catálogo e assinatura para arquivos temporários;
2. validar a assinatura destacada com `gpgv` e um keyring instalado localmente;
3. analisar o catálogo com o parser Rust;
4. recusar IDs que não estejam na allowlist local;
5. baixar o artefato indicado;
6. conferir tamanho, SHA-256 e assinatura do artefato;
7. extrair em staging sem aceitar caminhos absolutos, `..` ou links externos;
8. executar o validador local do componente;
9. ativar a nova versão por troca atômica;
10. preservar a versão anterior para reversão.

O catálogo remoto nunca define destinos arbitrários do sistema. Destinos,
validadores e necessidade de privilégio pertencem à allowlist local instalada
com o Mocha Update.

## Regras V1

- esquema aceito: `1`;
- canais aceitos: `stable` e `testing`;
- arquiteturas aceitas: `x86_64` e `any`;
- versões usam SemVer;
- hashes usam SHA-256 minúsculo com 64 caracteres;
- artefatos usam caminhos relativos dentro do bucket;
- um ID aparece no máximo uma vez por catálogo;
- downgrade não é instalado automaticamente;
- `mocha-update` é o único ID aceito como `application`;
- componentes desconhecidos são recusados antes do download;
- nenhuma operação é executada como root durante a consulta do catálogo.

## Etapas seguintes

1. integrar consulta assíncrona ao backend Rust/QML;
2. criar helper privilegiado específico para staging e ativação;
3. instalar keyring público de releases;
4. implementar download, assinatura e SHA-256;
5. implementar troca atômica e rollback;
6. acrescentar a tela “Atualizações Mocha”;
7. criar empacotador e publicador para o R2;
8. incluir os novos artefatos no instalador local e no payload do Calamares.
