# Fontes de dados: verificação da Etapa 0

Data: 2026-11-10 · Feita na máquina da pessoa, sem chave de API · Especificação: seção 4

Este arquivo registra **o que cada fonte entrega, com a chamada que prova**. Só nomes de campos, rotas e números
agregados do jogo; nenhum ID, apelido ou valor de jogador real. Herói usado nos exemplos: `hero_id=1` (dado do jogo).

## Resumo

| Fonte | Limite gratuito (fonte oficial) | Chave | Situação |
| --- | --- | --- | --- |
| OpenDota | **3.000 por dia, 60 por minuto**, sem chave | Paga: US$ 0,01 a cada 100 chamadas, exige cartão | Verificada |
| STRATZ | Token padrão: **20/s, 250/min, 2.000/h, 10.000/dia** | Gratuita, entrando com a Steam | Só limites e termos; dados **não verificados** (exigem token) |
| Valve (`www.dota2.com/datafeed`) | Não documentado | Não precisa | Só a lista de versões |

## Funções da seção 4

Resultado: **sim**, **não**, **parcial** ou **não verificado**.

| Função | Fonte | Resultado | Chamada que prova | Observação |
| --- | --- | --- | --- | --- |
| 1. Lista de versões com data, incluindo letras | OpenDota | parcial | `GET /api/constants/patch` | 200; 61 versões, de 6.70 a 7.41 (2026-03-24), com data; **nenhuma com letra** |
| 1. Lista de versões com data, incluindo letras | OpenDota | parcial | `GET /api/constants/patchnotes` | 116 versões com letra (`7_40b`, `7_40c`), **sem data**; para em `7_41`, sem 7.41a a 7.41f |
| 1. Lista de versões com data, incluindo letras | Valve | sim | `GET https://www.dota2.com/datafeed/patchnoteslist?language=english` | 118 versões, 84 com letra, campos `patch_number`, `patch_name`, `patch_timestamp`; vai até 7.41f (2026-09-15). **Rota sem documentação oficial** (ver "Lista de versões: fonte e plano B") |
| 1. Lista de versões com data, incluindo letras | STRATZ | não verificado | — | Exige token |
| 2. Estatísticas de herói por versão, rank e posição | OpenDota | parcial | `GET /api/heroStats` | 127 heróis numa chamada. **Por rank: sim** (`1_pick`/`1_win` a `8_pick`/`8_win`, de Arauto a Imortal). **Por versão: não** (documentação: "recent matches", sem parâmetro de versão). Tendência de 7 pontos em `pub_pick_trend`, `pub_win_trend`. Banimentos só profissionais (`pro_ban`) |
| 2. Estatísticas de herói por versão, rank e posição | OpenDota | parcial | `GET /api/scenarios/laneRoles?hero_id=1` | Campos `hero_id`, `lane_role`, `time`, `games`, `wins`. **Rota** (1 segura, 2 meio, 3 difícil, 4 selva), não posição 1 a 5; sem rank; período não informado |
| 2. Estatísticas de herói por versão, rank e posição | OpenDota | parcial | `GET /api/explorer?sql=` (SQL abaixo) | Por versão sim, mas **só partidas de liga**: 7.41 tem 8.892 partidas, todas de liga; 7.40 tem 7.943, todas de liga |
| 2. Estatísticas de herói por versão, rank e posição | STRATZ | não verificado | — | Exige token |
| 3. Builds de itens e de habilidades | OpenDota | parcial | `GET /api/heroes/1/itemPopularity` | Itens: `start_game_items`, `early_game_items`, `mid_game_items`, `late_game_items`, só **contagens** (sem taxa de vitória), "de partidas profissionais" (documentação), sem versão |
| 3. Builds de itens e de habilidades | OpenDota | parcial | `GET /api/schema` e `/api/explorer` | Habilidades: **nenhuma rota agregada**. A tabela `player_matches` tem `ability_upgrades_arr`, mas o explorer só tem partidas de liga |
| 3. Builds de itens e de habilidades | STRATZ | não verificado | — | Exige token |
| 4. Partidas recentes e estatísticas do jogador | OpenDota | pendente | `GET /api/players/{id}`, `/recentMatches`, `/wl`, `/matches?patch=60&limit=5` | Aguarda a pessoa rodar o script que imprime só nomes de campos. A rota `/matches` aceita `patch`, `lane_role`, `hero_id` e outros filtros (documentação) |
| 4. Referências de comparação (benchmarks) | OpenDota | sim | `GET /api/benchmarks?hero_id=1` | Percentis (`percentile`, `value`) de `gold_per_min`, `xp_per_min`, `kills_per_min`, `deaths_per_min`, `assists_per_min`, `last_hits_per_min`, `denies_per_min`, `hero_damage_per_min`, `hero_healing_per_min`, `tower_damage`. Documentação: filtros `bracket` (1 a 8) e `role` (núcleo ou suporte) |
| 4. Partidas recentes e estatísticas do jogador | STRATZ | não verificado | — | Exige token |
| 5. Limites, regras e atribuição | OpenDota | sim | Página `www.opendota.com/api-keys` e FAQ `blog.opendota.com/2014/08/01/faq/` | 3.000/dia e 60/min sem chave; "erros 500 não contam como uso". Termos: serviço *best-effort*, sem garantia. Atribuição: pedida para o **código** (MIT); para os dados não há regra escrita. **Anúncios: os termos não falam** (nem permitem nem proíbem) |
| 5. Limites, regras e atribuição | OpenDota | sim | Cabeçalhos de qualquer resposta | `X-Rate-Limit-Remaining-Minute` e `X-Rate-Limit-Remaining-Day`; sem cabeçalho de limite total nem de reinício |
| 5. Efeito de "Expose Public Match Data" | OpenDota | sim | FAQ | Desligado **por padrão**; com ele desligado o jogador aparece anônimo nas partidas seguintes; dados antigos não são apagados |
| 5. Limites, regras e atribuição | STRATZ | sim | Página `stratz.com/api` | Token padrão: sem formulário e sem tráfego de volta; aviso "Fornecido por STRATZ" é "muito apreciado". Tokens maiores exigem formulário e 1.000 indicações por mês. Proíbe uso para trapaça ou contra o acordo da Steam. **Anúncios: os termos não falam** |

