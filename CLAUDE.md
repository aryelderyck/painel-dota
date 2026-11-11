# CLAUDE.md: painel-dota

Este arquivo é lido automaticamente pelo Claude Code. Ele diz **quem é a pessoa, o que é o projeto, as regras e por onde
começar**. O "o quê e por quê" está na especificação; o "como, passo a passo" está no plano.

## Comece por aqui (nesta ordem)
1. `docs/PASSAGEM.md`: estado atual do trabalho, o que falta e os comandos exatos.
2. `docs/superpowers/specs/2026-11-10-painel-dota-design.md` (revisão 4, aprovada): leia as seções 1, 2, 4, 5, 6, 7, 7A e 8.
   A seção 7 tem a **direção visual escolhida** e a regra das **imagens e textos oficiais do jogo**.
3. `docs/superpowers/plans/2026-11-10-painel-dota-fundacao.md`: plano 1, executado **uma tarefa por vez**.
4. `docs/api-fontes.md`: o que as fontes de dados entregam, com a evidência.
5. `docs/MAPA-DE-ARQUIVOS.md`: o porquê de cada arquivo do repositório.

Continue na **tarefa 1 do plano 1** (Etapa 0). Antes dos passos que faltam, acrescente a ela a verificação de imagens e
textos em português descrita em `docs/PASSAGEM.md` ("O que falta na tarefa 1", item 5b). Não pule para as tarefas seguintes.

## Padrões obrigatórios
Este projeto segue o kit **padroes-de-qualidade** (repositório irmão `../padroes-de-qualidade`, versão 0.4), **nível 2**.
Leia no início de cada etapa grande: `PADROES.md` (seções 2 e 9A), `CONTEXTO.md`, `REVISAO.md` e a seção "Regras que saíram
dos erros" do `ERROS.md`. Antes de decidir algo importante, otimizar ou dizer "pronto", passe pelo bloco correspondente do
`REVISAO.md`. **Erro novo vira entrada no `ERROS.md` do kit no mesmo dia** (commit no repositório do kit) e um resumo no
`APRENDIZADOS.md`. Desvios dos padrões vão na seção 14 da especificação, com o motivo.

## Contexto da pessoa
Aryel é desenvolvedor **iniciante** e usa o projeto para **aprender** e montar portfólio (freelance ou vaga júnior).
Orçamento zero: só ferramentas gratuitas. Conhece mais League of Legends do que Dota 2: ao explicar regras do jogo, compare
com o LoL quando ajudar. Explique em português, de forma direta.
- **Inglês junto com o código:** termo técnico em inglês com a tradução na primeira vez; diante de mensagem de erro ou tela em
  inglês, peça que ele diga primeiro o que entendeu e só depois confirme ou corrija; ao fechar cada tarefa, registre de 3 a 5
  termos novos em `APRENDIZADOS.md`. O texto visível do site é em português do Brasil.
- **Ensine com recursos visuais:** diagramas, gráficos, tabelas e maquetes sempre que ajudarem, de preferência algo que abra
  no celular.
- **Cada arquivo com o seu porquê:** antes de criar qualquer arquivo (inclusive de configuração), explique em poucas linhas
  para que serve, por que fica naquela pasta e com aquele nome, quais alternativas existiam e por que não foram
  escolhidas. Atualize `docs/MAPA-DE-ARQUIVOS.md` no mesmo commit que cria, move ou apaga o arquivo. Se não conseguir
  justificar um arquivo, não o crie e avise.
- **Tarefa marcada (solo):** a pessoa escreve. Não entregue a solução: ofereça a ficha, os testes prontos e a próxima dica
  da escada **só quando ela pedir**. Ao fim de cada tarefa, rode `/fechar-tarefa` (criado na tarefa 4 do plano 1).
- Explique antes de fazer, com poucas palavras. Perguntas de verdade, uma por vez.

