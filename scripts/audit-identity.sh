#!/usr/bin/env bash
# Показывает, какими подписями (имя <почта>) подписаны коммиты в git-репозиториях под папкой.
# Только читает, ничего не меняет. Учитывает .mailmap (если подключён) — поэтому после
# setup-machine.* должна остаться одна строка на человека.
#
#   ./audit-identity.sh [папка=.] [фильтр-регэксп=.]
#   ./audit-identity.sh ~/work 'petrov|ivan'
set -euo pipefail
ROOT="${1:-.}"
FILTER="${2:-.}"

found=0
while IFS= read -r gitdir; do
  repo="$(dirname "$gitdir")"
  found=1
  echo "=== $repo"
  git -C "$repo" log --use-mailmap --format='%aN <%aE>' 2>/dev/null \
    | grep -Ei -- "$FILTER" | sort | uniq -c | sort -rn || true
  echo "    текущая подпись для новых коммитов: $(git -C "$repo" config user.name) <$(git -C "$repo" config user.email)>"
done < <(find "$ROOT" -maxdepth 3 -name .git -not -path '*/node_modules/*' 2>/dev/null)

[ "$found" = 1 ] || echo "Репозитории не найдены под: $ROOT"
