# painel-dota, plano 1: fundação

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** confirmar a fonte de dados com chamadas reais e deixar o repositório pronto para crescer: estrutura, CI verde, rota `/saude`, infraestrutura de ensino e a primeira tarefa escrita pela pessoa.

**Architecture:** este plano cobre as etapas 0 e 1 da especificação. O cliente da fonte, o coletor e o site ficam para o plano 2, porque as interfaces deles dependem do que a Etapa 0 provar. Tudo aqui roda na máquina da pessoa, com Claude Code, porque precisa de internet e de `pip`.

**Tech Stack:** Python 3.12, FastAPI, Pydantic, pytest, pytest-socket, httpx (cliente de teste), ruff, Docker, GitHub Actions.

**Spec:** `docs/superpowers/specs/2026-11-10-painel-dota-design.md` (revisão 4)

## Global Constraints

- Texto visível, mensagens de commit e documentação em português do Brasil. Commits no formato `tipo: o que mudou`.
- Repositório, testes e exemplos só com dados **fictícios**. Nenhum ID ou apelido de jogador real em arquivo algum, inclusive em `docs/api-fontes.md`.
- **Nenhum teste acessa a internet** (`pytest-socket` com `--disable-socket`).
- Nenhum recurso de terceiros no navegador. Segredos só em `.env` (ignorado pelo git) e `.env.example` sem valores.
- TDD: teste antes, ver falhar pelo motivo certo, depois o código. Antes de afirmar que funciona, rodar e ler a saída.
- Kit `padroes-de-qualidade` versão 0.4, nível 2. Erro novo vira entrada no `ERROS.md` do kit no mesmo dia.
- Tarefa marcada **(solo)** é escrita pela pessoa: Claude Code não entrega a solução, só a ficha, os testes e dicas em escada.

## Review Focus

1. Usuário cola o SteamID de 17 dígitos (começa com `7656119`) em vez do ID de amigo: erro claro, dizendo qual número usar. Teste na tarefa 6.
2. Entrada com espaços, sinal, letras, vazia ou zero: recusada sem exceção genérica. Teste na tarefa 6.
3. Um teste tenta acessar a rede por engano: a suíte falha em vez de passar em silêncio. Teste na tarefa 2.
4. `/saude` expõe versão de biblioteca, caminho ou variável de ambiente: a resposta tem só o campo `status`. Teste na tarefa 3.
5. Arquivo `.env` ou final de linha CRLF entra no repositório a partir do Windows: `.gitignore` e `.gitattributes` desde o primeiro commit. Verificação na tarefa 2.

---

### Task 1: Etapa 0, verificar as fontes de dados

**Files:**
- Create: `docs/api-fontes.md`
- Modify: `docs/superpowers/specs/2026-11-10-painel-dota-design.md` (seção 4, com a decisão)

**Interfaces:**
- Produces: a decisão "fonte única X" ou "X para jogador e Y para meta", que o plano 2 usa para desenhar `FonteDeDados`.

- [ ] **Step 1:** rodar `curl.exe -i https://api.opendota.com/api/constants/patch` e anotar: código de status, cabeçalhos de limite (qualquer um com `rate` ou `limit` no nome) e se a lista traz versões com letra.
- [ ] **Step 2:** abrir no navegador a documentação da OpenDota (`docs.opendota.com`) e a página de chaves (`www.opendota.com/api-keys`); anotar limites gratuitos, preço, regras de uso, atribuição e se uso com anúncios é permitido. Repetir para o STRATZ (`stratz.com/api`).
- [ ] **Step 3:** preencher em `docs/api-fontes.md` a tabela das 5 funções da seção 4 da especificação, uma linha por função e por fonte, com as colunas `função | fonte | sim, não ou parcial | chamada que prova | observação`. Para a linha de jogador, usar o próprio ID só no terminal e registrar apenas os **nomes dos campos** devolvidos, nunca o ID nem valores.
- [ ] **Step 4:** aplicar a regra de decisão (uma fonte, se cobrir a fase 1) e escrever a decisão e as consequências na seção 4 da especificação.
- [ ] **Step 5:** verificação: `docs/api-fontes.md` não tem linha em branco na coluna de resultado, e `git grep -nE "[0-9]{8,}" docs/api-fontes.md` não devolve nenhum ID de conta.
- [ ] **Step 6:** commit `docs: registra a verificação das fontes de dados e a decisão`.

