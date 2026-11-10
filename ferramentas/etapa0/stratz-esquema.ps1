# Etapa 0 (STRATZ), rodada 1: descobre a estrutura da API e a lista de versões, sem expor o token.
# Pré-requisito: $env:STRATZ_TOKEN definido NESTE terminal com Read-Host -AsSecureString.
# Grava em arquivo só nomes de tipos, campos e argumentos, mais a lista de versões do jogo. Nunca o token.
# Saída: ferramentas/etapa0/saida/stratz-esquema.txt (pasta ignorada pelo git), ao lado deste script.

$pastaSaida = Join-Path $PSScriptRoot "saida"
$saida = Join-Path $pastaSaida "stratz-esquema.txt"
$url = "https://api.stratz.com/graphql"
$limiteDeTentativas = 150

if (-not $env:STRATZ_TOKEN) {
    Write-Host "Falta o token: defina `$env:STRATZ_TOKEN neste terminal antes de rodar."
    exit 1
}
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$script:tentativas = 0
$linhas = New-Object System.Collections.Generic.List[string]
$tiposLidos = @{}

function Invoke-Stratz([string]$consulta) {
    # Envia uma consulta GraphQL; repete até 4 vezes se a conexão cair (E-026).
    $corpo = [Text.Encoding]::UTF8.GetBytes((@{ query = $consulta } | ConvertTo-Json -Compress))
    $cabecalhos = @{ Authorization = "Bearer $env:STRATZ_TOKEN" }
    for ($t = 1; $t -le 4; $t++) {
        $script:tentativas++
        try {
            $resp = Invoke-WebRequest -UseBasicParsing -Method Post -Uri $url -Headers $cabecalhos `
                -UserAgent "STRATZ_API" -ContentType "application/json" -Body $corpo -TimeoutSec 60
            $json = $resp.Content | ConvertFrom-Json
            if ($json.errors) {
                $mensagens = ($json.errors | ForEach-Object { $_.message }) -join " | "
                Write-Host "  aviso da API: $mensagens"
            }
            return $json.data
        } catch {
            $codigo = $null
            if ($_.Exception.Response) { $codigo = [int]$_.Exception.Response.StatusCode }
            if ($codigo -in 401, 403) { Write-Host "  HTTP $($codigo): token recusado. Parei."; exit 1 }
            if ($codigo -eq 429) { Write-Host "  HTTP 429: limite atingido. Parei."; exit 1 }
            Start-Sleep -Seconds 2
        }
    }
    Write-Host "  a consulta falhou 4 vezes"
    return $null
}

$fragmentoTipo = "name kind ofType { name kind ofType { name kind ofType { name kind } } }"

function Get-TipoBase($tipo) {
    # Tira as camadas de "lista" e "obrigatório" e devolve o tipo com nome.
    while ($tipo.ofType) { $tipo = $tipo.ofType }
    return $tipo
}

function Format-Tipo($tipo) {
    # Escreve o tipo como no GraphQL: [Tipo!] etc.
    switch ($tipo.kind) {
        "NON_NULL" { return (Format-Tipo $tipo.ofType) + "!" }
        "LIST"     { return "[" + (Format-Tipo $tipo.ofType) + "]" }
        default    { return $tipo.name }
    }
}

function Read-Tipo([string]$nome, [int]$profundidade, [bool]$lerEnums) {
    # Descreve um tipo; desce nos tipos dos campos enquanto houver profundidade.
    if ($tiposLidos.ContainsKey($nome) -or $script:tentativas -ge $limiteDeTentativas) { return }
    # Apelido "tipo:" porque o ConvertFrom-Json do PowerShell 5.1 quebra com a chave "__type" (E-029).
    $d = Invoke-Stratz "{ tipo: __type(name: `"$nome`") { name kind enumValues { name } fields { name args { name type { $fragmentoTipo } } type { $fragmentoTipo } } } }"
    if (-not $d -or -not $d.tipo) { $linhas.Add("TIPO $nome :: sem resposta"); return }
    $tipo = $d.tipo
    $tiposLidos[$nome] = $tipo
    if ($tipo.kind -eq "ENUM") {
        $linhas.Add("ENUM $nome = " + (($tipo.enumValues | ForEach-Object { $_.name }) -join ", "))
        return
    }
    $linhas.Add("TIPO $nome")
    $objetos = @()
    $enums = @()
    foreach ($campo in $tipo.fields) {
        $argumentos = ($campo.args | ForEach-Object { "$($_.name): $(Format-Tipo $_.type)" }) -join ", "
        $linhas.Add("  $($campo.name)($argumentos) -> $(Format-Tipo $campo.type)")
        $base = Get-TipoBase $campo.type
        if ($base.kind -eq "OBJECT") { $objetos += $base.name }
        if ($base.kind -eq "ENUM") { $enums += $base.name }
        foreach ($a in $campo.args) {
            $baseArg = Get-TipoBase $a.type
            if ($baseArg.kind -eq "ENUM") { $enums += $baseArg.name }
        }
    }
    if ($lerEnums) { foreach ($n in ($enums | Select-Object -Unique)) { Read-Tipo $n 0 $false } }
    if ($profundidade -gt 0) { foreach ($n in ($objetos | Select-Object -Unique)) { Read-Tipo $n ($profundidade - 1) $true } }
}