SQL usado no explorer:

```sql
SELECT mp.patch, count(*) AS partidas, sum(CASE WHEN m.leagueid > 0 THEN 1 ELSE 0 END) AS de_liga
FROM matches m JOIN match_patch mp USING (match_id)
WHERE mp.patch IN ('7.40','7.41') GROUP BY mp.patch
```

## Lista de versões: fonte e plano B

Decisão da pessoa (2026-11-10): o *datafeed* da Valve é usado **só para a lista de versões** (inclusive as com letra).

- **Por que:** é a única fonte verificada com as versões com letra e com data; custa 1 chamada a cada 6 horas e não gasta o
  saldo da OpenDota.
- **Risco:** a rota `www.dota2.com/datafeed/patchnoteslist` **não tem documentação oficial** da Valve. Pode mudar de
  formato ou sair do ar sem aviso, e não há termos de uso escritos para ela.
- **Plano B, nesta ordem**, se a rota falhar ou devolver algo fora do formato esperado:
  1. manter a **última lista guardada** (`dados/versoes.json`) e mostrar a data da última atualização;
  2. completar com a lista da OpenDota (`/api/constants/patch`), que só tem versões principais; uma versão principal
     nova aparece mesmo sem a Valve, e as letras voltam quando a rota voltar.
- **Como perceber:** a falha da rota quebra a execução do coletor e gera aviso (especificação, seção 13), em vez de
  apagar versões em silêncio.

## Outras observações

- **Conexão instável na máquina da pessoa** (E-026 do kit): cerca de metade das tentativas caiu no aperto de mãos TLS,
  antes da resposta; repetir resolveu sempre. Também aconteceu com `www.dota2.com`. O cliente da fonte precisa de nova
  tentativa com espera desde o início.
- **Radiant contra Dire** não vem no `heroStats`. A tabela `public_matches` (via `/api/schema`) tem `radiant_win` e
  `avg_rank_tier`, e a rota `/api/publicMatches` aceita `min_rank` e `max_rank`: dá para calcular por amostragem. Não testado.
- A tabela `match_patch` e a lista `constants/patch` usam só versões principais (`7.41`): as estatísticas da OpenDota
  **não se separam por versão com letra**.
