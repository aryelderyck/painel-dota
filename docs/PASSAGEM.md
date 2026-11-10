# Passagem: retomar o plano 1 em outro computador

Data: 2026-11-10 · Ramo: `plano-1-fundacao` · Tarefa em andamento: **tarefa 1 (Etapa 0)**

Este arquivo substitui o registro de progresso do Claude Code (`.superpowers/sdd/`), que é ignorado pelo git e não vai
para o outro computador. Atualize-o a cada passagem; apague-o quando o plano 1 terminar.

## Como retomar

1. Na mesma pasta, clone os dois repositórios da sua conta, lado a lado: `painel-dota` e `padroes-de-qualidade`
   (o plano usa o caminho `../padroes-de-qualidade`).
2. No `painel-dota`: `git switch plano-1-fundacao` e `git status -sb` (precisa estar em dia; E-020 do kit).
3. No Claude Code, aberto na pasta `painel-dota`: "Leia `docs/PASSAGEM.md` e continue a tarefa 1 do plano 1, com as
   mesmas regras de trabalho: uma tarefa por vez, explicar antes, TDD, nada sem verificar, erros no `ERROS.md` do kit."

## O que está feito

**Tarefa 1, passos 1 e 2: feitos. Passo 3: parcial.** Resultados em [`api-fontes.md`](api-fontes.md):

- **OpenDota, confirmado na página oficial:** 3.000 chamadas por dia e 60 por minuto, sem chave. A chave é **paga**
  (US$ 0,01 a cada 100 chamadas, com cartão). Termos: serviço *best-effort*; **não falam de anúncios**.
- **OpenDota, o que entrega:** estatísticas de herói **por faixa de rank** numa chamada (`/heroStats`), mas **não por versão**;
  posição só como **rota** (`/scenarios/laneRoles`); builds de itens só em contagens e de partidas profissionais; nenhuma
  rota agregada de builds de habilidades; o `/explorer` tem só partidas de liga; `benchmarks` por rank e função.
- **Versões com letra:** só no *datafeed* da Valve (até 7.41f), rota sem documentação oficial. Decisão da pessoa: usar só
  para a lista de versões, com plano B (última lista guardada, depois a lista da OpenDota).
- **STRATZ, confirmado na página oficial:** token padrão grátis (entrar com a Steam), 20/s, 250/min, 2.000/h, 10.000/dia,
  sem exigir tráfego de volta. Os **dados** ainda não foram verificados (exigem token).
- **Conexão instável** na máquina de hoje: cerca de metade das tentativas caiu no aperto de mãos TLS; repetir resolveu (E-026).

**Decisões da pessoa nesta sessão:** testar o STRATZ; usar a Valve só para a lista de versões, com plano B; passo 5 do plano
com `git grep --untracked`; regra "cada arquivo com o seu porquê" (mapa em [`MAPA-DE-ARQUIVOS.md`](MAPA-DE-ARQUIVOS.md),
atualizado no mesmo commit; temporários com uma linha); `.gitattributes` no kit; scripts da Etapa 0 no repositório.

**Decisões do Claude Code, para conferir:** trabalhar no ramo `plano-1-fundacao` em vez da `main` (o kit pede ramos
curtos); `.gitignore` criado já na tarefa 1, só com `ferramentas/etapa0/saida/` (a tarefa 2 acrescenta o resto).

**Kit `padroes-de-qualidade`:** erros E-025 a E-034, regras 17 e 18, `.gitattributes`, `docs/MAPA-DE-ARQUIVOS.md` e a
regra nova em `PRATICAS.md` como "Em teste (painel)".

## O que falta na tarefa 1

1. Rodar o script do jogador e colar a saída na conversa: o Claude Code preenche a linha da função 4 do `api-fontes.md`
   com **nomes de campos**, nunca valores.
2. Criar o token do STRATZ e rodar o script de esquema. O Claude Code lê `ferramentas/etapa0/saida/stratz-esquema.txt` e
   monta a **rodada 2**: consultas de dados reais (versão, rank, posição, builds), que também rodam antes contra um dublê
   (regra 18 do kit).
