# painel-dota: especificação de design

Data: 2026-11-10 · Situação: **rascunho para revisão da pessoa** · Nível no kit `padroes-de-qualidade`: 2

## 1. Entendimento

**O que a pessoa pediu (suas palavras):** um site de estatísticas e métricas de Dota 2, com **dados reais** da API,
**útil para jogadores**, fácil de ser **encontrado** na busca, em **vários idiomas** (os dos países que mais jogam),
bem **linkado** e dentro dos padrões de qualidade do Google "e até mais um pouco".

**Objetivos de aprendizado:** consumir uma API, guardar em banco, criar a própria API, testar, proteger, publicar.
A pessoa é iniciante: parte do código ela escreve sozinha, guiada (seção 10). Orçamento zero.

**Critérios de sucesso:**
1. Um jogador digita o ID da própria conta e recebe um diagnóstico em português baseado nas partidas reais dele.
2. As páginas públicas (heróis e meta) abrem rápido, passam no Lighthouse com 95 ou mais e estão prontas para indexação.
3. O repositório tem testes sem internet, CI verde e nenhum dado pessoal real.
4. A pessoa consegue explicar com as próprias palavras cada camada do projeto.

**Suposições minhas (corrija no que estiver errado):**
- O ID numérico da conta (ID de amigo do Dota) basta como forma de busca na versão 1.
- Inglês entra logo depois do português (versão 1.1), não junto.
- Nenhuma regra garante posição no Google. O projeto entrega a base técnica e conteúdo útil; a posição depende de tempo e de links de outros sites.

## 2. Escopo

**Versão 1 (aprovada pela pessoa):** páginas de heróis e meta, busca de jogador por ID, diagnóstico em pt-BR.
**Versão 1.1:** inglês em todas as páginas. **Depois, nesta ordem:** evolução ao longo do tempo, confrontos e counters,
comparação entre dois jogadores, e os demais idiomas (ru, es, zh-Hans, id, uk), cada um só com tradução revisada.

**Fora de escopo:** contas e login, pagamento, anúncios, comentários, busca por apelido (expõe dado pessoal),
qualquer recurso de terceiros no navegador (CDN, fontes externas, analytics com cookies).

## 3. Dado real e dado fictício

| Onde | Dados |
| --- | --- |
| O site em funcionamento | **Reais**, vindos da API |
| Repositório, testes, exemplos, capturas de tela | **Só fictícios** (IDs e apelidos inventados) |

Motivo: ID e apelido de jogador real são dado pessoal (LGPD) e não devem ficar guardados no GitHub nem nos testes.

## 4. Fonte de dados

**Decisão: OpenDota como fonte principal**, atrás de uma interface própria (`FonteDeDados`), para poder trocar ou
acrescentar outra fonte sem mexer no resto.

| Opção | Prós | Contras |
| --- | --- | --- |
| OpenDota (API REST da comunidade) | Código aberto (licença MIT), JSON simples, partidas já processadas, serve para aprender | Limites do plano gratuito não confirmados; mantida pelo projeto da comunidade, sem garantia de serviço |
| STRATZ (GraphQL, token) | Dados ricos de análise de partidas | Exige token; em artigo de 2021 exigia tráfego de volta para o site deles, regra que pode ter mudado e é incômoda para um site concorrente; GraphQL é mais um assunto para aprender |
| Steam Web API (Valve) | Fonte oficial | Dados brutos, sem partidas processadas, exige chave |

**Sobre "usar a mesma API dos concorrentes":** os grandes sites não consomem uma API pública, eles **são** a fonte.
A própria OpenDota informa que seus dados vêm da API da Valve e do processamento automático de replays. Consumir a
OpenDota é, na prática, usar a mesma base que eles.

**Não confirmado na fonte oficial (etapa 0 do plano):** limites do plano gratuito (um SDK de terceiros cita 2.000 chamadas por
dia e 60 por minuto), regras de uso e atribuição, nomes exatos dos endpoints, e quais campos existem para jogadores sem
partidas processadas. A documentação oficial não abre nas ferramentas desta sessão (E-017). Se algo contradisser esta
especificação, a especificação é corrigida antes de qualquer código.

**Limitações já conhecidas:** o jogador precisa ter ativado "Expose Public Match Data" no Dota 2, senão não há dados, e a
tela deve explicar isso. Gráficos minuto a minuto só existem para partidas já processadas.

## 5. Arquitetura (híbrida, aprovada)

- **Gerador do site estático** (`site/`, Python com Jinja2): lê dados de heróis e meta do cache e produz HTML pronto
  para cada idioma. Roda no CI em horário agendado e a cada mudança. Publicado de graça no GitHub Pages.
- **API própria** (`api/`, FastAPI): busca jogador, calcula diagnóstico, rota `/saude`, rota de exclusão (seção 7).
- **Cliente da fonte** (`api/fonte/`): implementa `FonteDeDados` com `httpx`, com tempo limite, nova tentativa com espera,
  respeito aos limites e tratamento de resposta inesperada.
- **Banco** (SQLAlchemy 2 e Alembic): SQLite no início, PostgreSQL depois. Guarda cache de heróis, meta e jogadores.
- **Diagnóstico** (`api/diagnostico/`): funções puras que recebem estatísticas e devolvem identificadores de achados
  (sem texto). O texto vem do arquivo de tradução. Regras determinísticas e testáveis; amostra pequena (menos de 20 partidas)
  gera aviso em vez de conclusão.