### Task 2: esqueleto do projeto e CI

**Files:**
- Create: `pyproject.toml` (a partir de `padroes-de-qualidade/templates/pyproject-python.toml`), `.gitignore`, `.gitattributes`, `.env.example`, `api/__init__.py`, `tests/__init__.py`, `tests/test_sem_rede.py`, `.github/workflows/ci.yml` (a partir de `templates/github/ci-python.yml`), `.github/dependabot.yml`, `.github/workflows/codeql.yml`, `CLAUDE.md` (a partir de `templates/CLAUDE.template.md`), `APRENDIZADOS.md`

- [ ] **Step 1:** escrever o teste que prova o bloqueio de rede:

```python
import socket
import pytest
from pytest_socket import SocketBlockedError

def test_rede_bloqueada_nos_testes():
    with pytest.raises(SocketBlockedError):
        socket.socket(socket.AF_INET, socket.SOCK_STREAM)
```

- [ ] **Step 2:** rodar `pytest tests/test_sem_rede.py -v`. Esperado: FALHA (sem `--disable-socket` configurado, o socket abre).
- [ ] **Step 3:** em `pyproject.toml`, dependências `fastapi`, `pydantic`, `uvicorn`; de desenvolvimento `pytest`, `pytest-socket`, `httpx`, `ruff`; `addopts = "--disable-socket"` na configuração do pytest; Python `>=3.12`.
- [ ] **Step 4:** `.gitattributes` com `* text=auto eol=lf`; `.gitignore` com `.env`, `.venv/`, `__pycache__/`, `*.db`.
- [ ] **Step 5:** rodar `pytest -v` e `ruff check .`. Esperado: 1 teste passa, ruff sem erros.
- [ ] **Step 6:** enviar e conferir o workflow `ci` verde na aba Actions. Commit `chore: cria o esqueleto do projeto com CI e bloqueio de rede nos testes`.

### Task 3: rota `/saude` (Claude Code mostra, a pessoa acompanha)

**Files:**
- Create: `api/app.py`, `api/rotas/__init__.py`, `api/rotas/saude.py`
- Test: `tests/api/test_saude.py`

**Interfaces:**
- Produces: `criar_app() -> fastapi.FastAPI` em `api/app.py`; rota `GET /saude`.

- [ ] **Step 1:** teste:

```python
from fastapi.testclient import TestClient
from api.app import criar_app

def test_saude_responde_ok_e_so_o_status():
    resposta = TestClient(criar_app()).get("/saude")
    assert resposta.status_code == 200
    assert resposta.json() == {"status": "ok"}
```

- [ ] **Step 2:** rodar `pytest tests/api/test_saude.py -v`. Esperado: FALHA com erro de importação de `api.app`.
- [ ] **Step 3:** implementar `criar_app()` e a rota, com um comentário no topo de cada arquivo dizendo a responsabilidade dele.
- [ ] **Step 4:** rodar `pytest -v`. Esperado: 2 testes passam. Mutação: trocar `"ok"` por `"okk"`, ver o teste falhar, desfazer.
- [ ] **Step 5:** rodar `uvicorn api.app:criar_app --factory` e abrir `http://127.0.0.1:8000/saude` e `/docs` no navegador.
- [ ] **Step 6:** commit `feat: adiciona a rota de saúde`.

### Task 4: infraestrutura de ensino

**Files:**
- Create: `docs/tarefas/MODELO.md`, `.claude/skills/fechar-tarefa/SKILL.md`, `.claude/settings.json` (gancho `Stop`), `.vscode/settings.json`, `.vscode/extensions.json`
- Modify: `CLAUDE.md`