# 1. Consultas de entrada (a "raiz" da API), sem descer.
$raiz = Invoke-Stratz "{ __schema { queryType { name fields { name type { $fragmentoTipo } } } } }"
if (-not $raiz) { Write-Host "Sem resposta da raiz. Introspecção pode estar desligada."; exit 1 }
$camposRaiz = $raiz.__schema.queryType.fields
Read-Tipo $raiz.__schema.queryType.name 0 $false

# 2. Desce nas partes que importam para as funções 1 a 4.
$alvos = [ordered]@{ heroStats = 2; constants = 1; player = 0 }
foreach ($nome in $alvos.Keys) {
    $campo = $camposRaiz | Where-Object { $_.name -eq $nome }
    if ($campo) { $linhas.Add(""); Read-Tipo (Get-TipoBase $campo.type).name $alvos[$nome] $true }
    else { $linhas.Add(""); $linhas.Add("RAIZ sem o campo '$nome'") }
}

# 3. Dado de verdade, só público: lista de versões do jogo, se existir.
$campoConstants = $camposRaiz | Where-Object { $_.name -eq "constants" }
if ($campoConstants) {
    $tipoConstants = $tiposLidos[(Get-TipoBase $campoConstants.type).name]
    $campoVersoes = $tipoConstants.fields | Where-Object { $_.name -eq "gameVersions" }
    if ($campoVersoes) {
        $tipoVersao = $tiposLidos[(Get-TipoBase $campoVersoes.type).name]
        $escalares = ($tipoVersao.fields | Where-Object { (Get-TipoBase $_.type).kind -eq "SCALAR" -and $_.args.Count -eq 0 } | ForEach-Object { $_.name }) -join " "
        $v = Invoke-Stratz "{ constants { gameVersions { $escalares } } }"
        $lista = @($v.constants.gameVersions)
        $linhas.Add("")
        $linhas.Add("DADOS constants.gameVersions: $($lista.Count) itens (até 10 mostra todos; senão, 5 primeiros e 5 últimos):")
        $mostrar = if ($lista.Count -le 10) { $lista } else { @($lista | Select-Object -First 5) + @($lista | Select-Object -Last 5) }
        $mostrar | ForEach-Object { $linhas.Add("  " + ($_ | ConvertTo-Json -Compress)) }
    }
}

New-Item -ItemType Directory -Force -Path $pastaSaida | Out-Null
$linhas | Set-Content -Path $saida -Encoding UTF8
Write-Host "Pronto: $($linhas.Count) linhas gravadas em $saida (tentativas: $script:tentativas)."
