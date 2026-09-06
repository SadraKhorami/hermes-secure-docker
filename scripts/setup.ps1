$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

docker info | Out-Null

if (-not (Test-Path .env)) {
  $password = -join ((48..57) + (97..102) | Get-Random -Count 36 | ForEach-Object {[char]$_})
  $secret = -join ((48..57) + (97..102) | Get-Random -Count 64 | ForEach-Object {[char]$_})
  (Get-Content .env.example) `
    -replace '^DASHBOARD_PASSWORD=.*$', "DASHBOARD_PASSWORD=$password" `
    -replace '^DASHBOARD_SESSION_SECRET=.*$', "DASHBOARD_SESSION_SECRET=$secret" |
    Set-Content .env
}

docker compose pull
docker compose run --rm hermes setup
docker compose up -d
