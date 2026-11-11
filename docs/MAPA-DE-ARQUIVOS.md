# Mapa de arquivos

Uma linha por arquivo do repositório: para que serve, por que está aqui e o que mais poderia ter sido feito.
Regra: todo arquivo é explicado **antes** de ser criado, e esta tabela muda no mesmo commit que cria, move ou apaga
um arquivo. Arquivo que não se consegue justificar não é criado. Para conferir se falta alguém: `git ls-files`.

| Arquivo | Para que serve | Por que está aqui | Alternativas | Tarefa em que foi criado |
| --- | --- | --- | --- | --- |
| `.gitignore` | Diz ao git o que não versionar; hoje só a saída dos scripts da Etapa 0 | Raiz, onde o git procura primeiro; a tarefa 2 acrescenta `.env`, `.venv/` e o resto | `.git/info/exclude` (não é versionado e não iria para outro computador); um `.gitignore` dentro de `saida/` (espalha regras por pastas) | Tarefa 1 |
| `ferramentas/etapa0/campos-jogador.ps1` | Mostra **quais campos** a OpenDota devolve para um jogador; pede o ID de forma oculta e nunca imprime valores | `ferramentas/` reúne utilitários rodados à mão, fora do produto e dos testes; `etapa0/` agrupa pela etapa que os usa | `scripts/` (nome em inglês, fora do padrão do projeto); `tests/` (não é teste automático e acessa a internet, o que os testes não podem fazer); deixar fora do repositório (não iria para outro computador) | Tarefa 1 |
| `ferramentas/etapa0/stratz-esquema.ps1` | Descobre a estrutura da API do STRATZ por introspecção e a lista de versões, com o token só no cabeçalho; grava em `ferramentas/etapa0/saida/` | Mesmo motivo do `campos-jogador.ps1`; a saída fica ao lado do script, calculada por `$PSScriptRoot`, sem caminho com nome de usuário | Mesmas do `campos-jogador.ps1`; consulta GraphQL escrita à mão sem introspecção (dependeria de nomes de campos adivinhados) | Tarefa 1 |
| `LICENSE` | Diz o que outras pessoas podem fazer com o código (licença MIT: usar, copiar e modificar, mantendo o aviso) | Raiz, com esse nome, porque o GitHub reconhece e mostra a licença; o kit exige MIT salvo motivo contrário | Apache-2.0 (mais longa, trata de patentes, nada que o projeto precise); sem licença (ninguém poderia reutilizar o código legalmente, ruim para portfólio) | Criação do repositório, antes do plano 1 |
| `README.md` | Porta de entrada: o que é o projeto, para quem, como rodar, decisões e limitações | Raiz, porque o GitHub mostra esse arquivo na página do repositório | Wiki do GitHub (fica fora do git e não acompanha o código); README em inglês primeiro (o projeto começa em pt-BR; inglês entra na versão 1.1) | Criação do repositório, antes do plano 1 |
| `docs/superpowers/specs/2026-11-10-painel-dota-design.md` | Especificação: o que o painel faz e por quê, com as decisões aprovadas | Pasta padrão das skills *superpowers*; a data no nome ordena as versões | Issue no GitHub (a discussão se perde e não é versionada junto com o código); dentro do README (misturaria decisão com instrução de uso) | Especificação, antes do plano 1 |
| `docs/superpowers/plans/2026-11-10-painel-dota-fundacao.md` | Plano 1: tarefas e passos para as etapas 0 e 1, marcados conforme são feitos | Mesma pasta padrão das skills, separada das especificações | GitHub Projects (quadro fora do git, sem histórico junto do código); lista de tarefas no README (cresceria sem limite) | Plano 1, antes da tarefa 1 |
| `docs/api-fontes.md` | Evidência da Etapa 0: o que cada fonte de dados entrega, com a chamada que prova, e o plano B da lista de versões | `docs/` porque é documentação do projeto, não do processo das skills; nome diz o conteúdo | Dentro da especificação (ficaria enorme; a especificação guarda só a decisão e aponta para cá); planilha (fora do git, sem histórico) | Tarefa 1 |
| `CLAUDE.md` | Contexto, regras e ordem de leitura que o Claude Code carrega sozinho ao abrir a pasta; evita colar um prompt longo a cada sessão | Raiz, porque é lá que o Claude Code procura; criado antes da tarefa 2 (o plano previa criá-lo lá) para a pessoa começar a codar sem depender de prompt | Prompt colado a cada sessão (esquece, não é versionado); só o `docs/PASSAGEM.md` (é estado de uma tarefa, não regra permanente); `README.md` (é para visitantes, não para o assistente) | Antes da tarefa 2 |
| `docs/PASSAGEM.md` | Estado do trabalho para retomar em outro computador: feito, falta, comandos, inglês em aberto, não verificado | `docs/`, porque é documentação; substitui o registro de progresso do Claude Code, que o git ignora. Atualizado a cada passagem e apagado ao fim do plano 1 | Issue no GitHub (fora do git); mensagem de commit (curta e difícil de achar); README (é a porta de entrada, não o estado de uma tarefa) | Tarefa 1 |
| `docs/MAPA-DE-ARQUIVOS.md` | Este mapa: o porquê de cada arquivo, para estudo e para as perguntas do `/fechar-tarefa` | `docs/` porque é documentação; nome em português, descritivo, em maiúsculas como os demais documentos-guia | Seção no README (deixaria a porta de entrada longa); comentário no topo de cada arquivo (não cabe em JSON nem na licença, e não dá visão de conjunto); lista gerada por `git ls-files` (dá os nomes, não o porquê) | Tarefa 1 |

## Fora do repositório (de propósito)

Arquivos que existem na máquina durante o trabalho, mas **não** entram no git:

| Caminho | O que é | Por que fica fora |
| --- | --- | --- |
| `.superpowers/sdd/` | Registro de progresso do plano usado pelo Claude Code | Rascunho de trabalho; tem um `.gitignore` próprio que ignora tudo dentro dela |
| `.playwright-mcp/` | Capturas do navegador automático | Saída temporária de ferramenta; entra no `.gitignore` na tarefa 2 |
| `ferramentas/etapa0/saida/` | Arquivo gerado pelo `stratz-esquema.ps1` | Gerado na hora; ignorado pelo `.gitignore` |
| Testes com dublê do script do STRATZ (pasta temporária da sessão) | Provam sem rede que o script percorre a API e não grava o token | Temporários, usados só na verificação |