- **Front-end da busca** (`site/js/`): JavaScript simples, sem framework, que chama a API. Sem JavaScript, as páginas
  públicas continuam legíveis.

**Fluxo da busca:** navegador chama a API, que consulta o cache (válido por 6 horas, valor ajustável); se vencido,
pede à fonte, grava, calcula o diagnóstico e responde. Páginas de jogador usam `noindex`.

## 6. Idiomas e busca (SEO)

- Um endereço por idioma (`/pt-br/`, `/en/`), `hreflang` recíproco com endereços completos e `x-default`, `<html lang>`,
  seletor feito de links comuns, `sitemap.xml` por build, `robots.txt`, canônica, `<title>` e descrição por página,
  JSON-LD só do que a página mostra, links internos descritivos e migalhas de pão.
- Textos só em arquivos de tradução. O build **falha** se faltar chave em algum idioma.
- Fontes próprias com subconjunto (sem Google Fonts). Números e datas com `Intl`.
- Metas: Lighthouse 95 ou mais em todas as categorias, LCP até 2,5 s, INP até 200 ms, CLS até 0,1 (`PADROES.md`, seção 9A).
- Testes automáticos de `hreflang` recíproco, links sem 404, um `<h1>` por página, canônica e `noindex` nas páginas de jogador.
- Não confirmado: de onde virão os nomes de heróis traduzidos (fase dos demais idiomas).

## 7. Privacidade e segurança

- Só dados públicos de partidas; guardamos o mínimo e por no máximo **90 dias**.
- `DELETE` do jogador apaga o que está guardado e impede nova coleta. A lista de bloqueio guarda só um **hash com segredo
  do servidor** do ID, nunca o ID.
- Limite de requisições por IP (valor inicial 30 por minuto, ajustável), CORS permitindo só o endereço do site,
  CSP `default-src 'self'` com `connect-src` apenas para a nossa API, cabeçalhos de segurança, validação do ID com Pydantic.
- Segredos só em variáveis de ambiente; nada no repositório. Logs em JSON sem ID de jogador.
- Aviso visível: projeto independente, sem vínculo com a Valve nem com a OpenDota; política de privacidade em linguagem simples.

## 8. Testes e entrega

- `pytest` com `respx`: **nenhum teste acessa a internet**; respostas gravadas ficam em fixtures com dados fictícios.
- Teste de contrato para a fonte: uma checagem ocasional contra a API real, fora do CI padrão, avisa se o formato mudou.
- Testes de mutação à mão em cada regra do diagnóstico (kit, E-009 e E-010).
- CI no GitHub Actions: `ruff`, `pytest`, build do site, Lighthouse CI, CodeQL e Dependabot (modelos em `padroes-de-qualidade/templates`).
- A Definição de Pronto do nível 2 do kit (`PADROES.md`, seção 2) vale integralmente.

## 9. Hospedagem gratuita

- Site estático: GitHub Pages (decidido).
- API: precisa de uma hospedagem gratuita que aceite Docker ou Python; essas hospedagens costumam "dormir" e a primeira
  consulta demora. A escolha é feita na etapa de publicação, depois de conferir as condições do momento, e a tela mostra
  um estado de carregamento. **Risco:** se nenhuma opção gratuita servir, a versão 1 publica as páginas públicas e roda a
  busca de jogador em Docker local, e o fato é dito com clareza no README.

## 10. Aprendizado

- Cada tarefa feita pela pessoa sozinha tem uma **ficha** em `docs/tarefas/` (conceitos do básico ao avançado, o que é pedido,
  como saber que ficou certo, escada de dicas) e **não** tem a solução. A lista das tarefas solo é definida no plano.
- `APRENDIZADOS.md` é atualizado a cada tarefa, com duas perguntas de explicar de volta e a resposta da pessoa **sem edição**.
- Configurações do Claude Code e do VS Code entram em `.claude/` e `.vscode/` depois da aprovação do plano.

## 11. Etapas (o plano detalha)

0. Confirmar a API oficial (limites, regras, endpoints) e registrar. 1. Esqueleto, CI e `/saude`. 2. Cliente da fonte
com fixtures. 3. Banco e cache. 4. API do jogador e diagnóstico. 5. Gerador do site, idiomas e SEO. 6. Front-end da
busca. 7. LGPD e segurança (exclusão, limites, CORS). 8. Publicação, Lighthouse CI e medição em campo.

## 12. Riscos

| Risco | O que fazemos |
| --- | --- |
| Limites ou regras da OpenDota diferentes do esperado | Etapa 0, cache no banco, interface `FonteDeDados` |
| API gratuita sem hospedagem adequada | Seção 9 |
| Poucos jogadores com dados públicos ativados | Mensagem clara; páginas de heróis e meta continuam úteis sem jogador |
| Tradução ruim prejudicar a busca | Idioma só entra com tradução revisada |
| Escopo grande para quem está aprendendo | Versão 1 enxuta; o resto em etapas separadas |

## 13. Desvios dos padrões do kit

Nenhum por enquanto. Qualquer padrão não cumprido será registrado aqui com o motivo.
