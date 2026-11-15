# 03. Переводы строк: .gitattributes

## Что случилось в одном из репозиториев

Коммит «Fix java sdk»: 73 файла, `+9980/−9845`. Если сравнить с игнорированием
конца строки (`git show --ignore-space-at-eol`), настоящих изменений **6 файлов, +178/−43**.
Остальное — файлы, у которых целиком поменялся CRLF ↔ LF. Такой коммит нельзя нормально ревьюить,
`git blame` показывает его автором каждой строки, откат ломает чужое.

Причина: `.gitattributes` перечислял только расширения
`*.py *.sh *.json *.yaml *.yml *.md`. Для `.java` и всего остального правил нет и нет `* text=auto`,
а `core.autocrlf` на машине не задан — Windows и macOS-коллеги пишут разные окончания строк.

## Решение: два уровня защиты

1. **В репозитории — `.gitattributes`** (главное, едет вместе с кодом и действует на всех машинах).
   Шаблон: [templates/.gitattributes](templates/.gitattributes). Ключевая строка: `* text=auto eol=lf`.
2. **На машине — `core.autocrlf=input`** (страховка для репозиториев без `.gitattributes`;
   ставит `setup-machine.*`).

Аналогия из Node: это `.editorconfig` + `endOfLine: "lf"` в prettier, но на уровне самого git.

## Как внедрить в репозиторий (один раз на репозиторий)

Делайте **отдельным коммитом**, без других правок, на отдельной ветке, а затем сливайте через MR.

```bash
cd <репозиторий>
git switch -c chore/normalize-eol
cp ../git-cheatsheets/templates/.gitattributes .gitattributes   # или смержите с имеющимся
git add .gitattributes
git commit -m "chore: add .gitattributes (eol=lf)"

git add --renormalize .          # пересчитать окончания строк у всех файлов
git status --short | head -30    # убедитесь, что поменялось ожидаемое
git commit -m "chore: normalize line endings to LF"

git push -u origin chore/normalize-eol
```

Правила:

- Не смешивайте нормализацию с правками кода — иначе вернётся та же проблема.
- Предупредите коллег: после слияния им нужно `git pull`, а у кого есть незакоммиченные правки —
  сначала закоммитить/спрятать их.
- Чтобы `git blame` не считал вас автором всех строк, добавьте хеш нормализующего коммита в
  `.git-blame-ignore-revs` и включите `git config blame.ignoreRevsFile .git-blame-ignore-revs`.

## Бинарные файлы

В шаблоне перечислены типичные бинарные расширения (`png`, `pdf`, `zip`, `tgz`, `jar`, `whl`…)
с атрибутом `binary` — git не пытается менять в них переводы строк и не показывает текстовый diff.
Если добавляете новый тип бинарников — дополните список.

## Как проверить, что файл нормализован

```bash
git ls-files --eol | grep -v 'i/lf' | head      # в индексе всё должно быть lf (или -text для бинарных)
git diff --stat --ignore-space-at-eol           # сколько правок «настоящих»
```
