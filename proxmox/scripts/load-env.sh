#!/usr/bin/env bash

SERVICE=$1
BASE_DIR="$(cd "$(dirname "$0")/../.." && pwd)"

ENV_FILE="${ENV_FILE:-$BASE_DIR/env/.env.$SERVICE}"

echo "🔧 Loading env: $ENV_FILE"

if [ ! -f "$ENV_FILE" ]; then
  echo "❌ Not found"
  exit 1
fi

set -a
source "$ENV_FILE"
set +a