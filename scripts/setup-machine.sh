#!/usr/bin/env bash
# Применяет рекомендованные глобальные настройки git (Linux / macOS / Git Bash).
#
#   ./setup-machine.sh --name "Ivan Petrov" --email "you@example.com" [--dry-run]
#
# Идемпотентен, ничего не удаляет. Существующий ~/.gitmailmap сохраняется в ~/.gitmailmap.bak-<время>.
set -euo pipefail

NAME=""; EMAIL=""; DRY=0
while [ $# -gt 0 ]; do
  case "$1" in
    --name)    NAME="${2:-}"; shift 2 ;;
    --email)   EMAIL="${2:-}"; shift 2 ;;
    --dry-run) DRY=1; shift ;;
    -h|--help) sed -n '2,6p' "$0"; exit 0 ;;
    *) echo "Неизвестный аргумент: $1" >&2; exit 2 ;;
  esac
done
[ -n "$NAME" ] && [ -n "$EMAIL" ] || { echo "Нужны --name и --email" >&2; exit 2; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMPLATE="$ROOT/templates/.mailmap"
TARGET="$HOME/.gitmailmap"

set_global() {
  local key="$1" value="$2" old
  old="$(git config --global --get "$key" 2>/dev/null || true)"
  if [ "$old" = "$value" ]; then printf '  ok      %s = %s\n' "$key" "$value"; return; fi
  local was="не было"; [ -n "$old" ] && was="было '$old'"
  if [ "$DRY" = 1 ]; then printf '  [dry]   %s = %s   (%s)\n' "$key" "$value" "$was"; return; fi
  git config --global "$key" "$value"
  printf '  set     %s = %s   (%s)\n' "$key" "$value" "$was"
}

echo "== Личность"
set_global user.name  "$NAME"
set_global user.email "$EMAIL"

echo "== Поведение"
set_global pull.rebase          true
set_global rebase.autoStash     true
set_global rebase.autoSquash    true
set_global fetch.prune          true
set_global push.autoSetupRemote true
set_global core.autocrlf        input
set_global merge.conflictStyle  zdiff3

echo "== .mailmap"
[ -f "$TEMPLATE" ] || { echo "Нет шаблона: $TEMPLATE" >&2; exit 1; }
# Разделитель | в sed: имя/почта не должны содержать | и &
NEW="$(sed -e "s|__NAME__|${NAME//&/\\&}|g" -e "s|__EMAIL__|${EMAIL//&/\\&}|g" "$TEMPLATE")"
if [ -f "$TARGET" ] && [ "$(cat "$TARGET")" = "$NEW" ]; then
  echo "  ok      $TARGET уже актуален"
elif [ "$DRY" = 1 ]; then
  echo "  [dry]   записать $TARGET"
else
  if [ -f "$TARGET" ]; then
    BAK="$TARGET.bak-$(date +%Y%m%d-%H%M%S)"; cp "$TARGET" "$BAK"; echo "  backup  $BAK"
  fi
  printf '%s\n' "$NEW" > "$TARGET"
  echo "  write   $TARGET"
fi
set_global mailmap.file "$TARGET"

echo
echo "Готово. Проверьте:  git config --global --list --show-origin"
echo "Дальше: .gitattributes в репозитории (03-line-endings-gitattributes.md) и SSH (04-ssh-gitverse.md)."