3. Passo 4: escrever na seção 4 da especificação a decisão de fonte e as correções (3.000 por dia confirmado, chave paga,
   termos do STRATZ, versões com letra pela Valve).
4. Passo 5: `git grep --untracked -nE "[0-9]{8,}" docs/api-fontes.md`, depois do ensaio com um número fictício.
5. Passo 6: commit `docs: registra a verificação das fontes de dados e a decisão`. Responder às perguntas de inglês.
   Atualizar esta passagem.

Decisão em aberto no kit: `REVISAO-CRITICA.md` se sobrepõe ao `REVISAO.md` e ninguém o cita; fundir ou marcar como obsoleto.

## Comandos exatos

No PowerShell, dentro da pasta `painel-dota`.

**Script do jogador** (pede o ID sem mostrar na tela e imprime só nomes de campos):

```powershell
powershell -ExecutionPolicy Bypass -File .\ferramentas\etapa0\campos-jogador.ps1
```

Antes de colar a saída na conversa, confira que nenhum número seu aparece nela.

**Token e script do STRATZ:**

1. Abra `https://stratz.com/api`, clique em **Entrar com Steam** e confira que a tela de senha é de `steamcommunity.com`.
2. Em **Meus Tokens**, copie o token. Não cole em nenhum outro lugar.
3. Guarde o token só neste terminal (aparecem asteriscos; o histórico grava o comando, não o token):

   ```powershell
   $env:STRATZ_TOKEN = [System.Net.NetworkCredential]::new("", (Read-Host "Token do STRATZ" -AsSecureString)).Password
   ```

4. Confira sem mostrar: `"token com $($env:STRATZ_TOKEN.Length) caracteres"`
5. Rode:

   ```powershell
   powershell -ExecutionPolicy Bypass -File .\ferramentas\etapa0\stratz-esquema.ps1
   ```

6. Confira que o token não foi para o arquivo (responde só `True` ou `False`; o esperado é `False`):

   ```powershell
   Select-String -Path .\ferramentas\etapa0\saida\stratz-esquema.txt -SimpleMatch $env:STRATZ_TOKEN -Quiet
   ```

7. Apague o token: `Remove-Item Env:STRATZ_TOKEN` (ou feche a janela).

Nunca use `$env:STRATZ_TOKEN = "..."` com o token escrito no comando: ele ficaria no histórico do PowerShell, em disco.

**Aproveite a outra rede:** se as quedas de conexão (E-026) não acontecerem no outro computador, isso aponta para a rede
ou o antivírus desta máquina. Anote se caíram ou não.

## Perguntas de inglês em aberto

Diga o que você entende antes de ler qualquer tradução:

1. `curl: (35) Recv failure: Connection was reset`: o que é *Recv failure*?
2. `"A bearer token is required for a request."`

Termos desta tarefa para o `APRENDIZADOS.md` (escolher de 3 a 5 no fechamento): *endpoint*, *response headers*,
*query parameter*, *rate limit*, *bearer token*, *introspection*, *User-Agent*, *mock*, *alias*, *BOM*.

## O que não foi verificado

- Os **dados** do STRATZ (versão, rank, posição, builds): exigem o token.
- Os campos que a OpenDota devolve para um jogador: dependem do script do jogador.
- O script do STRATZ com token de verdade: testado só sem token, com token falso (403) e com dublê (sem rede).
- Se o cabeçalho `User-Agent: STRATZ_API` é obrigatório: sem token, a resposta foi igual com ou sem ele.
- Se o texto colado no `Read-Host` fica fora do histórico do PowerShell: é o comportamento documentado, não testado aqui.
- Se o uso com anúncios é permitido pela OpenDota e pelo STRATZ: os termos não falam disso.
- Radiant contra Dire por amostragem de partidas públicas.
- A causa das quedas de conexão (E-026).
- Os scripts no outro computador (outra versão do PowerShell ou do Windows).
- Finais de linha do painel: 3 arquivos estão em CRLF na pasta deste computador; a correção é a tarefa 2.