- [ ] **Step 1:** `docs/tarefas/MODELO.md` com as seções: O que você vai construir · Conceitos (do básico ao avançado, cada um com exemplo mínimo que **não** é a solução) · Passo a passo sem código · Como saber que ficou certo (comando e saída esperada) · Escada de dicas (3 níveis, fechados em `<details>`) · Perguntas de explicar de volta (2).
- [ ] **Step 2:** `CLAUDE.md`: regra "em tarefa (solo), não escreva a solução; ofereça a próxima dica da escada só quando a pessoa pedir" e regra "ao fim de cada tarefa, rode `/fechar-tarefa`".
- [ ] **Step 3:** skill `/fechar-tarefa`: roda testes e ruff, faz as 2 perguntas da ficha, grava em `APRENDIZADOS.md` a data, a tarefa, o erro cometido e as respostas da pessoa **sem editar**.
- [ ] **Step 4:** gancho `Stop` que lembra de rodar `/fechar-tarefa` se houver commit novo sem entrada correspondente em `APRENDIZADOS.md`.
- [ ] **Step 5:** `.vscode/extensions.json` recomendando as extensões de Python e Ruff; `.vscode/settings.json` com formatar ao salvar pelo Ruff e pytest como executor de testes.
- [ ] **Step 6:** verificação na máquina da pessoa: abrir o projeto no VS Code, rodar um teste pela interface; no Claude Code, rodar `/fechar-tarefa` uma vez de ensaio e conferir a entrada gerada. O gancho nunca foi executado: se falhar, registrar no `ERROS.md` do kit e corrigir antes de seguir.
- [ ] **Step 7:** commit `chore: adiciona fichas de tarefa, skill de fechamento e configuração do editor`.

### Task 5: Docker e README

**Files:**
- Create: `Dockerfile` (a partir de `templates/Dockerfile.python`), `.dockerignore`
- Modify: `README.md`

- [ ] **Step 1:** `Dockerfile` em múltiplos estágios, usuário sem root, comando `uvicorn api.app:criar_app --factory --host 0.0.0.0 --port 8000`.
- [ ] **Step 2:** rodar `docker build -t painel-dota .` e `docker run --rm -p 8000:8000 painel-dota`; abrir `/saude`. Esperado: `{"status":"ok"}`.
- [ ] **Step 3:** `README.md`: como rodar (local e Docker), comandos de teste, o que existe hoje, e uma lista "ainda não verificado".
- [ ] **Step 4:** commit `chore: adiciona a imagem Docker e atualiza o README`.

### Task 6 (solo): validar o ID da conta

**Files:**
- Create: `docs/tarefas/01-validar-id-conta.md` (ficha, escrita por Claude Code), `api/validacao.py` (escrito pela pessoa)
- Test: `tests/api/test_validacao.py` (escrito por Claude Code antes, como rede de segurança)

**Interfaces:**
- Produces: `validar_id_conta(texto: str) -> int` e a exceção `IdContaInvalido(ValueError)` com atributo `motivo: str`, em `api/validacao.py`. Função pura, sem FastAPI e sem rede. O plano 2 usa na rota de jogador.

- [ ] **Step 1:** Claude Code escreve a ficha a partir de `docs/tarefas/MODELO.md` (conceitos: função pura, tipos, `str` e `int`, exceção própria, valores de borda, por que validar na entrada).
- [ ] **Step 2:** Claude Code escreve os testes (todos os IDs são inventados):

```python
import pytest
from api.validacao import IdContaInvalido, validar_id_conta

@pytest.mark.parametrize("texto, esperado", [("123456789", 123456789), ("  42  ", 42), ("4294967295", 4294967295)])
def test_aceita_id_valido(texto, esperado):
    assert validar_id_conta(texto) == esperado

@pytest.mark.parametrize("texto", ["", "   ", "abc", "12a", "-5", "+5", "1.5", "0", "4294967296"])
def test_recusa_id_invalido(texto):
    with pytest.raises(IdContaInvalido):
        validar_id_conta(texto)

def test_steamid_de_17_digitos_explica_qual_numero_usar():
    with pytest.raises(IdContaInvalido) as erro:
        validar_id_conta("76561190000000000")
    assert erro.value.motivo == "steamid64"
```

- [ ] **Step 3:** rodar `pytest tests/api/test_validacao.py -v`. Esperado: FALHA com erro de importação.
- [ ] **Step 4 (pessoa):** escrever `api/validacao.py` até todos os testes passarem. Regras: só dígitos depois de remover espaços das pontas; valor entre 1 e 4294967295; 17 dígitos começando com `7656119` gera `motivo == "steamid64"`; os demais casos geram `motivo == "formato"` ou `"faixa"`.
- [ ] **Step 5:** rodar `pytest -v` e `ruff check .`. Esperado: tudo passa.
- [ ] **Step 6:** `/fechar-tarefa`. Commit feito pela pessoa: `feat: valida o ID da conta`.

---

**Depois deste plano:** o plano 2 (cliente da fonte, coletor e arquivos de dados por versão) é escrito com a decisão da tarefa 1 em mãos.