## O que é este projeto
Painel de estatísticas de **Dota 2** para jogadores: versão atual do jogo sempre à frente (com navegação entre versões),
meta de heróis, builds de itens e de habilidades, busca de jogador com **diagnóstico em português** e explicação de cada
métrica. Site público, forte em **SEO**, com vários idiomas (pt-BR e inglês primeiro) e **pronto para receber anúncios
depois** (a versão 1 não tem anúncios). Dados **reais em execução**; o repositório, os testes e os exemplos só com dados
**fictícios**. Arquitetura híbrida: coletor agendado no GitHub Actions gera arquivos JSON, gerador de site estático
(Python + Jinja2) publica no GitHub Pages, e uma API FastAPI atende busca de jogador, diagnóstico e `/saude`, com
PostgreSQL só para cache, contador de requisições e lista de bloqueio (seções 4.1, 5 e 8 da especificação).

## Regras que não podem ser quebradas
- **Dado real nunca entra no repositório**: nenhum ID ou apelido de jogador, nenhuma resposta gravada de jogador real.
- **Imagens e textos do jogo** (heróis, itens, habilidades): usados como decidido pela pessoa, **carregados em tempo de
  execução do endereço informado pela fonte e nunca guardados no repositório**; todo texto vindo da fonte passa por
  conversão para uma lista fixa de elementos permitidos (nunca HTML cru na página). Detalhes na seção 7 da especificação.
- **Nenhum teste acessa a internet** (`pytest-socket` com `--disable-socket`); respostas gravadas ficam em fixtures com dados fictícios.
- Segredos só em `.env` (fora do git) e `.env.example` sem valores. **Nunca** peça, cole ou imprima token, ID de conta ou
  e-mail em arquivo, commit ou conversa. A pessoa guarda o token só na variável de ambiente do terminal.
- Fonte de dados atrás da interface `FonteDeDados`; nunca chamar a fonte quando o orçamento diário de chamadas acabou (seção 4.1).
- Sem biblioteca de terceiros carregada de fora no navegador; gráficos desenhados por nós (seção 7).
- Nada de "funciona" sem rodar o comando e ler a saída. O que não foi verificado é dito.
- **Verificar com script** (não por leitura de página) o que depende de dado real da fonte. Achados lidos por página estão
  marcados como provisórios na especificação.
- Commits pequenos, em português, `tipo: o que mudou`, trabalhando em ramo curto. Identidade do git configurada **só no
  repositório** (veja `docs/PASSAGEM.md`, passo 3), com o e-mail `noreply` do GitHub.

## Comandos
Ainda não há código; a tarefa 2 do plano 1 cria o esqueleto. Depois dela, esta seção lista instalar, rodar, testar e lint.
Até lá, os scripts da Etapa 0 estão em `ferramentas/etapa0/` (PowerShell 5.1; veja os cuidados no `ERROS.md` E-027 a E-033).

## Como trabalhar
- Mudou comportamento? Escreva ou ajuste o teste **antes** (TDD) e veja falhar pelo motivo certo.
- Ao mexer em tela, **olhe a página** (capturas em 1440 px e 390 px) antes de dizer que ficou boa.
- Ao fim de cada tarefa: `APRENDIZADOS.md` com a pessoa, checklist do nível 2, commit e atualização de `docs/PASSAGEM.md`.
- Teste que passa de primeira: quebre o código de propósito para confirmar que ele falha.

## Visual (resumo; a seção 7 da especificação manda)
Tema escuro, tecnológico mas simples. Base azul-marinho quase preta; **azul de mana** nas ações e seleções; **verde** para
subir e vitória, **vermelho** para cair e derrota (sempre com sinal ou texto, nunca só cor); **dourado** nos itens.
Cartão por herói com retrato grande, build em linha do tempo, diagnóstico em barras contra a média do herói. PC primeiro
(1440 px), responsivo até 390 px. Contraste mínimo 4,5:1, alvos de toque de 44 px. A maquete de referência é o canvas
"Painel Dota: direções visuais" (quadro "A+B. Mistura com retratos"), que a pessoa pode abrir no Claude.

## Plano de aprendizado (o que a pessoa escreve)
Método: Claude mostra, depois fazem juntos com lacunas, depois a pessoa escreve e Claude revisa.
1. Tarefa 6 do plano 1: `api/validacao.py` (`validar_id_conta`), com os testes já escritos.
2. Os próximos arquivos solo saem do plano 2 (a definir com a pessoa).
