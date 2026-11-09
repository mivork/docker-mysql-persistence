#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_DIR/backups"

# .env から認証情報を読み込む
if [[ ! -f "$PROJECT_DIR/.env" ]]; then
    echo "エラー: .env ファイルが見つかりません" >&2
    exit 1
fi

set -a
# shellcheck source=/dev/null
source "$PROJECT_DIR/.env"
set +a

mkdir -p "$BACKUP_DIR"

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP_FILE="$BACKUP_DIR/backup_${TIMESTAMP}.sql"

echo "バックアップを開始します: $BACKUP_FILE"

docker compose -f "$PROJECT_DIR/docker-compose.yml" exec -T db \
    mysqldump -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" \
    > "$BACKUP_FILE"

echo "バックアップが完了しました: $BACKUP_FILE"

# 最新 7 件だけ残して古いバックアップを削除
cd "$BACKUP_DIR"
# shellcheck disable=SC2012
ls -1t backup_*.sql | tail -n +8 | while IFS= read -r old_file; do
    echo "古いバックアップを削除: $old_file"
    rm -f "$old_file"
done

echo "完了"
