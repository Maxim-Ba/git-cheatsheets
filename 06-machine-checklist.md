# 06. Чек-лист настройки машины

Скопируйте блок на каждую машину и отмечайте. Проходить его нужно столько раз, сколько у вас машин.

Машина: ______________________   Дата: ____________   ОС: ____________

## A. Личность

- [ ] Выбраны единые имя и почта (см. `01-identity-and-mailmap.md`): `______________ <______________>`
- [ ] Запущен `scripts/setup-machine.ps1` (или `.sh`) с этими значениями
- [ ] `git config --global user.name` / `user.email` показывают их
- [ ] `git config --global mailmap.file` указывает на `~/.gitmailmap`; файл создан из шаблона
- [ ] (если две почты) `includeIf` для рабочей папки, проверено `git config user.email` внутри репозитория

## B. Поведение

- [ ] `git config --global pull.rebase` → `true`
- [ ] `git config --global core.autocrlf` → `input` (Windows, macOS, Linux — везде одинаково)
- [ ] `git config --global fetch.prune` → `true`; `push.autoSetupRemote` → `true`
- [ ] `git config --global --list --show-origin` — нет конфликтующих старых значений

## C. SSH (`04-ssh-gitverse.md`)

- [ ] На машине есть собственный ключ ed25519 (метка с именем машины)
- [ ] Открытый ключ добавлен в аккаунт на хостинге, отпечаток сверен
- [ ] `~/.ssh/config` содержит блок для хоста хостинга
- [ ] `ssh -T git@<хост>` — без `Permission denied`
- [ ] `git ls-remote origin` работает в каждом репозитории

## D. Репозитории (по одному)

Репозиторий: ______________________

- [ ] `.gitattributes` с `* text=auto eol=lf` лежит в корне (шаблон `templates/.gitattributes`)
- [ ] Нормализация сделана отдельным коммитом (`git add --renormalize .`), слита через MR/PR
- [ ] `git ls-files --eol | grep -v 'i/lf'` — пусто (кроме бинарных)
- [ ] Нет незакоммиченного (`git status`), нет забытых stash (`git stash list`)
- [ ] Каждая ветка с работой имеет upstream (`git branch -vv`)
- [ ] `scripts/audit-identity.sh .` — все новые коммиты подписаны одним именем
- [ ] У репозитория есть remote и он запушен (локальный репозиторий без remote существует в одной копии)
