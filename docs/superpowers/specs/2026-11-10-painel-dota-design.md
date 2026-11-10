# painel-dota: especificação de design

Data: 2026-11-10 · Revisão 2 · Situação: **rascunho para revisão da pessoa** · Nível no kit `padroes-de-qualidade`: 2

## 1. Entendimento

**O que a pessoa pediu (suas palavras):** um site de estatísticas e métricas de Dota 2, com **dados reais** da API,
**útil para jogadores**, fácil de ser **encontrado** na busca, em **vários idiomas** (os dos países que mais jogam),
bem **linkado**, dentro dos padrões de qualidade do Google "e até mais um pouco". Como guia de funções ela indicou o
Dota2ProTracker e o OP.GG, com **visual bem diferente**. O site precisa **sempre mostrar a versão mais atual do jogo**,
permitir **navegar entre versões** e mostrar **builds**. Ela quer "tudo e mais um pouco": estatísticas **mais completas e
mais simples de entender** do que as dos concorrentes.

**Objetivos de aprendizado:** consumir uma API, guardar em banco, criar a própria API, testar, proteger, publicar.
A pessoa é iniciante: parte do código ela escreve sozinha, guiada (seção 11). Orçamento zero.

**Critérios de sucesso:**
1. Um jogador digita o ID da própria conta e recebe um diagnóstico em português baseado nas partidas reais dele.
2. Quando sai uma versão nova do jogo, o site passa a mostrá-la sozinho (sem deploy manual) e as versões anteriores continuam navegáveis.
3. Cada herói tem página com estatísticas da versão e builds de itens e de habilidades (sujeito à seção 4).
4. As páginas públicas abrem rápido, passam no Lighthouse com 95 ou mais e estão prontas para indexação.
5. O repositório tem testes sem internet, CI verde e nenhum dado pessoal real.
6. A pessoa consegue explicar com as próprias palavras cada camada do projeto.

**Suposições minhas (corrija no que estiver errado):**
- O ID numérico da conta (ID de amigo do Dota) basta como forma de busca na primeira versão.
- Inglês entra logo depois do português (versão 1.1), não junto.
- "Tudo e mais um pouco" é o **destino**, entregue em fases (seção 2); a versão 1 precisa ser pequena o bastante para ser publicada.
- Nenhuma regra garante posição no Google. O projeto entrega a base técnica e conteúdo útil; a posição depende de tempo e de links de outros sites.

## 2. Mapa de funções e fases

Base: o que o Dota2ProTracker mostra na página inicial (lida em 2026-11-10), as funções típicas do OP.GG e extras nossos.
O OP.GG **não cobre Dota 2** na página inicial; serve de modelo das funções do League of Legends (busca de jogador,
estatísticas por faixa de rank, ranking, busca de vários jogadores, notas de versão).

| Fase | Funções |
| --- | --- |
| **1 (versão 1)**, em fatias que podem ser publicadas sozinhas | **Versões do jogo:** detectar a mais recente, navegar entre versões. **Meta por versão:** taxa de vitória, de escolha e de disputa, por faixa de rank e por posição (conforme a fonte), Radiant contra Dire, heróis em alta. **Página do herói:** builds de itens e de habilidades. **Busca de jogador** por ID e **diagnóstico em pt-BR**. **Explicação simples de cada métrica** e aviso de amostra pequena. |
| **1.1** | Inglês em todas as páginas. |
| **2** | Evolução do jogador ao longo do tempo. Mudanças de cada herói entre versões cruzadas com a variação da taxa de vitória (o que mudou e o que isso causou). |
| **3** | Confrontos, counters e sinergias. |
| **4** | Comparar dois jogadores e dois heróis. Builds fora do meta. |
| **5** | Demais idiomas (ru, es, zh-Hans, id, uk), cada um só com tradução revisada. Partidas profissionais e torneios, se a fonte permitir. Nota própria dos heróis, com fórmula pública (não copiar a de outro site). |

