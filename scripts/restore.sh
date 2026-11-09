#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

if [[ $# -ne 1 ]]; then
    echo "使い方: $0 <バックアップファイル.sql>" >&2
    echo "例:     $0 backups/backup_20260101_120000.sql" >&2
    exit 1
fi

BACKUP_FILE="$1"

if [[ ! -f "$BACKUP_FILE" ]]; then
    echo "エラー: ファイルが見つかりません: $BACKUP_FILE" >&2
    exit 1
fi

# .env から認証情報を読み込む
if [[ ! -f "$PROJECT_DIR/.env" ]]; then
    echo "エラー: .env ファイルが見つかりません" >&2
    exit 1
fi

set -a
# shellcheck source=/dev/null
source "$PROJECT_DIR/.env"
set +a

echo "リストアを開始します: $BACKUP_FILE"

docker compose -f "$PROJECT_DIR/docker-compose.yml" exec -T db \
    mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" \
    < "$BACKUP_FILE"

echo "リストアが完了しました"
