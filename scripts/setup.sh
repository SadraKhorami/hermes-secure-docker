#!/usr/bin/env bash
set -euo pipefail

root_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${root_dir}"

case "$(uname -s)" in
  Darwin)
    if ! docker info >/dev/null 2>&1 && command -v colima >/dev/null 2>&1; then
      colima start
    fi
    ;;
  Linux) ;;
  *) echo "Use scripts/setup.ps1 on Windows."; exit 1 ;;
esac

docker info >/dev/null || { echo "Start Docker, then run this script again."; exit 1; }

if [[ ! -f .env ]]; then
  password="$(openssl rand -hex 18)"
  secret="$(openssl rand -hex 32)"
  sed -e "s/^DASHBOARD_PASSWORD=.*/DASHBOARD_PASSWORD=${password}/" \
      -e "s/^DASHBOARD_SESSION_SECRET=.*/DASHBOARD_SESSION_SECRET=${secret}/" \
      .env.example > .env
  chmod 600 .env
fi

docker-compose pull
docker-compose run --rm hermes setup
docker-compose up -d