**Fora de escopo:** contas e login, pagamento, anúncios, comentários, busca por apelido (expõe dado pessoal), transmissões
ao vivo e vídeos incorporados (recursos de terceiros; só links para fora), acompanhamento de partida ao vivo.

**Diferencial:** o Dota2ProTracker, segundo a página inicial, usa partidas de MMR 7000 ou mais e profissionais. Se a fonte
permitir faixas de rank mais baixas, o painel serve também o jogador comum. Cada número vem com explicação em português
("o que isso significa", "quantas partidas há por trás").

## 3. Dado real e dado fictício

| Onde | Dados |
| --- | --- |
| O site em funcionamento | **Reais**, vindos da API |
| Repositório, testes, exemplos, capturas de tela | **Só fictícios** (IDs e apelidos inventados) |

Motivo: ID e apelido de jogador real são dado pessoal (LGPD) e não devem ficar guardados no GitHub nem nos testes.

## 4. Fonte de dados

**Correção:** eu havia dito que os grandes sites "não consomem uma API pública". Isso era amplo demais. Segundo a página
inicial, o Dota2ProTracker usa as APIs **Imprint e STRATZ** para enriquecer os dados. Do Dotabuff e do OP.GG não consegui
confirmar a origem.

**Decisão:** uma interface própria (`FonteDeDados`) isola o resto do projeto da API usada. **Qual API serve para cada função
é decidido na Etapa 0**, com chamadas reais feitas na máquina da pessoa (que tem internet), e registrado em
`docs/api-fontes.md` com a evidência. Regra de decisão: **uma única fonte, se ela cobrir tudo da fase 1; duas só se for
inevitável**, porque cada fonte a mais dobra clientes, testes e manutenção.

| Candidata | Prós | Contras |
| --- | --- | --- |
| OpenDota (REST) | Código aberto (MIT), JSON simples, serve para aprender; os dados vêm da API da Valve e de replays processados | Limites gratuitos não confirmados; mantida pelo projeto da comunidade, sem garantia de serviço |
| STRATZ (GraphQL, token) | Usada por um dos sites de referência; dados ricos de análise | Exige token; em artigo de 2021 exigia tráfego de volta ao site deles (pode ter mudado); GraphQL é outro assunto para aprender |
| Steam Web API (Valve) | Fonte oficial | Dados brutos, sem estatísticas processadas |

**A Etapa 0 verifica, para cada função, qual fonte entrega** (marcar sim, não ou parcial, com a chamada que prova):

1. Lista de versões do jogo com data de lançamento, incluindo as com letra (como 7.41d e 7.41f).
2. Estatísticas de herói **por versão** (ou por intervalo de datas desde o lançamento), por faixa de rank e por posição.
3. Builds de itens por herói (início, meio e fim de jogo) e builds de habilidades (ordem de evolução) com frequência e, se houver, taxa de vitória.
4. Partidas recentes e estatísticas de um jogador; referências de comparação (benchmarks).
5. Limites gratuitos, regras de uso e atribuição, e o efeito de "Expose Public Match Data" (o jogador precisa ativá-lo, senão não há dados).

**Consequências se algo não for entregue:** sem estatísticas por versão, o painel guarda **retratos periódicos** e o histórico
começa no dia da primeira coleta (dito com clareza na tela). Sem builds de habilidades agregadas, a versão 1 entrega os
builds de itens e deixa os de habilidades para depois, porque calcular a partir de partidas uma a uma não cabe nos limites
gratuitos.

Os limites que vi (2.000 chamadas por dia e 60 por minuto para a OpenDota, num SDK de terceiros; 2.000 por hora para o
STRATZ, em artigo de 2021) **não estão confirmados**. A documentação oficial não abre nas ferramentas desta sessão (E-017).
Se algo contradisser esta especificação, ela é corrigida antes de qualquer código.

## 5. Arquitetura (híbrida, aprovada)

- **Coletor agendado** (`coletor/`): roda no CI em horário fixo (a cada 6 horas, ajustável). Pergunta à fonte qual é a versão
  mais recente; se for nova, cria o registro dela e passa a guardar retratos das estatísticas **por versão**. Também atualiza
  heróis, meta e builds. É isso que faz o site seguir o jogo sozinho.
