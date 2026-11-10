# Etapa 0, função 4: descobre QUAIS CAMPOS a OpenDota devolve para um jogador.
# O ID é digitado de forma oculta, não fica em arquivo e não é impresso.
# Imprime só: rota, status HTTP, tentativas e nomes de campos. Nunca valores.
param([string]$JsonDeTeste)

function Get-NomesDeCampos($dados) {
    # Lista os nomes de campos; objetos aninhados viram "pai.filho".
    if ($dados -is [array]) {
        if ($dados.Count -eq 0) { return @("(lista vazia)") }
        $dados = $dados[0]
    }
    $nomes = @()
    foreach ($p in $dados.psobject.Properties) {
        if ($p.Value -is [System.Management.Automation.PSCustomObject]) {
            foreach ($f in $p.Value.psobject.Properties) { $nomes += "$($p.Name).$($f.Name)" }
        } else {
            $nomes += $p.Name
        }
    }
    return $nomes | Sort-Object
}

if ($JsonDeTeste) {
    # Modo de ensaio, sem rede: só para conferir a listagem de campos.
    (Get-NomesDeCampos ($JsonDeTeste | ConvertFrom-Json)) -join ", "
    exit 0
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$seguro = Read-Host "Seu ID de amigo do Dota (não aparece na tela)" -AsSecureString
$id = [System.Net.NetworkCredential]::new("", $seguro).Password
if ($id -notmatch '^\d{1,10}$') { Write-Host "O ID precisa ter só dígitos (até 10)."; exit 1 }

$base = "https://api.opendota.com/api/players/$id"
$rotas = [ordered]@{
    "/players/{id}"                        = $base
    "/players/{id}/recentMatches"          = "$base/recentMatches"
    "/players/{id}/wl"                     = "$base/wl"
    "/players/{id}/matches?patch=60&limit=5" = "$base/matches?patch=60&limit=5"
}

foreach ($nome in $rotas.Keys) {
    $resp = $null
    $tentativas = 0
    while (-not $resp -and $tentativas -lt 4) {
        $tentativas++
        try { $resp = Invoke-WebRequest -UseBasicParsing -Uri $rotas[$nome] -TimeoutSec 30 }
        catch { Start-Sleep -Seconds 1 }
    }
    if (-not $resp) { Write-Host "$nome :: falhou $tentativas vezes"; continue }
    $dados = $resp.Content | ConvertFrom-Json
    $qtd = if ($dados -is [array]) { "lista com $($dados.Count) itens" } else { "objeto" }
    Write-Host ""
    Write-Host "$nome :: HTTP $($resp.StatusCode), tentativas=$tentativas, $qtd, saldo do dia=$($resp.Headers['X-Rate-Limit-Remaining-Day'])"
    Write-Host ("  campos: " + ((Get-NomesDeCampos $dados) -join ", "))
}
$id = $null
