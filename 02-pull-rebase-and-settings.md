# 02. pull.rebase и глобальные настройки

## Проблема

В некоторых репозиториях встречаются коммиты вида `Merge branch 'master' of <хост>:<организация>/<репозиторий>` и `Master merge`.
Это результат `git pull` по умолчанию: он делает *fetch + merge*, и если у вас есть локальные коммиты,
а на сервере появились чужие, git создаёт бесполезный merge-коммит.

## Решение

```bash
git config --global pull.rebase true
```

Теперь `git pull` = `fetch` + `rebase`: ваши локальные коммиты аккуратно «пересаживаются» поверх
чужих, история остаётся линейной. Аналогия: как `git pull --rebase` в каждом проекте сразу.

**Когда rebase нельзя:** не ребейзьте коммиты, которые уже запушены и на которые опираются другие
(общая ветка `master`, чужая ветка). Локальные, ещё не запушенные коммиты — можно.

## Рекомендуемый набор настроек

Всё это делает `scripts/setup-machine.*`:

| Настройка | Значение | Зачем |
|---|---|---|
| `pull.rebase` | `true` | нет merge-коммитов при `git pull` |
| `rebase.autoStash` | `true` | rebase сам спрячет и вернёт незакоммиченные правки |
| `rebase.autoSquash` | `true` | коммиты `fixup!` автоматически встают на место при `rebase -i` |
| `fetch.prune` | `true` | удалённые на сервере ветки исчезают из `origin/*` |
| `push.autoSetupRemote` | `true` | первый `git push` новой ветки сам делает `-u`, без ошибки «no upstream» |
| `core.autocrlf` | `input` | CRLF → LF при коммите; страховка там, где нет `.gitattributes` (см. `03-…`) |
| `merge.conflictStyle` | `zdiff3` | в конфликтах видна и общая база — разбирать проще |
| `init.defaultBranch` | **не меняем** | в ваших репозиториях исторически и `master`, и `main` |

## Как проверить

```bash
git config --global --list --show-origin | grep -E 'pull|rebase|fetch|push|autocrlf|conflict'
```

## Если git pull всё-таки сообщил о конфликте

```bash
git status                 # увидите «rebase in progress» и файлы с конфликтом
# правите файлы, затем:
git add <файл>
git rebase --continue
# передумали:
git rebase --abort
```