- **Registro de versões** (tabela `versao`): identificador (como `7.41f`), data de lançamento, se é a atual.
- **Gerador do site estático** (`site/`, Python com Jinja2): lê o banco e produz HTML pronto para cada idioma e cada versão.
  Publicado de graça no GitHub Pages depois de cada coleta.
- **API própria** (`api/`, FastAPI): busca jogador, calcula diagnóstico, rota `/saude`, rota de exclusão (seção 8).
- **Cliente da fonte** (`api/fonte/`): implementa `FonteDeDados` com `httpx`, com tempo limite, nova tentativa com espera,
  respeito aos limites e tratamento de resposta inesperada.
- **Banco** (SQLAlchemy 2 e Alembic): SQLite no início, PostgreSQL depois. Guarda versões, estatísticas por versão, builds,
  cache de jogadores.
- **Diagnóstico** (`api/diagnostico/`): funções puras que recebem estatísticas e devolvem identificadores de achados
  (sem texto). O texto vem do arquivo de tradução. Regras determinísticas e testáveis; amostra pequena (menos de 20 partidas)
  gera aviso em vez de conclusão.
- **Front-end da busca** (`site/js/`): JavaScript simples, sem framework, que chama a API. Sem JavaScript, as páginas
  públicas continuam legíveis.

**Fluxo da busca:** navegador chama a API, que consulta o cache (válido por 6 horas, ajustável); se vencido, pede à fonte,
grava, calcula o diagnóstico e responde. Páginas de jogador usam `noindex`.

## 6. Endereços, versões e busca (SEO)

- Um endereço por idioma e por versão: `/pt-br/herois/` mostra **sempre a versão atual**; `/pt-br/7-41f/herois/` é o
  endereço permanente de cada versão. Enquanto a versão é a atual, a página dela aponta a canônica para o endereço "atual";
  quando sai uma versão nova, ela passa a ser a própria canônica. Seletor de versão feito de links comuns.
- Só a versão atual e a anterior entram no `sitemap.xml`; as mais antigas ficam acessíveis com `noindex,follow` (ajustável).
- Cada página: `hreflang` recíproco com endereços completos e `x-default`, `<html lang>`, `robots.txt`, canônica,
  `<title>` e descrição próprios, JSON-LD só do que a página mostra, links internos descritivos e migalhas de pão.
- Textos só em arquivos de tradução; o build **falha** se faltar chave em algum idioma. Fontes próprias com subconjunto
  (sem Google Fonts). Números e datas com `Intl`.
- Metas: Lighthouse 95 ou mais em todas as categorias, LCP até 2,5 s, INP até 200 ms, CLS até 0,1 (`PADROES.md`, seção 9A).
- Testes automáticos de `hreflang` recíproco, links sem 404, um `<h1>` por página, canônica correta nas páginas de versão e
  `noindex` nas páginas de jogador.
- Não confirmado: de onde virão os nomes de heróis traduzidos (fase dos demais idiomas).

## 7. Direção visual

Identidade própria, feita para telas pequenas primeiro, sem copiar o layout, as cores, os nomes de métricas nem a marca de
nenhum dos sites de referência. A direção (paleta, tipografia, componentes de tabela e gráfico, tema escuro e claro, contraste
mínimo de 4,5:1) é definida com **maquetes** no início da etapa do site, antes de qualquer página; a pessoa escolhe entre
opções. Os gráficos são desenhados por nós, sem biblioteca de terceiros carregada de fora.

## 8. Privacidade e segurança

- Só dados públicos de partidas; guardamos o mínimo e por no máximo **90 dias**.
- `DELETE` do jogador apaga o que está guardado e impede nova coleta. A lista de bloqueio guarda só um **hash com segredo
  do servidor** do ID, nunca o ID.
- Limite de requisições por IP (valor inicial 30 por minuto, ajustável), CORS permitindo só o endereço do site,
  CSP `default-src 'self'` com `connect-src` apenas para a nossa API, cabeçalhos de segurança, validação do ID com Pydantic.
- Segredos (como o token da fonte) só em variáveis de ambiente e no cofre de segredos do CI; nada no repositório. Logs em JSON
  sem ID de jogador.
- Aviso visível: projeto independente, sem vínculo com a Valve nem com as fontes de dados; política de privacidade em linguagem simples.

## 9. Testes e entrega

- `pytest` com `respx`: **nenhum teste acessa a internet**; respostas gravadas ficam em fixtures com dados fictícios.
- Teste de contrato para a fonte: uma checagem ocasional contra a API real, fora do CI padrão, avisa se o formato mudou.
- Teste da troca de versão: com fixtures de duas versões, o coletor cria a nova, o gerador aponta "atual" para ela e a anterior continua navegável.
- Testes de mutação à mão em cada regra do diagnóstico (kit, E-009 e E-010).
- CI no GitHub Actions: `ruff`, `pytest`, build do site, Lighthouse CI, CodeQL e Dependabot (modelos em `padroes-de-qualidade/templates`).
- A Definição de Pronto do nível 2 do kit (`PADROES.md`, seção 2) vale integralmente.

## 10. Hospedagem gratuita

- Site estático: GitHub Pages (decidido). O coletor roda como tarefa agendada do GitHub Actions (gratuito em repositório público).
- API: precisa de uma hospedagem gratuita que aceite Docker ou Python; essas hospedagens costumam "dormir" e a primeira
  consulta demora. A escolha é feita na etapa de publicação, depois de conferir as condições do momento, e a tela mostra
  um estado de carregamento. **Risco:** se nenhuma opção gratuita servir, a versão 1 publica as páginas públicas e roda a
  busca de jogador em Docker local, e o fato é dito com clareza no README.

## 11. Aprendizado

- Cada tarefa feita pela pessoa sozinha tem uma **ficha** em `docs/tarefas/` (conceitos do básico ao avançado, o que é pedido,
  como saber que ficou certo, escada de dicas) e **não** tem a solução. A lista das tarefas solo é definida no plano.
- `APRENDIZADOS.md` é atualizado a cada tarefa, com duas perguntas de explicar de volta e a resposta da pessoa **sem edição**.
- Configurações do Claude Code e do VS Code entram em `.claude/` e `.vscode/` depois da aprovação do plano.

## 12. Etapas (o plano detalha)

0. Verificar as APIs na máquina da pessoa e decidir a fonte (`docs/api-fontes.md`). 1. Esqueleto, CI e `/saude`.
2. Cliente da fonte com fixtures. 3. Banco, versões e cache. 4. Coletor agendado e troca de versão. 5. Direção visual com maquetes.
6. Gerador do site: meta por versão e página do herói com builds, idiomas e SEO. 7. API do jogador, diagnóstico e front-end da busca.
8. LGPD e segurança (exclusão, limites, CORS). 9. Publicação, Lighthouse CI e medição em campo. Cada etapa termina com algo publicável.

## 13. Riscos

| Risco | O que fazemos |
| --- | --- |
| Limites ou regras da fonte diferentes do esperado | Etapa 0, cache no banco, interface `FonteDeDados` |
| A fonte não entrega estatísticas por versão ou builds de habilidades | Retratos periódicos; builds de habilidades adiados (seção 4) |
| Escopo grande para quem está aprendendo | Versão 1 em fatias publicáveis; o resto em fases (seção 2) |
| API gratuita sem hospedagem adequada | Seção 10 |
| Poucos jogadores com dados públicos ativados | Mensagem clara; páginas de heróis e meta continuam úteis sem jogador |
| Tradução ruim prejudicar a busca | Idioma só entra com tradução revisada |
| Muitas páginas (heróis x idiomas x versões) parecerem conteúdo repetido | Sitemap só com versão atual e anterior; amostra mínima por página; explicações próprias em cada uma |

## 14. Desvios dos padrões do kit

Nenhum por enquanto. Qualquer padrão não cumprido será registrado aqui com o motivo.
